#include <xc.inc>

global CiphertextArray, PlaintextArray, TableLength, counter_pt, counter_ec, KeyArray

extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn print_plaintext, print_ciphertext   
extrn feistel_encrypt

psect udata_acs   ; reserve data space in access RAM
counter_pt: ds 1    ; counter for printing the initial data
counter_ec: ds 1    ; encoding counter
counter_k: ds 1    ; counter for copying the key

psect udata_bank3 ; reserve data in Bank3
PlaintextArray:    ds 0x80 ; reserve 128 bytes for message data
CiphertextArray:   ds 0x80 ; reserve 128 bytes for modified message data

psect udata_bank4 ; reserve data in Bank4
KeyArray:          ds 0x80 ; reserve 128 bytes for the KeyArray

psect data    
; ******* Plaintext and Key Data in program memory *****
PlaintextTable:
    db 'h','e','l','l','o','w','o','r','l','d'                   
    TableLength   EQU 10    
    align 2

psect key_data, class=CODE
KeyTable:
    db 'k','e','y','k','e','y','k','e','y','k'   ; Define the key
    KeyLength   EQU 10   
    align 2

psect code, abs
rst:    org 0x0
	goto setup

; ******* Program Setup Code ***********************
setup:    
    bcf	    CFGS    ; point to Flash program memory  
    bsf	    EEPGD   ; access Flash program memory
    call    LCD_Setup    ; setup LCD
    movlw   0x00
    movwf   TRISH, A
    movlw   0x00
    movwf   PORTH, A
    goto    start

start:
    call    copy_plaintext    ; Load plaintext from Flash to RAM
    call    copy_key          ; Load key from Flash to RAM
    call    print_plaintext   ; Print the plaintext on LCD

    movlw   0xC0            ; Move cursor to the second line for ciphertext
    call    LCD_Send_Byte_I
    movlw   0x01            ; Allow time for cursor to move
    call    LCD_delay_ms

    call    feistel_encrypt  ; Perform Feistel encryption

    call    print_ciphertext ; Print ciphertext to LCD

    goto    $

copy_plaintext:
    lfsr    0, PlaintextArray   ; Load FSR0 with address in RAM    
    movlw   low highword(PlaintextTable)
    movwf   TBLPTRU, A
    movlw   high(PlaintextTable)
    movwf   TBLPTRH, A
    movlw   low(PlaintextTable)
    movwf   TBLPTRL, A
    movlw   TableLength
    movwf   counter_pt, A
    goto    setup_loop

copy_key:
    lfsr    1, KeyArray
    movlw   low highword(KeyTable)
    movwf   TBLPTRU, A
    movlw   high(KeyTable)
    movwf   TBLPTRH, A
    movlw   low(KeyTable)
    movwf   TBLPTRL, A
    movlw   KeyLength
    movwf   counter_k, A
    goto    setup_loop_key

setup_loop:
    tblrd*+            ; Read one byte from program memory
    movff TABLAT, POSTINC0  ; Move data to RAM
    movf TABLAT, W, A
    decfsz counter_pt, A
    bra setup_loop
    return

setup_loop_key:
    tblrd*+
    movff   TABLAT, POSTINC1
    movf    TABLAT, W, A
    decfsz  counter_k, A
    bra	    setup_loop_key
    return

ending:
    nop
end rst
