#include <xc.inc>

extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D

psect udata_acs
counter_pt: ds 1
counter_ec: ds 1
key_index: ds 1

psect udata_bank4
CiphertextArray: ds 0x80

psect data
KeyTable:
    db 'K','E','Y'
KeyLength EQU 3
align 2

psect code
PlaintextArray:
    db 'P','l','a','i','n','t','e','x','t'
TableLength EQU 9

psect code, abs
rst: org 0x0
    goto setup

setup:
    bcf CFGS
    bsf EEPGD
    call LCD_Setup
    movlw 0x00
    movwf TRISH, A
    movlw 0x00
    movwf PORTH, A
    goto start

start:
    call print_plaintext
    movlw 0xC0
    call LCD_Send_Byte_I

    movlw 0xFF
    call LCD_delay_ms

    call vigenere_encrypt
    call print_ciphertext

    movlw 0xFF
    call LCD_delay_ms
    movlw 0xFF
    call LCD_delay_ms
    movlw 0xFF
    call LCD_delay_ms
    movlw 0xFF
    call LCD_delay_ms

    goto ending

vigenere_encrypt:
    lfsr 0, CiphertextArray
    lfsr 2, KeyTable

    movlw TableLength
    movwf counter_ec, A

    clrf key_index, A

    goto encrypt_loop

encrypt_loop:
    movf counter_ec, W, A
    bz encrypt_done

    movlw HIGH(PlaintextArray)
    movwf TBLPTRH
    movlw LOW(PlaintextArray)
    addwf counter_ec, W
    movwf TBLPTRL
    tblrd*+

    movf TABLAT, W
    sublw 'A'
    movwf INDF1, A

    movf INDF2, W, A
    sublw 'A'
    addwf INDF1, W, A
    addlw 'A'
    movwf POSTINC0, A

    incf key_index, A
    movf key_index, W, A
    sublw KeyLength
    btfsc STATUS, 2
    clrf key_index, A

    lfsr 2, KeyTable
    addwf key_index, W, A
    movwf FSR2L, A

    decfsz counter_ec, A
    bra encrypt_loop

encrypt_done:
    return

print_ciphertext:
    lfsr 0, CiphertextArray

    movlw TableLength
    movwf counter_pt, A
    goto print_loop

print_plaintext:
    movlw TableLength
    movwf counter_pt, A
    goto print_plaintext_loop

print_plaintext_loop:
    movf counter_pt, W, A
    bz print_plaintext_done

    movlw HIGH(PlaintextArray)
    movwf TBLPTRH
    movlw LOW(PlaintextArray)
    addwf counter_pt, W
    movwf TBLPTRL
    tblrd*+

    movf TABLAT, W
    call LCD_Send_Byte_D

    decfsz counter_pt, A
    bra print_plaintext_loop

print_plaintext_done:
    return

print_loop:
    movf counter_pt, W, A
    bz print_done

    movf POSTINC0, W, A
    call LCD_Send_Byte_D

    decfsz counter_pt, A
    bra print_loop
    goto print_done

print_done:
    return

ending:
    nop

    end rst