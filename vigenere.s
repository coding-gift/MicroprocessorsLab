#include <xc.inc>
extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray, key_length
global vig_modify_table, counter_key
    
psect udata_acs
 counter_key: ds 1	; key counter

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

    goto    vig_modify_loop

vig_modify_loop:
    movf    counter_ec, W, A
    bz      vig_modify_done    ; Exit when all characters processed

    movlw   0x60              ; 'a' shift = 1
    subwf   POSTINC0, W, A    ; Convert plaintext letter to offset

    addwf   POSTINC1, W, A    ; Add corresponding key character, increment the key array position
    
    incf    counter_key, A	; increment the key counter
    
    cpfslt  'z', B
    btfss   STATUS, 2, A
    bra     vig_wrap_done
    sublw   0x1A              ; Wrap around within alphabet

vig_wrap_done:
    movwf   POSTINC2, A       ; Store ciphertext character

    movf    counter_key, W, A
    subwf   key_length, W, A    ; Compare counter_k with KeyLength
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
