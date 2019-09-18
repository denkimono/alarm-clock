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


; A IS REGISTER, B IS LITERAL
; ZERO FLAG SET IF A==B
IFEQU	MACRO A,B
		MOVLW	B
		SUBWF	A,W
		ENDM

;------------------
MOVLF MACRO REG,VAL
	MOVLW VAL
	MOVWF REG
	ENDM
;------------------

CASE:	MACRO	REG,STATE
	MOVLW	STATE
	SUBWF	REG,W
	BTFSC	STATUS,Z
	ENDM

CASENOT:	MACRO	REG,STATE
	MOVLW	STATE
	SUBWF	REG,W
	BTFSS	STATUS,Z
	ENDM

; MOVE REG2 TO REG1
MOVFF	MACRO	REG1,REG2
	MOVFW	REG2
	MOVWF	REG1
	ENDM

DISPLAY	MACRO VALUE,POS
	MOVLF	INT_CURSOR,POS
	MOVFW	VALUE
	CALL	SHOW_DIGIT
	ENDM

KEYSOUND	MACRO
	BCF		MORE_FLAGS,TICKING
	MOVLF	BUZZER_COUNT,0X30 ;0X1F
	BSF		TICKS,KEYBEEP
	ENDM

TICKSOUND	MACRO
	BSF		MORE_FLAGS,TICKING
	MOVLF	BUZZER_COUNT,0X20 ;0X1F
	BSF		TICKS,KEYBEEP
	ENDM

TOGGLEBIT	MACRO	REG,BIT
	CLRF	TEMP1
	BSF		TEMP1,BIT
	MOVFW	TEMP1
	XORWF	REG,F	
	ENDM

; 1ST PCB VERSION HAD THE BUZZER CONNECTED TO VCC
; OTHERS ARE CONNECTED TO GND

BUZZER_OFF	MACRO
	IF SYSTEM_VERSION == PROTOTYPE_2
		BSF	PORTB,BUZZER
	ELSE
		BCF	PORTB,BUZZER
	ENDIF
	ENDM

BUZZER_ON	MACRO
	IF SYSTEM_VERSION == PROTOTYPE_2
		BCF	PORTB,BUZZER
	ELSE
		BSF	PORTB,BUZZER
	ENDIF
	ENDM

