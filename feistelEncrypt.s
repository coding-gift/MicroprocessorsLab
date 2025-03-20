#include <xc.inc>

extrn CiphertextArray, PlaintextArray, KeyArray
extrn TableLength, counter_ec
global feistel_encrypt

psect udata_bank2 ; reserve data in Bank3
CiphertextArray1:    ds 0x80 ; reserve 128 bytes for message data
CiphertextArray2:   ds 0x80 ; reserve 128 bytes for modified message data

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
feistel_encrypt:
    ; ======= replace feistel_loop_L(length_pt)_R(no_rounds) ==========
    ; available:
    ;           key Lenght = 1
    ;		Lenght = 2 Round = 1 => feistel_loop_L2_R1
    ;		Lenght = 2 Round = 2 => feistel_loop_L2_R2
    ;		Lenght = 2 Round = 3 => feistel_loop_L2_R3  ; ciphertext = plaintext
    ;		Length = 4 Round = 1 => feistel_loop_L4_R1_K1
    ;		Lenght = 4 Round = 2 =>  feistel_loop_L4_R2_K1
    
    ;           Key Length = 2
    ;		Lenght = 4 Round = 1 => feistel_loop_L4_R1
    ;		Lenght = 4 Round = 2 => feistel_loop_L4_R2
    ;		Lenght = 4 Round = 3 => feistel_loop_L4_R3  ; ciphertext = plaintext
   
    ;           Key Length = 3
    ;		Lenght = 6 Round = 1 => feistel_loop_L6_R1
    ;		Lenght = 6 Round = 2 => feistel_loop_L6_R2
    ;         
    bra     feistel_loop_L4_R2        ; change for diffrent number of lengths and rounds

feistel_done:
    return
    ; =========================== Length=2, Round = 1 ===========================

feistel_loop_L2_R1:
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
    movwf   char_1, A		; store it in L
    
    movf    char_2, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A
    
    bra feistel_done
; 
;    
;; ===================== Lenght = 2 Round = 2 ==============
feistel_loop_L2_R2:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)
    
    movf    POSTINC0, W, A       ; Load plaintext char 1 ; L
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2 ; R
    movwf   char_2, A         ; store

    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    char_2, W, A	; R
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A		; store it in L
    
    movf    char_2, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A

    ; Round 2
    ;Initialize FSRs for data pointers
    lfsr    0, CiphertextArray1     ; FSR0 -> PlaintextArray (Left Half)
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
    movwf   char_1, A		; store it in L
    
    movf    char_2, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A
    
    bra feistel_done

;; ===================== Lenght = 2 Round = 3 ==============
feistel_loop_L2_R3:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)
    
    movf    POSTINC0, W, A       ; Load plaintext char 1 ; L
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2 ; R
    movwf   char_2, A         ; store

    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    char_2, W, A	; R
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A		; store it in L
    
    movf    char_2, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A
    
    ; Round 2
    ;Initialize FSRs for data pointers
    lfsr    0, CiphertextArray1     ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)
    
    movf    POSTINC0, W, A       ; Load plaintext char 1 ; L
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2 ; R
    movwf   char_2, A         ; store

    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    char_2, W, A	; R
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A		; store it in L
    
    movf    char_2, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A
    
    ; Round 3
    ;Initialize FSRs for data pointers
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
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
    movwf   char_1, A		; store it in L
    
    movf    char_2, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A
    
    bra feistel_done

    ; =========================== Lenght=4, Round = 1 ==================
feistel_loop_L4_R1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

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
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    bra feistel_done
    ; ==================== Key length = 1, Lenght=4, Round = 1 ==================
feistel_loop_L4_R1_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

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
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    bra feistel_done    
    
    ; =================== KeyLenght = 2, Lenght = 4, Round = 2 ==================
feistel_loop_L4_R2:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

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
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

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
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    bra feistel_done
    
    ; =================== KeyLenght = 1, Lenght=4, Round = 2 ==================
feistel_loop_L4_R2_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

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
    
    movf    char_3, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

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
    
    movf    char_3, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    bra feistel_done

    ; =========================== Lenght=4, Round = 3 ==================
feistel_loop_L4_R3:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

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
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)

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
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    ; ROUND 3
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

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
    movwf   char_1, A
    
    movf    char_4, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_3, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    bra feistel_done
    
   
   ; =========================== Lenght=6, Round = 1 ==================
feistel_loop_L6_R1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    movf    POSTINC0, W, A       ; Load plaintext char 1
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2
    movwf   char_2, A         ; store
    
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_3, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_4, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_5, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_6, A         ; Store 
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_2, A
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_3, A
    
    movf    char_4, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_5, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_6, W, A
    xorwf   key_3, W, A         ; F(R, Key) = R xor Key
    xorwf   char_3, W, A      ; New Right = L xor F(R, Key)
    movwf   char_3, A
    
    movf    char_4, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_5, W, A
    movwf   POSTINC2, A
    movf    char_6, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    movf    char_3, W, A
    movwf   POSTINC2, A
    
    bra feistel_done

   ; =========================== Lenght=6, Round = 2 ==================
feistel_loop_L6_R2:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    movf    POSTINC0, W, A       ; Load plaintext char 1
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2
    movwf   char_2, A         ; store
    
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_3, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_4, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_5, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_6, A         ; Store 
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_2, A
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_3, A
    
    movf    char_4, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_5, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_6, W, A
    xorwf   key_3, W, A         ; F(R, Key) = R xor Key
    xorwf   char_3, W, A      ; New Right = L xor F(R, Key)
    movwf   char_3, A
    
    movf    char_4, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_5, W, A
    movwf   POSTINC2, A
    movf    char_6, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    movf    char_3, W, A
    movwf   POSTINC2, A
    
    ; Round 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    movf    POSTINC0, W, A       ; Load plaintext char 1
    movwf   char_1, A         ; Store
  
    movf    POSTINC0, W, A       ; Load pt char 2
    movwf   char_2, A         ; store
    
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_3, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_4, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_5, A         ; Store 
    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_6, A         ; Store 
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_2, A
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_3, A
    
    movf    char_4, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_5, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_6, W, A
    xorwf   key_3, W, A         ; F(R, Key) = R xor Key
    xorwf   char_3, W, A      ; New Right = L xor F(R, Key)
    movwf   char_3, A
    
    movf    char_4, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_5, W, A
    movwf   POSTINC2, A
    movf    char_6, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    
    movf    char_2, W, A
    movwf   POSTINC2, A
    
    movf    char_3, W, A
    movwf   POSTINC2, A
    bra feistel_done