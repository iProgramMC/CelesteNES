; Copyright (C) 2025 iProgramInCpp

;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

chrb_papho0 = $40
chrb_papho1 = $41
chrb_papho2 = $42
chrb_papho3 = $43
chrb_papho4 = $44
chrb_papho5 = $45
chrb_papho6 = $46
chrb_papho7 = $47
chrb_papho8 = $48

; ######### ANIMATION TABLES #########
.proc level2_payphone_idle
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
main:
	.byte $00,$00,pal_gray,$00
	.byte $00,$02,pal_gray,$08
	.byte $00,$04,pal_red, $10
pole:
	.byte $10,$22,pal_gray,$08
	.byte $10,$24,pal_red, $10
	.byte $20,$08,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte $FF
.endproc

.proc level2_payphone_mad1
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$C4,$80,    $FB
	.byte $28,$C6,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad2
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$10,$80,    $FB
	.byte $28,$12,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad3
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$14,$80,    $FB
	.byte $28,$16,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad4
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$18,$80,    $FB
	.byte $28,$1A,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad5
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$06,$80,    $FB
	.byte $28,$26,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad6
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$18,$80,    $FB
	.byte $28,$0E,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad7
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$1C,$80,    $FB
	.byte $28,$1E,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.define level2_payphone_table \
	level2_payphone_idle,     \
	level2_payphone_mad1,     \
	level2_payphone_mad2,     \
	level2_payphone_mad3,     \
	level2_payphone_mad5,     \
	level2_payphone_mad6,     \
	level2_payphone_mad7,     \
	level2_payphone_mad7,     \
	$0000

level2_payphone_table_lo:	.lobytes level2_payphone_table
level2_payphone_table_hi:	.hibytes level2_payphone_table

level2_payphone_max_timer = 8

; ######### ANIMATION CODE #########

; ** ENTITY: level2_payphone
; desc: This draws and animates the payphone entity.
.proc level2_payphone
	ldx temp1
	lda sprspace+sp_l2ph_timer, x
	
	; increment the timer
	pha
	clc
	adc #1
	cmp #level2_payphone_max_timer
	bne :+
	lda #0
:	sta sprspace+sp_l2ph_timer, x
	pla
	
	tax
	lda level2_payphone_table_lo, x
	sta setdataaddr
	lda level2_payphone_table_hi, x
	sta setdataaddr+1
	
	; draw
	ldy #0
	lda (setdataaddr), y
	iny
	sta spr1_bknum
	
	ldx oam_wrhead

@loop:
	; write Y coordinate
	lda (setdataaddr), y
	cmp #$FF
	beq @return
	cmp #$FE
	beq @jump
	clc
	adc temp3
	sta oam_buf, x
	inx
	iny
	
	; write tile number
	lda (setdataaddr), y
	;hack
	clc
	adc #$41
	sta oam_buf, x
	inx
	iny
	
	; write attributes
	stx oam_wrhead
	sty temp11
	lda (setdataaddr), y
	bmi :+
	jsr gm_allocate_palette
:	and #$7F
	ldy temp11
	ldx oam_wrhead
	sta oam_buf, x
	inx
	iny
	
	; write X coordinate
	lda (setdataaddr), y
	clc
	adc temp2
	sta oam_buf, x
	inx
	iny
	stx oam_wrhead
	jmp @loop

@return:
	rts

@jump:
	iny
	lda (setdataaddr), y
	tax
	iny
	lda (setdataaddr), y
	stx setdataaddr
	sta setdataaddr+1
	ldx oam_wrhead
	ldy #0
	beq @loop
.endproc

; ** ENTITY: level2_mirror
; desc: The mirror that unlocks the Dream Blocks!
.proc level2_mirror
	jsr animateBadeline
	jsr drawBadeline
	
	ldx temp1
	lda sprspace+sp_l2mi_state, x
	sta $FF
	beq @state_Idle
	cmp #1
	beq @state_Reflected
	cmp #2
	beq @state_BegunScene
	cmp #3
	beq @state_WalkForwardReflection
	cmp #4
	beq @state_BadelineWait
	cmp #5
	beq @state_ShatterMirror_
	cmp #6
	beq @state_BadelineWait2
	cmp #7
	beq @state_BadelineFlee
	cmp #8
	beq @state_BadelineJump
	cmp #9
	beq @state_RevealDreamBlock

@state_Idle:
	lda player_x
	cmp #$A0
	bcc @return
	
	; reflected, now wait for her to come back
	inc sprspace+sp_l2mi_state, x
@return:
	rts

@state_Reflected:
	lda player_x
	cmp #$90
	bcs @return
	
	; came back, begin the cutscene and wait
	inc sprspace+sp_l2mi_state, x
	
	lda temp1
	pha
	
	txa
	ldx #<ch2_mirror_shatter
	ldy #>ch2_mirror_shatter
	jsr dlg_begin_cutscene_g
	
	pla
	sta temp1

@state_BegunScene:
	rts

@state_WalkForwardReflection:
	lda sprspace+sp_l2mi_reflx, x
	clc
	adc #1
	cmp #$76
	bcc :+
	lda #$76
	inc sprspace+sp_l2mi_state, x
:	sta sprspace+sp_l2mi_reflx, x
	rts

@state_BadelineWait:
	rts

@state_BadelineWait2:
@state_RevealDreamBlock:
	rts

@state_ShatterMirror_:
	beq @state_ShatterMirror

@state_BadelineFlee:
	jsr moveLeftX
	
	cmp #60
	bcs @return
	
	; time to jump!
	inc sprspace+sp_l2mi_state, x
	
	lda #18
	sta sprspace+sp_l2mi_jhold, x
	
	lda #<-jumpvel
	sta sprspace+sp_vel_y_lo, x
	lda #>-jumpvel
	sta sprspace+sp_vel_y, x
	rts

@state_BadelineJump:
	jsr moveLeftX
	cmp #$E0
	bcc :+
	
	cmp #$F8
	bcc @wentOffScreen
	
:	inc sprspace+sp_l2mi_timer, x
	
	lda sprspace+sp_l2mi_rlylo, x
	clc
	adc sprspace+sp_vel_y_lo, x
	sta sprspace+sp_l2mi_rlylo, x
	
	lda sprspace+sp_l2mi_refly, x
	adc sprspace+sp_vel_y, x
	sta sprspace+sp_l2mi_refly, x
	
	; gravity
	lda sprspace+sp_l2mi_jhold, x
	beq @noHold
	
	dec sprspace+sp_l2mi_jhold, x
	jmp @hold
	
@noHold:
	lda sprspace+sp_vel_y_lo, x
	clc
	adc #$40
	sta sprspace+sp_vel_y_lo, x
	bcc @hold
	inc sprspace+sp_vel_y, x
@hold:
	
	; check if the velocity is negative
	lda sprspace+sp_vel_y, x
	bmi @nofloorcheck
	
	lda sprspace+sp_l2mi_refly, x
	cmp #$70
	bcc @nofloorcheck
	
	lda #$70
	sta sprspace+sp_l2mi_refly, x
	lda #0
	sta sprspace+sp_vel_y, x
	sta sprspace+sp_vel_y_lo, x
	
@nofloorcheck:
	rts

@wentOffScreen:
	lda #$F8
	sta sprspace+sp_l2mi_reflx, x
	inc sprspace+sp_l2mi_state, x
	rts

@state_ShatterMirror:
	lda sprspace+sp_l2mi_timer, x
	inc sprspace+sp_l2mi_timer, x
	
	cmp #12
	bne @dontStartQuaking
	
	lda #15
	sta quakeflags
	lda #12
	sta quaketimer
	
@dontStartQuaking:
	cmp #16
	bne @dontSpawnParticles
	
	; Spawn Particles
	;jsr spawnParticles
	
@dontSpawnParticles:
	cmp #19
	bcc :+
	lda #19
:	lsr
	lsr
	tax
	lda dataSourcesLow, x
	sta setdataaddr
	lda dataSourcesHigh, x
	sta setdataaddr+1
	
	lda #6
	sta clearsizex
	lda #4
	sta clearsizey
	
	lda #16+1
	clc
	adc roombeglo2
	tax
	
	lda #15+1
	tay
	
	
	jsr h_request_transfer
	rts

drawBadeline:
	; Calculate Middle of Screen
	lda roombeglo
	clc
	adc #$A0
	sta temp5
	lda roombeghi
	adc #0
	sta temp6
	
	lda temp5
	sec
	sbc camera_x
	sta temp5
	lda temp6
	sbc camera_x_pg
	sta temp6
	
	lda temp5
	sec
	sbc #$20
	sta temp11
	
	lda sprspace+sp_l2mi_state, x
	cmp #3
	bcc @calculateReflectionPos
	
	lda sprspace+sp_l2mi_reflx, x
	sta temp2
	lda sprspace+sp_l2mi_refly, x
	sta temp3
	bne @doneCalculatingXY
	
@calculateReflectionPos:
	; amount player is offset from screen
	lda player_x
	sec
	sbc temp5
	sta temp2
	
	lda temp5
	sec
	sbc temp2
	sec
	sbc #$10
	sta temp2
	
	lda player_y
	sta temp3
	
	lda temp2
	sta sprspace+sp_l2mi_reflx, x
	lda temp3
	sta sprspace+sp_l2mi_refly, x
	
@doneCalculatingXY:
	lda sprspace+sp_l2mi_state, x
	cmp #5
	bcc :+
	jmp @dontDrawMirrorGlare
	
:	; draw 4 empty sprites above and below the mirror
	lda #$F0
	sta x_crd_temp
	lda #$74
	sta y_crd_temp
	
	jsr put4Sprites
	
	lda #$A0
	sta y_crd_temp
	jsr put4Sprites
	jsr put4Sprites
	
	lda player_y
	cmp #$75
	bcc @dontDraw
	cmp #$A0
	bcs @dontDraw
	
	; check for the X coordinate
	lda temp5
	sec
	sbc #(24+16)
	cmp temp2
	bcs @dontDraw  ; mirrorLeftEdge >= reflectionX
	
	lda temp5
	clc
	adc #24
	cmp temp2
	;bcc @dontDraw  ; mirrorRightEdge < reflectionX
	bcs @doDraw
@dontDraw:
	rts

@doDraw:
	; draw the overlay
	lda temp2
	pha
	
	lda #pal_mirror
	jsr gm_allocate_palette
	sta temp8
	
	pla
	pha
	
	clc
	adc #$24
	sec
	sbc temp5
	lsr
	lsr
	lsr
	and #7
	pha
	tax
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	; draw the first sprite
	lda spriteRow1, x
	tay
	lda #$87
	sta y_crd_temp
	lda temp8
	jsr oam_putsprite
	
	; then the second
	inx
	cpx #8
	bne :+
	ldx #0
:	txa
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	lda spriteRow1, x
	tay
	lda temp8
	jsr oam_putsprite
	
	; Now for the second row
	pla
	tax
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	; the first sprite
	lda spriteRow2, x
	tay
	lda #$97
	sta y_crd_temp
	lda temp8
	jsr oam_putsprite
	
	; then the second
	inx
	cpx #8
	bne :+
	ldx #0
:	txa
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	lda spriteRow2, x
	tay
	lda temp8
	jsr oam_putsprite
	
	; done with the overlay
	pla
	sta temp2
	
@dontDrawMirrorGlare:
	ldx temp1
	lda sprspace+sp_l2mi_reflx, x
	cmp #$F8
	beq @dontDraw2
	
	lda #pal_chaser
	jsr gm_allocate_palette
	;ora #obj_backgd
	sta temp5
	sta temp8
	
	; Draw Body
	ldx plr_spr_l
	ldy plr_spr_r
	lda plattemp1
	beq :+
	ldx plr_spr_r
	ldy plr_spr_l
	lda temp5
	ora #obj_fliphz
	sta temp5
	sta temp8
:	stx temp6
	sty temp7
	
	; HACK for walking
	lda spryoff
	bpl :+
	clc
	adc temp3
	sta temp3
	
:	ldx temp1
	lda sprspace+sp_l2mi_state, x
	cmp #5
	bcs @skipOffMirrorChecks
	
	lda temp11
	cmp temp2
	bcc :+
	
	; mirrorLeftEdge >= player_x
	lda #$5E
	sta temp6
	
:	lda temp11
	clc
	adc #$30
	cmp temp2
	bcs :+
	
	; mirrorRightEdge <= player_x
	lda #$5E
	sta temp7
	
:
@skipOffMirrorChecks:
	lda sprspace+sp_l2mi_reflx, x
	cmp #$F8
	bcc :+
	
	lda #$5E
	sta temp6
	
:	jmp drawSprite

@dontDraw2:
	rts
	
put4Sprites:
	ldy #$5E
	jsr oam_putsprite
	ldy #$5E
	jsr oam_putsprite
	ldy #$5E
	jsr oam_putsprite
	ldy #$5E
	jmp oam_putsprite

drawSprite:
	lda temp2
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	
	lda temp6
	cmp #$5E
	beq :+
	
	clc
	adc #$40
	tay
	lda temp5
	jsr oam_putsprite

:	lda temp7
	cmp #$5E
	beq :+
	
	clc
	adc #$40
	tay
	lda temp2
	clc
	adc #8
	sta x_crd_temp
	lda temp8
	jmp oam_putsprite

:	rts

animateBadeline:
	; while in the reflection phase, just mirror what Madeline is doing
	lda spr0_bknum
	clc
	adc #chrb_splv2l
	sta spr1_bknum
	
	lda playerctrl
	and #pl_left
	eor #pl_left
	sta plattemp1
	
	lda sprspace+sp_l2mi_state, x
	cmp #3
	beq @running
	cmp #7
	beq @running
	cmp #8
	beq @jumping
	rts

@running:
	lda #1
	sta plattemp1
	
	lda sprspace+sp_l2mi_timer, x
	lsr
	lsr
	lsr
	pha
	
	; bank #
	and #1
	
	pha
	eor #1
	sec
	sbc #1
	sta spryoff
	pla
	
	clc
	adc #chrb_splv2l
	sta spr1_bknum
	
	pla
	; sprite #
	and #%00000010
	asl
	clc
	adc #$14
	sta plr_spr_l
	clc
	adc #2
	sta plr_spr_r
	rts

@jumping:
	lda #1
	sta plattemp1
	
	lda sprspace+sp_vel_y, x
	bne :+
	lda sprspace+sp_vel_y_lo, x
	bne :+
	lda sprspace+sp_l2mi_refly, x
	cmp #$70
	beq @running
	
:	lda #chrb_splv2l
	sta spr1_bknum
	lda #$08
	sta plr_spr_l
	lda #$0A
	sta plr_spr_r
	rts

spriteRow1:	.byte $70,$72,$74,$76,$78,$7A,$7C,$7E
spriteRow2:	.byte $40,$76,$78,$7A,$62,$64,$66,$42

moveLeftX:
	inc sprspace+sp_l2mi_timer, x
	
	lda sprspace+sp_l2mi_rlxlo, x
	sec
	sbc #maxwalkLO
	sta sprspace+sp_l2mi_rlxlo
	
	lda sprspace+sp_l2mi_reflx, x
	sbc #maxwalkHI
	sta sprspace+sp_l2mi_reflx, x
	rts

spawnParticles:
	lda temp1
	pha
	
	tax
	lda sprspace+sp_x, x
	clc
	adc #$20
	sta plattemp1
	lda sprspace+sp_x_pg, x
	adc #0
	sta temp3
	
	lda sprspace+sp_y, y
	sta plattemp2
	
	; character
	lda #$98
	sta temp4
	
	; time alive
	lda #$20
	sta temp9
	
	ldx #0
@loopSpawn:
	lda particleTable, x
	clc
	adc plattemp1
	sta temp1
	
	lda particleTable+1, x
	clc
	adc plattemp2
	sta temp2
	
	lda particleTable+2, x
	sta temp8
	
	inx
	inx
	inx
	
	stx trantmp1
	jsr gm_spawn_particle
	ldx trantmp1
	
	lda particleTable, x
	sta sprspace+sp_vel_x, y
	lda particleTable+1, x
	sta sprspace+sp_vel_x_lo, y
	lda particleTable+2, x
	sta sprspace+sp_vel_y, y
	lda particleTable+3, x
	sta sprspace+sp_vel_y_lo, y
	
	inx
	inx
	inx
	inx
	
	cpx #7 * 10
	bne @loopSpawn
	
	pla
	sta temp1
	tax
	rts

particleTable:
	; Off X, Off Y, Gravity, Vel X, Vel X Lo, Vel Y, Vel Y Lo
	.byte <-24,   0, $00, $FF, $FE, $FF, $FD
	.byte <-14,  10, $00, $FF, $FF, $FF, $FD
	.byte <- 4,   0, $00, $00, $00, $FF, $FC
	.byte <  6,  10, $00, $00, $01, $FF, $FD
	.byte < 16,   0, $00, $00, $02, $FF, $FD
	
	.byte <-24,  20, $00, $FF, $FC, $FF, $FF
	.byte <-14,  30, $00, $FF, $FD, $FF, $FF
	.byte <- 4,  20, $00, $FF, $FE, $FF, $FD
	.byte <  6,  30, $00, $00, $03, $FF, $FD
	.byte < 16,  20, $00, $00, $04, $00, $00

dataSourcesLow: 	.byte <mirrorFrame1, <mirrorFrame2, <mirrorFrame3, <mirrorFrame4, <mirrorFrame5
dataSourcesHigh:	.byte >mirrorFrame1, >mirrorFrame2, >mirrorFrame3, >mirrorFrame4, >mirrorFrame5

mirrorFrame1:
	.byte $61,$71,$72,$79
	.byte $62,$72,$73,$7A
	.byte $63,$73,$74,$7B
	.byte $64,$74,$75,$7C
	.byte $65,$75,$6D,$7D
	.byte $66,$76,$6E,$7E
mirrorFrame2:
	.byte $61,$71,$72,$5F
	.byte $62,$72,$16,$06
	.byte $63,$73,$27,$7B
	.byte $64,$4F,$28,$7C
	.byte $65,$75,$6D,$7D
	.byte $66,$76,$6E,$7E
mirrorFrame3:
	.byte $61,$01,$01,$01
	.byte $69,$01,$01,$01
	.byte $6A,$01,$01,$01
	.byte $6B,$01,$01,$01
	.byte $6C,$01,$01,$01
	.byte $66,$01,$01,$01
mirrorFrame4:
	.byte $61,$01,$01,$26
	.byte $69,$01,$17,$01
	.byte $6A,$02,$18,$01
	.byte $6B,$03,$19,$29
	.byte $6C,$01,$01,$01
	.byte $66,$01,$01,$01
mirrorFrame5:
	.byte $04,$0A,$1A,$2A
	.byte $05,$0B,$1B,$2B
	.byte $63,$0C,$1C,$2C
	.byte $07,$0D,$1D,$2D
	.byte $08,$0E,$1E,$2E
	.byte $09,$0F,$1F,$2F

.endproc

; ** IRQ HANDLER: level2_dream_block_reveal_irq
; desc: This IRQ sets the bank number to the bank that contains the activated dream blocks.
; The cutscene opens with the dream blocks glowing, then their colored form below.
.proc level2_dream_block_reveal_irq
	pha
	
	lda #mmc3bk_bg1
	sta mmc3_bsel
	lda #chrb_lvl2+2
	sta mmc3_bdat
	lda mmc3_shadow
	sta mmc3_bsel
	sta mmc3_irqdi
	
	pla
	rti
.endproc

; these rows are supposed to be copied
; first 32 tiles (written to $28C0+X)
.if 0
.byte $41,$42,$41,$42,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $4C,$5B,$4D,$5D,$55,$42,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$4D,$58,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40
.byte $00,$00,$00,$00,$00,$5B,$57,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$41,$41,$56
.byte $00,$00,$00,$00,$00,$00,$55,$42,$43,$41,$42,$37,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$41,$41,$56,$4C,$5B,$00
.byte $00,$00,$00,$00,$00,$00,$00,$5D,$5C,$4C,$4D,$55,$43,$41,$44,$F8,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$FD,$49,$5C,$4E,$00,$00,$00,$00

; last 4 tiles (written to $2CC0+X)
.byte $00,$00,$36,$42
.byte $00,$00,$47,$5C
.byte $42,$43,$56,$00
.byte $5C,$5D,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.endif
