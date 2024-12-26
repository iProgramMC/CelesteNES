; Copyright (C) 2024 iProgramInCpp

; Things moved in from PRG_MAIN.


; ** SUBROUTINE: rand
; arguments: none
; clobbers:  a
; returns:   a - the pseudorandom number
; desc:      generates a pseudo random number
rand:
	lda rng_state
	asl
	bcc @no_feedback
	eor #$21
@no_feedback:
	sta rng_state
	lda rng_state
	rts

; ** SUBROUTINE: oam_putsprite
; arguments:
;   a - attributes
;   y - tile number
;   [x_crd_temp] - y position of sprite
;   [y_crd_temp] - y position of sprite
; clobbers:  a, y
; desc:      inserts a sprite into OAM memory
oam_putsprite:
	pha             ; preserve the attributes
	tya
	pha             ; preserve the tile number
	ldy oam_wrhead  ; load the write head into Y
	lda y_crd_temp  ; store the Y coordinate into OAM
	sta oam_buf, y
	iny             ; move on to the tile number byte
	pla
	; flip bit 1 because I am lazy and don't want to make every tile index be odd...
	eor #$01
	sta oam_buf, y  ; store the tile number into OAM
	iny
	pla
	sta oam_buf, y  ; store the attributes into OAM
	iny
	lda x_crd_temp
	sta oam_buf, y  ; store the X coordinate into OAM
	iny
	sty oam_wrhead
	rts

; ** SUBROUTINE: calc_approach
; desc: Approaches an 8-bit value towards another 8-bit value.
;
; parameters:
;     X - The index into the zero page of the value to update
;     Y - The value to add
;     A - The approached value
;
; note:
;     clobbers temp1, temp2
calc_approach:
@end = temp1
@add = temp2
	sta @end
	sty @add
	
	lda 0, x
	cmp @end
	bcs @startBiggerThanEnd
	
	; start < end
	; clc
	adc @add
	bcc :+
	lda @end   ; it overflew! so, just end
:	cmp @end
	bcc :+
	lda @end   ; start now >= end, load end
:	sta 0, x
	rts
	
@startBiggerThanEnd:
	; start >= end
	; sec
	sbc @end
	bcs :+
	lda @end   ; it underflew! so, just end
:	cmp @end
	bcs :+
	lda @end   ; start now < end, load end
:	sta 0, x
	rts

; ** SUBROUTINE: fade_once_color
; desc: Fades a color once.
.proc fade_once_color
	cmp #$10
	bcc justBlack
	
	cmp #$1D
	beq justBlack  ; special exception as we'd end up in $0D
	
	sec
	sbc #$10
	rts

justBlack:
	lda #$0F
	rts
.endproc

; ** SUBROUTINE: fade_twice_if_high
; desc: Fades twice if >= $30, fades once otherwise
.proc fade_twice_if_high
	cmp #$30
	bcc fadeOnce
	
	jsr fade_once_color
fadeOnce:
	jmp fade_once_color
.endproc
