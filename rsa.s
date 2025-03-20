#include <xc.inc>

global initialise_rsa, n_val_low, n_val_high, val_middle, val_high, val_low, encrypt, encoded_low, encoded_high, rsa_print_ciphertext, decrypt, decoded, rsa_modify_table, rsa_decode_table
extrn LCD_Write_Hex, LCD_delay_ms, LCD_Send_Byte_D, LCD_Send_Byte_I ;(LCD.s)
extrn char, char_low, char_high ;(main / make ciphertext) 
extrn  ARG1L, ARG1H, ARG2L, ARG2H, RES0, RES1, RES2, RES3, mult_extended, calc_remainder ;(maths.s)
extrn PlaintextArray, CiphertextArray, DecryptedArray, TableLength, char, DecryptedArray, char_high, char_low, counter_ec
    
psect	udata_acs   ; named variables in access ram
    t_val:			ds 1	    ; neecssary for some reason?
    p_val:			ds 1
    q_val:			ds 1
    n_val_low:			ds 1	; n=p*q (lower byte)
    n_val_high:			ds 1	; n=p*q (upper byte)
    phi_val_low:		ds 1	; phi = (p-1)*(q-1) (lower byte)
    phi_val_high:		ds 1	; phi = (p-1)*(q-1) (upper byte)
    e_val:			ds 1
    d_val:			ds 1
    temp_maths1:		ds 1
    temp_maths2:		ds 1
    val:			ds 1
    val_low:			ds 1
    val_middle:			ds 1
    val_high:			ds 1
    quart_low:			ds 1
    quart_high:			ds 1
    encoded_low:		ds 1
    encoded_high:		ds 1 
    
    four_low:			ds 1 
    four_high:			ds 1 
    eight_low:			ds 1 
    eight_high:			ds 1 
    thirty_two_low:		ds 1 
    thirty_two_high:		ds 1 
    hundred_twenty_eight_low:	ds 1 
    hundred_twenty_eight_high:	ds 1 
    decoded:			ds 1
    
    
psect   rsa_code, class=CODE    
initialise_rsa:
    
    movlw   0x11		; 17
    movwf   p_val, A	; load p

    movlw   0x13		;19
    movwf   q_val, A	; load q
    
    movlw   0x05		; 5
    movwf   e_val, A	; load e
    
    movlw   0xAD		; 173
    movwf   d_val, A	; load d

    ; Calculate n = p * q
    movf    p_val, W, A  ; Move p_val into WREG
    mulwf   q_val, A    ; Multiply WREG (p) by q_val
    movff   PRODL, n_val_low, A   ; Store n = p * q
    movff   PRODH, n_val_high, A   ; Store n = p * q

    ; Calculate p-1
    movlw   0x01
    subwf   p_val, W, A  ; W = p_val - 1
    movwf   temp_maths1, A

    ; Calculate q-1
    movlw   0x01
    subwf   q_val, W, A  ; W = q_val - 1
    movwf   temp_maths2, A

    ; Calculate phi = (p-1) * (q-1)
    movf    temp_maths1, W, A
    mulwf   temp_maths2, A
    movff   PRODL, phi_val_low, A  ; Store phi = (p-1) * (q-1)
    movff   PRODH, phi_val_high, A  ; Store phi = (p-1) * (q-1)
    
    ; setup val_low, val_middle, val_high
    movlw   0x00
    movwf   val_low, A
    movwf   val_middle, A
    movwf   val_high, A
    
    return
    
encrypt:
    movf    char, W, A
    movwf   val, A	; largest value here = 7A (122 decimal)
    
    mulwf   val, A	; multiply the character by itself to get the squared value - ALWAYS WITHIN TWO BITES
    movff   PRODL, val_low, A	; move the sqaured values into val_low, val_middle (cannot be big enough here to get ito the upper register)
    movff   PRODH, val_middle, A
    call    calc_remainder	; the remainder of m^emod(n) is now in val_low, val_middle, val_high - MAX SIZE HERE = 322 (10) . 
    
    movff   val_low, ARG1L	; load the remainder of the square function into arg1 and arg2 - currently only val_low and val_midle filled
    movff   val_middle, ARG1H
    movff   val_low, ARG2L
    movff   val_middle, ARG2H
    call    mult_extended	; fourth power is now stored in RES0 - RES3 (max value: 19504(16), held in res0, res1, half res2)
    movff   RES2, val_high, A	; move the multiplied fourth power into the val registers
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; calculate the remainder of the fourth power - max size is 322, in val_low and val_middle
    movff   val_low, quart_low, A
    movff   val_middle, quart_high, A	; move the fourth power remainder into quart_low, quart_high
    
    movff   quart_low, ARG1L, A		; move the fourth powers (modded) into arg1
    movff   quart_high, ARG1H, A    
    movlw   0x00    
    movwf   ARG2H, A	    ; set upper byte of arg2 to 0, as character is only ever one byte
    movff   char, ARG2L, A  ; set lower byte of arg2 to the characater
    call    mult_extended   ; multiply to get the fifth power
    
    movff RES2, val_high, A
    movff RES1, val_middle, A
    movff RES0, val_low, A
    call calc_remainder	    ; max value here is 322 again -> three bytes or less
    
    movff val_low, encoded_low, A   ; move the encoded values to encoded_low, encoded_high
    movff val_middle, encoded_high, A

    return
    
decrypt:
    ;character stored in char_low, char_high
    
    movff   char_low, ARG1L, A	; calculate the square
    movff   char_high, ARG1H, A
    movff   char_low, ARG2L, A
    movff   char_high, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of squared
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder		; get the squared val remainder -> now remainder in val_low, val_middle
    
    movff   val_low, ARG1L, A	; calculate the fourth power
    movff   val_middle, ARG1H, A
    movff   val_low, ARG2L, A
    movff   val_middle, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of fourth power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the fourth power val remainder, furth power remainder in val_middle, val_low
    movff   val_low, four_low, A
    movff   val_middle, four_high, A    ;store the fourth power
    
    movff   val_low, ARG1L, A	; calculate the eighth power
    movff   val_middle, ARG1H, A
    movff   val_low, ARG2L, A
    movff   val_middle, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of eighth power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the eighth power val remainder
    movff   val_low, eight_low, A
    movff   val_middle, eight_high, A    ;store the eighth power
    
    movff   val_low, ARG1L, A	; calculate the sixteenth power
    movff   val_middle, ARG1H, A
    movff   val_low, ARG2L, A
    movff   val_middle, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of sixteenth power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the sixteenth power val remainder
    
    movff   val_low, ARG1L, A	; calculate the 32nd power
    movff   val_middle, ARG1H, A
    movff   val_low, ARG2L, A
    movff   val_middle, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of 32nd power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the 32nd power val remainder
    movff   val_low, thirty_two_low, A
    movff   val_middle, thirty_two_high, A    ;store the 32nd power
    
    movff   val_low, ARG1L, A	; calculate the 64th power
    movff   val_middle, ARG1H, A
    movff   val_low, ARG2L, A
    movff   val_middle, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of 64th power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the 64th power val remainder
    
    movff   val_low, ARG1L, A	; calculate the 128th power
    movff   val_middle, ARG1H, A
    movff   val_low, ARG2L, A
    movff   val_middle, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of 128th power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the 128th power val remainder
    movff   val_low, hundred_twenty_eight_low, A
    movff   val_middle, hundred_twenty_eight_high, A    ;store the 128th power
    
    ; multiply the powers together
    
    ; 1 + 4
    movff   char_low, ARG1L, A
    movff   char_high, ARG1H, A
    movff   four_low, ARG2L, A
    movff   four_high, ARG2H, A
    call    mult_extended
    movff   RES2, val_high, A	; store the value of 5th power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the 5th power val remainder
    
    ; 5 + 8
    movff   val_low, ARG1L, A	; fifth power
    movff   val_middle, ARG1H, A    ; fifth power
    movff   eight_low, ARG2L, A		;8th power
    movff   eight_high, ARG2H, A	; 8th power
    call    mult_extended
    movff   RES2, val_high, A	; store the value of 13th power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the 13th power val remainder
    
    ; 13 + 32
    movff   val_low, ARG1L, A				; 13th power
    movff   val_middle, ARG1H, A			; 13th power
    movff   thirty_two_low, ARG2L, A			; 32nd power
    movff   thirty_two_high, ARG2H, A			; 32nd power
    call    mult_extended
    movff   RES2, val_high, A	; store the value of 45th power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the 45th power val remainder
    
    ; 45 + 128
    movff   val_low, ARG1L, A				; 45th power
    movff   val_middle, ARG1H, A			; 45th power
    movff   hundred_twenty_eight_low, ARG2L, A		; 128th power
    movff   hundred_twenty_eight_high, ARG2H, A		; 128th power
    call    mult_extended
    movff   RES2, val_high, A	; store the value of 173rd power
    movff   RES1, val_middle, A
    movff   RES0, val_low, A
    call    calc_remainder	; get the 173rd power val remainder
    
    ; move the character into decoded
    movff val_low, decoded

    return

rsa_print_ciphertext:
    ; Set cursor to the desired start position on the LCD
    movlw   0xC0                ; Adjust the cursor position as needed
    call    LCD_Send_Byte_I
    movlw   0x01                ; Small delay for cursor stabilization
    call    LCD_delay_ms

    ; Set up FSR to point to the start of the CiphertextArray
    movlw   LOW(CiphertextArray)
    movwf   FSR0L, A
    movlw   HIGH(CiphertextArray)
    movwf   FSR0H, A

    ; Load the number of plaintext characters
    movlw   TableLength
    movwf   counter_ec, A        ; Each character has 2 bytes in ciphertext

print_loop:
    movf    counter_ec, W, A
    bz      print_done           ; If counter is zero, we're done

    ; Display the high byte in hex (encoded_high)
    movf    INDF0, W, A
    call    LCD_Write_Hex
    incf    FSR0L, A             ; Move to the next byte (encoded_low)

    ; Display the low byte in hex (encoded_low)
    movf    INDF0, W, A
    call    LCD_Write_Hex
    incf    FSR0L, A             ; Move to the next encrypted value (next 2 bytes)

    ; Optional: Add a space between displayed hex values for readability
    movlw   ' '
    ;call    LCD_Send_Byte_D

    decfsz  counter_ec, F, A     ; Decrement plaintext counter
    bra     print_loop           ; Continue printing until done    
    
print_done:
    return
    
  
rsa_modify_table:
    movlw   LOW(PlaintextArray)  ; Load low byte of PlaintextArray address
    movwf   FSR1L, A
    movlw   HIGH(PlaintextArray) ; Load high byte of PlaintextArray address
    movwf   FSR1H, A

    movlw   LOW(CiphertextArray) ; Load low byte of CiphertextArray address
    movwf   FSR0L, A
    movlw   HIGH(CiphertextArray); Load high byte of CiphertextArray address
    movwf   FSR0H, A

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    goto    rsa_modify_loop          ; Start modification

rsa_modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      rsa_modify_done          ; If zero, we are done

    movff    INDF1, char, A          ; Read character from PlaintextArray into char
    
    call encrypt	; encrypt the character
    
    movff   encoded_high, INDF0, A     ; Store upper byte of encoded result
    incf    FSR0L, A                   ; Move to the next byte of CiphertextArray
    movff   encoded_low, INDF0, A      ; Store lower byte of encoded result
    incf    FSR0L, A                   ; Move to the next byte of CiphertextArray
    

    incf    FSR1L, A               ; Move to the next character in PlaintextArray
    decfsz  counter_ec, A        ; Decrement counter and check if done
    bra     rsa_modify_loop          ; Loop again if not finished

rsa_modify_done:
    return
    
rsa_decode_table:
    movlw   LOW(CiphertextArray)  ; Load low byte of PlaintextArray address
    movwf   FSR1L, A
    movlw   HIGH(CiphertextArray) ; Load high byte of PlaintextArray address
    movwf   FSR1H, A

    movlw   LOW(DecryptedArray) ; Load low byte of CiphertextArray address
    movwf   FSR0L, A
    movlw   HIGH(DecryptedArray); Load high byte of CiphertextArray address
    movwf   FSR0H, A

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    goto    rsa_decode_loop          ; Start modification
rsa_decode_loop:
    ; Check if counter_ec is zero (done decoding)
    movf    counter_ec, W, A
    bz      rsa_decode_done        ; If counter_ec is zero, end the loop

    ; Read the first byte from CiphertextArray (via FSR1) into char_high
    movf    INDF1, W, A          ; Read the value from the memory location pointed to by FSR1
    movwf   char_high, A         ; Store the value in char_high
    incf    FSR1L, F, A        ; Increment the low byte of FSR1 to point to the next byte in CiphertextArray

    ; Read the second byte from CiphertextArray (via FSR1) into char_low
    movf    INDF1, W, A
    movwf   char_low, A
    incf    FSR1L, F, A           ; Increment FSR1 again to point to the next byte in CiphertextArray

    ; Call decrypt function with char_low and char_high
    call    decrypt            ; Assuming decrypt updates char_low and char_high with the decrypted value

    ; Store the decrypted result back into DecryptedArray (via FSR0)
    movf    decoded, W, A         ; Assuming decrypted result is stored in the 'decoded' variable
    movwf   INDF0, A              ; Store the decrypted result in the DecryptedArray
    incf    FSR0L, F, A           ; Increment FSR0 to move to the next byte in DecryptedArray

    ; Decrement counter_ec and check if we are done
    decfsz  counter_ec, F, A      ; Decrement counter_ec, skip the next instruction if counter_ec is zero
    goto    rsa_decode_loop        ; Continue looping if counter_ec is not zero

rsa_decode_done:
    return                     ; End the function when done

