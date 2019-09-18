; ~10uS delay ----------------------------------------------------------

; loop is ((20*TEMP1)+1) cycles (TEMP1>=1)

; clock is 1.024 ips (~1us)
DLY10US:NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		DECFSZ	PTEMP1,F
		GOTO	DLY10US
		RETURN
;---------------------------------------------------------------------

;***** PAUSE MACRO  - Delays for ((DLYF*20)+5) cycles (DLYF>=1) *****
; 5 cycle overhead on this routine

; clock is 1.024 ips

PAUSE	MACRO	DLYF
		MOVLW	DLYF
		MOVWF	PTEMP1
		CALL	DLY10US
		ENDM

;***********************

; 10us * 255 * 196

;**** ~0.5s delay ******

P1SEC	MOVLW	D'196'
		MOVWF	PTEMP2

P1LOOP
		PAUSE	D'255'

		DECFSZ	PTEMP2,F
        GOTO    P1LOOP
		RETURN

