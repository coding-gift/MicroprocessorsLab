#include <xc.inc>
; Vigenere cipher
extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray
global modify_table
    
psect	modify_code,class=CODE
    
modify_table:
    ; Initialize FSR1 to point to PlaintextArray
    lfsr    0, PlaintextArray
    
    
    ; Initialize FSR2 to point to KeyArray
    lfsr    1, KeyArray

    ; Initialize FSR0 to point to CiphertextArray
    lfsr    2, CiphertextArray

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    goto    modify_loop          ; Start modification

modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      modify_done          ; If zero, we are done

    movlw   0x60 ; making 'a' shift = 1
    subwf   POSTINC0, W

    addwf   POSTINC1, W    ; Add the key

    cpfslt  'z'                 ; Compare WREG with 'z'
    
    ;btfss   STATUS, 2, A            ; If greater, it's out of range
    bra     wrap_done            ; If no wrap, skip
    
    ; if greater then subtract 26 = 0x1A
    ; Subtract 0x1A to wrap around
    sublw   0x1A                 ; Subtract 'z' - 'a' (26)
    
wrap_done:    
    movwf   POSTINC2, A         ; Write encrypted character to CiphertextArray
    decfsz  counter_ec, A        ; Decrement counter and check if done
    bra     modify_loop          ; Loop again if not finished

modify_done:
    return