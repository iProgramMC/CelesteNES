; Copyright (C) 2025 iProgramInCpp

; NOTE: This is included from PRG_PAUS! (For "some reason". The
; reason is that I need as much space as possible in PRG_LVL2E.

; ** SUBROUTINE: level2_init_adv_trace
; desc: Initializes the advanced trace.  Note that this does not
.proc level2_init_adv_trace
	ldy #0
	sty advtracehd
	
	lda #1
	sta advtracesw
	; fallthrough
.endproc

.proc level2_dark_chaser_otherbank
	ldx temp1
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
	jmp gm_draw_common2

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
:	jsr gm_draw_common2
	
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
:	jsr gm_draw_common2
	
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
