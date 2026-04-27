; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_ent_move_x
; desc: Applies the X velocity component the specified entity.
;       Currently does not perform collision checking against tiles, though that may soon change.
; parameters:
;       Y reg - The index of the entity to move
gm_ent_move_x:
	sty tmpRoomTran
	
	lda sprspace+sp_vel_x, y
	bne @notZero
	lda sprspace+sp_vel_x_lo, y
	bne @notZero
	
	rts

@notZero:
	lda sprspace+sp_vel_x_lo, y
	clc
	adc sprspace+sp_x_lo, y
	sta sprspace+sp_x_lo, y
	
	lda sprspace+sp_vel_x, y
	bmi @velMinus
	
	adc sprspace+sp_x, y
	sta sprspace+sp_x, y
	bcc @doneAddingX
	
	lda sprspace+sp_x_pg, y
	adc #0
	sta sprspace+sp_x_pg, y
	jmp @doneAddingX
	
@velMinus:
	adc sprspace+sp_x, y
	sta sprspace+sp_x, y
	bcs @doneAddingX
	
	lda sprspace+sp_x_pg, y
	sbc #0
	sta sprspace+sp_x_pg, y

@doneAddingX:
	; NOTE: I (iProgramInCpp) must be careful where enemies go to avoid them going outside
	; the level!
	
	; Check if the player is standing on this tile.
	cpy entground
	bne @notStanding

	; rounds the velocity up, and stores it into currlboostX
;	ldx sprspace+sp_vel_x, y
;	stx $100 ; DEBUG
;	lda sprspace+sp_vel_x_lo, y
;	sta $101 ; DEBUG
;	beq @noChange
;	cpx #0
;	bmi @decrement
;	;increment
;	inx
;	bne @noChange
;@decrement:
;	dex
;@noChange:
;	stx currlboostX

	; we actually need to round it down, sorry
	ldx sprspace+sp_vel_x, y
	bpl @noChange
	lda sprspace+sp_vel_x_lo, y
	beq @noChange
	inx
@noChange:
	stx currlboostX

	lda playerctrl
	and #pl_climbing
	beq @notClimbing
	
	; OKAY, now check if the player is standing on the near or far side of the platform.
	jsr gm_calchorzplat
	beq @notClimbing    ; somehow this didn't work...
	
	; check left side
	lda player_x
	cmp plattemp1
	bcs @notHoldingOntoLeft
	
	lda plattemp1
	sec
	sbc #(7+plr_x_left)
	bcs :+
	lda #0  ; here the player might be getting crushed against the screen
:	sta player_x
	jmp @doneAdding

@notHoldingOntoLeft:
	; check right side
	lda plattemp2
	cmp player_x
	bcc @notClimbing
	
	; standing on right
	lda plattemp2
	sec
	sbc #(plr_x_left+plr_x_left+4)
	bcs :+
	lda #0
:	sta player_x
	jmp @doneAdding
	
@notClimbing:
	; Yes, so offset their position by our velocity as well to keep them on the ground.
	;
	; NOTE: this can cause clipping glitches, be careful if platforms may go into walls!
	lda sprspace+sp_vel_x_lo, y
	clc
	adc player_sp_x
	sta player_sp_x
	
	lda sprspace+sp_vel_x, y
	bmi @addMinus
	
	; Adding a positive player velocity.  Fix up all instances of player being moved to >$F0.
	adc player_x
	bcc :+
	lda #$FF
:	cmp #$F0
	bcc :+
	lda #$F0
:	sta player_x
	
	jmp @doneAdding

@addMinus:
	; Adding a negative player velocity.  Fix up all instances of player being moved to <$00.
	adc player_x
	bcs :+           ; Carry is set when an underflow happened, and underflows typically happen
	lda #0           ; with negative numbers, so if an underflow _didn't_ happen, must be the
:	sta player_x     ; case that they wrapped around.
	
@doneAdding:
@notStanding:
	; note: apparently this is NOT that expensive!
	jmp gm_ent_call_check_plr

@return:
	rts

.proc gm_ent_call_check_plr
	lda temp1
	pha
	lda temp2
	pha
	lda temp3
	pha
	lda temp4
	pha
	
	lda #<ph_ent_call_check_plr
	sta farcalladdr
	lda #>ph_ent_call_check_plr
	sta farcalladdr+1
	ldy #prgb_phys
	jsr far_call
	
	pla
	sta temp4
	pla
	sta temp3
	pla
	sta temp2
	pla
	sta temp1
	rts
.endproc

; ** SUBROUTINE: gm_ent_move_y
; desc: Applies the Y velocity component the specified entity.
;       Currently does not perform collision checking against tiles, though that may soon change.
; parameters:
;       Y reg - The index of the entity to move
gm_ent_move_y:
	lda sprspace+sp_vel_y_lo, y
	clc
	adc sprspace+sp_y_lo, y
	sta sprspace+sp_y_lo, y
	
	lda sprspace+sp_vel_y, y
	bmi @velNegative
	
	adc sprspace+sp_y, y
	sta sprspace+sp_y, y
	bcs @overflow
	bcc @continue
	
@velNegative:
	adc sprspace+sp_y, y
	sta sprspace+sp_y, y
	bcc @overflow
	bcs @continue
	
@overflow:
	lda #g3_transitA
	bit gamectrl3
	bne @continue           ; in transition, so can't be in limbo
	
	lda #rf_new
	bit roomflags
	beq @continue           ; can't go in limbo in a normal room
	
	lda sprspace+sp_flags, y
	eor #ef_limbo
	sta sprspace+sp_flags, y
	
@continue:
	; NOTE: I (iProgramInCpp) must be careful where enemies go to avoid them going outside
	; the level!
	
	; Check if the player is standing on this entity.
	cpy entground
	bne @notStanding
	
	lda sprspace+sp_vel_y, y
	sta currlboostY
	
	; Yes, so offset their position by our velocity as well to keep them on the ground.
	;
	; NOTE: this can cause clipping glitches, be careful if platforms may go into walls!
	lda sprspace+sp_vel_y, y
	eor player_vl_y
	bmi @doNotCopy
	
	; though, never copy if the player's climbing
	lda playerctrl
	and #pl_climbing
	bne @doNotCopy
	
	; the signs are the same therefore, copy the velocity of the platform onto the player.
	lda sprspace+sp_vel_y_lo, y
	sta player_vs_y
	lda sprspace+sp_vel_y, y
	sta player_vl_y
	
	; now add the Y delta to the player
@doNotCopy:
	lda sprspace+sp_vel_y_lo, y
	clc
	adc player_sp_y
	sta player_sp_y
	
	; NOTE: in horizontal levels, overflow vertically typically doesn't happen.
	lda sprspace+sp_vel_y, y
	adc player_y
	sta player_y
	
@notStanding:
	; check for a squish. First, determine the direction of the platform.
	lda sprspace+sp_vel_y, y
	bmi @checkSquishUP
	
	; the platform is falling, so ensure the player's being pushed by it.
	jsr gm_collentceil
	beq @notBeingPushedDown
	
	; it collided with the player. gm_collentceil returned a Y position, so snap the player there.
	clc
	adc #(8-(16-plrheight)) ; add the height of the tile, minus the top Y offset of the player hitbox
	sta player_y
	
@notBeingPushedDown:
	; the platform is falling, so check that the player wasn't placed inside a floor.
	jsr gm_getmidx
	tax
	jsr gm_getbottomy_f
	tay
	lda #gc_floor
	jsr gm_collide
	beq @noCollisionDown
	
	; collided with a floor. snap her up there
	lda #%11111000
	and player_y
	sta player_y
	
	; check if we're colliding with anything else?
	jsr gm_collentceil
	beq @noCollisionDown
	
	; okay, try to slide the player left/right a bit
	lda player_x
	sta temp12
	sec
	sbc #5
	sta player_x
	jsr gm_collentceil
	beq @successfulCorrectionLeft
	
	lda temp12
	clc
	adc #5
	sta player_x
	jsr gm_collentceil
	beq @successfulCorrectionRight
	
	; looks like the player was squished in between this platform and the ground. RIP :(
	jmp gm_killplayer
@noCollisionDown:
	rts

; NOTE: this relies on nobody clobbering plattemp1 and plattemp2.
@successfulCorrectionLeft:
	; warp the player exactly to the left edge of the platform.
	lda plattemp1
	sec
	sbc #(plrwidth+plr_x_left)
	sta player_x
	rts

@successfulCorrectionRight:
	; warp the player exactly to the right edge of the platform.
	lda plattemp2
	sec
	sbc #plr_x_left
	sta player_x
	rts

@checkSquishUP:
	; the platform is going up, so ensure the player's being pushed by it.
	jsr gm_collentfloor
	beq :+
	
	; it collided with player. gm_collentfloor returned a Y position, so snap there.
	sta player_y
	
	; the platform is going up, so check that the player wasn't placed inside a ceiling.
:	jsr gm_getmidx
	tax
	jsr gm_gettopy
	tay
	lda #gc_ceil
	jsr gm_collide
	beq @noMoreCollision
	
	; collided with a ceiling, snap the player there
	lda player_y
	clc
	adc #plr_y_top
	and #%11111000
	clc
	adc #(8-(16-plrheight))
	sta player_y
	
	; check if they're now in the entity's floor
	jsr gm_collentfloor
	beq @noMoreCollision
	
	; okay, try to slide the player left/right a bit
	lda player_x
	sta temp12
	sec
	sbc #5
	sta player_x
	jsr gm_collentfloor
	beq @successfulCorrectionLeft
	
	lda temp12
	clc
	adc #5
	sta player_x
	jsr gm_collentfloor
	beq @successfulCorrectionRight
	
	lda temp12
	sta player_x
	
	; ok, we know for SURE the player was squished in between this platform and the ceiling. Die :(
	jmp gm_killplayer
@noMoreCollision:
	rts

; ** SUBROUTINE: gm_calchorzplat
; desc: Calculates the edges of a platform entity in plattemp1, plattemp2, screen coordinates.
;       These can be used to check whether the player is standing on a platform.
; arguments: Y register - the index of the Entity
; returns:   plattemp1 - Left edge, plattemp2 - Right edge, !ZF - Are they valid
.proc gm_calchorzplat
	; TODO: Needs more testing, like, a lot more testing.
	
	; LEFT edge.
	lda sprspace+sp_x, y
	sbc camera_x
	sta plattemp1
	
	lda sprspace+sp_x_pg, y
	sbc camera_x_pg
	sta temp4
	bmi @isMinus              ; the difference is <0, therefore partly offscreen. set left pos to 0.
	bne @noHitBox             ; the difference is >0, therefore off screen.
	beq @isNotMinus           ; the difference is =0. Skip the code below. I dislike that I have to do this.
	
@isMinus:
	lda #0
	sta plattemp1
@isNotMinus:
	
	; RIGHT edge.
	lda sprspace+sp_x, y
	clc
	adc sprspace+sp_wid, y
	sta plattemp2
	
	lda sprspace+sp_x_pg, y
	adc #0
	sta temp4
	
	lda plattemp2
	sec
	sbc camera_x
	sta plattemp2
	
	lda temp4
	sbc camera_x_pg
	bmi @noHitBox            ; the entire hitbox went over the left edge, therefore entirely off screen.
	beq :+                   ; if it's >0, means the edge wrapped over to outside the screen, therefore load the max
	lda #$FF
	sta plattemp2
:	lda #1
	rts
	
@noHitBox:
	lda #0
	rts
.endproc
