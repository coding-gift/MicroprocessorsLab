#include <xc.inc>

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
    
    movf    POSTINC0, W	    ; Read the plaintext character
    addwf   POSTINC1, W    ; Add the key to PlainText
    ;; alphabet warpping code need to implemented
    movwf   POSTINC2, A             ; Write encrypted character to CiphertextArray
    
    decfsz  counter_ec, A        ; Decrement counter and check if done
    
    bra     modify_loop          ; Loop again if not finished

modify_done:
    return