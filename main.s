
#include <xc.inc>
global CiphertextArray, PlaintextArray, DecryptedArray,  TableLength, counter_pt, counter_ec, measure_modify_table
global timer_low, timer_high, PlaintextTable, KeyArray, counter_k, KeyTable, char, char_low, char_high

extrn LCD_Setup, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn print_plaintext, print_ciphertext, send_characters, copy_plaintext, copy_key 
extrn feistel_decrypt, feistel_encrypt, print_timer
    
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
    
psect	udata_bank4		; reserve data anywhere in RAM (here at 0x400)
PlaintextArray:	    ds 0x30	; reserve 128 bytes for message data
CiphertextArray:    ds 0x30	; reserve 128 bytes for modified message data
KeyArray:	    ds 0x30
DecryptedArray:	    ds 0x30

    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
PlaintextTable:
	;db  'c', 'd', 'g', 0x60 ; 'a', 'b','c', 'd'
;	db 'c','d','g',0x60
	db 'a','b','c','d','e','f', 'g', 'h'
;	db 'm','n','o',0x60,'a','b','c','d'
;	db 'g', 0x60,'a','b'
;	db 'a','b'
	TableLength	EQU	    8
	align 2

	
psect key_data, class=CODE
KeyTable:    ; ======= Have KeyLength = TableLength/2
	db  'i'
	KeyLength   EQU		4	
	align	2

psect	code, abs
rst:	org 0x0
	goto setup
	
	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	
	movlw	0x04
	movwf	TableLength, A
	goto	start

start:
	call	copy_key            ; Load key from Flash to RAM  <-- ADD THIS
	call	copy_plaintext		; Load plaintext from Flash to RAM
	call	print_plaintext		; Print the plaintext
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call	measure_modify_table       ; Modify the ciphertext array
	call	print_ciphertext    ; Print the modified data to the LCD
	
	call	print_timer
	goto	$

ending:
    nop
    
    end rst
    
	