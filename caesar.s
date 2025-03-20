#include <xc.inc>

extrn CiphertextArray, PlaintextArray, TableLength, counter_ec
global c_modify_table
    
psect	modify_code,class=CODE
    
c_modify_table:
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
    
    goto    c_modify_loop          ; Start modification

c_modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      c_modify_done          ; If zero, we are done
    movf    INDF1, W, A          ; Read character from PlaintextArray into w
    
    addlw   0x05	 ; CAESAR CIPHER!
    
    movwf   INDF0, A             ; Write character to CiphertextArray
    incf    FSR1L, A             ; Increment FSR1 (next character in PlaintextArray)
    incf    FSR0L, A             ; Increment FSR0 (next character in CiphertextArray)

    decfsz  counter_ec, A        ; Decrement counter and check if done
    bra     c_modify_loop          ; Loop again if not finished

c_modify_done:
    return


