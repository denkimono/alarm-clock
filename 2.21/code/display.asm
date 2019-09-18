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


UPDATE_DISPLAY

	; SWITCH MODE
	CASE MODE,MODE_CD
	CALL	CD_DISPLAY

	CASE MODE,MODE_TM
	CALL	TM_DISPLAY

	CASE MODE,MODE_AL
	CALL	AL_DISPLAY

	RETURN


; DISPLAY THE DECIMAL DIGIT IN 'W'
; AT POSITION 'INT_CURSOR'
SHOW_DIGIT
	MOVWF	D_NUM
	MOVLF	D_DIV,D'10'
	CALL	DIV

	MOVFF	FSR,INT_CURSOR
	MOVFF	INDF,D_MOD
	INCF	FSR,F
	MOVFF	INDF,D_NUM
	RETURN


; HOURS
CD_SHOW_HOUR

	MOVF	HOUR,F
	BTFSS	STATUS,Z
	GOTO	CD_SHO1
	RETURN
CD_SHO1
	DISPLAY HOUR,DIG1
	RETURN

; MINUTES
CD_SHOW_MIN

	MOVF	HOUR,F
	BTFSS	STATUS,Z
	GOTO	CD_SM1
	DISPLAY MIN,DIG1
	RETURN
CD_SM1
	DISPLAY MIN,DIG3
	RETURN

; SECONDS
CD_SHOW_SEC

	MOVF	HOUR,F
	BTFSS	STATUS,Z
	GOTO	CD_SS1
	DISPLAY SEC,DIG3
	RETURN
CD_SS1
	DISPLAY SEC,DIG5
	RETURN

; HUNDREDS
CD_SHOW_HUN
	MOVF	HOUR,F
	BTFSS	STATUS,Z
	GOTO	CD_SH1
	DISPLAY HUN,DIG5
CD_SH1
	RETURN

; display the entire countdown display
CD_DISPLAY


	BTFSC	MORE_FLAGS,FREEZE
	GOTO	FREEZE_COLONS;CD_COLONS	;RETURN ADDRESS ALREADY ON STACK

	CASE CD_MODE,CD_PAUSED
	GOTO	CD_D2

	CASE CD_MODE,CD_RUNNING
	GOTO	CD_D3

	RETURN

CD_D5
	MOVLW	COLONS
	MOVWF	DIG7
	GOTO	CD_D4

CD_D3
	CALL	CD_COLONS

CD_D4

	CALL	CD_SHOW_HOUR
	CALL	CD_SHOW_MIN
	CALL	CD_SHOW_SEC
	CALL	CD_SHOW_HUN

	RETURN

CD_D2

	; COLONS ON STEADY
	MOVLW	COLONS
	MOVWF	DIG7

	; IF COUNTDOWN ALARM IS SOUNDING THEN FLASH DISPLAY
	BTFSS	TICKS,CD_ALARM_ON
	RETURN

	BTFSC	TICKS,BUZZER_PHASE
	GOTO	CD_D4

	BTFSC	TICKS,TICKS_HSECOND
	GOTO	CD_D4

	MOVLF	DIG1,BLANK
	MOVLF	DIG2,BLANK
	MOVLF	DIG3,BLANK
	MOVLF	DIG4,BLANK
	MOVLF	DIG5,BLANK
	MOVLF	DIG6,BLANK

	RETURN

CD_COLONS
	; KEEP COLONS IN PHASE WITH COUNT
	; IF HUN IS >= 50 THEN COLONS ON

	; COLONS ARE 180 DEGREES OUT OF PHASE IN COUNT UP MODE

	BTFSS	MORE_FLAGS,UP_DOWN
	GOTO	CD_D7

; COLON CONTROL FOR COUNT DOWN
	MOVLW	D'50'
	SUBWF	HUN,W
	BTFSS	STATUS,C
	GOTO	CD_D6

	MOVLW	COLONS
	MOVWF	DIG7
	GOTO	CD_C1

CD_D6
	MOVLW	BLANK
	MOVWF	DIG7
	GOTO	CD_C1

; COLON CONTROL FOR COUNT UP
CD_D7
	MOVLW	D'50'
	SUBWF	HUN,W
	BTFSS	STATUS,C
	GOTO	CD_D8

	MOVLW	BLANK
	MOVWF	DIG7
	GOTO	CD_C1

CD_D8
	MOVLW	COLONS
	MOVWF	DIG7

CD_C1

	RETURN
	

TM_DISPLAY

	CASE	TM_MODE,TM_SET
	GOTO	TM_D1

	; UN-FREEZE DISPLAY IF 12-H MODE (FREEZE DOESN'T REALLY MAKE SENSE IN THIS MODE)
	BTFSS	MORE_FLAGS,MIL_MODE
	BCF		MORE_FLAGS,FREEZE

	; TIME FREEZE MODE
	BTFSC	MORE_FLAGS,FREEZE
	;RETURN
	GOTO	FREEZE_COLONS

	; COLONS
	MOVLW	COLON_12H
	BTFSC	MORE_FLAGS,MIL_MODE
	MOVLW	COLONS

	BTFSC	TICKS,TICKS_HSECOND
	MOVLW	BLANK
	MOVWF	DIG7


	; SNOOZE INDICATOR
	MOVF	SNOOZE_MINS,F
	BTFSC	STATUS,Z
	GOTO	TM_D2

	BTFSC	C_SEC,1
	GOTO	TM_D2

	; DISPLAY 'SNOOZE'
	MOVLF	DIG1,D'5'    ; 5
	MOVLF	DIG2,LETTER_N; N
	MOVLF	DIG3,D'0'    ; 0
	MOVLF	DIG4,D'0'    ; 0
	MOVLF	DIG5,D'2'    ; 2
	MOVLF	DIG6,LETTER_E; E

	RETURN	

TM_D2

	; MINS
	MOVFF	D_NUM,C_MIN
	MOVLF	D_DIV,D'10'
	CALL	DIV
	MOVFF	DIG3,D_MOD
	MOVFF	DIG4,D_NUM

	BTFSC	MORE_FLAGS,MIL_MODE
	GOTO	TM_D3

	; 12 HOUR DISPLAY

	; IF HOURS > 12 THEN DISPLAY HOURS-12
	MOVLW	D'12'
	SUBWF	C_HOUR,W
	BTFSC	STATUS,C
	GOTO	TM_D4
	MOVFW	C_HOUR

TM_D4

	; CATCH 24 O'CLOCK (12 AM)
	ANDLW	0XFF 
	BTFSC	STATUS,Z
	MOVLW	D'12'

	MOVWF	D_NUM
	MOVLF	D_DIV,D'10'
	CALL	DIV
	MOVFW	D_MOD

	; SUPPRESS LEADING ZERO
	BTFSC	STATUS,Z
	MOVLW	BLANK
	
	MOVWF	DIG1
	MOVFF	DIG2,D_NUM

	MOVLF	DIG5,BLANK

	; DISPLAY AM OR PM
	MOVFW	C_HOUR 
	SUBLW	D'11'
	BTFSS	STATUS,C
	GOTO	TM_D5
	MOVLF	DIG6,LETTER_A
	RETURN
TM_D5
	MOVLF	DIG6,LETTER_P
	RETURN


; 24 HOUR DISPLAY
TM_D3
	; HOURS
	MOVFF	D_NUM,C_HOUR
	MOVLF	D_DIV,D'10'
	CALL	DIV
	MOVFF	DIG1,D_MOD
	MOVFF	DIG2,D_NUM

	; SECS
	MOVFF	D_NUM,C_SEC
	MOVLF	D_DIV,D'10'
	CALL	DIV
	MOVFF	DIG5,D_MOD
	MOVFF	DIG6,D_NUM
	RETURN


TM_D1
	;FLASH CURRENT CURSOR POSITION

	; CALCULATE ADDRESS IN DISPLAY MEMORY
	MOVFW	CURSOR
	ADDLW	DIG1
	MOVWF	FSR

	MOVLW	UNDERSCORE
	BTFSS	TICKS,TICKS_HSECOND
	MOVLW	BLANK

	MOVWF	INDF

	RETURN


AL_DISPLAY

	CASE AL_MODE,AL_VER
	GOTO	AL_D1; SHOWING VERSION NUMBER


	; COLONS ON STEADY
	MOVLW	SET_COLON
	MOVWF	DIG7

	MOVLF	DIG1,LETTER_A
	MOVLF	DIG2,LETTER_L

	CASE AL_MODE,AL_SET
	GOTO	TM_D1; REUSE CODE FOR TIME DISPLAY

	; CHECK IF ALARM IS CANCELLED (INVALID ALARM VALUES)
	CASE	A_HOUR,0XFF
	GOTO	AL_D2

	; HOURS
	MOVFF	D_NUM,A_HOUR
	MOVLF	D_DIV,D'10'
	CALL	DIV
	MOVFF	DIG3,D_MOD
	MOVFF	DIG4,D_NUM

	; MINS
	MOVFF	D_NUM,A_MIN
	MOVLF	D_DIV,D'10'
	CALL	DIV
	MOVFF	DIG5,D_MOD
	MOVFF	DIG6,D_NUM

AL_D1
	RETURN


AL_D2
	MOVLF	DIG3,DASH
	MOVLF	DIG4,DASH
	MOVLF	DIG5,DASH
	MOVLF	DIG6,DASH
	RETURN


; PUT CURRENT KEY ON DISPLAY AT CURSOR POSITION
ACCEPT_KEY
	MOVFW	CURSOR
	ADDLW	DIG1
	MOVWF	FSR

	MOVFW	IN_KEY
	MOVWF	INDF
	
	; MOVE CURSOR
	INCF CURSOR,F
	MOVLW D'6'
	SUBWF CURSOR,W

	RETURN

; display freeze mode colons
; sync with main 500ms ticks (phase isn't really important when display is static)
FREEZE_COLONS

	MOVLW	COLON_TOP
	BTFSS	TICKS,TICKS_HSECOND
	MOVLW	COLON_BOT

	MOVWF	DIG7
	RETURN

