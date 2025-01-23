; Copyright (C) 2024-2025 iProgramInCpp
; Level 0 specific entities.

; ** Entity Draw/Update routines
; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

; ** ENTITY: level0_granny
; desc: This is Granny. She will initiate dialog with Madeline when approached.
level0_granny:
	; Granny States
	@idle  = 0
	@walk  = 1
	@laugh = 2
	
	; ensure her bank is loaded
	lda #chrb_splvl0
	sta spr1_bknum
	
	lda sprspace+sp_l0gr_ttimr, x
	bne :+
	lda #1
	sta sprspace+sp_l0gr_ttimr, x
	
:	lda #pal_granny
	jsr gm_allocate_palette
	ldx temp1
	sta temp5
	
	lda sprspace+sp_flags, x
	and #ef_faceleft
	; assert(ef_faceleft == $80)
	lsr
	ora temp5
	sta temp5
	sta temp8
	
	lda sprspace+sp_l0gr_state
	bne @notIdle
	
	; idle
	dec sprspace+sp_l0gr_ttimr, x
	bne :+
	lda #20
	sta sprspace+sp_l0gr_ttimr, x
	inc sprspace+sp_l0gr_timer, x
	
:	lda sprspace+sp_l0gr_timer, x
	and #3
	tay
	lda @idleAnim, y
	sta temp6
	bne @stateDone
	
@notIdle:
	cmp #@walk
	bne @notWalk
	
	; walking
	dec sprspace+sp_l0gr_ttimr, x
	bne :+
	lda #12
	sta sprspace+sp_l0gr_ttimr, x
	inc sprspace+sp_l0gr_timer, x
	
:	lda sprspace+sp_l0gr_timer, x
	and #1
	tay
	lda @walkAnim, y
	sta temp6
	bne @stateDone
	
@notWalk:
	cmp #@laugh
	bne @notLaugh
	
	; laughing
	dec sprspace+sp_l0gr_ttimr, x
	bne :+
	lda #12
	sta sprspace+sp_l0gr_ttimr, x
	inc sprspace+sp_l0gr_timer, x
	
:	lda sprspace+sp_l0gr_timer, x
	and #1
	tay
	lda @laughAnim, y
	sta temp6
	bne @stateDone
	
@notLaugh:
@stateDone:
	lda temp6
	clc
	adc #2
	sta temp7
	
	lda sprspace+sp_flags, x
	and #ef_faceleft
	beq @dontFlip
	
	lda temp6
	pha
	lda temp7
	sta temp6
	pla
	sta temp7
	
@dontFlip:
	jsr gm_draw_common
	
	; Check if the player is at position 64 or greater.
	lda player_x
	cmp #$40
	bcc @return
	
	; Check if Granny already initiated the cutscene
	lda sprspace+sp_l0gr_cutsc, x
	bne @return
	
	lda #g3_transitA
	bit gamectrl3
	bne @return
	
	lda player_y
	cmp #$73
	bcs @return
	
	lda #pl_ground
	bit playerctrl
	beq @return
	
	lda dbenable
	bne @return
	
	lda #1
	sta sprspace+sp_l0gr_cutsc, x
	
	inc dbenable
	
	lda temp1
	pha
	
	txa
	ldx #<ch0_granny
	ldy #>ch0_granny
	jsr dlg_begin_cutscene_g
	
	pla
	sta temp1
@return:
	rts

@idleAnim:	.byte $40,$44,$48,$4C
@laughAnim:	.byte $50,$54
@walkAnim:	.byte $58,$5C

; ** ENTITY: level0_bird_climb
; desc: This is the tutorial bird that teaches you how to climb.
.proc level0_bird_climb
boxSize = tmpRoomTran + 5
	
	; update the bird
	lda sprspace+sp_l0bc_state, x
	beq @idleState
	cmp #1
	beq @climbHintState
	cmp #2
	beq @fleeState
	
@idleState:
	lda #0
	sta boxSize
	
	lda #$72
	sta temp6
	lda #$70
	sta temp7
	
	lda temp2
	sec
	sbc #100
	cmp player_x
	bcs @drawBankB
	
	; move on to the "tutorial" phase
	inc sprspace+sp_l0bc_state, x
	lda #0
	sta sprspace+sp_l0bc_timer, x

@drawBankB:
	; ensure the bird's bank is loaded
	lda #chrb_splv0b
	sta spr1_bknum

@draw:
	lda #pal_bird
	jsr gm_allocate_palette
	ora #obj_fliphz
@draw2:
	sta temp5
	sta temp8
	jmp gm_draw_common

@climbHintState:
	; draw the climb hint bubble
	lda sprspace+sp_l0bc_timer, x
	cmp #14
	bcc :+
	jsr drawClimbingHint
	
	; check if the player's higher than the bird and on the ground
:	lda playerctrl
	and #pl_ground
	beq @dontFlee
	
	lda temp3
	cmp player_y
	bcc @dontFlee
	
	inc sprspace+sp_l0bc_state, x
	lda #0
	sta sprspace+sp_l0bc_timer, x
	
	lda #(cont_up | cont_left)
	sta quakeflags
	lda #1
	sta quaketimer
	
	jsr gm_whoosh_sfx
	
@dontFlee:
	; finally, draw the bird, cawing
	lda sprspace+sp_l0bc_timer, x
	inc sprspace+sp_l0bc_timer, x
	cmp #24
	bcc :+
	lda #24
	sta sprspace+sp_l0bc_timer, x
:	cmp #10
	bne :+
	jsr playSoundEffect
:	lsr
	lsr
	lsr
	tay
	lda spriteIndicesCaw, y
	sta temp7
	clc
	adc #2
	sta temp6
	bne @drawBankB

@fleeState:
	; we need the full bird frame set
	lda sprspace+sp_l0bc_timer, x
	inc sprspace+sp_l0bc_timer, x
	cmp #11
	bcc @stayOnNormalBank
	
	lda #chrb_splvl0
	sta spr1_bknum

@stayOnNormalBank:
	lda boxSize
	beq @boxSizeIsZero
	
	dec boxSize
	beq @boxSizeIsZero  ; fail-safe
	dec boxSize
	beq @boxSizeIsZero  ; fail-safe
	
	jsr drawClimbingHint
	
	; since it incremented the size, decrement it again
	dec boxSize
	
@boxSizeIsZero:
	lda sprspace+sp_l0bc_timer, x
	inc sprspace+sp_l0bc_timer, x
	
	cmp #32
	bcs @notInitialLeap
	; initial leap
	jsr addOneToXPosition
	lda sprspace+sp_y, x
	sec
	sbc #1
	sta sprspace+sp_y, x
	
	lda sprspace+sp_l0bc_timer, x
	lsr
	lsr
	tay
	lda spriteIndicesFleeInitial, y
	sta temp7
	clc
	adc #2
	sta temp6
	jmp @draw

@notInitialLeap:
	jsr addOneToXPosition
	
	lda sprspace+sp_vel_y_lo, x
	clc
	adc #$20
	sta sprspace+sp_vel_y_lo, x
	bcc :+
	inc sprspace+sp_vel_y, x

:	lda sprspace+sp_y_lo, x
	sec
	sbc sprspace+sp_vel_y_lo, x
	sta sprspace+sp_y_lo, x
	
	lda sprspace+sp_y, x
	sbc sprspace+sp_vel_y, x
	sta sprspace+sp_y, x
	
	; if went off screen, despawn
	bcc @despawn
	
	lda sprspace+sp_l0bc_timer, x
	lsr
	lsr
	lsr
	and #3
	tay
	lda spriteIndicesFleeNormal, y
	sta temp6
	clc
	adc #2
	sta temp7
	
	lda #pal_bird
	jsr gm_allocate_palette
	jmp @draw2

@despawn:
	lda #0
	sta sprspace+sp_kind, x
	rts

drawClimbingHint:
	lda #pal_bubble
	jsr gm_allocate_palette
	sta temp9
	
	inc boxSize
	lda boxSize
	cmp #8
	bcc @bigEnough
	lda #8
	sta boxSize
@bigEnough:
	
	lda boxSize
	asl
	asl
	; carry is already clear I hope! (since we just shifted out zeroes)
	adc boxSize
	lsr
	sta temp11
	
	lda temp2      ; X position
	clc
	adc #8
	sec
	sbc temp11
	sta x_crd_temp
	
	; note: hardcoded offset left
	lda boxSize
	lsr
	tay
	lda x_crd_temp
	sec
	sbc hardcodedLeftOffset, y
	sta x_crd_temp
	
	lda temp3
	sec
	sbc #32
	sta temp8
	sta y_crd_temp
	clc
	adc #16
	sta temp7
	
.repeat 5, I
	lda temp9
	ldy #$40 + I * 2
	jsr oam_putsprite
	
	lda temp7
	sta y_crd_temp
	
	.if I <> 3
		ldy #$60 + I * 2
	.else
		ldy ctrlscheme
		lda tableContSchemes, y
		tay
	.endif
	lda temp9
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc boxSize
	sta x_crd_temp
	
	lda temp8
	sta y_crd_temp
.endrepeat
	
	ldx temp1
	rts

hardcodedLeftOffset:	.byte 4, 3, 2, 1, 0
tableContSchemes:		.byte $66, $66, $5A, $58

addOneToXPosition:
	inc sprspace+sp_x, x
	bne :+
	inc sprspace+sp_x_pg, x
:	rts

playSoundEffect:
	pha
	jsr gm_bird_caw_sfx
	pla
	ldx temp1
	rts

spriteIndicesCaw:			.byte $74, $78, $78, $70
spriteIndicesFleeInitial:	.byte $7C, $7C, $7C, $64, $64, $64
spriteIndicesFleeNormal:	.byte $6C, $68, $7C, $64
.endproc

; ** ENTITY: level0_bird_dash
; desc: This is the tutorial bird that teaches you how to dash.
.proc level0_bird_dash
boxSize = tmpRoomTran + 5
	; default sprites
	lda #$78
	sta temp6
	lda #$7A
	sta temp7
	
	lda sprspace+sp_l0bd_state, x
	cmp sprspace+sp_l0bd_ostat, x
	beq @sameState
	
	; different states, so reset the timer
	sta sprspace+sp_l0bd_ostat, x
	lda #0
	sta sprspace+sp_l0bd_timer, x
	
@sameState:
	lda sprspace+sp_l0bd_state, x
	bne checkMoreStates
	
	; Idle State
	lda temp2
	sec
	sbc player_x
	bmi return
	
	cmp #$55
	bcs return
	
	lda player_y
	cmp #160
	bcc return
	cmp #180
	bcs return
	
	lda player_vl_y
	bmi return
	
	; initiate the cutscene if needed
	lda #1
	cmp sprspace+sp_l0bd_state, x
	beq return
	
	sta sprspace+sp_l0bd_state, x
	
	; force the hair color to show as red
	lda #pal_red
	sta plh_forcepal
	
	; but the dash count should be max (the player can't dash)
	lda #maxdashes
	sta dashcount
	
	; (the player will only be able to dash after the bird bawks)
	
	lda temp1
	pha
	
	ldx #<ch0_dash_tutorial
	ldy #>ch0_dash_tutorial
	jsr dlg_begin_cutscene_g
	
	pla
	sta temp1
	
normalFaceRight:
	lda #pal_bird
	jsr gm_allocate_palette
:	sta temp5
	sta temp8
	jmp gm_draw_common
	
normalFaceLeft:
	lda #pal_bird
	jsr gm_allocate_palette
	ora #obj_fliphz
	bne :-

return:
	rts

checkMoreStates:
	cmp #1
	beq slowDownState
	cmp #2
	beq flyDownState
	cmp #3
	beq bawkState
	cmp #4
	beq flyAwayState

slowDownState:
	; slowed down, wait for further instructions from the cutscene
	jmp normalFaceRight

flyDownState:
	; flying down TODO
	jmp normalFaceLeft

bawkState:
	lda sprspace+sp_l0bd_timer, x
	tay
	bne bawkWaiting
	
	inc sprspace+sp_l0bd_timer, x
	
	lda #0
	sta dashcount
	sta plh_forcepal
	
	jsr gm_bird_caw_sfx
	jmp normalFaceLeft

bawkWaiting:
	lda #chrb_splv0b
	sta spr1_bknum
	
	lda gamectrl2
	and #<~g2_nodash
	sta gamectrl2
	
	lda #0
	sta game_cont_force
	sta game_cont_force+1
	
	jsr drawDashingHint
	
	; waiting for the player to dash and then land
	lda dashcount
	beq normalFaceLeft       ; dash count is still zero, means player didn't yet dash!
	
	lda gamectrl3
	and #<~g3_nogradra
	sta gamectrl3

	; ok, dashed, constantly hold the up and climb buttons until they land
	lda #(cont_up|cont_right)
	sta game_cont_force
	lda #cont_lsh
	sta game_cont_force+1
	jmp normalFaceRight

flyAwayState:
	lda boxSize
	beq @boxSizeIsZeroAndResetBank
	dec boxSize
	beq @boxSizeIsZero ; fail-safe
	dec boxSize
	beq @boxSizeIsZero ; fail-safe
	
	jsr drawDashingHint
	; since it incremented the size, decrement it again
	dec boxSize
	
@boxSizeIsZero:
	; flying away TODO
	jmp normalFaceRight

@boxSizeIsZeroAndResetBank:
	lda #chrb_splvl0
	jmp normalFaceRight

drawDashingHint:
	lda #pal_bubble
	jsr gm_allocate_palette
	sta temp9
	
	inc boxSize
	lda boxSize
	cmp #8
	bcc @bigEnough
	lda #8
	sta boxSize
@bigEnough:
	
	lda boxSize
	asl
	asl
	; carry is already clear I hope! (since we just shifted out zeroes)
	adc boxSize
	lsr
	sta temp11
	
	lda temp2      ; X position
	clc
	adc #8
	sec
	sbc temp11
	sta x_crd_temp
	
	; note: hardcoded offset left
	lda boxSize
	lsr
	tay
	lda x_crd_temp
	sec
	sbc level0_bird_climb::hardcodedLeftOffset, y
	sta x_crd_temp
	
	lda temp3
	sec
	sbc #32
	sta temp8
	sta y_crd_temp
	clc
	adc #16
	sta temp7
	
.repeat 5, I
	lda temp9
	ldy #$4A + I * 2
	jsr oam_putsprite
	
	lda temp7
	sta y_crd_temp
	
	.if I < 3
		ldy #$6A + I * 2
	.else
		ldy #$54 + (I - 3) * 2
	.endif
	lda temp9
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc boxSize
	sta x_crd_temp
	
	lda temp8
	sta y_crd_temp
.endrepeat
	
	ldx temp1
	rts
.endproc

; ** ENTITY: level0_bridge_manager
; desc: This entity manages a single bridge instance  (13 tiles wide) and
;       initiates the fall sequence for each.
.proc level0_bridge_manager
currentIndex := temp11
entityX := temp4
entityY := temp9
entityXHi := plattemp1
accelArray := dlg_bitmap + $000
positArray := dlg_bitmap + $080

	lda temp4
	sta entityXHi
	lda temp2
	sta entityX
	lda temp3
	sta entityY
	
	lda sprspace+sp_l0bm_state, x
	bne @state_Falling
	
	lda player_x
	clc
	adc camera_x
	sta temp5
	
	lda camera_x_pg
	adc #0
	sta temp6
	
	lda sprspace+sp_l0bm_acoll, x
	beq @normalIdleState
	
	; auto collapse, so start much earlier
	lda temp5
	clc
	adc #$30
	sta temp5
	bcc @normalIdleState
	inc temp6
	
	; idle state. Check if the player has approached this entity's position
@normalIdleState:
	
	; check if that X position exceeds the bridge manager's
	lda temp6
	cmp sprspace+sp_x_pg, x
	
	bcc @noFallInit   ; player X <<< bman X
	bne @forceFall    ; player X >>> bman X
	
	cpx #0
	bne :+
	
	; if this is the first bridge, wait for later
	lda dbenable
	cmp #1
	beq @noFallInit
	
:	lda temp5
	cmp sprspace+sp_x, x
	bcc @noFallInit

@forceFall:
	; start falling immediately
	lda #1
	sta sprspace+sp_l0bm_state, x
	
	lda dbenable
	sta sprspace+sp_l0bm_acidx, x
	cmp #1
	bne :+
	jsr aud_play_music_by_index
	
	; NOTE: This will overwrite pltraces AND part of dlgram!
	ldx temp1
:	inc dbenable
	lda dbenable
	and #3
	asl
	asl
	asl
	asl
	asl
	sta sprspace+sp_l0bm_index, x
	
	tay
	
:	lda #0
	sta positArray, y
	sta accelArray, y
	iny
	tya
	; is it a multiple of 32
	and #%00011111
	bne :-
	
	lda gamectrl2
	ora #g2_nodash
	sta gamectrl2

@exit:
	ldy sprspace+sp_l0bm_acoll, x
	bne :+
	lda #20
:	sta sprspace+sp_l0bm_timer, x

@noFallInit:
	rts
	
@state_Falling:
	; Falling state. If the timer is zero, determine which block to fall, and
	; make it fall.
	
	lda sprspace+sp_l0bm_blidx, x
	cmp #13
	bcc :+

	jsr drawSprites
	jmp clearTypeAndReturnA

:	ldy sprspace+sp_l0bm_acoll, x
	bne @forceNow
	
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
	bne drawSprites
	;bne @drawSprite_Bne
	
	; check if a clear is already enqueued.
	lda #nc_clearenq
	bit nmictrl
	beq :+
	
	; clear is already enqueued. Simply wait one more frame
	inc sprspace+sp_l0bm_timer, x
	bne drawSprites
	
:	; falling!
	lda sprspace+sp_x_pg, x
	lsr                      ; shift bit 1 in the carry
	lda sprspace+sp_x, x
	ror                      ; shift sp_x right by 1, and shift the carry in
	lsr
	lsr                      ; finish the division by eight
	
	; OK. Now load the block index to overwrite
	clc
	adc sprspace+sp_l0bm_blidx, x
	and #$3F
	sta temp2
	
	ldy sprspace+sp_l0bm_blidx, x
	lda block_widths, y
	sta temp8
	sta clearsizex
	sta temp11
	lda #2
	sta clearsizey
	
	lda sprspace+sp_y, x
	lsr
	lsr
	lsr
	sta temp3
	
	lda #$01
	sta setdataaddr
	sta setdataaddr+1
	
	stx temp1
	
	ldx temp2
	ldy temp3
	jsr h_request_transfer
	
	lda #0
	jsr h_clear_tiles
	
	lda temp11
	sta clearsizex
	lda #8
	sta clearsizey
	
	ldx temp1
	; done. Now advance and set a timer
	lda #20
	sta sprspace+sp_l0bm_timer, x
	
	ldy sprspace+sp_l0bm_blidx, x
	lda block_widths, y
	
	clc
	adc sprspace+sp_l0bm_blidx, x
	sta sprspace+sp_l0bm_blidx, x
	
	jmp drawSprites

@returnEarly:
	rts

drawSprites:
	lda gamectrl2
	ora #g2_notrace
	sta gamectrl2
	
	lda #pal_gray
	jsr gm_allocate_palette
	sta temp10
	ldx temp1
	lda #0
@loop:
	cmp sprspace+sp_l0bm_blidx, x
	bcs @return
	
	sta currentIndex
	
	lda currentIndex
	asl
	asl
	asl
	clc
	adc entityX
	; that's the X coordinate
	sta x_crd_temp
	
	lda entityXHi
	adc #0
	; if not on screen, skip this column
	bne @skipColumn
	
	lda sprspace+sp_l0bm_index, x
	clc
	adc currentIndex
	and #$7F
	tay
	
	lda positArray, y
	clc
	adc entityY
	bcc :+
	lda #$FF
:	sta y_crd_temp
	
	; add acceleration to it
	lda accelArray, y
	lsr
	lsr
	lsr
	clc
	adc positArray, y
	bcs @carry
	sta positArray, y
	
	cmp #$40
	bcs @carry
	
	;lda framectr
	;and #1
	;beq @back
	
	lda accelArray, y
	clc
	adc #1
	bcs @carry
	sta accelArray, y
	
@back:
	ldx temp1
	ldy currentIndex
	lda sprspace+sp_l0bm_acidx, x
	cmp #5
	bne @normalSprite
	lda sprites2, y
	bne @justDraw
@normalSprite:
	lda sprites, y
@justDraw:
	eor #1
	tay
	lda temp10
	jsr oam_putsprite
	
@skipColumn:
	inc currentIndex
	lda currentIndex
	bne @loop
	
@return:
	rts

@carry:
	lda #$40
	sta positArray, y
	lda #0
	sta accelArray, y
	beq @back

clearTypeAndReturnA:
	ldx temp1
	ldy sprspace+sp_l0bm_index, x
	
@clearCheckLoop:
	lda positArray, y
	cmp #$3C
	bcc :+
	iny
	tya
	; is y%32==13
	and #%00011111
	cmp #13
	bcc @clearCheckLoop
	
	; looks like we can
	lda #0
	sta sprspace+sp_kind, x
:	rts

block_widths:
	.byte 2,0,1,1,1,1,1,1,1,1,2,0,1
sprites:
	.byte $10,$12,$24,$26,$28,$2A,$3C,$7E,$BE,$24,$D0,$E0,$F0
sprites2:
	.byte $10,$12,$5C,$5C,$5C,$5C,$3C,$7E,$BE,$24,$D0,$E0,$F0

.endproc

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
	txa
	pha
	tya
	pha
	
	lda #pal_blue
	jsr gm_allocate_palette
	sta sprpaltemp
	
	pla
	tay
	pla
	tax
	
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
	lda sprpaltemp
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
	lda sprpaltemp
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
	lda sprpaltemp
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
	lda sprpaltemp
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
	
	lda #7
	sta clearsizex
	lda #4
	sta clearsizey
	lda #$01
	sta setdataaddr
	sta setdataaddr+1     ; $0101 is close enough
	jsr level0_ic_calcpos
	stx temp2
	sty temp3
	jsr h_request_transfer
	
	ldx temp2
	ldy temp3
	lda #0
	jsr h_clear_tiles
	
	lda #7
	sta clearsizex
	lda #4
	sta clearsizey
	; need to restore X since we proceed to use it after calling this func
	ldx l0crshidx
	
	rts

@setTilesForIC:
	; Set the flags that will clear the crusher's nametable visually.
	stx l0crshidx
	
	; Initiate the setting process.
	lda #7
	sta clearsizex
	lda #4
	sta clearsizey
	lda #<l0ic_chardata
	sta setdataaddr
	lda #>l0ic_chardata
	sta setdataaddr+1
	jsr level0_ic_calcpos
	stx temp2
	sty temp3
	jsr h_request_transfer
	
	; set those tiles in the actual tile data
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
; desc: Calculates the tile position of the IntroCrusher into the X/Y registers.
; clobbers: temp2
.proc level0_ic_calcpos
	; Initiate the setting process.
	lda sprspace + sp_y, x
	lsr
	lsr
	lsr
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
	tax
	rts
.endproc

l0ic_dataFHU:	.byte $81, $89, $8B, $8D
l0ic_dataFHD:	.byte $83, $8F, $91, $93
l0ic_dataSHU:	.byte $8D, $89, $85
l0ic_dataSHD:	.byte $8F, $93, $87
l0ic_shake_table:	.byte $01, $00, $FF, $00

l0ic_chardata:
	.byte $80,$81,$82,$83
	.byte $88,$89,$8E,$8F
	.byte $8A,$8B,$90,$91
	.byte $8C,$8D,$92,$93
	.byte $8C,$8D,$99,$8F
	.byte $88,$89,$92,$93
	.byte $84,$85,$86,$87
