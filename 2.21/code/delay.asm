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

