#include <xc.inc>

extrn CiphertextArray, PlaintextArray, TableLength, counter_pt, LCD_Send_Byte_D, KeyArray
global print_plaintext, print_ciphertext

psect   print_code, class=CODE

; Function to print the plaintext
print_plaintext:
    ; Load the start address of PlaintextArray into FSR0
    movlw   LOW(PlaintextArray)  
    movwf   FSR0L, A
    movlw   HIGH(PlaintextArray) 
    movwf   FSR0H, A

    movlw   TableLength    ; Load the number of characters to print
    movwf   counter_pt, A  ; Store in counter
    goto print_loop 

; Function to print the ciphertext
print_ciphertext: ;; printing the keyarray now (debug) change to ciphertextarray later
    ; Load the start address of CiphertextArray into FSR0
    movlw   LOW(CiphertextArray)  
    movwf   FSR0L, A
    movlw   HIGH(CiphertextArray) 
    movwf   FSR0H, A

    movlw   TableLength    ; Load the number of characters to print
    movwf   counter_pt, A  ; Store in counter
    goto print_loop 

print_loop:
    movf    counter_pt, W, A  
    bz      print_done      ; If counter is zero, we're done

    movf    POSTINC0, W, A  ; Read character and auto-increment FSR0
    call    LCD_Send_Byte_D ; Send it to the LCD

    decfsz  counter_pt, A  
    bra     print_loop

print_done:
    return
