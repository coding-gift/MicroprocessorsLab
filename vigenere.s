#include <xc.inc>
extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray, KeyLength
global vig_modify_table, counter_key
    
psect udata_acs
 counter_key: ds 1	; key counter
    z_val:  ds 1
 unwrapped_char:	ds 1

psect	modify_code, class=CODE

vig_modify_table:
    lfsr    0, PlaintextArray  ; Set FSR0 to start of plaintext
    lfsr    1, KeyArray        ; Set FSR1 to start of key
    lfsr    2, CiphertextArray ; Set FSR2 to start of ciphertext
    
    movlw   0x00
    movwf   counter_key, A

    movlw   TableLength
    movwf   counter_ec, A      ; Set counter for plaintext length

    clrf    WREG, A
    movwf   counter_key, A       ; Reset key index counter
    
    movlw '{'	; one more than z to fix overflow issue
    movwf  z_val, A

    goto    vig_modify_loop

vig_modify_loop:
    movf    counter_ec, W, A
    bz      vig_modify_done    ; Exit when all characters processed

    movlw   0x60              ; 'a' shift = 1
    subwf   POSTINC0, W, A    ; Convert plaintext letter to offset
    addwf   POSTINC1, W, A    ; Add corresponding key character, increment the key array position
    
    cpfsgt      z_val, A
    bra		subtract_z
    bra		vig_wrap_done   

subtract_z:
    movwf   unwrapped_char, A
    movlw   0x1A
    subwf   unwrapped_char, W, A
    
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
