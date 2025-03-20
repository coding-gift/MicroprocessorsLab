#include <xc.inc>
    
global calc_remainder, mult_extended, ARG1L, ARG1H, ARG2L, ARG2H, RES0, RES1, RES2, RES3
extrn val_low, val_middle, val_high, n_val_low, n_val_high

psect	udata_acs    
ARG1L:	    ds	1
ARG1H:	    ds	1
ARG2L:	    ds	1
ARG2H:	    ds	1
RES0:	    ds	1
RES1:	    ds	1
RES2:	    ds	1
RES3:	    ds	1    
    
psect maths_code, class=CODE
  

calc_remainder:
    call subtract
    bc calc_remainder   ; Continue if borrow is clear (val >= n_val)

    ; If we exit loop, add n_val back to restore correct remainder
    movf n_val_low, W, A
    addwf val_low, f, A
    movf n_val_high, W, A
    addwfc val_middle, f, A  ; Carry propagates to middle byte
    clrf WREG, A
    addwfc val_high, f, A     ; Carry propagates to high byte
    return 

subtract:	; Subtract the two-byte n_val from the three-byte val
    movf n_val_low, W, A
    subwf val_low, f, A
    movf n_val_high, W, A
    subwfb val_middle, f, A  ; Borrow propagates to middle byte
    clrf WREG, A
    subwfb val_high, f, A    ; Borrow propagates to high byte
    return

mult_extended:
    MOVF ARG1L, W, A
    MULWF ARG2L, A ; ARG1L * ARG2L->
    ; PRODH:PRODL
    MOVFF PRODH, RES1 ;
    MOVFF PRODL, RES0 ;
    ;
    MOVF ARG1H, W, A
    MULWF ARG2H, A ; ARG1H * ARG2H->
    ; PRODH:PRODL
    MOVFF PRODH, RES3 ;
    MOVFF PRODL, RES2 ;
    ;
    MOVF ARG1L, W, A
    MULWF ARG2H, A ; ARG1L * ARG2H->
    ; PRODH:PRODL
    MOVF PRODL, W, A ;
    ADDWF RES1, F, A ; Add cross
    MOVF PRODH, W, A ; products
    ADDWFC RES2, F, A ;
    CLRF WREG, A ;
    ADDWFC RES3, F, A ;
    ;
    MOVF ARG1H, W, A ;
    MULWF ARG2L, A ; ARG1H * ARG2L->
    ; PRODH:PRODL
    MOVF PRODL, W, A ;
    ADDWF RES1, F, A ; Add cross
    MOVF PRODH, W, A ; products
    ADDWFC RES2, F, A ;
    CLRF WREG, A ;
    ADDWFC RES3, F, A ;
    RETURN



