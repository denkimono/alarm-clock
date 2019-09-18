; Copyright (c) 2007 Mark Longstaff-Tyrrell All Rights Reserved.
; DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
;
; This code is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License version 3 only, as
; published by the Free Software Foundation.
;
;  This code is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this work.  If not, see <http://www.gnu.org/licenses/>.


; MULTIPLEXER INTERRUPT (100Hz)
MPX_INTERRUPT

	; DECREMENT 10ms TICK COUNTER
	; (NOT STRICTLY PART OF THE MULTIPLEXER!)
	DECF	SUBTICKS,F
	BTFSC	STATUS,Z
	CALL	ITICKS ; ITICKS IS IN INTERRUPTS.ASM

	; CLEAR BRIGHTNESS PWM COUNTER
	MOVLW	0X09
	SUBWF	FRAME_COUNT,W
	BTFSC	STATUS,Z
	CLRF	FRAME_COUNT

	; CHECK FOR LOW POWER MODE
	CASE	LP_MODE,1
	GOTO	LOW_POWER_MODE

	; EXTINGUISH DISPLAY
	BSF		PORTC,DIGIT7
	MOVLF	PORTA,0xFF

	; SELECT NEXT DIGIT (unless we're giving this digit some extra juice)
;	DECF	MPX_CYCLES,F
;	BTFSS	STATUS,Z
;	GOTO MPX_I7	

	INCF	MPX_DIGIT,F
	; CONTROL DISPLAY BRIGHTNESS
	INCF	FRAME_COUNT,F

MPX_I7

; SELECT BIT PATTERN FROM DISPLAY MEMORY
	MOVFW	MPX_DIGIT
	ADDLW	DIG1
	MOVWF	FSR
	MOVFW	INDF
	CALL	PTRN	; get bit pattern
	MOVWF	PORTC	; update segment drive
;

; ENABLE CURRENT DIGIT

	; set number of multiplexer cycles to hold this digit on for
	; to boos brightness of 5th digit which has different drive electronics
	; - fixing hardware with software :-S

;	MOVFW MPX_CYCLES
;	BTFSS STATUS,Z
;	GOTO	MPX_I0
;
;	MOVLF MPX_CYCLES,0x01
;	MOVLW 0x04
;	SUBWF MPX_DIGIT,W
;
;	BTFSS	STATUS,Z
;	GOTO	MPX_I0
;
;	MOVLF MPX_CYCLES,0x02

MPX_I0
	MOVLW	0X06
	SUBWF	MPX_DIGIT,W

	BTFSS	STATUS,Z
	GOTO	MPX_I1

; SELECT DIGIT 7 (PORT C)
	BCF	PORTC,DIGIT7
; MAKE NEXT INCREMENT EQUAL ZERO	
	MOVLF	MPX_DIGIT,0XFF

	GOTO	MPX_I2

; SELECT DIGITS 1-6 (PORT A)
MPX_I1

	; LOOK UP PORTA DIGIT SELECT VALUE FROM TABLE
	MOVFW	MPX_DIGIT
	CALL	DIGIT_LOOKUP

	XORLW	0xFF
	MOVWF	PORTA

MPX_I2

	; TURN THE DISPLAY OFF DEPENDING ON THE BRIGHTNESS
	; CHECK VALUE IS < 10
	MOVFW	BRIGHTNESS
	SUBWF	FRAME_COUNT,W
	BTFSC	STATUS,C
	GOTO	MPX_I6
	;FRAME_COUNT >= BRIGHTNESS

	; EXTINGUISH DISPLAY
	BSF	PORTC,DIGIT7
	MOVLF	PORTA,0xFF

MPX_I6
	BCF		INTCON,T0IF
	RETURN

LOW_POWER_MODE
	
;FLASH A COLON LED EVERY 3 SECONDS	

; on strt D_DIV=divisor, D_NUM=numerator
	MOVLF	D_DIV,D'3'
	MOVFW	C_SEC
	MOVWF	D_NUM
	CALL	DIV

; on exit D_MOD=modulus, D_NUM=remainder
	MOVFW	D_NUM
	BTFSS	STATUS,Z
	GOTO	LPM1


	CASENOT	ISECOND,D'1'
	GOTO	LPM1

	CASENOT	IHSECOND,D'1'
	GOTO	LPM1

	CASENOT	ITSECOND,D'1'
	GOTO	LPM1

	; MAKE THE LED DIMMER
	MOVLW	30
	SUBWF	FRAME_COUNT,W
	BTFSC	STATUS,C
	GOTO	LPM1

	; light the standby LED
	MOVLF 	PORTC,B'00111111'
	MOVLF	PORTA,0xFF
	GOTO	MPX_I6

LPM1
	; EXTINGUISH DISPLAY
	BSF		PORTC,DIGIT7
	MOVLF	PORTA,0xFF

	GOTO	MPX_I6











