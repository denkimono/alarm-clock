
; on strt D_DIV=divisor, D_NUM=numerator
; on exit D_MOD=modulus, D_NUM=remainder
DIV
	CLRF	D_MOD
	MOVF	D_DIV,W
LOOP_DIV
	SUBWF	D_NUM,F
	BTFSC	STATUS,C
	GOTO	LD1

	MOVFW	D_DIV
	ADDWF	D_NUM,F
	
	RETURN
LD1

;	BTFSC	STATUS,Z
;	RETURN

	INCF 	D_MOD,F
	GOTO	LOOP_DIV

; on strt D_MOD=M1, D_NUM=M2
; on exit W=M1*M2

MUL
	CLRW
MUL1
	ADDWF	D_MOD,W
	DECF	D_NUM,F
	BTFSC	STATUS,Z
	RETURN
	GOTO	MUL1
	
