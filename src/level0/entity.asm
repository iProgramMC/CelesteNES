; Copyright (C) 2024 iProgramInCpp
; Level 0 specific entities.

; ** Entity Draw/Update routines
; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

; ** ENTITY: level0_bridge_manager
; desc: This entity manages a single bridge instance  (13 tiles wide) and
;       initiates the fall sequence for each.
level0_bridge_manager:
	lda sprspace+sp_l0bm_state, x
	bne @state_Falling
	
	; idle state. Check if the player has approached this entity's position
	lda player_x
	clc
	adc camera_x
	sta temp5
	
	lda camera_x_pg
	adc #0
	sta temp6
	
	; check if that X position exceeds the bridge manager's
	lda temp6
	cmp sprspace+sp_x_pg, x
	
	bcc @noFallInit   ; player X <<< bman X
	bne @forceFall    ; player X >>> bman X
	
	lda temp5
	cmp sprspace+sp_x, x
	bcc @noFallInit

@forceFall:
	; start falling immediately
	lda #1
	sta sprspace+sp_l0bm_state, x
	lda #20
	sta sprspace+sp_l0bm_timer, x

@noFallInit:
	lda #0
	rts
	;jmp @drawSprite
	
@state_Falling:
	; Falling state. If the timer is zero, determine which block to fall, and
	; make it fall.
	
	; if player somehow outruns the default rhythm, just set the timer to zero.
	lda sprspace+sp_l0bm_blidx, x
	asl
	asl
	asl
	clc
	adc sprspace+sp_x, x
	sta temp7
	
	lda sprspace+sp_x_pg, x
	adc #0
	sta temp8
	
	lda #24
	adc temp7
	sta temp7
	bcc :+
	inc temp8
	
:	lda player_x
	clc
	adc camera_x
	sta temp5
	
	lda camera_x_pg
	adc #0
	sta temp6
	
	lda temp6
	bmi @noSpeedUp
	cmp temp8
	
	bcc @noSpeedUp
	bne @forceNow
	
	lda temp5
	cmp temp7
	bcc @noSpeedUp

@forceNow:
	lda #1
	sta sprspace+sp_l0bm_timer, x
	
@noSpeedUp:
	dec sprspace+sp_l0bm_timer, x
	bne @returnEarly
	;bne @drawSprite_Bne
	
	; falling !
	lda sprspace+sp_x_pg, x
	lsr                      ; shift bit 1 in the carry
	lda sprspace+sp_x, x
	ror                      ; shift sp_x right by 1, and shift the carry in
	lsr
	lsr                      ; finish the division by eight
	
	; OK. Now load the block index to overwrite
	clc
	adc sprspace+sp_l0bm_blidx, x
	sta temp2
	
	ldy sprspace+sp_l0bm_blidx, x
	lda l0bm_block_widths, y
	sta temp8
	sta clearsizex
	lda #8
	sta clearsizey
	
	lda sprspace+sp_y, x
	lsr
	lsr
	lsr
	sta temp3
	
	; check if a clear is already enqueued.
	lda #g2_clrcru
	bit gamectrl2
	beq :+
	
	; clear is already enqueued. Simply wait one more frame
	inc sprspace+sp_l0bm_timer, x
	bne @returnEarly
	;bne @drawSprite_Bne
	
:	ora gamectrl2
	sta gamectrl2
	
	jsr h_calcppuaddr
	
	; clear the tiles
	ldx #0
@loop:
	stx temp7
	
	ldy temp3
	ldx temp2
	jsr h_comp_addr
	inx
	stx temp2
	
	ldx #3
	lda #0
:	sta (lvladdr), y
	iny
	dex
	bne :-
	
	ldx temp7
	inx
	cpx temp8
	bne @loop
	
	ldx temp1
	
	; done. Now advance and set a timer
	lda #20
	sta sprspace+sp_l0bm_timer, x
	
	ldy sprspace+sp_l0bm_blidx, x
	lda l0bm_block_widths, y
	
	clc
	adc sprspace+sp_l0bm_blidx, x
	sta sprspace+sp_l0bm_blidx, x
	
	cmp #13   ; the maximum tile index
	bcc @returnEarly
	
	; ok. so despawn the Entity
	lda #0
	sta sprspace+sp_kind, x

@returnEarly:
	rts

;@drawSprite_Bne:
;	bne @drawSprite

;@drawSprite:
;	sta temp5
;	sta temp8
;	lda #$F4
;	sta temp6
;	lda #$F6
;	sta temp7
;	jmp gm_draw_common

l0bm_block_widths:
	.byte 2,0,1,1,1,1,1,1,1,1,2,0,1

; ** ENTITY: level0_intro_crusher
; desc: The intro crusher from the Prologue.
;       Draws itself in two halves which alternate their order every frame.
;       This way, at least some of the crusher is visible even if the
;       player is horizontally adjacent.
l0ic_dormant  = $00
l0ic_shaking  = $01
l0ic_falling  = $02
l0ic_fallen   = $03

l0ic_maxy        = 120
l0ic_defshaketmr = (256 - 20)
l0ic_palette     = $2

level0_intro_crusher:
	lda #0
	sta temp7
	ldx temp1
	
	; This sprite is collidable at all times.
	lda #ef_collidable
	ora sprspace+sp_flags, x
	sta sprspace+sp_flags, x
	
	lda #56
	sta sprspace+sp_wid, x
	lda #32
	sta sprspace+sp_hei, x
	
	lda sprspace+sp_l0ic_state, x
	; cmp #1
	; bne @returnEarly
	sta temp6 ; TEMP
	
	cmp #l0ic_dormant
	bne @notDormant
	
	; Is dormant
	lda player_x
	sec
	sbc #30
	bcc @notDormant
	cmp temp2
	bcc @returnEarly
	
	; trigger a fall.
	inc sprspace+sp_l0ic_state, x
	lda #l0ic_defshaketmr
	sta sprspace+sp_l0ic_timer, x
	
	lda temp2
	pha
	lda temp3
	pha
	jsr @clearTilesForIC
	pla
	sta temp3
	pla
	sta temp2
	
	jmp @drawSprite
	
@returnEarly:
	rts
	
@notDormant:
	cmp #l0ic_shaking
	bne @notShaking
	
	lda sprspace+sp_l0ic_timer, x
	bne @doShake
	
	; sprite timer hit 0! time to fall!!
	inc sprspace+sp_l0ic_state, x
	lda #0
	sta sprspace+sp_y_lo, x
	sta sprspace+sp_l0ic_vel_y, x
	sta sprspace+sp_l0ic_vsu_y, x
	
	bne @drawSprite

@doShake:
	lda sprspace+sp_l0ic_timer, x
	and #3
	tay
	lda l0ic_shake_table, y
	clc
	adc temp2
	sta temp2
	jmp @drawSprite

@notShaking:
	cmp #l0ic_falling
	bne @notFalling
	
	; is falling
	; accelerate
	clc
	lda sprspace+sp_l0ic_vsu_y, x
	adc #$20
	sta sprspace+sp_l0ic_vsu_y, x
	bcc :+
	inc sprspace+sp_l0ic_vel_y, x

	; pull
:	lda temp1
	pha
	lda temp2
	pha
	lda temp3
	pha
	
	txa
	tay
	jsr gm_ent_move_y
	
	pla
	sta temp3
	pla
	sta temp2
	pla
	sta temp1
	
	ldx temp1
	lda sprspace+sp_y, x
	cmp #l0ic_maxy
	bcc @drawSprite
	
	; has fallen
	lda #l0ic_maxy
	sta sprspace+sp_y, x
	inc sprspace+sp_l0ic_state, x
	
	lda #$7
	sta quakeflags
	sta quaketimer
	
	jsr @setTilesForIC
	
@notFalling:
	; Is fallen
	rts
	
@drawSprite:
	inc sprspace+sp_l0ic_timer, x
	lda sprspace+sp_l0ic_timer, x
	and #1
	bne @drawFirstHalfFirst
	; draw second half first.
	jsr @secondHalf
	jsr @firstHalf
	rts
@drawFirstHalfFirst:
	; draw first half first.
	jsr @firstHalf
	jsr @secondHalf
	rts
	
; Draws the first half.
@firstHalf:
	jsr @firstHalfUp
	jsr @firstHalfDown
	rts

@secondHalf:
	jsr @secondHalfUp
	jsr @secondHalfDown
	rts

@firstHalfUp:
	lda temp2
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	
	ldy #0
:	sty temp5
	lda l0ic_dataFHU, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_fhu
	
	ldy temp5
	iny
	cpy #4
	bne :-
	
@return_fhu:
	rts

@firstHalfDown:
	lda temp2
	sta x_crd_temp
	lda temp3
	clc
	adc #16
	sta y_crd_temp
	bcs @return_fhd
	
	ldy #0
:	sty temp5
	lda l0ic_dataFHD, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_fhd
	
	ldy temp5
	iny
	cpy #4
	bne :-
	
@return_fhd:
	rts

@secondHalfUp:
	lda temp2
	clc
	adc #32
	sta x_crd_temp
	bcs @return_shu
	lda temp3
	sta y_crd_temp
	
	ldy #0
:	sty temp5
	lda l0ic_dataSHU, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_shu
	
	ldy temp5
	iny
	cpy #3
	bne :-
	
@return_shu:
	rts

@secondHalfDown:
	lda temp2
	clc
	adc #32
	sta x_crd_temp
	bcs @return_shd
	lda temp3
	clc
	adc #16
	sta y_crd_temp
	bcs @return_shd
	
	ldy #0
:	sty temp5
	lda l0ic_dataSHD, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_shd
	
	ldy temp5
	iny
	cpy #3
	bne :-
	
@return_shd:
	rts

@incrementX:
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	rts

@clearTilesForIC:
	; Set the flags that will clear the crusher's nametable visually.
	stx l0crshidx
	
	; Enqueue a clear for the size of the intro crusher..
	lda #g2_clrcru
	ora gamectrl2
	sta gamectrl2
	
	lda #7
	sta clearsizex
	lda #4
	sta clearsizey
	
	; Initiate the clearing process.
	jsr level0_ic_calcpos ; calculate tile pos in (temp2, temp3)
	jsr h_calcppuaddr     ; use said tile pos to prepare for the g2_clrcru NMI.
	
	ldx #0
@loop:
	stx temp4
	
	ldy temp3
	ldx temp2
	jsr h_comp_addr
	inx
	stx temp2
	
	ldx #4
	lda #0
:	sta (lvladdr), y
	iny
	dex
	bne :-
	
	ldx temp4
	inx
	cpx #7
	bne @loop
	
	; need to restore X since we proceed to use it after calling this func
	ldx l0crshidx
	
	rts

@setTilesForIC:
	; Set the flags that will clear the crusher's nametable visually.
	stx l0crshidx
	
	lda #g2_setcru
	ora gamectrl2
	sta gamectrl2
	
	; Initiate the setting process.
	jsr level0_ic_calcpos ; calculate tile pos in (temp2, temp3)
	jsr h_calcppuaddr     ; use said tile pos to prepare for the g2_setcru NMI.
	
	ldx #0
	stx temp6
@loop1:
	stx temp4
	
	ldy temp3
	ldx temp2
	jsr h_comp_addr
	inx
	stx temp2
	
	lda #1
	ldx #4
:	sta (lvladdr), y
	iny
	dex
	bne :-
	
	ldx temp4
	inx
	cpx #7
	bne @loop1
	
	; no need to restore X as there's a return immediately after
	
	rts

; ** SUBROUTINE: level0_ic_calcpos
; desc: Calculates the tile position of the IntroCrusher into [temp2, temp3].
level0_ic_calcpos:
	; Initiate the setting process.
	lda sprspace + sp_y, x
	lsr
	lsr
	lsr
	sta temp3
	tay
	
	lda sprspace + sp_x_pg, x
	ror
	ror
	ror
	ror
	and #%00100000
	sta temp2
	
	lda sprspace + sp_x, x
	lsr
	lsr
	lsr
	ora temp2
	sta temp2
	
	rts

l0ic_dataFHU:	.byte $81, $89, $8B, $8D
l0ic_dataFHD:	.byte $83, $8F, $91, $93
l0ic_dataSHU:	.byte $8D, $89, $85
l0ic_dataSHD:	.byte $8F, $93, $87
l0ic_shake_table:	.byte $01, $00, $FF, $00

l0ic_chardata:
	.byte $80,$88,$8A,$8C,$8C,$88,$84
	.byte $81,$89,$8B,$8D,$8D,$89,$85
	.byte $82,$8E,$90,$92,$99,$92,$86
	.byte $83,$8F,$91,$93,$8F,$93,$87
