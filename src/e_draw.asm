; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_draw_common
; desc: draws a common 2X sprite.
; parameters:
;    temp5 - attributes for left side
;    temp8 - attributes for right side
;    temp6 - tile # for left side
;    temp7 - tile # for right side
gm_draw_common:
	ldx #<xt_draw_common
	ldy #>xt_draw_common
	lda #prgb_ents
	jmp far_call2

; ** SUBROUTINE: gm_draw_common2
; desc: draws a common 2X sprite.  Ensures that there is no wraparound.
.proc gm_draw_common2
	lda temp4
	bmi @temp4Negative
	bne @temp4PositiveNonZero
	
	; temp4 is zero, so can draw
@doDraw:
	jmp gm_draw_common

@temp4PositiveNonZero:
@temp4NegativeTemp2Negative:
	; if temp4 > 0, then clearly off screen
	rts

@temp4Negative:
	; it could still be on screen if temp2 >= $F8 (so, the RHS would end up back
	; in screen bounds)
	lda temp2
	cmp #$F8
	bcc @temp4NegativeTemp2Negative
	bcs @doDraw

.endproc

; ** SUBROUTINE: gm_unload_cassette_manager
; desc: Unloads a cassette block manager entity.
; parameters:
;    X - The entity to unload.
.proc gm_unload_cassette_manager
	lda #0
	sta cassrhythm
	lda sprspace+sp_cbmg_ospbk, x
	sta spr1_bknum
	lda sprspace+sp_cbmg_obg0b, x
	sta bg0_bknum
	lda sprspace+sp_cbmg_obg1b, x
	sta bg1_bknum
	rts
.endproc

; ** SUBROUTINE: gm_unload_os_ents
; desc: Unloads entities that went off the left side of the screen.
gm_unload_os_ents:
	ldx #<sgm_unload_os_ents
	ldy #>sgm_unload_os_ents
	lda #prgb_ents
	jmp far_call2

; ** SUBROUTINE: gm_draw_entities
; desc: Draws visible entities to the screen.
gm_draw_entities:
	ldx #<xt_draw_entities
	ldy #>xt_draw_entities
	lda #prgb_ents
	jmp far_call2

