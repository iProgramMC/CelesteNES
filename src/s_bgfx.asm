; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: s_init_starry_night
; desc: Initializes the starry night background.  This is not meant to be called
;       by itself, because it falls through to s_update_starry_night.
.proc s_init_starry_night
	ldy #0
loopInit:
	jsr rand
	sta stars_x, y
	
	jsr rand
	sta stars_y, y
	
	jsr rand
	and #15
	sta stars_state, y
	
	iny
	cpy #max_stars
	bne loopInit
	
	lda #1
	sta starsbgctl
	; fallthrough
.endproc

; ** SUBROUTINE: s_update_starry_night
; desc: Updates Chapter 2's starry night background.
.proc s_update_starry_night
	lda starsbgctl
	beq s_init_starry_night
	
	lda roomflags2
	and #r2_outside
	beq return
	
	jsr s_bg_allocate_palette
	ora #obj_backgd
	sta temp3
	
	; Updates and draws all of the starry particles.
	ldy #0
loopDraw:
	sty temp1
	
	lda stars_x, y
	sta x_crd_temp
	lda stars_y, y
	sta y_crd_temp
	
	; occlusion check!!
	jsr s_bg_check_occluded
	bne @continue
	
	; compute the sprite
	
	ldx temp1
	ldy stars_state, x
	lda star_sprites, y
	tay
	
	ldx oam_wrhead
	lda y_crd_temp
	sta oam_buf, x
	inx
	
	tya
	sta oam_buf, x
	inx
	
	lda temp3
	sta oam_buf, x
	inx
	
	lda x_crd_temp
	sta oam_buf, x
	inx
	
	stx oam_wrhead
	
	;tay
	;lda temp3
	;jsr oam_putsprite
	
@continue:
	ldy temp1
	iny
	cpy #max_stars
	bne loopDraw

return:
	rts

star_sprites:
	.byte $A7,$A7,$A9,$A9	; type 1
	.byte $A1,$A3,$A5,$A7	; type 2
	.byte $AB,$AD,$AB,$AD	; type 3
	.byte $AB,$AD,$AD,$AB	; type 4
.endproc

; ** SUBROUTINE: s_bg_check_occluded
; desc: Checks if this star is being occluded by a solid tile.
; parameters: x_crd_temp, y_crd_temp
.proc s_bg_check_occluded
	lda x_crd_temp
	clc
	adc #3
	sta temp4
	lda #0
	adc #0
	sta temp5
	
	lda temp4
	clc
	adc camera_x
	sta temp4
	
	lda camera_x_pg
	adc temp5
	ror
	
	lda temp4
	ror
	lsr
	lsr
	; [0-63]
	tax
	
	lda y_crd_temp
	clc
	adc #8
	clc
	adc camera_y_sub
	lsr
	lsr
	lsr
	clc
	adc vertoffshack
	cmp #30
	bcc :+
	sbc #30
:	tay
	
	jsr h_comp_addr
	lda (lvladdr), y
	rts
.endproc

; ** SUBROUTINE: s_bg_allocate_palette
; desc: Attempts to allocate a palette for the starry background.
;       If fails, just returns the player's palette.
.proc s_bg_allocate_palette
	lda sprpalcount
	cmp #3
	bcs @returnZero
	
	; it's go time!
	lda #pal_blue
	jmp gm_allocate_palette
	
@returnZero:
	; return 0 to prevent flickering (normally, we'd return 1, but 1 may oscillate)
	lda #0
	rts
.endproc

; ** SUBROUTINE: s_update_bg_effects
; desc: Updates background effects in the game.
.proc s_update_bg_effects
	lda levelnumber
	cmp #2
	beq @level2
	rts
	
@level2:
	jmp s_update_starry_night
.endproc
