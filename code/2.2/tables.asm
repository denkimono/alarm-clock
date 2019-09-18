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

; KEYBOARD MAPPING

KEY_MAPPING	ADDWF   PCL,F
;	XXXX CC RR

;COLUMN 1
		RETLW	1
		RETLW	4
		RETLW	7
		RETLW	BARS

;COLUMN 2
		RETLW	2
		RETLW	5
		RETLW	8
		RETLW	0

;COLUMN 3
		RETLW	3
		RETLW	6
		RETLW	9
		RETLW	UNDERSCORE

	IF SYSTEM_VERSION == PROTOTYPE_1
 
; LED bit patterns (1st prototype - veroboard)
PTRN	ADDWF   PCL,F
;                 xGFEDCBA
		RETLW	B'01000000'	; '0'
		RETLW	B'01111001'	; '1'
		RETLW	B'00100100'	; '2'
		RETLW	B'00110000'	; '3'
		RETLW	B'00011001'	; '4'
		RETLW	B'00010010'	; '5'
		RETLW	B'00000010'	; '6'
		RETLW	B'01111000'	; '7'
		RETLW	B'00000000'	; '8'
		RETLW	B'00010000'	; '9'
		RETLW	B'01111111'	; BLANK (A)
		RETLW	B'01110000'	; COLONS(B)
		RETLW	B'01110011'	; DOTS  (C)
		RETLW	B'00111111'	; DASH  (D)
		RETLW	B'01110111'	; UNDERSCORE  (E)
		RETLW	B'00110110'	; BARS  (F)
		RETLW	B'00110111'	; EQUALS  (10)
		RETLW	B'00000111'	; 'T' (11)
		RETLW	B'00000110'	; 'E' (12)
		RETLW	B'00000011'	; COLONS FOR TIME/ALARM SETTING (13)
		RETLW	B'00001000'	; 'A' (14)
		RETLW	B'01000111'	; 'L' (15)
		RETLW	B'01001000'	; 'N' (16)
		RETLW	B'00001100'	; 'P' (17)
;		RETLW	B'01001110'	; 'R' (18)
		RETLW	B'00101111'	; 'R' (18)
		RETLW	B'01111000'	; COLONS FOR S/W VERSION (19)
		RETLW	B'01111100'	; COLONS FOR 12 HOUR MODE (1A)
		RETLW	B'01110110' ; FREEZE MODE COLONS TOP (1B)
		RETLW	B'01111001' ; FREEZE MODE COLONS BOTTOM (1C)
		RETLW	B'01111111'	; ALL OFF
	ELSE

; LED bit patterns (PCB versions)
PTRN	ADDWF   PCL,F
;                 xABCDEFG
		RETLW	B'10000001'	; '0'
		RETLW	B'11001111'	; '1'
		RETLW	B'10010010'	; '2'
		RETLW	B'10000110'	; '3'
		RETLW	B'11001100'	; '4'
		RETLW	B'10100100'	; '5'
		RETLW	B'10100000'	; '6'
		RETLW	B'10001111'	; '7'
		RETLW	B'10000000'	; '8'
		RETLW	B'10000100'	; '9'
		RETLW	B'11111111'	; BLANK (A)
		RETLW	B'10000111'	; COLONS(B)
		RETLW	B'11100111'	; DOTS  (C)
		RETLW	B'11111110'	; DASH  (D)
		RETLW	B'11110111'	; UNDERSCORE  (E)
		RETLW	B'10110110'	; BARS  (F)
		RETLW	B'11110110'	; EQUALS  (10)
		RETLW	B'11110000'	; 'T' (11)
		RETLW	B'10110000'	; 'E' (12)
		RETLW	B'11010000'	; COLONS FOR TIME/ALARM SETTING (13)
		RETLW	B'10001000'	; 'A' (14)
		RETLW	B'11110001'	; 'L' (15)
		RETLW	B'10001001'	; 'N' (16)
		RETLW	B'10011000'	; 'P' (17)
;		RETLW	B'10111001'	; 'R' (18) (tall 'R')
		RETLW	B'11111010'	; 'R' (18) (short 'R')
		RETLW	B'10100111'	; COLONS FOR S/W VERSION (19)
		RETLW	B'10101111'	; COLONS FOR 24H CLOCK (1A)
		RETLW	B'11100111' ; FREEZE MODE COLONS TOP (1B)
		RETLW	B'10011111' ; FREEZE MODE COLONS BOTTOM (1C)
		RETLW	B'11111111'	; ALL OFF
	ENDIF


; RETURN THE MAX VALUES+1 FOR TIMES AT EACH CURSOR POSITION
TIME_LIMITS
		ADDWF   PCL,F

		RETLW	D'0'	; DUMMY VALUE
		RETLW	D'0'	; DUMMY VALUE
		RETLW	D'3'	; 2
		RETLW	D'4'	; 3
		RETLW	D'6'	; 5
		RETLW	D'10'	; 9

; TODO: XOR this lot & remove XOR in multiplexer.asm
DIGIT_LOOKUP
		ADDWF   PCL,F
		RETLW	20	; PIN 6
		RETLW	08	; PIN 4
		RETLW	04	; PIN 3
		RETLW	02	; PIN 2
		RETLW	10	; PIN 5
		RETLW	01	; PIN 1
