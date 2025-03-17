#include <xc.inc>

extrn CiphertextArray, PlaintextArray, KeyArray
extrn TableLength, counter_ec
global feistel_encrypt

psect	udata_acs   ; reserve data space in access ram
temp_left:	ds 1    ; counter for printing the initial data
temp_right:	ds 1	; encoding counter
;counter_k:	ds 1	; counter for copying the key
    
psect feistel_code, class=CODE

feistel_encrypt:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)
    
    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    bra     feistel_loop         ; Start encryption rounds

feistel_loop:
    movf    counter_ec, W, A     ; Check if rounds are finished
    bz      feistel_done         ; If zero, we are done

    movf    POSTINC0, W, A       ; Load Left Half (L)
    movwf   temp_left, A         ; Store in temp register (L)
    
    movf    POSTINC0, W, A       ; Load Right Half (R)
    movwf   temp_right, A        ; Store in temp register (R)

    movf    POSTINC1, W, A       ; Load Key
    xorwf   temp_right, W, A     ; F(R, Key) = R ? Key
    xorwf   temp_left, W, A      ; New Right = L ? F(R, Key)
    
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    movf    temp_right, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A

    decfsz  counter_ec, A        ; Decrement round counter
    bra     feistel_loop         ; Repeat for next round

feistel_done:
    return