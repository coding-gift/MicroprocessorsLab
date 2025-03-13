#include <xc.inc>
; Feistel Cipher
extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray
global feistel_encrypt

psect udata_acs
    temp_maths: ds 1
    left_half: ds 1
    right_half: ds 1
    round_key: ds 1
    rounds: ds 1

psect modify_code, class=CODE

feistel_encrypt:
    lfsr 0, PlaintextArray  ; Load PlaintextArray into FSR0
    lfsr 1, KeyArray        ; Load KeyArray into FSR1
    lfsr 2, CiphertextArray ; Load CiphertextArray into FSR2

    movlw  TableLength
    movwf  counter_ec, A    ; Counter for characters

    movlw  4               ; Number of rounds
    movwf  rounds, A

encrypt_loop:
    movf   counter_ec, W, A
    bz     encrypt_done

    movf   POSTINC0, W      ; Read plaintext character
    movwf  left_half        ; Store in left_half

    movf   POSTINC1, W      ; Read key character
    movwf  round_key        ; Store as round key

    movf   left_half, W
    movwf  right_half       ; Initialize right_half = left_half

    ; Start Feistel rounds
    movf   rounds, W
    movwf  temp_maths

rounds_loop:
    movf   round_key, W     ; Load round key
    xorwf  right_half, W    ; F-function: simple XOR
    movwf  left_half        ; L(i+1) = R(i)
    movwf  right_half       ; Swap halves

    decfsz temp_maths, A
    bra    rounds_loop

    movf   right_half, W
    movwf  POSTINC2, A      ; Store encrypted char in CiphertextArray

    decfsz counter_ec, A
    bra    encrypt_loop

encrypt_done:
    return



