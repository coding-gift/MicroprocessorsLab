#include <xc.inc>
extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray, DecryptedArray, KeyLength
global vig_decrypt

psect udata_acs
    counter_key: ds 1	; key counter
    a_val:  ds 1
    unwrapped_char:	ds 1

psect   modify_code, class=CODE
vig_decrypt:
    ; Initialize FSR0 to point to CiphertextArray
    lfsr    0, CiphertextArray 
    ; Initialize FSR1 to point to KeyArray
    lfsr    1, KeyArray
    ; Initialize FSR2 to point to PlaintextArray
    lfsr    2, DecryptedArray

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    clrf    WREG, A
    movwf   counter_key, A       ; Reset key index counter
    
    movlw '`'	; one more than z to fix overflow issue
    movwf  a_val, A
    
    goto    vig_modify_loop      ; Start modification

vig_modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      vig_modify_done      ; If zero, we are done

    movf    POSTINC1, W, A       ; Get the current key character
    subwf   POSTINC0, W, A       ; Subtract the corresponding ciphertext character
    addlw   0x60                 ; Make the 'a' shift = 1 (adjust to 0-based index)

    cpfslt      a_val, A
    bra		add_a
    bra		vig_wrap_done   

add_a:
    movwf   unwrapped_char, A
    movlw   0x1A
    addwf   unwrapped_char, W, A
    
vig_wrap_done:
    movwf   POSTINC2, A       ; Store ciphertext character
    incf    counter_key, A	; increment the key counter
    movf    counter_key, W, A
    sublw   KeyLength    ; Compare counter_k with KeyLength
    btfsc   STATUS, 2, A         ; If counter_k == KeyLength, reset
    bz	    reset_counter
    goto    vig_continue
    
reset_counter:    
    lfsr    1, KeyArray       ; Reset FSR1 to start of KeyArray
    clrf    counter_key, A       ; Reset key counter
    goto    vig_continue

vig_continue:
    decfsz  counter_ec, A
    bra     vig_modify_loop    ; Repeat loop

vig_modify_done:
    return


