#include <xc.inc>

extrn CiphertextArray, PlaintextArray, KeyArray
extrn TableLength, counter_ec
global feistel_decrypt

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
feistel_decrypt:  
    ; ====== Avaiable functions ==========
    ;		Length = 2, Round = 1 => feistel_d_loop_L2_R1
    ;		Length = 4, Round = 1 => feistel_d_loop_L4_R1
    bra     feistel_d_loop_L4_R1         ; Start encryption rounds

; =============================  Lenght=4, Round=1 ==========================
feistel_d_loop_L4_R1:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray     ; FSR2 -> CiphertextArray (Output)

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
    
    bra     feistel_d_done

;; =========================== Length=2, Round = 1 ===========================

feistel_d_loop_L2_R1:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    movf    POSTINC0, W, A       ; Load plaintext char 1 ; L
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2 ; R
    movwf   char_2, A         ; store

    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    char_2, W, A	; R
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A		; store it in L
    
    movf    char_2, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A
   
    bra    feistel_d_done
feistel_d_done:
    return