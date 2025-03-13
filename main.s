
#include <xc.inc>

#include <xc.inc>
global CiphertextArray, PlaintextArray, TableLength, counter_pt, counter_ec, timer_low, timer_high, PlaintextTable, KeyArray, counter_k, KeyTable
extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn print_plaintext, print_ciphertext,  send_characters, copy_plaintext, copy_key
extrn c_modify_table
extrn measure_modify_table
extrn vig_modify_table

psect	udata_acs		; reserve data space in access ram
counter_pt:	ds 1		; counter for printing the initial data
counter_ec:	ds 1		; encoding counter
counter_k:	ds 1	; counter for copying the key
timer_low:	ds 1		; Store low byte of Timer1
timer_high:	ds 1		; Store high byte of Timer1
clock_pin:	ds 1
    
psect	udata_bank4		; reserve data anywhere in RAM (here at 0x400)
PlaintextArray:	    ds 0x50	; reserve 128 bytes for message data
CiphertextArray:    ds 0x50	; reserve 128 bytes for modified message data
KeyArray:	    ds 0x50

    
psect	data    
PlaintextTable:
	db	'l','e','l','l','o',' ', 'a','b','c','c'				
	TableLength   EQU	10

	align	2

	psect key_data, class=CODE
KeyTable:
	db 'l','b','g','a','b','c','a','k','l', 't'  ; Define the keyword "key"
	KeyLength   EQU		10
	align	2
	
psect	code, abs
rst:	org 0x0
	goto setup
	
setup:	bcf	CFGS		; point to Flash program memory  
	bsf	EEPGD		; access Flash program memory
	call	LCD_Setup	; setup LCD
	call	encode_setup
	goto	start

start:
	; call caesar_func
	call vigenere_func
	goto	$
	

encode_setup:
    	movlw	0x00
	movwf	TRISH, A	; setup clock pin output
	movwf	TRISD, A	; set up message output
	movlw	0x00
	movwf	PORTH, A
	return

	
decode_setup:
	movlw	0xFF
	movwf	TRISH, A	; setup clock pin input
	movwf	TRISD, A	; set up message input
	return

caesar_func:
	call	copy_plaintext		; load code into RAM
	call	print_plaintext		; print the plaintext

	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call measure_modify_table   ; Modify the ciphertext array and time it
	

	call print_ciphertext    ; Print the modified data to the LCD
	
	; add a space then print the timer values
	movlw ' '
	call LCD_Send_Byte_D 
	movf timer_high, W, A
	call LCD_Write_Hex
	movf timer_low, W, A
	call LCD_Write_Hex

	; send the message from portF, portH
	movlw 0xFF
	movwf PORTH, A		; set clock pin high
	call send_characters	; send the characters
	movlw	0x00	
	movwf PORTH, A		; set the clock pin low

	return 

vigenere_func:
    	call	copy_plaintext		; Load plaintext from Flash to RAM
	call	copy_key            ; Load key from Flash to RAM
	call	print_plaintext		; Print the plaintext
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call vig_modify_table        ; Modify the ciphertext array
	
	call print_ciphertext    ; Print the modified data to the LCD
  
ending:
    nop
    
    end rst
    
	