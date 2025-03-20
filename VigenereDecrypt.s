#include <xc.inc>
extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray
global vig_decrypt

psect   modify_code, class=CODE

vig_decrypt:
    ; Initialize FSR0 to point to CiphertextArray
    lfsr    0, CiphertextArray 
    ; Initialize FSR1 to point to KeyArray
    lfsr    1, KeyArray
    ; Initialize FSR2 to point to PlaintextArray
    lfsr    2, PlaintextArray

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    goto    vig_modify_loop      ; Start modification

vig_modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      vig_modify_done      ; If zero, we are done

    movf    POSTINC1, W, A       ; Get the current key character
    subwf   POSTINC0, W, A       ; Subtract the corresponding ciphertext character
    addlw   0x60                 ; Make the 'a' shift = 1 (adjust to 0-based index)

    cpfsgt  'a', B               ; Compare the result with 'a'
    
    btfss   STATUS, 2, A         ; If result is less than 'a', it's out of range
    bra     vig_wrap_done        ; If no wrap, skip to write

    addlw   0x1A                 ; Add 0x1A to wrap it back within the alphabet
    
vig_wrap_done:    
    movwf   POSTINC2, A         ; Store the decrypted character in PlaintextArray
    decfsz  counter_ec, A       ; Decrement counter and check if done
    bra     vig_modify_loop      ; Repeat if there are more characters

vig_modify_done:
    return
