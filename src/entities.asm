

gm_draw_berry:
	lda #$01
	sta temp4
	lda #$F8
	sta temp5
	lda #$FA
	sta temp6
	jmp gm_draw_common
	
gm_draw_refill:
	lda #$03
	sta temp4
	lda #$FC
	sta temp5
	lda #$FE
	sta temp6
	jmp gm_draw_common
	
gm_draw_spring:
	lda #$01
	sta temp4
	lda #$C8
	sta temp5
	lda #$CA
	sta temp6
	jmp gm_draw_common
	
gm_draw_key:
	lda #$03
	sta temp4
	lda #$DC
	sta temp5
	lda #$DE
	sta temp6
	jmp gm_draw_common
	
gm_draw_common:
	ldx #temp4
	lda temp2
	ldy temp3
	jsr gm_draw_2xsprite
	rts

; ** SUBROUTINE: gm_draw_ent_call
; desc: Calls the relevant entity draw function.
; arguments:
;     A - entity type
;     temp1 - entity index
; note: temp1 is occupied by gm_draw_entities and represents the index within the sprspace array.
gm_draw_ent_call:
	tax
	lda gm_entjtable_lo, x
	sta lvladdr
	lda gm_entjtable_hi, x
	sta lvladdrhi
	
	; as a shortcut, calculate the on-screen X and Y positions too.
	ldx temp1
	lda sprspace+sp_x, x
	sbc camera_x
	sta temp2
	lda sprspace+sp_y, x
	sbc camera_y
	sta temp3
	
	jmp (lvladdr)

; TODO: figure out how to avoid defining two tables like this
gm_entjtable_lo:
	.byte $00
	.byte <gm_draw_berry
	.byte <gm_draw_refill
	.byte <gm_draw_spring
	.byte <gm_draw_key

gm_entjtable_hi:
	.byte $00
	.byte >gm_draw_berry
	.byte >gm_draw_refill
	.byte >gm_draw_spring
	.byte >gm_draw_key