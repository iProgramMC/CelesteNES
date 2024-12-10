; Copyright (C) 2024 iProgramInCpp

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
	
	lda #16
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
	cmp #28  ; note: -2
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
	
	lda #0
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
	; TODO: carry here means it overflew!
	sta x_crd_temp
	
	ldx temp1
	lda temp10
	clc
	adc #8
	cmp sprspace+sp_wid, x
	bcc loop
	
	rts

getState:
	lda sprspace+sp_flags, x
	rol
	rol
	rol
	rol
	and #%00000111
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
	
	lda sprspace+sp_x, x
	sta sprspace+sp_l1zm_homex, x
	lda sprspace+sp_y, x
	sta sprspace+sp_l1zm_homey, x
	
dontSetHome:
	; Currently, velX and velY are the home coordinates. We need to preserve
	; that quality.
	
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
	
	ldy #$FF
	lda sprspace+sp_l1zm_homex, x
	sec
	sbc sprspace+sp_x, x
	cmp #$80
	sta temp1
	bcc :+
	sty temp2

:	lda sprspace+sp_l1zm_homey, x
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
