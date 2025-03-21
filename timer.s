#include <xc.inc>
    
global measure_modify_table, overflow_count, print_timer
extrn feistel_encrypt, feistel_decrypt
extrn timer_low, timer_high,LCD_Send_Byte_I, LCD_Send_Byte_I, LCD_Write_Hex, LCD_delay_ms,LCD_Send_Byte_D
    
psect udata_acs
overflow_count:	    ds 1  ; Reserve one byte for tracking overflows
  
psect	timer_code,class=CODE
measure_modify_table:
	clrf    TMR1H, A     ; Clear Timer1 High Byte
	clrf    TMR1L, A     ; Clear Timer1 Low Byte
	clrf	overflow_count, A   ;clear the timer overflow byte

	
	movlw   0b00000001   ; Configure Timer1: Enable, No Prescaler, Fosc/4
	movwf   T1CON, A     ; Enable Timer1

	;Feistel Cipher
	call	feistel_encrypt


	bcf     T1CON, 0, A    
	movf    TMR1L, W, A	; Read low byte of Timer1
	movwf   timer_low, A	; Store in timer_low
	movf    TMR1H, W, A	; Read high byte of Timer1
	movwf   timer_high, A	; Store in timer_high
	btfsc   PIR1, 0, A	; check if there has been an overflow
	call    handle_overflow  
	
	return

handle_overflow:
	incf	overflow_count, F, A
	bcf	PIR1, 0, A
	return 
    
print_timer:
	movlw	0x89		; move it to the 
	call	LCD_Send_Byte_I
	movlw	0x01
	call	LCD_delay_ms
    
	movf	overflow_count, W, A
	call	LCD_Write_Hex
	movlw	' '
	call	LCD_Send_Byte_D
    
	movf	TMR1H, W, A
	call	LCD_Write_Hex
	movf	TMR1L, W, A
	call	LCD_Write_Hex
	return 