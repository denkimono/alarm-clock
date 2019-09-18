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


INITIALISE

	; configure pull-ups/interrups edge config/clock prescaler
	BSF     STATUS,RP0              ; BANK 1
	CLRF	OPTION_REG
	BCF		OPTION_REG,T0CS

	BCF		OPTION_REG,PS2
	BCF		OPTION_REG,PS1
	BCF		OPTION_REG,PS0

	BCF		OPTION_REG,NOT_RBPU

	; configure I/O pins

	BSF     STATUS,RP0              ; BANK 1
	MOVLW   B'00000000'             ; Set Port A I/O pins
	MOVWF	TRISA

	MOVLW   B'11110000'             ; Set Port B I/O pins
	MOVWF	TRISB

	MOVLW   B'0000000'             ; Set Port C I/O pins
	MOVWF	TRISC
	;

	;CONFIGURE TIMER 2
    BCF     STATUS,RP0              ; BANK 0
	CLRF	T2CON
	BSF		T2CON,TMR2ON

	BCF		T2CON,TOUTPS3
	BCF		T2CON,TOUTPS2
	BCF		T2CON,TOUTPS1
	BSF		T2CON,TOUTPS0

	BCF		T2CON,T2CKPS1
	BCF		T2CON,T2CKPS0

	; CONFIGURE PERIPHERAL INTERRUPTS
	BSF     STATUS,RP0              ; BANK 1
	CLRF	PIE1
	BSF		PIE1,TMR2IE 			; TIMER 2 INTERRUPT
	;	

	; configure interrupts
	BCF     STATUS,RP0              ; BANK 0
	CLRF	INTCON	                
	BSF		INTCON,T0IE			; interrupt on TMR0

    BCF     STATUS,RP0              ; BANK 0

    CLRF    PORTA                   ; clear port a
    CLRF    PORTB                   ; clear port b
    CLRF    PORTC                   ; clear port c

	CLRF	MPX_DIGIT
	CLRF	COUNTER

	; INIT TIMER VARIABLES
	MOVLF	SUBTICKS,SUBTICK_COUNT
	MOVLF	ITSECOND,TSECOND_COUNT
	MOVLF	IHSECOND,HSECOND_COUNT
	MOVLF	ISECOND,SECOUND_COUNT

	; KEYBOARD COLUMN SCAN VARIABLES ETC
	CLRF	KEY_COL
	CLRF	KEY_COUNT
	MOVLF	CURRENT_KEY,0XFF
	MOVLF	TEMP_KEY,0XFF
	MOVLF	LAST_KEY,0XFF
	MOVLF	IN_KEY,BLANK


	; INIT TIME ETC

	CLRF	TICKS

	; countdowm timer values
	CLRF	HOUR
	CLRF	MIN
	CLRF	SEC
	CLRF	HUN
	
	; clock values
	MOVLF	C_HOUR,D'12'
	CLRF	C_MIN
	CLRF	C_SEC
	
	; alarm values
	MOVLF	A_HOUR,0XFF
	MOVLF	A_MIN,0XFF
	

	; INIT MODES
	MOVLF	MODE,MODE_CD
	CLRF	CD_MODE
	CLRF	TM_MODE
	CLRF	AL_MODE

	CLRF	SNOOZE_MINS
	CLRF	MORE_FLAGS
	CLRF	LP_MODE
	BSF		MORE_FLAGS,MIL_MODE; start in 24 hour mode

	; PUT VALID VALUES IN DISPLAY MEMORY BEFORE STARTING MULTIPLEXER!
	; 00:00:00
	MOVLW	0X00
	MOVWF	DIG1
	MOVWF	DIG2
	MOVWF	DIG3
	MOVWF	DIG4
	MOVWF	DIG5
	MOVWF	DIG6
	MOVLF	DIG7,COLONS

	CLRF	BRIGHTNESS
	CLRF	FRAME_COUNT

	; SET TIMER 2 PERIOD REGISTER
	BSF     STATUS,RP0              ; BANK 1
	MOVLW	0X1F
	MOVWF	PR2

	;ENABLE TIMER 2
    BCF     STATUS,RP0              ; BANK 0

	BUZZER_OFF
	
	CALL UPDATE_DISPLAY

; ENABLE INTERRUPTS
	BSF		INTCON,GIE

	RETURN
