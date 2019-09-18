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


	include "P16f72.inc"
	include "system.inc"
	include "macros.inc"

;---------------------------------------------------------

; reset vector
	ORG     0X00

    GOTO    START

; interrupt vector
	ORG     0X04
	GOTO    INT

;---------------------------------------------------------

	include "initialise.asm"
	include "tables.asm"
	include "maths.asm"
	include "interrupts.asm"
	include "display.asm"
	include "keyboard.asm"
	include "multiplexer.asm"
	include "delay.asm"
	include "clock.asm"
	include "alarm.asm"
	include "countdown.asm"



;***********************
START

	; SET UP THE SYSTEM
	CALL	INITIALISE

; Main program loop
MAIN

	; UPDATE THE DISPLAY MEMORY 
	BTFSS	TICKS,DISPLAY_INT
	GOTO	M3

	CALL	UPDATE_DISPLAY
	BCF		TICKS,DISPLAY_INT

M3

	; CHECK FOR A KEYPRESS
	; NOTE 'CURRENT_KEY' MIGHT CHANGE AT ANY TIME
	; SO COPY IT
	MOVFF	IN_KEY,CURRENT_KEY
	BTFSC	IN_KEY,7
	GOTO	M1

	; IF KEY HAS CHANGED (PREVENT ROLLOVER)
	MOVFW	LAST_KEY
	SUBWF	IN_KEY,W
	BTFSC	STATUS,Z
	GOTO	M2

	MOVFF	LAST_KEY,IN_KEY
	CLRF	KEY_COUNT

	; HANDLE TIME GLIMPSE IN LP MODE
	CASE	LP_MODE,0
	GOTO	M8

	; DISPLAY TIME FOR A COUPLE OF SECONDS IF A KEY IS PRESSED
	CASE	LP_MODE,1
	INCF	LP_MODE,F

	GOTO	MAIN
M8

	; MAKE KEYSOUND
	KEYSOUND

	; CANCEL ALARMS/SET SNOOZE
	MOVFW	TICKS
	ANDLW	B'00001100'; IF ALARM IS SOUNDING
	BTFSC	STATUS,Z
	GOTO	M4

	CASE IN_KEY,MODE_KEY
	GOTO	M5	
M6
	; restore display if we're cancelling countdown alarm
	BTFSC	TICKS,CD_ALARM_ON	
	CALL	CD_D4

	CLRF	SNOOZE_MINS
	BCF		TICKS,TM_ALARM_ON
	BCF		TICKS,CD_ALARM_ON
	CLRF	BUZZER_COUNT

	GOTO MAIN

M5	; STOP ALARM, SET SNOOZE MODE
	BTFSS	TICKS,TM_ALARM_ON
	GOTO	M6
	MOVLF	SNOOZE_MINS,SNOOZE_DURATION
	BCF		TICKS,TM_ALARM_ON
	CLRF	BUZZER_COUNT
	GOTO	MAIN

M4

	CASE IN_KEY,MODE_KEY
	GOTO	CANCEL_SNOOZE

M7
	CASE IN_KEY,MODE_KEY
	GOTO	CHANGE_MODE

	; SWITCH MODE
	CASE MODE,MODE_CD
	CALL	CD_KEYPRESSED

	CASE MODE,MODE_TM
	CALL	TM_KEYPRESSED

	CASE MODE,MODE_AL
	CALL	AL_KEYPRESSED
	GOTO MAIN


; NO KEY PRESSED
M1
	; CLEAR LAST KEYPRESS
	MOVLF	LAST_KEY,0XFF
	GOTO MAIN

M2
	CASE KEY_COUNT,LONG_KEY
	GOTO LONG_KEYPRESS
	GOTO MAIN


LONG_KEYPRESS

	CLRF	KEY_COUNT

	; UN-FREEZE DISPLAY
	BCF	MORE_FLAGS,FREEZE

	; MAKE KEYSOUND
	KEYSOUND

	; SWITCH MODE
	CASE MODE,MODE_CD
	CALL	CD_LONGKEYPRESSED

	CASE MODE,MODE_TM
	CALL	TM_LONGKEYPRESSED

	CASE MODE,MODE_AL
	CALL	AL_LONGKEYPRESSED

	GOTO MAIN


CHANGE_MODE

	; UN-FREEZE DISPLAY
	BCF	MORE_FLAGS,FREEZE

	CASE	MODE,MODE_TM
	GOTO	CM3
CM4
	; RESET MODES WITH SUBMODES
	CLRF	TM_MODE
	CLRF	AL_MODE

CM2
	INCF	MODE,F
	CASE MODE,MAX_MODE
	CLRF	MODE

; CALL MODECHANGED...
	CALL MODECHANGED

	GOTO MAIN

CM3
	; 12/24 HOUR MODE CHANGE

	; WHEN MODE IS PRESSED DURING TIME SET
	CASE	TM_MODE,TM_TIME
	GOTO	CM4

	; TOGGLE 12/24 HOUR MODE
	TOGGLEBIT MORE_FLAGS,MIL_MODE

	; CLEAR TIME SET MODE
	CLRF	TM_MODE
	GOTO	MAIN

MODECHANGED
; INFORM MODES THAT THE MODE HAS CHANGED
	CASE MODE,MODE_CD
	CALL	CD_MODECHANGED
	RETURN

CANCEL_SNOOZE	; CANCEL SNOOZE MODE
	MOVF	SNOOZE_MINS,F
	BTFSC	STATUS,Z
	GOTO	M7
	CLRF	SNOOZE_MINS
	GOTO	MAIN

	END
