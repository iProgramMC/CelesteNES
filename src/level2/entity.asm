; Copyright (C) 2025 iProgramInCpp

;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

level2_payphone_table:
	.word level2_payphone_idle       ; idle
	.word level2_payphone_mad1       ; pickUp
	.word level2_payphone_mad2       ; pickUp
	.word level2_payphone_mad3       ; pickUp
	.word level2_payphone_mad4       ; pickUp
	.word level2_payphone_mad5       ; pickUp
	.word level2_payphone_mad6       ; pickUp
	.word level2_payphone_mad7       ; pickUp
	.word level2_payphone_mad8       ; pickUp
	.word level2_payphone_mad9       ; pickUp, talkPhone
	.word level2_payphone_madjump1   ; jumpBack
	.word level2_payphone_madjump2   ; jumpBack
	.word level2_payphone_madjump3   ; jumpBack
	.word level2_payphone_madjump4   ; jumpBack, scare
	.word level2_payphone_xform1     ; transform
	.word level2_payphone_xform2     ; transform
	.word level2_payphone_xform3     ; transform
	.word level2_payphone_xform4     ; transform
	.word level2_payphone_xform5     ; transform
	.word level2_payphone_xform6     ; transform
	.word level2_payphone_xform7     ; transform
	.word level2_payphone_xform8     ; transform
	.word level2_payphone_xform9     ; transform
	.word level2_payphone_xform10    ; transform
	.word level2_payphone_xform11    ; transform
	.word level2_payphone_xform12    ; transform
	.word level2_payphone_xform13    ; transform
	.word level2_payphone_monsterI   ; transform
	.word level2_payphone_monster1   ; transform
	.word level2_payphone_monster2   ; transform
	.word level2_payphone_monstere1  ; eat
	.word level2_payphone_monstere2  ; eat
	.word level2_payphone_monstere3  ; eat
	.word level2_payphone_monstere4  ; eat
	.word level2_payphone_monstere5  ; eat
	.word level2_payphone_monstere6  ; eat
	.word level2_payphone_monstere7  ; eat
	.word level2_payphone_monsterd1  ; eat
	.word level2_payphone_monsterd2  ; eat
	.word level2_payphone_monsterd3  ; eat
	.word level2_payphone_monsterd4  ; eat
	.word level2_payphone_monsterd5  ; eat
	.word level2_payphone_monsterd6  ; eat
	.word level2_payphone_monsterd7  ; eat
	.word level2_payphone_monsterd8  ; eat
	.word level2_payphone_monsterd9  ; eat
	.word level2_payphone_monsterd10 ; eat
	.word level2_payphone_monsterd11 ; eat
	.word level2_payphone_monsterd10 ; eat
	.word level2_payphone_monsterd12 ; eat
	.word level2_payphone_monsterd2  ; monsterIdle
	.word $0000

level2_payphone_table_lo:	.lobytes level2_payphone_table
level2_payphone_table_hi:	.hibytes level2_payphone_table
level2_payphone_max_timer = 52

; idle, pickUp, talkPhone, jumpBack, scare, transform, eat
level2_payphone_anims_start:	.byte $00, $01, $09, $0A, $0D, $0E, $1E, $32
level2_payphone_anims_length:	.byte $01, $09, $01, $04, $01, $10, $14, $01

; ######### ANIMATION CODE #########

; ** ENTITY: level2_payphone
; desc: This draws and animates the payphone entity.
.proc level2_payphone
@currentPalette := temp10
	lda currA000bank
	pha
	ldy #prgb_lvl2a
	lda #mmc3bk_prg1
	jsr mmc3_set_bank
	
	ldx temp1
	lda sprspace+sp_flags, x
	ora #ef_timerspec2
	sta sprspace+sp_flags, x
	
	; load the current animation state
	ldy sprspace+sp_l2ph_state, x
	
	; Celeste's anim frame delay is 0.080 which is close to 5 frames. (4.8, to be exact)
	; We'll just advance the timer every 5 frames, meaning our anim will play slightly
	; slower.
	inc sprspace+sp_l2ph_sbtmr, x
	lda sprspace+sp_l2ph_sbtmr, x
	cmp #5
	bcc @noIncrementMainTimer
	lda #0
	sta sprspace+sp_l2ph_sbtmr, x
	inc sprspace+sp_l2ph_timer, x
	
	; check if the timer exceeds the length of this animation
	lda sprspace+sp_l2ph_timer, x
	cmp level2_payphone_anims_length, y
	bcc @noExceed
	
	lda level2_payphone_anims_length, y
	sec
	sbc #1
	sta sprspace+sp_l2ph_timer, x

@noExceed:
@noIncrementMainTimer:
	lda sprspace+sp_l2ph_timer, x
	clc
	adc level2_payphone_anims_start, y
	asl
	tax
	lda level2_payphone_table, x
	sta setdataaddr
	inx
	lda level2_payphone_table, x
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
	bpl :+
	cmp #pph_exit
	beq @return
	cmp #pph_jump
	beq @jump
	cmp #pph_call
	beq @call
	cmp #pph_return
	beq @returnInsn
	cmp #pph_plrbrace
	beq @playerInsn_
	cmp #pph_palette
	beq @palette
:	clc
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
	lda @currentPalette
	sta oam_buf, x
	inx
	
	; write X coordinate
	lda (setdataaddr), y
	clc
	adc temp2
	sta oam_buf, x
	bcs @detour
@detoured:
	inx
	iny
	stx oam_wrhead
	jmp @loop

@return:
	pla
	tay
	lda #mmc3bk_prg1
	jsr mmc3_set_bank
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

@returnInsn:
	pla
	sta setdataaddr
	pla
	sta setdataaddr+1
	ldy #0
@loop_:
	beq @loop

@call:
	iny
	lda (setdataaddr), y
	sta plattemp1
	iny
	lda (setdataaddr), y
	sta plattemp2
	iny
	
	; this will be our return address
	tya
	clc
	adc setdataaddr
	sta setdataaddr
	bcc :+
	inc setdataaddr+1
:	lda setdataaddr+1
	pha
	lda setdataaddr
	pha
	
	lda plattemp1
	sta setdataaddr
	lda plattemp2
	sta setdataaddr+1
	ldy #0
	beq @loop_

@playerInsn_:
	beq @playerInsn

@palette:
	stx oam_wrhead
	iny
	sty temp11
	lda (setdataaddr), y
	bmi :+
	jsr gm_allocate_palette
:	and #$7F
	ldy temp11
	ldx oam_wrhead
	iny
	
	sta @currentPalette
	jmp @loop

@detour:
	; carry set! is the current X coordinate offset negative ?
	lda (setdataaddr), y
	bmi @detoured
	
	; no, positive. this means that it was not supposed to overflow
	dex
	dex
	dex
	lda #$FF
	sta oam_buf, x
	iny
	jmp @loop

@playerInsn:
	tya
	pha
	
	; quick macro for the player standing at offset $F1, $28
	lda #pal_red
	jsr gm_allocate_palette
	sta temp11
	
	lda #$28
	clc
	adc temp3
	sta y_crd_temp
	
	lda #$F1
	clc
	adc temp2
	sta x_crd_temp
	
	; body
	ldy #$74
	lda #0
	jsr oam_putsprite
	
	; hair
	ldy #$32
	lda temp11
	jsr oam_putsprite
	
	; body
	ldy #$76
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	lda #0
	jsr oam_putsprite
	
	; hair
	ldy #$30
	lda temp11
	jsr oam_putsprite
	
	pla
	tay
	iny
	ldx oam_wrhead
	jmp @loop
.endproc

; ** ENTITY: level2_mirror
; desc: The mirror that unlocks the Dream Blocks!
.proc level2_mirror
	lda dbenable
	beq @dreamBlocksNotEnabled
	
	; there are still things to do?
	lda sprspace+sp_l2mi_state, x
	bne @dreamBlocksNotEnabled
	
	lda #g3_transitA
	bit gamectrl3
	bne @returnDBE
	
	lda gamectrl
	and #<~gs_camlock
	sta gamectrl
	
	; Dream Blocks are enabled, so set the broken mirror already and stop
	lda #<level2_mirror_frame_5
	sta setdataaddr
	lda #>level2_mirror_frame_5
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
	
	ldx temp1
	lda #0
	sta sprspace+sp_kind, x
	
@returnDBE:
	rts
	
@dreamBlocksNotEnabled:
	jsr animateBadeline
	jsr drawBadeline
	
	ldx temp1
	lda sprspace+sp_l2mi_state, x
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
	bcs @state_RevealDreamBlockScene_

@state_Idle:
	lda player_x
	cmp #$90
	bcc @return
	
	; reflected, now wait for her to come back
	jsr @stateIdleReturn
@return:
	rts

@state_Reflected:
	lda player_x
	cmp #$B8
	bcc @return
	
	; came back, begin the cutscene and wait
	inc sprspace+sp_l2mi_state, x
	
	lda temp1
	pha
	
	;txa
	ldx #<ch2_mirror_shatter
	ldy #>ch2_mirror_shatter
	jsr beginCutsceneAndCheckPlayerX
	
	pla
	sta temp1
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

@state_BegunScene:
@state_BadelineWait:
@state_BadelineWait2:
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

@state_RevealDreamBlockScene_:
	bcs @state_RevealDreamBlockScene
	
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
	
	lda #0
	sta sprspace+sp_l2mi_timer, x
	rts

@state_ShatterMirror:
	lda sprspace+sp_l2mi_timer, x
	inc sprspace+sp_l2mi_timer, x
	
	cmp #12
	bne @dontStartQuaking
	
	lda #15
	sta quakeflags
	lda #20
	sta quaketimer
	
	lda #12
	
@dontStartQuaking:
	cmp #16
	bne @dontSpawnParticles
	
	; Spawn Particles
	;jsr spawnParticles
	
@dontSpawnParticles:
	cmp #23
	bcc :+
	lda #23
:	lsr
	lsr
	tax
	lda level2_mirror_frames_lo, x
	sta setdataaddr
	lda level2_mirror_frames_hi, x
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

@state_RevealDreamBlockScene:
	; the dream block reveal
	cmp #9
	beq @state_RevealDreamBlock_ScrollUp
	cmp #10
	beq @state_RevealDreamBlock_Glow_
	cmp #11
	beq @state_RevealDreamBlock_Unveil
	cmp #12
	beq @state_RevealDreamBlock_ScrollDown
	rts

@stateIdleReturn:
	inc sprspace+sp_l2mi_state, x
	;lda gamectrl
	;ora #gs_camlock
	;sta gamectrl
	rts

@state_RevealDreamBlock_Unveil:
	; Reveal the Dream Block
	lda #chrb_lvl2d
	sta bg1_bknum
	
	; The timer is supposed to go down from 168 to 72.
	ldx temp1
	lda sprspace+sp_l2mi_timer, x
	
	sta miscsplit
	
	lda #<level2_dream_block_reveal_irq
	sta irqaddr
	lda #>level2_dream_block_reveal_irq
	sta irqaddr+1
	
	lda #2
	sta quaketimer
	lda #7
	sta quakeflags
	
	; may be dangerous?!
	lda framectr
	and #3
	bne :+
	
	dec sprspace+sp_l2mi_timer, x
	lda #0
	sta framectr
	
	; decrement only half of the time
:	lda sprspace+sp_l2mi_timer, x
	cmp #72
	bcs @returnReveal
	
	inc sprspace+sp_l2mi_state, x
	lda #0
	sta sprspace+sp_l2mi_timer, x
	
	lda #chrb_lvl2+2
	sta bg1_bknum
	
	inc dbenable
	
@returnReveal:
	rts

@state_RevealDreamBlock_ScrollUp:
	; for the course of 10 frames, scroll up
	ldx temp1
	ldy sprspace+sp_l2mi_timer, x
	cpy #20
	bcs @dontDoThat1
	
	lda camera_y_sub
	and #%111
	bne :+
	
	jsr revealDreamBlock_revealRowUpper
	
:	lda camera_y_sub
	sec
	sbc #4
	sta camera_y_sub
	
	inc sprspace+sp_l2mi_timer, x
	rts

@state_RevealDreamBlock_Glow_:
	beq @state_RevealDreamBlock_Glow
	
@dontDoThat1:
	lda #136
	sta sprspace+sp_l2mi_timer, x
	rts

@state_RevealDreamBlock_ScrollDown:
	; for the course of 10 frames, scroll down
	ldx temp1
	ldy sprspace+sp_l2mi_timer, x
	cpy #20
	bcs @dontDoThat2
	
	lda camera_y_sub
	and #%111
	bne :+
	
	jsr revealDreamBlock_revealRowLower
	
:	lda camera_y_sub
	clc
	adc #4
	sta camera_y_sub
	
	inc sprspace+sp_l2mi_timer, x
	rts
	
@dontDoThat2:
	lda #0
	sta sprspace+sp_l2mi_state, x
	sta sprspace+sp_l2mi_timer, x
	rts

@state_RevealDreamBlock_Glow:
	; NOTE: The timer starts at 136, actually!!
	lda sprspace+sp_l2mi_timer, x
	inc sprspace+sp_l2mi_timer, x
	cmp #(32+136)
	bcc @dontStartUnveiling
	
	; wait for the unveiling state but 
	lda #168
	sta sprspace+sp_l2mi_timer, x
	lda #chrb_lvl2d
	sta bg1_bknum
	bne @skipUnveilFrames
	
@dontStartUnveiling:
	sbc #(168-1) ; since carry is clear
	and #%00011000
	lsr
	lsr
	clc
	adc #chrb_lvl2e
	sta bg1_bknum
	
@skipUnveilFrames:
	; though we do not want the bank to be overridden, so set miscsplit to a non-zero
	; value and keep the idle handler
	lda #<irq_idle
	sta irqaddr
	lda #>irq_idle
	sta irqaddr+1
	lda #$C0
	sta miscsplit
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
	beq @dontDraw2
	cmp #6
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

beginCutsceneAndCheckPlayerX:
	jsr dlg_begin_cutscene_g
	lda #$C2
	cmp player_x
	bcs :+
	sta player_x
:	lda #0
	sta dashtime
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
	ldy #0
	lda sprspace+sp_l2mi_state, x
	cmp #3
	beq :+
	iny
:	sty plattemp1
	
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

revealDreamBlock_revealRowUpper:
	tya
	lsr
	tay
	
	lda level2_db_opening_rows_lo, y
	sta setdataaddr
	lda level2_db_opening_rows_hi, y
	sta setdataaddr+1
	
	lda #29<<1
	sec
	sbc sprspace+sp_l2mi_timer, x
	lsr
	tay
	
	jmp revealDreamBlock_revealRow_farCall

revealDreamBlock_revealRowLower:
	tya
	lsr
	tay
	
	lda level2_db_closing_rows_lo, y
	sta setdataaddr
	lda level2_db_closing_rows_hi, y
	sta setdataaddr+1
	
	lda sprspace+sp_l2mi_timer, x
	lsr
	clc
	adc #20
	tay
	jmp revealDreamBlock_revealRow_farCall

revealDreamBlock_revealRow:
	lda roombeglo2
	tax
	sta temp11
	clc
	adc #36          ; the other end
	and #$1F         ; get its X in nametable coordinates
	sta wrcountHR2   ; that'll be how many bytes we need to write
	
	lda #36
	sec
	sbc wrcountHR2
	sta wrcountHR1
	
	; calculate the ppu addresses we need to write to
	jsr h_calcppuaddr
	
	lda clearpalo
	sta ppuaddrHR1
	and #%11100000
	sta ppuaddrHR2
	
	lda clearpahi
	sta ppuaddrHR1+1
	eor #$04
	sta ppuaddrHR2+1
	
	ldy #0
	sty wrcountHR3
	sty wrcountHP1
	sty wrcountHP2
	
	lda temp11
	and #$1F
	tax
@writeLoop:
	lda (setdataaddr), y
	cpx #32
	bcs @writeOtherHalf
	sta temprow1, y
	inx
	iny
	cpy #36
	bne @writeLoop
	beq @endWriteLoop

@writeOtherHalf:
	sta temprow2-32, x
	inx
	iny
	cpy #36
	bne @writeLoop
	
@endWriteLoop:
	lda nmictrl
	ora #nc_flushrow
	sta nmictrl
	
	ldx temp1
	rts

revealDreamBlock_revealRow2:
	lda temp9
	ldx temp10
	ldy temp11
	jmp revealDreamBlock_revealRow

revealDreamBlock_revealRow_farCall:
	sta temp9
	stx temp10
	sty temp11
	
	; far call to load the level data bank back in
	ldx #<revealDreamBlock_revealRow2
	ldy #>revealDreamBlock_revealRow2
	lda lvldatabank
	jmp far_call2
.endproc

; ** IRQ HANDLER: level2_dream_block_reveal_irq
; desc: This IRQ sets the bank number to the bank that contains the activated dream blocks.
; The cutscene opens with the dream blocks glowing, then their colored form below.
.proc level2_dream_block_reveal_irq
	pha
	
	lda #(mmc3bk_bg1|def_mmc3_bn)
	sta mmc3_bsel
	lda #chrb_lvl2+2
	sta mmc3_bdat
	lda mmc3_shadow
	sta mmc3_bsel
	sta mmc3_irqdi
	
	pla
	rti
.endproc

; Dream block opening cutscene data was here, but moved out to bank_3.asm

.proc level2_campfire
	lda #chrb_splvl2
	sta spr1_bknum
	
	ldx dbenable
	lda palettes, x
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	
	ldx temp1
	lda sprspace+sp_l2cf_timer, x
	inc sprspace+sp_l2cf_timer, x
	
	lsr
	and #%00011100
	clc
	adc #$40
	sta temp6
	
	clc
	adc #2
	sta temp7
	
	jmp gm_draw_common

palettes:	.byte pal_green, pal_green, pal_green, pal_fire
.endproc

; ** SUBROUTINE: level2_init_adv_trace
; desc: Initializes the advanced trace.  Note that this does not
.proc level2_init_adv_trace
	ldy #0
	sty advtracehd
	
	lda #1
	sta advtracesw
	; fallthrough
.endproc

.proc level2_dark_chaser
	lda sprspace+sp_l2dc_state, x
	cmp #4
	bcc :+
	jmp @state_Cutscene
	
:	lda #g3_transitA
	bit gamectrl3
	bne @return2
	
	lda advtracesw
	beq level2_init_adv_trace
	
	lda #$5C
	sta temp6
	lda #$5E
	sta temp7
	
	lda sprspace+sp_l2dc_state, x
	cmp #2
	beq @state_Chase_
	cmp #1
	beq @state_Tween
	cmp #3
	bne :+
	jmp @state_Dead
:	lda sprspace+sp_l2dc_timer, x
	bne @alreadyPoppedIn
	
	; check if we can pop her in
	lda chasercdown
	bne @return2
	
@alreadyPoppedIn:
	lda #20
	sta chasercdown
	
	; pop into existence
	jsr incrementPoppingInTimer
	
	inc sprspace+sp_l2dc_timer, x
	lda sprspace+sp_l2dc_timer, x
	cmp #24
	bcc @drawTweeningPlayer
	
	; prepare the tween
	jsr prepareTween
	
	; increment the state to 1 which is the tweening state.
	inc sprspace+sp_l2dc_state, x
	
	lda advtracehd
	sta sprspace+sp_l2dc_index, x
	
	lda #adv_trace_hist_size
	sta sprspace+sp_l2dc_timer, x
	
@drawTweeningPlayer:
	; pick some default sprites
	lda #chrb_splv2b
	sta spr1_bknum
	
	jsr calculateXYOnScreen
	
	lda #pal_chaser
	jsr gm_allocate_palette
	ldx temp11
	bpl @dontSwap
	ldx temp6
	ldy temp7
	sty temp6
	stx temp7
	ora #obj_fliphz
@dontSwap:
	sta temp5
	sta temp8
	jmp level2_draw_common_replacement

@return2:
	rts

@state_Chase_:
	beq @state_Chase

@incrementStateToDead_:
	jmp @incrementStateToDead
@setStateToDeadNoCopyPos_:
	jmp @setStateToDeadNoCopyPos

@state_Tween:
	; chaser is tweening towards the player
	lda sprspace+sp_x_lo, x
	clc
	adc sprspace+sp_vel_x_lo, x
	sta sprspace+sp_x_lo, x
	
	lda sprspace+sp_x, x
	adc sprspace+sp_vel_x, x
	sta sprspace+sp_x, x
	
	lda sprspace+sp_x_pg, x
	adc sprspace+sp_l2dc_velxh, x
	sta sprspace+sp_x_pg, x
	
	lda sprspace+sp_y_lo, x
	clc
	adc sprspace+sp_vel_y_lo, x
	sta sprspace+sp_y_lo, x
	
	lda sprspace+sp_y, x
	adc sprspace+sp_vel_y, x
	sta sprspace+sp_y, x
	
	lda playerctrl
	and #pl_dead
	bne @setStateToDeadNoCopyPos_
	
	dec sprspace+sp_l2dc_timer, x
	bne @drawTweeningPlayer
	
	; start actually chasing
	inc sprspace+sp_l2dc_state, x
	bne @drawTweeningPlayer

@state_Chase:
	; check if the player is dead
	lda playerctrl
	and #pl_dead
	bne @incrementStateToDead_
	
	; then we will recalculate the position in temp2, temp3, and temp4
	lda sprspace+sp_l2dc_index, x
	clc
	adc #1
	and #(adv_trace_hist_size - 1)
	sta sprspace+sp_l2dc_index, x
	tay
	
	; calculate Y, the simplest
	lda adv_trace_y, y
	sec
	sbc camera_y
	bcs :+
	sbc #15
	clc
:	sta temp3
	sta sprspace+sp_y, x
	
	lda adv_trace_y_hi, y
	sbc camera_y_hi
	bne @return2
	
	lda temp3
	sec
	sbc camera_y_sub
	sta temp3
	
	lda adv_trace_x, y
	sta sprspace+sp_x, x
	sec
	sbc camera_x
	sta temp2
	
	lda adv_trace_x_pg, y
	sta sprspace+sp_x_pg, x
	sbc camera_x_pg
	sta temp4
	
	sty temp9
	lda #pal_chaser
	jsr gm_allocate_palette
	sta temp5
	
	ldy temp9
	lda adv_trace_pc, y
	lsr
	and #%00000011
	; facing state is now in carry
	sta plattemp1
	
	lda #0
	ror
	lsr
	sta temp11
	ora temp5
	sta temp5
	sta temp8
	
	; the goal is to load the OTHER bank into spr1_bknum
	; the reason why is because spr0_bknum may change. And we are trying to draw the character
	; again, potentially from a different bank.
	;
	; If we're trying to draw from the same bank as spr0_bknum, then so be it, just use that bank.
	; Else, we'll use our reserved bank, thank you very much :)
	lda spr0_bknum
	eor #1
	sta spr1_bknum
	
	; now compare the two banks. we'll add either 0 or $40, depending on whether or not
	; the sprite bank we are trying to use is loaded into spr0 or spr1
	lda spr0_bknum
	cmp plattemp1
	beq @load0
	; load #$40 to the diff
	lda #$40
	sta plattemp2
	bne @doneWithBankDiscrim
	
@load0:
	; load #$00 to the diff, since
	lda #0
	sta plattemp2
@doneWithBankDiscrim:
	
	; draw the body
	sty temp9
	
	lda adv_trace_sl, y
	clc
	adc plattemp2
	sta temp6
	lda adv_trace_sr, y
	clc
	adc plattemp2
	sta temp7
	lda temp11
	beq :+
	lda temp7
	ldy temp6
	sta temp6
	sty temp7
:	jsr level2_draw_common_replacement
	
	; determine sprxoff (11000000) and spryoff (00111000)
	ldy temp9
	
	lda adv_trace_pc, y
	rol
	rol
	rol
	and #%00000011
	sta temp10
	and #%11111110
	bne @negativeSprXOff
	
	; positive sprxoff
	lda temp11
	bne @positiveFacingLeft
	
	; positive and facing right
	lda temp2
	clc
	adc temp10
	sta temp2
	bcc :+
	inc temp4
:	jmp @doneSprXOff

@return:
	rts

@positiveFacingLeft:
	; positive and facing left
	lda temp2
	sec
	sbc temp10
	sta temp2
	bcs :+
	dec temp4
:	jmp @doneSprXOff

@negativeSprXOff:
	; negative sprxoff
	lda temp11
	bne @negativeFacingLeft
	
	; negative and facing right
	lda temp2
	bne :+
	dec temp4
:	dec temp2
	jmp @doneSprXOff
	
@negativeFacingLeft:
	inc temp2
	bne @doneSprXOff
	inc temp4
	
@doneSprXOff:
	; finally done with sprxoff, now do the same with spryoff
	ldy temp9
	lda adv_trace_pc, y
	lsr
	lsr
	lsr
	and #%00000111
	; expand the sign
	sta temp10
	and #%11111100
	beq :+
	lda #%11111100
:	ora temp10
	; then add it to the Y
	clc
	adc temp3
	sta temp3
	
	; then the hair
	lda adv_trace_hl, y
	clc
	adc plattemp2
	sta temp6
	lda adv_trace_hr, y
	clc
	adc plattemp2
	sta temp7
	lda temp11
	beq :+
	lda temp7
	ldy temp6
	sta temp6
	sty temp7
:	jsr level2_draw_common_replacement
	
	; finally, check the hitbox
	lda #6
	sta temp7
	lda #10
	sta temp8
	sta temp9
	lda #16
	sta temp10
	
	ldy temp1
	jsr gm_check_collision_ent
	beq @return
	
	; collided!
	jmp gm_killplayer

@state_Dead:
	lda #chrb_lvl2b
	sta spr1_bknum
	
	; what's so funny huh?
	inc sprspace+sp_l2dc_timer, x
	lda sprspace+sp_l2dc_timer, x
	lsr
	lsr
	and #3
	tay
	lda laughingSprites, y
	sta temp6
	clc
	adc #2
	sta temp7
	
	jmp @drawTweeningPlayer

@incrementStateToDead:
	lda #3
	sta sprspace+sp_l2dc_state, x
	
	ldy sprspace+sp_l2dc_index, x
	
	; copy the player's positions
	lda adv_trace_x, y
	sta sprspace+sp_x, x
	lda adv_trace_x_pg, y
	sta sprspace+sp_x_pg, x
	
	lda #0
	sta sprspace+sp_l2dc_timer, x
	beq @state_Dead

@setStateToDeadNoCopyPos:
	lda #3
	sta sprspace+sp_l2dc_state, x
	lda #0
	sta sprspace+sp_l2dc_timer, x
	beq @state_Dead

@state_Cutscene:
	lda #g3_transitA
	bit gamectrl3
	bne @state_CutsceneWait
	
	lda sprspace+sp_l2dc_state, x
	cmp #5
	beq @state_CutsceneWait
	cmp #10
	beq @state_StartChasing
	
	lda dbenable
	cmp #2
	bcc @continue
	
	lda #0
	sta sprspace+sp_l2dc_state, x
	rts
	
@continue:
	jsr @state_CutsceneWait
	
	inc sprspace+sp_l2dc_state, x
	txa
	pha
	
	;txa
	ldx #<ch2_badeline_start
	ldy #>ch2_badeline_start
	jsr dlg_begin_cutscene_g
	lda #2
	sta dbenable
	
	pla
	sta temp1
@return3:
	rts

@state_StartChasing:
	lda #0
	sta sprspace+sp_l2dc_state, x
	lda #20
	sta sprspace+sp_l2dc_timer, x
	rts

@state_CutsceneWait:
	lda #$60
	sta temp6
	lda #$62
	sta temp7
	lda #0
	sta temp11
	jmp @drawTweeningPlayer

incrementPoppingInTimer:
	ldy sprspace+sp_l2dc_ssize, x
	iny
	cpy #23
	bcc :+
	ldy #23
:	tya
	sta sprspace+sp_l2dc_ssize, x
	lsr
	lsr
	lsr
	tay
	lda poppingInSprites, y
	sta temp6
	clc
	adc #2
	sta temp7
	rts

poppingInSprites:	.byte $50,$54,$58,$5C
laughingSprites:	.byte $40,$44,$48,$4C

calculateXYOnScreen:
	; don't care about the result, only that it calculates temp2 and temp4 for us
	lda sprspace+sp_x, x
	sec
	sbc camera_x
	sta temp2
	lda sprspace+sp_x_pg, x
	sbc camera_x_pg
	sta temp4
	
	lda sprspace+sp_y, x
	sta temp3
	rts

prepareTween:
	ldy #0
	sty temp10
	
	lda camera_x
	clc
	adc player_x
	sta temp11
	
	lda camera_x_pg
	adc #0
	sta temp9
	
	lda temp11
	sec
	sbc sprspace+sp_x, x
	sta temp11
	
	lda temp9
	sbc sprspace+sp_x_pg, x
	;sta temp9
	
	; [A Reg, temp11, temp10] represents, the amount to move IN TOTAL. shift it by 5
.repeat 6, i
	cmp #$80
	ror
	ror temp11
	ror temp10
.endrepeat
	
	sta sprspace+sp_l2dc_velxh, x
	lda temp11
	sta sprspace+sp_vel_x, x
	lda temp10
	sta sprspace+sp_vel_x_lo, x
	
	; same for Y now
	sty temp10
	
	lda player_y
	sec
	sbc sprspace+sp_y, x
	
.repeat 6, i
	cmp #$80
	ror
	ror temp10
.endrepeat
	sta sprspace+sp_vel_y, x
	lda temp10
	sta sprspace+sp_vel_y_lo, x
	rts

.endproc

; ** SUBROUTINE: level2_draw_common_replacement
; desc: Replaces gm_draw_common.
;       gm_draw_common has one major flaw - it doesn't handle out of bounds
.proc level2_draw_common_replacement
	
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
