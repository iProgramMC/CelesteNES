; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_ent_move_x
; desc: Applies the X velocity component the specified entity.
;       Currently does not perform collision checking against tiles, though that may soon change.
; parameters:
;       Y reg - The index of the entity to move
gm_ent_move_x:
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
	
	lda sprspace+sp_vel_x, y
	sta currlboostX
	
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
;	; check if player is colliding anyway
;	lda #0
;	sta temp7
;	sta temp8
;	lda sprspace+sp_wid, x
;	sta temp9
;	lda sprspace+sp_hei, x
;	sta temp10
;	jsr gm_check_collision_ent
;	beq @return
;	
;	lda sprspace+sp_vel_x, y
;	bmi @velMinus2
;	beq @return
;	
;	jmp gm_ent_call_check_left_plr
;	
;@velMinus2:
;	jmp gm_ent_call_check_right_plr
;
;@return:
	rts

;.proc gm_ent_call_check_left_plr
;	lda temp1
;	pha
;	lda temp2
;	pha
;	lda temp3
;	pha
;	lda temp4
;	pha
;	
;	lda #<gm_applyx::checkLeft
;	sta temp1
;	lda #>gm_applyx::checkLeft
;	sta temp1+1
;doit:
;	ldy #prgb_xtra
;	jsr far_call
;	
;	pla
;	sta temp4
;	pla
;	sta temp3
;	pla
;	sta temp2
;	pla
;	sta temp1
;	rts
;.endproc
;
;.proc gm_ent_call_check_right_plr
;	lda temp1
;	pha
;	lda temp2
;	pha
;	lda temp3
;	pha
;	lda temp4
;	pha
;
;	lda #<gm_applyx::checkRight
;	sta temp1
;	lda #>gm_applyx::checkRight
;	sta temp1+1
;	jmp gm_ent_call_check_left_plr::doit
;.endproc

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
	bmi :+
	
	; the signs are the same therefore, copy the velocity of the platform onto the player.
	lda sprspace+sp_vel_y_lo, y
	sta player_vs_y
	lda sprspace+sp_vel_y, y
	sta player_vl_y
	
	; now add the Y delta to the player
:	lda sprspace+sp_vel_y_lo, y
	clc
	adc player_sp_y
	sta player_sp_y
	
	; NOTE: in horizontal levels, overflow vertically typically doesn't happen.
	lda sprspace+sp_vel_y, y
	adc player_y
	sta player_y
	
@notStanding:
	
	; Check for a squish. First, determine the direction of the platform.
	lda sprspace+sp_vel_y, y
	bmi @checkSquishUP
	
	; Platform is falling, so check that the player wasn't placed inside a floor.
	; TODO: don't call the whole of gm_collentceil, just the one for this Y
	jsr gm_collentceil
	bne :+
	
	; no collision here!
	rts

:	; Platform has collided with player. It has returned a Y position, so snap the player there.
	clc
	adc #(8-(16-plrheight)) ; add the height of the tile, minus the top Y offset of the player hitbox
	sta player_y
	
	; Ok, now check if a floor is here
	jsr gm_getmidx
	tax
	jsr gm_getbottomy_f
	tay
	lda #gc_floor
	jsr gm_collide
	beq :+
	
	; Collided with a floor also!
	lda #%11111000
	and player_y
	sta player_y
	
	; one more collision check for good measure
	jsr gm_collentceil
	beq :+
	
	; ok, we know for SURE the player was squished in between this platform and the ground. Die :(
	jsr gm_killplayer
:	rts
	
@checkSquishUP:
	jsr gm_collentfloor
	bne :+
	
	; no collision here!
	rts
	
:	; Platform has collided with player. It returned a Y position, so snap there.
	sta player_y
	
	; Ok, now check if a ceiling is here
	jsr gm_getmidx
	tax
	jsr gm_gettopy
	tay
	lda #gc_ceil
	jsr gm_collide
	beq :+
	
	; Collided with a ceiling also!
	lda player_y
	clc
	adc #plr_y_top
	and #%11111000
	clc
	adc #(8-(16-plrheight))
	sta player_y
	
	; one more collision check for good measure
	jsr gm_collentfloor
	beq :+
	
	; ok, we know for SURE the player was squished in between this platform and the ceiling. Die :(
	jsr gm_killplayer
:	rts

; ** SUBROUTINE: gm_check_collision_ent
; desc: Checks for collision between the player and an entity.
;
; parameters:
;     temp7 - X offset (left)
;     temp8 - Y offset (top)
;     temp9 - X offset (right)
;     temp10- Y offset (bottom)
;
;     Y - the entity's index.
;
; returns:
;     ZF set - No collision
.proc gm_check_collision_ent
	jsr gm_calc_ent_hitbox
	
	; r1 is player
	; r2 is entity
	; conditions mean instant failure
	
	; r1->left >= r2->right
	lda player_x
	clc
	adc #plr_x_left
	cmp temp9
	bcs failure
	
	; r1->right <= r2->left
	; r1->right - 1 < r2->left
	lda player_x
	clc
	adc #(plr_x_right - 1)
	cmp temp7
	bcc failure
	
	; r1->top >= r2->bottom
	lda player_y
	clc
	adc #plr_y_top
	cmp temp10
	bcs failure
	
	; r1->bottom <= r2->top
	; r1->bottom - 1 < r2->top
	lda player_y
	clc
	adc #(plr_y_bot - 1)
	cmp temp8
	bcc failure
	
	lda #1
	rts

failure:
	lda #0
	rts
.endproc

; ** SUBROUTINE: gm_calc_ent_hitbox
; desc: Calculates an entity's hit box.  This is used when calculating
;       collisions with the player, so these positions will be relative
;       to the camera position.
;       This also handles over/underflow on the X-axis.
;
; parameters:
;     temp7 - X offset (left)
;     temp8 - Y offset (top)
;     temp9 - X offset (right)
;     temp10- Y offset (bottom)
;
;     Y - the entity's index.
;
; returns:
;     temp7, 8, 9, 10 - the hitbox itself.
;
; note: The entity must be at least partly on screen.
.proc gm_calc_ent_hitbox
	lda sprspace+sp_x, y
	clc
	adc temp7
	sec
	sbc camera_x
	sta temp7
	
	lda sprspace+sp_x_pg, y
	sbc camera_x_pg
	; this should be zero. If it is not, then the left edge is off screen.
	beq xHighZero
	bpl xHighPositive
	lda #0
	sta temp7
	bne xHighZero
xHighPositive:
	lda #$FF
	sta temp7
xHighZero:
	
	lda sprspace+sp_x, y
	clc
	adc temp9
	sec
	sbc camera_x
	sta temp9
	
	lda sprspace+sp_x_pg, y
	sbc camera_x_pg
	; this should be zero. If it is not, then the right edge is off screen.
	beq x2HighZero
	bpl x2HighPositive
	lda #0
	sta temp9
	bne x2HighZero
x2HighPositive:
	lda #$FF
	sta temp9
x2HighZero:
	
	lda sprspace+sp_y, y
	clc
	adc temp8
	sta temp8
	
	lda sprspace+sp_y, y
	clc
	adc temp10
	sta temp10
	
	rts
.endproc