#include <xc.inc>

extrn CiphertextArray, PlaintextArray, TableLength, counter_ec, KeyArray
global modify_table
    
psect   modify_code, class=CODE
psect   modify_data, class=DATA

TEMP_KEY:                        ; Allocate TEMP_KEY in memory
    ds      1                    ; Reserve 1 byte of space

modify_table:
    movlw   LOW(PlaintextArray)  ; Load low byte of PlaintextArray address
    movwf   FSR1L, A
    movlw   HIGH(PlaintextArray) ; Load high byte of PlaintextArray address
    movwf   FSR1H, A

    movlw   LOW(CiphertextArray) ; Load low byte of CiphertextArray address
    movwf   FSR0L, A
    movlw   HIGH(CiphertextArray) ; Load high byte of CiphertextArray address
    movwf   FSR0H, A

    movlw   LOW(KeyArray)        ; Load low byte of KeyArray address
    movwf   FSR2L, A
    movlw   HIGH(KeyArray)       ; Load high byte of KeyArray address
    movwf   FSR2H, A

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec
    
    goto    modify_loop          ; Start modification

modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      modify_done          ; If zero, we are done

   ;; Vigenère cipher logic
    movf    INDF2, W             ; Read character from KeyArray into W
    sublw   0x41                 ; Convert key character to 0-25 range (A=0, Z=25)
    movwf   TEMP_KEY, A          ; Store key shift temporarily

    movf    INDF1, W             ; Read character from PlaintextArray into W
    sublw   0x41                 ; Convert plaintext character to 0-25 range (A=0, Z=25)
    addwf   TEMP_KEY, W, A       ; Add the key shift to the plaintext shift

    movlw   26                   ; Modulo 26 logic (wraparound after 'Z')
    subwf   WREG, W, A           ; Ensure result is within 0-25 range if >=26

    addlw   0x41                 ; Convert back to ASCII ('A'-'Z')
    movwf   INDF0, A             ; Write encrypted character to CiphertextArray
    ;;
    
    ;addlw   0x02		   ; Caesar (using for debugging)
    
    
    incf    FSR1L, A             ; Increment FSR1 (next character in PlaintextArray)
    incf    FSR0L, A             ; Increment FSR0 (next character in CiphertextArray)
    incf    FSR2L, A             ; Increment FSR2 (next character in KeyArray)

    decfsz  counter_ec, A        ; Decrement counter and check if done
    bra     modify_loop          ; Loop again if not finished

modify_done:
    return
