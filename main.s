
#include <xc.inc>
global CiphertextArray, PlaintextArray, TableLength, counter_pt, counter_ec, KeyArray
    
extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn print_plaintext, print_ciphertext   
extrn vig_modify_table
    
psect	udata_acs   ; reserve data space in access ram
counter_pt:	ds 1    ; counter for printing the initial data
counter_ec:	ds 1	; encoding counter
counter_k:	ds 1	; counter for copying the key
    
psect udata_bank3 ; reserve data in Bank3
PlaintextArray:    ds 0x80 ; reserve 128 bytes for message data
CiphertextArray:   ds 0x80 ; reserve 128 bytes for modified message data
    
psect udata_bank4 ; reserve data in Bank4
KeyArray:          ds 0x80 ; reserve 128 bytes for the KeyArray
    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
PlaintextTable:
	db	'p','l','a','i','n','t','e','x','t'
					
	TableLength   EQU	9	
	align	2
psect key_data, class=CODE
KeyTable:
	db 'a','b','c','a','b','c','a','b','c'   ; Define the keyword "key"
	KeyLength   EQU		9	
	align	2

psect	code, abs
rst:	org 0x0
	goto setup
	
	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	movlw	0x00
	movwf	TRISH, A
	movlw	0x00
	movwf	PORTH, A
	goto	start

start:
	call	copy_plaintext		; Load plaintext from Flash to RAM
	call	copy_key            ; Load key from Flash to RAM  <-- ADD THIS
	call	print_plaintext		; Print the plaintext
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call vig_modify_table        ; Modify the ciphertext array
	
	call print_ciphertext    ; Print the modified data to the LCD
	
	goto	$

copy_plaintext:
	lfsr	0, PlaintextArray	; Load FSR0 with address in RAM	
	movlw	low highword(PlaintextTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(PlaintextTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(PlaintextTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	TableLength	; bytes to read
	movwf 	counter_pt, A
	goto setup_loop
copy_key:
	lfsr	0, KeyArray	; Load FSR0 with address in RAM	
	movlw	low highword(KeyTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(KeyTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(KeyTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	TableLength	; bytes to read
	movwf 	counter_k, A
	goto setup_loop_key

setup_loop:
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	movf	TABLAT, W, A
	decfsz	counter_pt, A		; count down to zero
	bra	setup_loop	; keep going until finished
	return
setup_loop_key:
	
	movff	TABLAT, POSTINC1; move data from TABLAT to (FSR0), inc FSR0	
	movf	TABLAT, W, A
	decfsz	counter_pt, A		; count down to zero
	bra	setup_loop	; keep going until finished
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	return
ending:
    nop
    
    end rst
    
	