#include <xc.inc>

extrn CiphertextArray, PlaintextArray, KeyArray
extrn TableLength, counter_ec
global feistel_encrypt

psect udata_bank2 ; reserve data in Bank3
CiphertextArray1:    ds 0x40 ; reserve 128 bytes for message data
CiphertextArray2:   ds 0x40 ; reserve 128 bytes for modified message data

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
    bra     feistel_loop_L8_R1_K1       ; change for diffrent number of lengths and rounds

feistel_done:
    return
; =========================== Length = 2, Key = 1 ===========================

; ================ Round = 1 =======================
feistel_loop_L2_R1:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)
    
    call    pt_len2
    
    bra feistel_done
;    
;; ==================== Round = 2 ==============
feistel_loop_L2_R2:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)
    
    call    pt_len2

    ; Round 2
    ;Initialize FSRs for data pointers
    lfsr    0, CiphertextArray1     ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)
    
    call    pt_len2
    
    bra feistel_done

;; ===================  Round = 3 ==============
feistel_loop_L2_R3:
    ;Initialize FSRs for data pointers
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)
    
    call pt_len2
    
    ; Round 2
    ;Initialize FSRs for data pointers
    lfsr    0, CiphertextArray1     ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)
    
    call pt_len2
    
    ; Round 3
    ;Initialize FSRs for data pointers
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)
    
    call    pt_len2
    
    bra feistel_done

    ; ==================== Lenght = 4, Key = 2 ==================
; =================== Round = 1 ====================    
feistel_loop_L4_R1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len4_k2
    
    bra feistel_done
    ; ============ Round = 2 ==================
feistel_loop_L4_R2:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len4_k2
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len4_k2
    
    bra feistel_done
; ========================  Round = 3 ==================
feistel_loop_L4_R3:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len4_k2
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)

    call len4_k2
    
    ; ROUND 3
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len4_k2
    bra feistel_done
; ==================== Length = 4, Key = 1 ==================

; =============== Round = 1 ====================
feistel_loop_L4_R1_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len4_k1
    
    bra feistel_done    
; =================== Round = 2 ==================
feistel_loop_L4_R2_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len4_k1
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len4_k1
    
    bra feistel_done
; =================== Round = 3 ==================
feistel_loop_L4_R3_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len4_k1
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)

    call len4_k1
    
    ; ROUND 3
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len4_k1
    
    bra feistel_done
; =========================== Lenght=6, Key = 3 ==================

; =======================  Round = 1 ==================
feistel_loop_L6_R1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len6_k3
    
    bra feistel_done
   ; =========================== Round = 2 ==================
feistel_loop_L6_R2:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len6_k3
    
    ; Round 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len6_k3
    bra feistel_done
   ; ========================= Round = 3 ==================
feistel_loop_L6_R3:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len6_k3
    
    ; Round 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)

    call len6_k3
    
    ; Round 3
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len6_k3
    
    bra feistel_done
; =========================== Lenght=6, Key = 1 ==================

;  ==================== Round = 1 ==========================
feistel_loop_L6_R1_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len6_k1
    
    bra feistel_done
 
   ; ===================== Round = 2 ==================
feistel_loop_L6_R2_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len6_k1
    
    ; Round 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len6_k1
    bra feistel_done

   ; ===================== Round = 3 ==================
feistel_loop_L6_R3_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)
    
    call len6_k1
    
    ; Round 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)

    call len6_k1
    
    ; Round 3
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len6_k1
    
    bra feistel_done
; =========================== Lenght = 8, Key = 4 ==================

;  ==================== Round = 1 ==========================
feistel_loop_L8_R1_K4:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len8_k4
    
    bra feistel_done
   ; ===================== Round = 2 ==================
feistel_loop_L8_R2_K4:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len8_k4
    
    ; Round 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len8_k4
    bra feistel_done
; ========================  Round = 3 ==================
feistel_loop_L8_R3_K4:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len8_k4
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)

    call len8_k4
    
    ; ROUND 3
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len8_k4
    bra feistel_done
 
; =========================== Lenght = 8, Key = 1 ==================

;  ==================== Round = 1 ==========================
feistel_loop_L8_R1_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len8_k1
    
    bra feistel_done
   ; ===================== Round = 2 ==================
feistel_loop_L8_R2_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len8_k1
    
    ; Round 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len8_k1
    bra feistel_done
; ========================  Round = 3 ==================
feistel_loop_L8_R3_K1:
    lfsr    0, PlaintextArray    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray1   ; FSR2 -> CiphertextArray (Output)

    call len8_k1
    
    ; ROUND 2
    lfsr    0, CiphertextArray1    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray2   ; FSR2 -> CiphertextArray (Output)

    call len8_k1
    
    ; ROUND 3
    lfsr    0, CiphertextArray2    ; FSR0 -> PlaintextArray (Left Half)
    lfsr    1, KeyArray          ; FSR1 -> KeyArray
    lfsr    2, CiphertextArray   ; FSR2 -> CiphertextArray (Output)

    call len8_k1
    bra feistel_done
;                               Algorithms
    
; =========================== Length = 2, Key = 1 ===========================
pt_len2:
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
    
    return

; ==================== Length = 4, Key = 1 ==================
len4_k1:
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
    
    return 
    
; ==================== Lenght = 4, Key = 2 ==================
len4_k2:
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
    
    return 
    
   ; =========================== Lenght=6, Key = 1 ==================
len6_k1:
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
    
    movf    char_4, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_5, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_6, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
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
    
    return
; =========================== Lenght=6, Key = 3 ==================
len6_k3:
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
    
    return 
    
; =========================== Lenght = 8, Key = 1 ==================
len8_k1:
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
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_7, A         ; Store     
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_8, A 
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A    

    movf    char_5, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_6, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_7, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_3, W, A      ; New Right = L xor F(R, Key)
    movwf   char_3, A
    
    movf    char_8, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_4, W, A      ; New Right = L xor F(R, Key)
    movwf   char_4, A
    
    movf    char_5, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_6, W, A
    movwf   POSTINC2, A
    movf    char_7, W, A
    movwf   POSTINC2, A
    movf    char_8, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    movf    char_2, W, A
    movwf   POSTINC2, A
    movf    char_3, W, A
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    return 
    
 ; =========================== Lenght = 8, Key = 4 ==================
len8_k4:
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
    movf    POSTINC0, W, A       ; Load pt char 3
    movwf   char_7, A         ; Store    
    movf    POSTINC0, W, A       ; Load pt char 4
    movwf   char_8, A 
    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_1, A    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_2, A    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_3, A    
    movf    POSTINC1, W, A       ; Load Key
    movwf   key_4, A
    
    movf    char_5, W, A
    xorwf   key_1, W, A         ; F(R, Key) = R xor Key
    xorwf   char_1, W, A      ; New Right = L xor F(R, Key)
    movwf   char_1, A
    
    movf    char_6, W, A
    xorwf   key_2, W, A         ; F(R, Key) = R xor Key
    xorwf   char_2, W, A      ; New Right = L xor F(R, Key)
    movwf   char_2, A
    
    movf    char_7, W, A
    xorwf   key_3, W, A         ; F(R, Key) = R xor Key
    xorwf   char_3, W, A      ; New Right = L xor F(R, Key)
    movwf   char_3, A
    
    movf    char_8, W, A
    xorwf   key_4, W, A         ; F(R, Key) = R xor Key
    xorwf   char_4, W, A      ; New Right = L xor F(R, Key)
    movwf   char_4, A
    
    movf    char_5, W, A     ; Move Old R to be the new Left
    movwf   POSTINC2, A
    movf    char_6, W, A
    movwf   POSTINC2, A
    movf    char_7, W, A
    movwf   POSTINC2, A
    movf    char_8, W, A
    movwf   POSTINC2, A
    
    movf    char_1, W, A
    movwf   POSTINC2, A          ; Store New Right in CiphertextArray
    movf    char_2, W, A
    movwf   POSTINC2, A
    movf    char_3, W, A
    movwf   POSTINC2, A
    movf    char_4, W, A
    movwf   POSTINC2, A
    
    return 