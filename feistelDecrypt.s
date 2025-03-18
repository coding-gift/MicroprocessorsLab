#include <xc.inc>

extrn PlaintextArray, KeyArray
extrn TableLength, counter_ec
global feistel_decrypt, CiphertextArray
    

psect	udata_acs   ; reserve data space in access ram
temp_left:	ds 1    ; counter for printing the initial data
temp_right:	ds 1	; encoding counter
;counter_k:	ds 1	; counter for copying the key
char_1:		ds 1
char_2:		ds 1
char_3:		ds 1
char_4:		ds 1
char_5:		ds 1
char_6:		ds 1
char_7:		ds 1
char_8:		ds 1

key_1:		ds 1
key_2:          ds 1
key_3:		ds 1
key_4:          ds 1
    
psect feistel_code, class=CODE

;lfsr	0, PlaintextArray	
;movlw	low highword(0x1FE30)	; address of data in PM
;movwf	TBLPTRU, A		; load upper bits to TBLPTRU
;movlw	high(0x1FE30)	; address of data in PM
;movwf	TBLPTRH, A		; load high byte to TBLPTRH
;movlw	low(0x1FE30)	; address of data in PM
;movwf	TBLPTRL, A		; load low byte to TBLPTRL    
    
feistel_decrypt:
    ;Initialize FSRs for data pointers
    lfsr    0, CiphertextArray     ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, PlaintextArray   ; FSR2 -> CiphertextArray (Output)
    
    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    bra     feistel_d_loop         ; Start encryption rounds

feistel_d_loop:
    movf    counter_ec, W, A     ; Check if rounds are finished
    bz      feistel_d_done         ; If zero, we are done

    movf    POSTINC0, W, A       ; Load plaintext char 1
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2
    movwf   char_2, A         ; store
    
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_3, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_4, A         ; Store 

    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_2, A
    
    movf    char_3, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_3, A
    
    movf    char_4, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_4, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    ; Decrease counter and loop
    decfsz  counter_ec, A     ; Decrement counter
    bra     feistel_d_loop      ; Continue with next round
feistel_d_done:
    return