; Copyright (C) 2024 iProgramInCpp


; NOTE: this only covers a range of PI/4.
; Each table is 32 items in size.
sintable:	.byte 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,59,62,65,67,70,73,75,78,80,82,85,87,89,91,94,96,98,100,102,103,105,107,108,110,112,113,114,116,117,118,119,120,121,122,123,123,124,125,125,126,126,126,126,126,127

; ** SUBROUTINE: sine
; desc: Calculates the sine for an angle.
; parameters: A - Angle in 1/256 Full Rotations
; note: clobbers X, temp5
; note: Flags match the current state of A.
.proc sine
	cmp #65
	bcs notFirstQuarter
	tax
	
	; between 0 and PI/4, straightforward - take the small side of a triangle in the first 8th
	lda sintable, x
	rts
	
notFirstQuarter:
	; maybe it's the second half
	cmp #128
	bcs notFirstHalf
	
	; between PI/4 and PI/2, take the first quarter but mirrored
	and #63
	sta temp5
	lda #64
	sec
	sbc temp5
	tax
	lda sintable, x
	rts

notFirstHalf:
	; between PI and 2PI, it's actually the first half but upside down.
	and #$7F
	jsr sine
	
	; not done yet! we need to flip the sine now
	sta temp5
	lda #0
	sec
	sbc temp5
	rts
.endproc

; ** SUBROUTINE: cosine
; desc: Calculates the cosine for an angle.
; note: See sine for a description of parameters and clobbers.
.proc cosine
	clc
	adc #64
	jmp sine
.endproc

; ** SUBROUTINE: mul_8x8
; desc:       Multiplies two 8 bit numbers.
; clobbers:   temp1, temp2
; parameters: A - factor 1, Y - factor 2
; returns:    A - low 8 bits, Y - high 8 bits
; clobbers:   temp1, temp2, Y reg
; credits:    https://www.nesdev.org/wiki/8-bit_Multiply#tepples_unrolled
.proc mul_8x8
@productLow = temp1
@factor2    = temp2
	lsr
	sta @productLow
	tya
	beq return
	dey
	sty @factor2
	lda #0
.repeat 8, i
	.if i > 0
		ror @productLow
	.endif
	bcc :+
	adc @factor2
:	ror
.endrepeat
	tay
	lda @productLow
	ror
return:
	rts
.endproc
