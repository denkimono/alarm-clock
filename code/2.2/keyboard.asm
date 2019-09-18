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



SCAN_KEYBOARD

	; COPY ROW VALUE
	MOVFW	PORTB
	MOVWF	ICOUNTER

	CLRF	ITEMP1
	BTFSS	ICOUNTER,KB_ROW1
	INCF	ITEMP1,F

	BTFSS	ICOUNTER,KB_ROW2
	INCF	ITEMP1,F

	BTFSS	ICOUNTER,KB_ROW3
	INCF	ITEMP1,F

	BTFSS	ICOUNTER,KB_ROW4
	INCF	ITEMP1,F

	; DETECT NO KEY PRESSED
	; DETECT MULTIPLE KEYS PRESSED
	DECF	ITEMP1,F
	BTFSS	STATUS,Z
	GOTO	SK2

	; GET ROW VALUE
	; ONLY ONE BIT IS SET NOW
	BTFSS	ICOUNTER,KB_ROW1
	MOVLW	0

	BTFSS	ICOUNTER,KB_ROW2
	MOVLW	1

	BTFSS	ICOUNTER,KB_ROW3
	MOVLW	2

	BTFSS	ICOUNTER,KB_ROW4
	MOVLW	3

	; W NOW CONTAINS THE ROW NUMBER 0-3
	MOVWF	ITEMP1

	MOVFW	KEY_COL
	MOVWF	ICOUNTER
	RLF		ICOUNTER,F
	RLF		ICOUNTER,F
	MOVFW	ICOUNTER
	ANDLW	0X0C
	IORWF	ITEMP1,W

	; NOW LOOK UP THE KEY VALUE
	CALL	KEY_MAPPING
	
	; IF WE'VE ALREADY SEEN A KEY ON THIS PASS, REGISTER NO KEYS PRESSED
	; AND START SCANNING AGAIN
	BTFSC	TEMP_KEY,7
	GOTO	SK4

	MOVLF	TEMP_KEY,0XFF
	MOVLF	CURRENT_KEY,0XFF
	MOVLF	KEY_COL,0X02

	GOTO SK2

SK4
	MOVWF	TEMP_KEY
SK2

	; SELECT NEXT COLUMN
	BSF		PORTB,KB_COL1
	BSF		PORTB,KB_COL2
	BSF		PORTB,KB_COL3

	INCF	KEY_COL,F
	MOVFW	KEY_COL
	SUBLW	0X03
	BTFSS	STATUS,Z
	GOTO	SK3

	; END OF PASS, UPDATE GLOBAL KEY VARIABLE IF KEY REGISTERED
	MOVFW	TEMP_KEY
	MOVWF	CURRENT_KEY
	CLRF	KEY_COL
	MOVLF	TEMP_KEY,0XFF

SK3

	; ENERGISE CURRENT COLUMN
	MOVFW	KEY_COL
	BTFSC	STATUS,Z
	BCF		PORTB,KB_COL1
	
	BTFSC	KEY_COL,0
	BCF		PORTB,KB_COL2
	
	BTFSC	KEY_COL,1
	BCF		PORTB,KB_COL3	

	RETURN


; CHECK DIGIT AT CURSOR POSITION IS IN THE VALID RANGE
; FOR TIME AND ALARM SETTING
SET_DIGIT

	CASE	CURSOR,0X03
	GOTO	SD1
	
	MOVFW	CURSOR
	CALL	TIME_LIMITS

	GOTO SD2

SD1
	; VALIDATE HOUR UNITS DEPENDING ON HOUR TENS
	; GET HOUR VALUE
	MOVLW	DIG3
	MOVWF	FSR

	MOVLW	0X0A
	CASE	INDF,2
	MOVLW	0X04

SD2

	SUBWF	IN_KEY,W
	BTFSC	STATUS,C
	GOTO	SD3
	
	CALL ACCEPT_KEY
	RETURN

SD3	; INVALID CHARACTER
	MOVLW 0XFF
	RETURN