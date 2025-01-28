; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_draw_common
; desc: draws a common 2X sprite.
; parameters:
;    temp5 - attributes for left side
;    temp8 - attributes for right side
;    temp6 - tile # for left side
;    temp7 - tile # for right side
gm_draw_common:
	lda temp3
	sta y_crd_temp
	
	; draw the left sprite
	lda temp2
	cmp #$F8
	bcc :+
	; sprite X is bigger than $F8, because either the sprite is to the
	; left of the screen (so fraudulently got there via overflow), or
	; legitimately to the right
	lda temp4
	bmi @skipLeftSprite      ; X high coord < $00, don't draw that part
	lda temp2
	
:	sta x_crd_temp
	
	lda temp5
	ldy temp6
	jsr oam_putsprite
	
@skipLeftSprite:
	; draw the right sprite
	lda temp4
	bmi @temp4neg
	lda temp2
	clc
	adc #8
	bcs :+                   ; if it overflew while computing the coord,
@temp4negd:
	sta x_crd_temp           ; then it need not render
	
	lda temp8
	ldy temp7
	jsr oam_putsprite
	
:	rts

@temp4neg:
	lda temp2
	clc
	adc #8
	bcs @temp4negd
	bcc @temp4negd

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

