; Copyright (C) 2024 iProgramInCpp


; NOTE: this only covers a range of PI/4.
; Each table is 32 items in size.
sintable:	.byte 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,59,62,65,67,70,73,75,78,80,82,85,87
costable:	.byte 127,126,126,126,126,126,125,125,124,123,123,122,121,120,119,118,117,116,114,113,112,110,108,107,105,103,102,100,98,96,94,91

; ** SUBROUTINE: sine
; desc: Calculates the sine for an angle.
; parameters: A - Angle in 1/256 Full Rotations
; note: clobbers X, temp5
.proc sine
	cmp #32
	bcs notFirstEighth
	tax
	
	; between 0 and PI/4, straightforward - take the small side of a triangle in the first 8th
	lda sintable, x
	rts
	
notFirstEighth:
	sta temp5
	sbc #32
	cmp #32
	bcs notSecondEighth
	
	; between PI/4 and PI/2 - take the big side of a triangle in the first 8th, with the angle (PI/2 - Angle)
	sta temp5
	lda #31
	sec
	sbc temp5
	tax
	lda costable, x
	rts

notSecondEighth:
	; between PI/2 and PI, it's actually just the same but mirrored
	sbc #32
	cmp #64
	bcs notSecondQuadrant ; third and fourth 8ths
	
	sta temp5
	lda #63
	sec
	sbc temp5
	jmp sine              ; jump back to start and calculate the first quadrant's result

notSecondQuadrant:
	; between PI and 2PI, it's actually the 2s complement of the other sine
	lda #0
	sec
	sbc temp5
	cmp #$80
	bne :+
	lda #$00
:	jsr sine
	
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

; Well, here it is, if you need it.
.if 0

; ** SUBROUTINE: mul_8x8
; desc:       Multiplies two 8 bit numbers.
; clobbers:   temp1, temp2
; parameters: A - factor 1, Y - factor 2
; returns:    A - low 8 bits, Y - high 8 bits
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

.endif
