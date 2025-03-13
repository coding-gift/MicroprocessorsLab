#include <xc.inc>
    
global  UART_Setup, UART_Transmit_Message

psect	udata_acs   ; reserve data space in access ram
UART_counter: ds    1	    ; reserve 1 byte for variable UART_counter

psect	uart_code,class=CODE
UART_Setup:
    movlb   15
    bsf	    SPEN2	; enable
    bcf	    SYNC2	; synchronous
    bcf	    BRGH2	; slow speed
    bsf	    TXEN2	; enable transmit
    bsf	    CREN2	; enable receive
    bcf	    BRG162	; 8-bit generator only
    movlw   103		; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG2, B	; set baud rate
    bsf	    TRISG, PORTG_TX2_POSN, A	; TX1 pin is output on RC6 pin
					; must set TRISC6 to 1
    movlb   0
    return

UART_Transmit_Message:	    ; Message stored at FSR2, length stored in W
    movwf   UART_counter, A
UART_Loop_message:
    movf    POSTINC2, W, A
    call    UART_Transmit_Byte
    decfsz  UART_counter, A
    bra	    UART_Loop_message
    return

UART_Transmit_Byte:	    ; Transmits byte stored in W
    movlb   15
    btfss   TX2IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte
    movwf   TXREG2, A
    movlb   0
    return


