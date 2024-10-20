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
	adc sprspace+sp_x, y
	sta sprspace+sp_x, y
	; NOTE: I (iProgramInCpp) must be careful where enemies go to avoid them going outside
	; the level!
	
	; Check if the player is standing on this tile.
	cpx entground
	bne @notStanding
	
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
	; TODO: Collision?  Ideally would depend on whether the collidable flag is set.
	rts

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
	adc sprspace+sp_y, y
	sta sprspace+sp_y, y
	; NOTE: I (iProgramInCpp) must be careful where enemies go to avoid them going outside
	; the level!
	
	; Check if the player is standing on this tile.
	cpx entground
	bne @notStanding
	
	; Yes, so offset their position by our velocity as well to keep them on the ground.
	;
	; NOTE: this can cause clipping glitches, be careful if platforms may go into walls!
	lda sprspace+sp_vel_y, y
	eor player_vl_y
	bne :+
	
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
	; TODO
	
	rts
