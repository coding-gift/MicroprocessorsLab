#include <xc.inc>
global CiphertextArray, PlaintextArray, TableLength, counter_pt, counter_ec
global KeyArray, counter_k, KeyLength
global repeat_keyword  ; Declare function globally

extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn print_plaintext, print_ciphertext   
extrn modify_table

psect udata_acs   ; reserve data space in access RAM
counter_pt:	ds 1    ; Counter for printing the initial data
counter_ec:	ds 1	; Encoding counter
counter_k:	ds 1	; Counter for copying the key

psect udata_bank3 ; Reserve data in Bank3
PlaintextArray:    ds 0x80 ; Reserve 128 bytes for message data
CiphertextArray:   ds 0x80 ; Reserve 128 bytes for modified message data

psect udata_bank4 ; Reserve data in Bank4
KeyArray:          ds 0x80 ; Reserve 128 bytes for the KeyArray

psect	data    
	; ******* myTable, data in program memory, and its length *****
PlaintextTable:
	db	'A','A','A','A','A','A','A','A','A'  ; Example plaintext
					
	TableLength   EQU	9	
	align	2

psect key_data, class=CODE
KeyTable:
	db 'A', 'B', 'C' ; Define the keyword "ABC"
	KeyLength   EQU		3	
	align	2

psect	code, abs
rst:	org 0x0
	goto setup
	
	; ******* Program Setup ***********************
setup:	bcf	CFGS	; Point to Flash program memory  
	bsf	EEPGD 	; Access Flash program memory
	call	LCD_Setup	; Setup UART
	movlw	0x00
	movwf	TRISH, A
	movlw	0x00
	movwf	PORTH, A
	goto	start

start:
	call	copy_plaintext		; Load plaintext from Flash to RAM
	call	copy_key            ; Load key from Flash to RAM  
	call	repeat_keyword		; Expand key to match plaintext length
	call	print_plaintext		; Print the plaintext
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; Allow time for cursor to move
	call	LCD_delay_ms
	
	call modify_table        ; Modify the ciphertext array
	call print_ciphertext    ; Print the modified data to the LCD
	
	goto	$

copy_plaintext:
	lfsr	0, PlaintextArray	; Load FSR0 with address in RAM	
	movlw	low highword(PlaintextTable)	; Address of data in PM
	movwf	TBLPTRU, A		; Load upper bits to TBLPTRU
	movlw	high(PlaintextTable)	; Address of data in PM
	movwf	TBLPTRH, A		; Load high byte to TBLPTRH
	movlw	low(PlaintextTable)	; Address of data in PM
	movwf	TBLPTRL, A		; Load low byte to TBLPTRL
	movlw	TableLength	; Bytes to read
	movwf 	counter_pt, A
	goto setup_loop

copy_key:
	lfsr	1, KeyArray	; Load FSR1 with address in RAM	
	movlw	low highword(KeyTable)	; Address of data in PM
	movwf	TBLPTRU, A		; Load upper bits to TBLPTRU
	movlw	high(KeyTable)	; Address of data in PM
	movwf	TBLPTRH, A		; Load high byte to TBLPTRH
	movlw	low(KeyTable)	; Address of data in PM
	movwf	TBLPTRL, A		; Load low byte to TBLPTRL
	movlw	KeyLength	; Bytes to read
	movwf 	counter_k, A
	goto setup_loop_key

setup_loop:
	tblrd*+			; Read one byte from PM to TABLAT, increment TBLPTR
	movff	TABLAT, POSTINC0 ; Move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter_pt, A		; Count down to zero
	bra	setup_loop	; Keep going until finished
	return

setup_loop_key:
	tblrd*+			; Read one byte from PM to TABLAT, increment TBLPTR
	movff	TABLAT, POSTINC1 ; Move data from TABLAT to (FSR1), inc FSR1	
	decfsz	counter_k, A		; Count down to zero
	bra	setup_loop_key	; Keep going until finished
	return

; ============================
; Repeat the key to match plaintext length
; ============================
repeat_keyword:
	clrf counter_k, A	; Reset key index
	clrf counter_ec, A	; Reset encoding counter
	lfsr 0, KeyArray	; FSR0 points to start of KeyArray

	movlw	TableLength
	movwf	counter_pt, A	; counter_pt = TableLength

repeat_loop:
    movf    counter_k, W, A     ; Load counter_k into WREG
    sublw   KeyLength           ; Compare WREG with KeyLength (WREG = KeyLength - counter_k)
    btfsc   STATUS, 2           ; If counter_k == KeyLength, reset counter_k to 0
    clrf    counter_k, A        ; Reset counter_k if reached end of key

    ; Offset FSR0 by counter_k
    movf    counter_k, W
    addwf   FSR0L, F, A         ; Offset FSR0 by counter_k
    movf    counter_k, W
    addwfc  FSR0H, F, A         ; Handle carry if needed

    ; Read the correct key character and store it into KeyArray
    movf    INDF0, W
    movwf   POSTINC1            ; Store in KeyArray

    incf    counter_k, F, A     ; Increment key counter
    incf    counter_ec, F, A    ; Increment encoding counter

    movf    counter_ec, W, A    ; Load encoding counter into WREG
    sublw   TableLength         ; Compare counter_ec with plaintext length
    btfss   STATUS, 2           ; If counter_ec < TableLength, keep repeating
    bra     repeat_loop         ; Loop until keyword matches plaintext length

    return

mod_loop:
    ; Ensure plaintext and key are properly aligned
    lfsr    0, PlaintextArray   ; Load FSR0 with PlaintextArray base address
    lfsr    1, KeyArray         ; Load FSR1 with KeyArray base address
    lfsr    2, CiphertextArray  ; Load FSR2 with CiphertextArray base address

mod_process:
    movf    POSTINC0, W         ; Load plaintext character
    xorwf   POSTINC1, W         ; XOR with corresponding key character
    movwf   POSTINC2, A         ; Store result in CiphertextArray

    decfsz  counter_ec, F, A    ; Decrease counter, stop when reaching 0
    bra     mod_process         ; Repeat for all characters

    return

ending:
    nop
    
    end rst
