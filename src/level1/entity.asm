; Copyright (C) 2024-2025 iProgramInCpp

;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

.proc level1_zip_mover
; sp_l1zm_state
idle    = 0
charge  = 1
lunge   = 2
crash   = 3
retreat = 4
cooldn  = 5

	lda temp1
	pha
	tax
	
	lda sprspace+sp_flags, x
	ora #ef_collidable
	sta sprspace+sp_flags, x
	
	lda #chrb_splvl1
	sta spr1_bknum
	
	lda #16
	ldy sprspace+sp_kind, x
	cpy #e_l1zipmovt
	bne notTallZipMover
	
	; a tall zip mover is actually 32
	asl
	
	ldy #chrb_splv1b
	sty spr1_bknum

notTallZipMover:
	sta sprspace+sp_hei, x
	
	lda gamectrl3
	and #g3_transitA
	beq noTransition
	
	jsr resetState
	
noTransition:
	; which state are we in?
	jsr getState
	beq idleState
	cmp #charge
	beq chargeState
	cmp #lunge
	beq lungeState
	cmp #crash
	beq crashState
	cmp #retreat
	beq retreatState
	cmp #cooldn
	beq cooldownState
	
idleState:
	cpx entground
	bne drawProcess
	
	; Store the home coordinates
	lda sprspace+sp_x, x
	sta sprspace+sp_vel_x, x
	lda sprspace+sp_y, x
	sta sprspace+sp_vel_y, x
	
	; entground is this entity's index, therefore increase the state
	jsr incrementState
	bne drawProcess

chargeState:
	inc sprspace+sp_l1zm_timer, x
	lda sprspace+sp_l1zm_timer, x
	cmp #6
	bne drawProcess
	
	; move on to the lunge state
	jsr incrementState
	lda #0
	sta sprspace+sp_l1zm_timer, x
	beq drawProcess

lungeState:
	jsr level1_zip_mover_lunge_move
	
	ldx temp1
	inc sprspace+sp_l1zm_timer, x
	lda sprspace+sp_l1zm_timer, x
	cmp #32  ; note: +2
	bne drawProcess
	
	; ok, it reached 32
incrementStateAndDraw:
	jsr incrementState
	lda #0
	sta sprspace+sp_l1zm_timer, x
	beq drawProcess

crashState:
	inc sprspace+sp_l1zm_timer, x
	lda sprspace+sp_l1zm_timer, x
	cmp #1
	bne noShakeOnCrash
	lda #15
	sta quakeflags
	lda #8
	sta quaketimer
noShakeOnCrash:
	cmp #48
	bne drawProcess
	beq incrementStateAndDraw

retreatState:
	jsr level1_zip_mover_retreat_move
	
	inc sprspace+sp_l1zm_timer, x
	lda sprspace+sp_l1zm_timer, x
	cmp #128 ; note: +8
	bne drawProcess
	
	; ok, it reached 128
	jsr incrementState
	lda #0
	sta sprspace+sp_l1zm_timer, x
	beq drawProcess
	
cooldownState:
	inc sprspace+sp_l1zm_timer, x
	lda sprspace+sp_l1zm_timer, x
	cmp #10
	bne drawProcess
	
	jsr resetState
	lda #0
	sta sprspace+sp_l1zm_timer, x

drawProcess:
	pla
	sta temp1
	tax
	
	lda sprspace+sp_wid, x
	sec
	sbc #8
	sta temp9
	
	lda #pal_gray
	jsr gm_allocate_palette
	sta temp8
	
	lda temp2
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	
	
	ldx temp1
	ldy sprspace+sp_kind, x
	cpy #e_l1zipmovt
	bne notTallZipMover2
	jmp level1_tall_zip_mover_draw
	
notTallZipMover2:
	lda #0
	sta temp10
	jsr skipLeftSpriteIfNeeded
	
	lda temp10
loop:
	sta temp10
	
	; draw a sprite
	tay             ; tay to calculate flags, not because we need it in Y
	bne notZero
	
	; it's zero
	lda #$40
	bne draw
	
notZero:
	; check if it's the end
	cmp temp9
	bne notEnd
	
	; it's the end
	lsr
	lsr
	and #2
	beq endWhatever
	lda #$46
	bne draw
endWhatever:
	lda #$48
	bne draw

notEnd:
	; not the end
	lsr
	lsr
	and #2
	clc
	adc #$42
	
draw:
	tay
	
	lda temp8
	pha
	sty temp8
	
	jsr getState
	beq noAnim
	cmp #charge
	beq noAnim
	cmp #crash
	beq noAnim
	
	cmp #lunge
	bne noLunge
	
	lda sprspace+sp_l1zm_timer, x
	lsr
	jmp normalSpeed
	
noLunge:
	lda sprspace+sp_l1zm_timer, x
	lsr
	lsr
normalSpeed:
	and #3
	tay
	lda tableTimer, y
	clc
	adc temp8
	tay
	
noAnim:
	pla
	sta temp8
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc #8
	bcs spikeyProcessing   ; if carried, break
	sta x_crd_temp
	
	ldx temp1
	lda temp10
	clc
	adc #8
	cmp sprspace+sp_wid, x
	bcc loop

spikeyProcessing:
	lda sprspace+sp_l1zm_flags, x
	and #sp_l1zmf_spikyUP
	beq notSpikey
	
	lda temp2
	sta x_crd_temp
	lda temp3
	sec
	sbc #16
	sta y_crd_temp
	
	lda #0
	sta temp10
	
	jsr skipLeftSpriteIfNeeded
	
	lda temp10
spikesLoop:
	sta temp10
	ldy #$7E
	lda temp8
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc #8
	bcs notSpikey
	sta x_crd_temp
	
	lda temp10
	clc
	adc #8
	bcs notSpikey   ; if carried, return
	cmp sprspace+sp_wid, x
	bcc spikesLoop
	
	cpx entground
	bne notSpikey
	
	lda playerctrl
	and #(pl_ground | pl_climbing)
	cmp #pl_ground
	bne notSpikey
	
	jmp gm_killplayer
	
notSpikey:
	rts

getState:
	lda sprspace+sp_flags, x
	rol
	rol
	rol
	rol
	and #%00000111
	rts

skipLeftSpriteIfNeeded:
	lda temp2
	cmp #$F8
	bcc :+
	
	; sprite X is bigger than $F8, because either the sprite is to the
	; left of the screen (so fraudulently got there via overflow), or
	; legitimately to the right
	lda temp4
	bmi @skipLeftSprite
	lda temp2

:	sta x_crd_temp
	rts

@skipLeftSprite:
	lda x_crd_temp
	and #7
	sta x_crd_temp
	lda temp10
	clc
	adc #8
	sta temp10
	rts

incrementState:
	lda sprspace+sp_flags, x
	clc
	adc #%00100000
	sta sprspace+sp_flags, x
	rts

resetState:
	lda sprspace+sp_flags, x
	and #%00011111
	sta sprspace+sp_flags, x
	rts

tableTimer:	.byte 0, 10, 20, 30
.endproc

.proc level1_zip_mover_lunge_move
	lda temp4
	pha
	lda temp3
	pha
	lda temp2
	pha
	lda temp1
	pha
	
	lda sprspace+sp_l1zm_timer, x
	bne dontSetHome
	
	lda #0
	sta sprspace+sp_vel_x, x
	sta sprspace+sp_vel_y, x
	sta sprspace+sp_vel_x_lo, x
	sta sprspace+sp_vel_y_lo, x
	
	lda sprspace+sp_x_pg, x
	sta sprspace+sp_l1zm_homxh, x
	lda sprspace+sp_x, x
	sta sprspace+sp_l1zm_homex, x
	lda sprspace+sp_y, x
	sta sprspace+sp_l1zm_homey, x
	
dontSetHome:
	ldy #0
	lda sprspace+sp_l1zm_desty, x
	bpl :+
	dey
:	clc
	adc sprspace+sp_vel_y_lo, x
	sta sprspace+sp_vel_y_lo, x
	
	tya
	adc sprspace+sp_vel_y, x
	sta sprspace+sp_vel_y, x
	
	ldy #0
	lda sprspace+sp_l1zm_destx, x
	bpl :+
	dey
:	clc
	adc sprspace+sp_vel_x_lo, x
	sta sprspace+sp_vel_x_lo, x
	
	tya
	adc sprspace+sp_vel_x, x
	sta sprspace+sp_vel_x, x
	
	jsr moveXY
	
epilogue:
	pla
	sta temp1
	tax
	pla
	sta temp2
	pla
	sta temp3
	pla
	sta temp4
	rts

moveXY:
	txa
	pha
	tay
	jsr gm_ent_move_y
	
	pla
	tay
	jmp gm_ent_move_x
.endproc

.proc level1_zip_mover_retreat_move
	lda temp4
	pha
	lda temp3
	pha
	lda temp2
	pha
	lda temp1
	pha
	
	lda sprspace+sp_l1zm_timer, x
	bne dontPrepare
	
	lda #0
	sta sprspace+sp_x_lo, x
	sta sprspace+sp_y_lo, x
	sta temp2
	sta temp4
	
	; [temp2, temp1], respectively [temp4, temp3] would hold the velocity to be applied over 128 frames.
	; Instead of storing to temp2, temp4 and dividing by 2^7, just store to temp1, temp3 and multiply by 2.
	; It has the same effect
	
	lda sprspace+sp_l1zm_homex, x
	sec
	sbc sprspace+sp_x, x
	sta temp1
	lda sprspace+sp_l1zm_homxh, x
	sbc sprspace+sp_x_pg, x
	sta temp2

	ldy #$FF
	lda sprspace+sp_l1zm_homey, x
	sec
	sbc sprspace+sp_y, x
	cmp #$80
	sta temp3
	bcc :+
	sty temp4

:	; now multiply by 4
	asl temp1
	rol temp2
	
	asl temp3
	rol temp4
	
	; ok, now apply the velocity
	lda temp2
	sta sprspace+sp_vel_x, x
	lda temp1
	sta sprspace+sp_vel_x_lo, x
	lda temp4
	sta sprspace+sp_vel_y, x
	lda temp3
	sta sprspace+sp_vel_y_lo, x
	
dontPrepare:
	jsr level1_zip_mover_lunge_move::moveXY
	
	jmp level1_zip_mover_lunge_move::epilogue
.endproc

.proc level1_tall_zip_mover_draw
idle    = level1_zip_mover::idle
charge  = level1_zip_mover::charge
lunge   = level1_zip_mover::lunge
crash   = level1_zip_mover::crash
retreat = level1_zip_mover::retreat
cooldn  = level1_zip_mover::cooldn

	; What the level1_zip_mover routine did before:
	; It executed the movement code, and then allocated a palette into temp8, and setup an X limit in temp9
	; It also copied temp2, temp3 into x_crd_temp, y_crd_temp
	lda #0
	sta temp10
	jsr level1_zip_mover::skipLeftSpriteIfNeeded
	lda temp10
loop:
	sta temp10
	
	; TODO: This is copied verbatim from the other function. Maybe optimize?!
	; draw a sprite
	tay             ; tay to calculate flags, not because we need it in Y
	bne notZero
	
	; it's zero
	lda #$40
	bne draw
	
notZero:
	; check if it's the end
	cmp temp9
	bne notEnd
	
	; it's the end
	lsr
	lsr
	and #2
	beq endWhatever
	lda #$46
	bne draw
endWhatever:
	lda #$48
	bne draw

notEnd:
	; not the end
	lsr
	lsr
	and #2
	clc
	adc #$42
	
draw:
	tay
	
	lda temp8
	pha
	sty temp8
	
	jsr level1_zip_mover::getState
	beq noAnim
	cmp #charge
	beq noAnim
	cmp #crash
	beq noAnim
	
	cmp #lunge
	bne noLunge
	
	lda sprspace+sp_l1zm_timer, x
	lsr
	jmp normalSpeed
	
noLunge:
	lda sprspace+sp_l1zm_timer, x
	lsr
	lsr
normalSpeed:
	and #1
	tay
	lda tableTimer, y
	clc
	adc temp8
	tay
	
noAnim:
	pla
	sta temp8
	
	tya
	pha ; backup the calculated tile ID
	
	lda temp8
	jsr oam_putsprite
	
	jsr add16ToYTemp
	
	pla ; restore it, then add #$10 to it
	clc
	adc #$20
	tay
	
	lda temp8
	jsr oam_putsprite
	
	lda temp3
	sta y_crd_temp
	
	lda x_crd_temp
	clc
	adc #8
	bcs @end
	sta x_crd_temp
	
	ldx temp1
	lda temp10
	clc
	adc #8
	cmp sprspace+sp_wid, x
	bcc loop
	
@end:
	jmp level1_zip_mover::spikeyProcessing

add16ToYTemp:
	lda y_crd_temp
	clc
	adc #$10
	sta y_crd_temp
	rts

tableTimer:	.byte 0, 10
.endproc

.proc level1_campfire
	; TODO: Add cutscene here
	lda #chrb_splvl2
	sta spr1_bknum
	
	lda sprspace+sp_l1cf_state, x
	beq @stateIdle
	cmp #1
	beq @stateWaiting
	cmp #2
	beq @stateBurning
	
@stateIdle:
	lda player_x
	cmp #$C0
	bcc @return
	
	inc sprspace+sp_l1cf_state, x
	
	lda temp1
	pha
	ldx #<ch1_ending
	ldy #>ch1_ending
	jsr dlg_begin_cutscene_g
	pla
	sta temp1
	
@return:
@stateWaiting:
	rts
	
@stateBurning:
	lda #pal_fire
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	
	ldx temp1
	lda sprspace+sp_l1cf_timer, x
	inc sprspace+sp_l1cf_timer, x
	
	lsr
	and #%00011100
	clc
	adc #$40
	sta temp6
	
	clc
	adc #2
	sta temp7
	
	jmp gm_draw_common
.endproc
