; Copyright (C) 2025 iProgramInCpp

;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

.proc level3_sinking_platform
@entidx   := temp1
@entX     := temp2
@entY     := temp3
@entXhi   := temp4
@currentX := temp5
@donehalf := temp6
@tempspr  := temp7
@tempspd  := temp8
	ldx temp1
	
	ldy #$80
	lda playerctrl2
	and #p2_ducking
	beq :+
	ldy #$FF
:	sty @tempspd
	
	lda sprspace+sp_flags, x
	ora #ef_collidable | ef_platform
	sta sprspace+sp_flags, x
	lda #4
	sta sprspace+sp_hei, x
	
	lda #chrb_splv3a
	sta spr1_bknum
	
	lda #0
	sta @currentX
	sta @donehalf
	
@loop:
	lda @entXhi
	bne @offScreen
	
	; Determine Frame (loaded into Y)
	lda @currentX
	bne @notZero
	ldy #$40
	bne @doneDetermining

@notZero:
	lda sprspace+sp_wid, x
	sec
	sbc @currentX
	cmp #9
	bcs @notEnd
	ldy #$46
	bne @doneDetermining
	
@notEnd:
	; check if it's more than half
	lda sprspace+sp_wid, x
	lsr
	sec
	sbc #8
	cmp @currentX
	bcs @notHalf
	
	; did we already generate one half sprite
	lda @donehalf
	bne @notHalf
	
	; now generate it
	ldy #$44
	sty @donehalf
	bne @doneDetermining
	
@notHalf:
	ldy #$42

@doneDetermining:
	sty @tempspr
	
	lda #pal_red
	jsr gm_allocate_palette
	
	pha
	lda temp2
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	pla
	
	ldy @tempspr
	jsr oam_putsprite
	
@offScreen:
	ldx @entidx
	lda #8
	clc
	adc @entX
	sta @entX
	bcc :+
	inc @entXhi
:	lda #8
	clc
	adc @currentX
	sta @currentX
	cmp sprspace+sp_wid, x
	bcc @loop
	
	; check if the player is standing
	lda entground
	cmp @entidx
	bne @notColliding
	
	; if riseTimer <= 0 then play sound here
	
	lda #6
	sta sprspace+sp_l3sp_rstmr, x
	
	; if sp_vel_y <= 0, thein increment. else, set to half directly
	lda sprspace+sp_vel_y, x
	bmi :+
	beq :+
	bpl @setToHalf
	
	; add $00.$20 to the velocity
:	lda #$20
	clc
	adc sprspace+sp_vel_y_lo, x
	sta sprspace+sp_vel_y_lo, x
	bcc :+
	inc sprspace+sp_vel_y, x
	
:	; check if >= $00.$80 (or $00.$FF if ducking)
	lda sprspace+sp_vel_y, x
	bmi @doneHere
	lda @tempspd
	cmp sprspace+sp_vel_y_lo, x
	bcs @doneHere
	
@setToHalf:
	; cap it to $00.$80 (or $00.$FF if ducking)
	lda @tempspd
	sta sprspace+sp_vel_y_lo, x
	lda #0
	sta sprspace+sp_vel_y, x
	
	beq @doneHere
	
@notColliding:
	lda sprspace+sp_l3sp_rstmr, x
	beq @riseTimerZero
	
	dec sprspace+sp_l3sp_rstmr, x
	
	; TODO: approach
	lda #$C0
	sta sprspace+sp_vel_y_lo, x
	lda #0
	sta sprspace+sp_vel_y, x
	beq @doneHere
	
@riseTimerZero:
	; destination: $FF.$20
	lda sprspace+sp_vel_y, x
	bpl :+
	lda sprspace+sp_vel_y, x
	cmp #$20
	bcc @setToFF20
	
:	lda sprspace+sp_vel_y_lo, x
	sec
	sbc #$20
	sta sprspace+sp_vel_y_lo, x
	bcs :+
	dec sprspace+sp_vel_y, x
	
:	; check if <= $FF.$20
	lda sprspace+sp_vel_y, x
	bpl @doneHere
	lda #$20
	cmp sprspace+sp_vel_y_lo, x
	bcc @doneHere

@setToFF20:
	; cap it to $FF.$20
	lda #$20
	sta sprspace+sp_vel_y_lo, x
	lda #$FF
	sta sprspace+sp_vel_y, x
	
@doneHere:
	lda sprspace+sp_vel_y, x
	bmi @notDown
	
	lda sprspace+sp_y, x
	pha
	
	ldy @entidx
	jsr gm_ent_move_y
	
	pla
	ldx @entidx
	
	; compare the old coord with the new coord
	; if it's bigger than the new one, it has overflown
	cmp sprspace+sp_y, x
	bcc :+
	beq :+
	
	lda #$FF
	sta sprspace+sp_y, x
	
	; and disable collision
	lda sprspace+sp_flags, x
	and #<~ef_collidable
	sta sprspace+sp_flags, x
	
:	rts
	
@notDown:
	lda sprspace+sp_y, x
	cmp sprspace+sp_l3sp_homey, x
	bcc @alreadyThere
	beq @alreadyThere
	
	; going up
	lda sprspace+sp_l3sp_homey, x
	clc
	adc #1
	cmp sprspace+sp_y, x
	bcc @skipThis
	
	lda sprspace+sp_y_lo, x
	sta sprspace+sp_vel_y_lo, x
	lda sprspace+sp_l3sp_homey, x
	sec
	sbc sprspace+sp_y, x
	sta sprspace+sp_vel_y, x
	
@skipThis:
	ldy @entidx
	jsr gm_ent_move_y
	ldx @entidx
	rts
	
@alreadyThere:
	lda sprspace+sp_l3sp_homey, x
	sta sprspace+sp_y, x
	
	lda sprspace+sp_vel_y_lo, x
	beq :+
	
	; play sound here
	
	lda #0
	sta sprspace+sp_vel_y, x
	sta sprspace+sp_vel_y_lo, x
	
:	rts
.endproc

; TODO: Allow entities to be updated even if they're off screen.
.proc level3_dust_bunny
@entidx  := temp1
@entX    := temp2
@entY    := temp3
@entXhi  := temp4
	ldx @entidx
	
	ldy dustrhythm
	
	lda sprspace+sp_l3db_tratp, x
	and #4
	beq :+
	
	; double speed
	tya
	asl
	tay
	
:	tya
	clc
	adc sprspace+sp_l3db_timer, x
	sta temp6
	
	; ok, now calculate the object's position based on its trajectory type
	
	; save temp1 and temp2 because we'll need them, and they're clobbered by mul_8x8
	lda temp1
	sta temp7
	pha
	lda temp2
	sta temp8
	pha
	
	; load the timer and store it in temp6
	lda sprspace+sp_l3db_trara, x
	sta temp11
	
	; check if should handle horizontal?
	
	; calculate the sine
	lda temp6
	jsr sine
	
	; store it in temp9 because we'll determine whether it's positive.
	; mul_8x8 performs an *unsigned* multiplication.
	sta temp9
	bmi @negativeMultiplication
	
	; Is positive, so multiply and add.  We only care about the high byte.
	ldy temp11
	jsr mul_8x8
	tya
	
	ldy temp7
	clc
	adc sprspace+sp_l3db_homex, y
	sta sprspace+sp_x, y
	
	lda sprspace+sp_l3db_homxh, y
	adc #0
	sta sprspace+sp_x_pg, y
	
	jmp @doneXCoord

@negativeMultiplication:
	; Get the two's complement.
	lda #0
	sec
	sbc temp9
	ldy temp11
	
	; multiply and subtract.  We only care about the high byte.
	jsr mul_8x8
	sty temp12
	
	ldy temp7
	lda sprspace+sp_l3db_homex, y
	sec
	sbc temp12
	sta sprspace+sp_x, y
	
	lda sprspace+sp_l3db_homxh, y
	sbc #0
	sta sprspace+sp_x_pg, y
	
@doneXCoord:
	; done for the X coordinate.  Do the same for the Y coordinate
	lda temp6
	jsr cosine
	
	; store it in temp9 because we'll determine whether it's positive.
	sta temp9
	bmi @negativeMultiplicationY
	
	; Is positive, so multiply and add.  We only care about the high byte.
	ldy temp11
	jsr mul_8x8
	tya
	
	ldy temp7
	clc
	adc sprspace+sp_l3db_homey, y
	sta sprspace+sp_y, y
	
	jmp @doneYCoord
	
@negativeMultiplicationY:
	; Get the two's complement.
	lda #0
	sec
	sbc temp9
	ldy temp11
	
	; multiply and subtract.  We only care about the high byte.
	jsr mul_8x8
	sty temp12
	
	ldy temp7
	lda sprspace+sp_l3db_homey, y
	sec
	sbc temp12
	sta sprspace+sp_y, y
	
@doneYCoord:
	; restore temp1 and temp2 because they were clobbered
	pla
	sta temp2
	pla
	sta temp1
	
	ldx temp1
	; check collision
	lda #2
	sta temp7
	sta temp8
	lda #14
	sta temp9
	sta temp10
	ldy temp1
	jsr gm_check_collision_ent
	beq @noCollision
	
	jsr gm_killplayer
	
@noCollision:
	; draw
	lda framectr
	lsr
	lsr
	lsr
	pha
	and #3
	tay
	lda @leftFrames, y
	sta temp6
	lda @rightFrames,y
	sta temp7
	
	lda #chrb_splv3a
	sta spr1_bknum
	
	lda #pal_dust
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	
	; determine if should flip
	pla
	pha
	and #4
	beq :+
	
	lda temp6
	ldx temp7
	stx temp6
	sta temp7
	lda temp5
	ora #obj_fliphz
	sta temp5
	sta temp8
	
:	pla
	and #8
	beq :+
	lda temp5
	ora #obj_flipvt
	sta temp5
	sta temp8
	
:	jmp gm_draw_common
	
@leftFrames:	.byte $48, $4C, $50, $54
@rightFrames:	.byte $4A, $4E, $52, $56
.endproc
