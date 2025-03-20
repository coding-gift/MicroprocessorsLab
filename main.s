#include <xc.inc>

global PlaintextArray, TableLength, counter_pt, counter_ec, KeyArray
    
extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn	print_plaintext, print_ciphertext   
extrn	feistel_decrypt, CiphertextArray, feistel_encrypt
	
psect	udata_acs   ; reserve data space in access ram
counter_pt:	ds 1    ; counter for printing the initial data
counter_ec:	ds 1	; encoding counter
counter_k:	ds 1	; counter for copying the key

counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect udata_bank3 ; reserve data in Bank3
PlaintextArray:    ds 0x80 ; reserve 128 bytes for message data
;CiphertextArray:   ds 0x80 ; reserve 128 bytes for modified message data
    
psect udata_bank4 ; reserve data in Bank4

KeyArray:          ds 0x80 ; reserve 128 bytes for the KeyArray
    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
PlaintextTable:
	db	'a', 'b', 'c', 'd' ;'p','l','a','i','n','t','e','x','t'

	TableLength	EQU	    4
	align 2

	
psect key_data, class=CODE
KeyTable:
	db	'e', 'f' ;'a','b','c','a','b','c','a','b','c'   ; Define the keyword "key"
	KeyLength   EQU		2	
	align	2

psect	code, abs
rst:	org 0x0
	goto setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	;
	movlw	0x00
	movwf	TRISH, A
	movlw	0x00
	movwf	PORTH, A
	;
	goto	start
	
	; ******* Main programme ****************************************
start:
	call	print_plaintext
	call	copy_plaintext		; Load plaintext from Flash to RAM
	call	copy_key            ; Load key from Flash to RAM  <-- ADD THIS
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
	call	feistel_encrypt        ; Modify the ciphertext array
	
	movlw	TableLength
	lfsr	2, CiphertextArray
	
	call	LCD_Write_Message
	
	movlw	TableLength
	lfsr	2, CiphertextArray
	call	UART_Transmit_Message

	
read_loop:
	btfss	RC2IF
	bra	read_loop
	movlb   15
	movf	RCREG2, W, B
	movlb	0
	bcf	RC2IF
	call	LCD_Send_Byte_D
	goto	read_loop		; goto current line in code
	
	
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
	movlw	KeyLength	; bytes to read
	movwf 	counter_k, A
	goto setup_loop_key

setup_loop:
	tblrd*+			    ; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0    ; move data from TABLAT to (FSR0), inc FSR0	
	movf	TABLAT, W, A
	decfsz	counter_pt, A	    ; count down to zero
	bra	setup_loop	    ; keep going until finished
	return

setup_loop_key:
	movff	TABLAT, POSTINC1        ; move data from TABLAT to (FSR1), inc FSR1	
	movf	TABLAT, W, A
	decfsz	counter_k, A		; count down to zero
	bra	setup_loop	        ; keep going until finished
	tblrd*+			        ; one byte from PM to TABLAT, increment TBLPRT
	return



	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst