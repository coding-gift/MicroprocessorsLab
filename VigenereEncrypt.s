#include <xc.inc>
extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray
global vig_encrypt
    
psect	modify_code,class=CODE
    
vig_encrypt:
    ; Initialize FSR1 to point to PlaintextArray
    lfsr    0, PlaintextArray
    ; Initialize FSR2 to point to KeyArray
    lfsr    1, KeyArray
    ; Initialize FSR0 to point to CiphertextArray
    lfsr    2, CiphertextArray

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    goto    vig_modify_loop          ; Start modification

vig_modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      vig_modify_done          ; If zero, we are done

    movlw   0x60 ; making 'a' shift = 1
    subwf   POSTINC0, W, A

    addwf   POSTINC1, W, A    ; Add the key
    cpfslt  'z', B               ; Compare WREG with 'z'
    
    btfss   STATUS, 2, A            ; If greater, it's out of range
    bra     vig_wrap_done            ; If no wrap, skip
    sublw   0x1A                 ; Subtract 'z' o make it within alphabet
    
vig_wrap_done:    
    movwf   POSTINC2, A         ; Write encrypted character to CiphertextArray
    decfsz  counter_ec, A        ; Decrement counter and check if done
    bra     vig_modify_loop          ; Loop again if not finished

vig_modify_done:
    return