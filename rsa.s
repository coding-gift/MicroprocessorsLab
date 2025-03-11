#include <xc.inc>

global initialise_rsa, n_val, phi_val, p_val, q_val, e_val

psect	udata_acs   ; named variables in access ram
    p_val:	    ds 1
    q_val:	    ds 1
    n_val:	    ds 1	; n=p*q
    phi_val:	    ds 1	; phi = (p-1)*(q-1)
    e_val:	    ds 1
    temp_maths1:    ds 1
    temp_maths2:    ds 1
    one:	    ds 1
    
	psect   rsa_code, class=CODE    
initialise_rsa:
    movlw 0x05
    movwf p_val, A    ; load p

    movlw 0x07
    movwf q_val, A    ; load q
    
    movlw 0x0B		; 11
    movwf e_val, A	; load e

    ; Calculate n = p * q
    movf p_val, W, A  ; Move p_val into WREG
    mulwf q_val, A    ; Multiply WREG (p) by q_val
    movff PRODL, n_val, A   ; Store n = p * q

    ; Calculate p-1
    movlw 0x01
    subwf p_val, W, A  ; W = p_val - 1
    movwf temp_maths1, A

    ; Calculate q-1
    movlw 0x01
    subwf q_val, W, A  ; W = q_val - 1
    movwf temp_maths2, A

    ; Calculate phi = (p-1) * (q-1)
    movf temp_maths1, W, A
    mulwf temp_maths2, A
    movff PRODL, phi_val, A  ; Store phi = (p-1) * (q-1)

    return
