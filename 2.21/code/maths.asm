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
	
