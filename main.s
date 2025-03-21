
#include <xc.inc>

#include <xc.inc>
global CiphertextArray, PlaintextArray, DecryptedArray,  TableLength, counter_pt, counter_ec, timer_low, timer_high, PlaintextTable, KeyArray, counter_k, KeyTable, char, char_low, char_high, key_length
extrn LCD_Setup, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn print_plaintext, print_ciphertext, send_characters, copy_plaintext, copy_key
extrn c_modify_table, measure_modify_table, vig_modify_table, c_decode
extrn initialise_rsa, encrypt, encoded_low, encoded_high, rsa_print_ciphertext, decrypt, decoded, rsa_decode_table, print_timer
extrn UART_Setup, UART_Transmit_Message, print_decodedtext, feistel_decrypt

psect	udata_acs		; reserve data space in access ram
counter_pt:	    ds 1		; counter for printing the initial data
counter_ec:	    ds 1		; encoding counter
counter_k:	    ds 1		; counter for copying the key
timer_low:	    ds 1		; Store low byte of Timer1
timer_high:	    ds 1		; Store high byte of Timer1
clock_pin:	    ds 1
char:		    ds 1
char_low:	    ds 1
char_high:	    ds 1
key_length:	    ds 1
    
psect	udata_bank1		; reserve data anywhere in RAM (here at 0x400)
PlaintextArray:	    ds 0x10	; reserve 128 bytes for message data
CiphertextArray:    ds 0x10	; reserve 128 bytes for modified message data
KeyArray:	    ds 0x10
DecryptedArray:	    ds 0x10

    
psect	data    
PlaintextTable:
	db	'h','i','y','a','e', 'f', 'g','h', 'a', 'a','a', 'a','a','a','a','a'
	TableLength   EQU	0x04

	align	2

	psect key_data, class=CODE
KeyTable:
	db 'e','f','a','a', 'a', 'b', 'c', 'd', 'a', 'b', 'c', 'd'
	KeyLength   EQU		0x06
	align	2
	
psect	code, abs
rst:	org 0x0
	goto setup
	
setup:	bcf	CFGS		; point to Flash program memory  
	bsf	EEPGD		; access Flash program memory
	call	LCD_Setup	; setup LCD
	call	UART_Setup
	call	initialise_rsa
	goto	start

start:
	;call	caesar_func
	;call	caesar_decode_func
	
	;call	rsa_encoding_func
	;call	rsa_decoding_func
	
	call	feistel_func
	call	feistel_decrypt_func
	
	;call    vigenere_func
	;call	 vig_decrypt
	
	call	send_message

	goto	$

caesar_func:
	call	copy_plaintext		; load code into RAM
	call	print_plaintext		; print the plaintext
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call	measure_modify_table   ; Modify the ciphertext array and time it
	call	print_ciphertext    ; Print the modified data to the LCD
	call	print_timer
	
	return 
	
caesar_decode_func:
    
	movlw 0xFF
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	
	movlw 0x01
	call LCD_Send_Byte_I
	
	movlw 0xFF
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	
	call c_decode
	
	call print_decodedtext
	return 

vigenere_func:
    
	movlw	0x03
	movwf	key_length, A
    	call	copy_plaintext		; Load plaintext from Flash to RAM
	call	copy_key            ; Load key from Flash to RAM
	call	print_plaintext		; Print the plaintext
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call	measure_modify_table        ; Modify the ciphertext array
	call	print_ciphertext    ; Print the modified data to the LCD
	call	print_timer
	
	return
  
rsa_encoding_func:
	call	copy_plaintext		; load code into RAM
	call	print_plaintext		; print the plaintext
    
	call	measure_modify_table
	call	rsa_print_ciphertext
	call	print_timer
    
    return
    
rsa_decoding_func:
	movlw	0xFF
	call	LCD_delay_ms
	call	LCD_delay_ms
	call	LCD_delay_ms
	call	LCD_delay_ms
	
	movlw	0x01
	call	LCD_Send_Byte_I
	
	movlw	0x84
	call	LCD_Send_Byte_I
	movlw	0x01
	call	LCD_delay_ms
    
	call	rsa_decode_table
	
	movlw	0xFF
	call	LCD_delay_ms
	call	LCD_delay_ms
	call	print_decodedtext
	
	return	

feistel_func:	
	call	copy_plaintext
	call	print_plaintext
	call	copy_key            ; Load key from Flash to RAM  <-- ADD THIS
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call measure_modify_table
	call print_ciphertext
	call print_timer
	return

feistel_decrypt_func:
    movlw 0xFF
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	
	movlw 0x01
	call LCD_Send_Byte_I
	
	movlw 0xFF
	call LCD_delay_ms
	call LCD_delay_ms
	call LCD_delay_ms
	
	call feistel_decrypt
	
	call print_decodedtext
	return
send_message:	
	lfsr	2,CiphertextArray
	movlw	TableLength
	call	UART_Transmit_Message
ending:
    nop
    
    end rst
    