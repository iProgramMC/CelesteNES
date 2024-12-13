; Copyright (C) 2024 iProgramInCpp

gm_targetsLO:	.byte $00, maxwalkLO, maxwalkNLO
gm_targetsHI:	.byte $00, maxwalkHI, maxwalkNHI
gm_xaxisfixup:	.byte $00, $01, $02, $00

; ** SUBROUTINE: gm_gettarget
; desc: Gets the index of the target velocity, based on buttons held on the controller.
;       The index is used in the arrays: gm_targetsLO, gm_targetsHI.
gm_gettargetindex:
	lda forcemovext
	beq gm_gettargetindexforce
	lda forcemovex
	rts
	
gm_gettargetindexforce:
	lda game_cont
	and #(cont_left | cont_right)
	; since cont_left and cont_right are $02 and $01 respectively,
	; we can simply use them as indices into a table.
	;
	; if left and right happen to be pressed at the same time, simply
	; cancel them out.
	tax
	lda gm_xaxisfixup, x
	rts

; ** SUBROUTINE: gm_velsignbtnshld
; desc: Checks if the X velocity's sign matches that of the held buttons.
; result: located in ZERO flag.  If the zero flag is set, the held buttons
;         match the velocity's sign.
; clobbers: A, X
gm_velsignbtnshld:
	jsr gm_gettargetindex
	tax
	cmp #1
	bne :+
	
	lda player_vl_x     ; it's 1, meaning we're holding right.
	bmi @different
	bne @same
	lda player_vs_x     ; pixel component is 0, so check the subpixel now
	bne @different
@same:
	lda #0
	rts
	
:	cmp #2
	bne :+
	lda player_vl_x     ; it's 2, meaning we're holding left.
	bpl @different      ; if the pixel component is 0 or above, signs don't match
	bmi @same

:	lda player_vl_x
	bne @different
	lda player_vs_x
	bne @different
	rts
@different:
	lda #1
	rts

; ** SUBROUTINE: gm_shouldreduce
; desc: Determines whether accel or accelreduce is used.
;
; something like:
; [Math.Abs(Speed.X) > max  &&  Math.Sign(Speed.X) == moveX] ? RunReduce : RunAccel
gm_shouldreduce:
	jsr gm_velsignbtnshld  ; if Math.Sign(Speed.X) != moveX
	bne @returnNormal      ; then it's simply normal
	; note: button state index still loaded into X
	
	; now compare the absolute of the velocity.
	clc
	lda player_vl_x
	bmi @checkMinus
	
	; player velocity is positive.
	cmp #maxwalkHI
	bcc @returnNormal      ; SpeedXHigh < maxwalkHI
	bne @returnReduce      ; SpeedXHigh > maxwalkHI
	
	lda player_vs_x
	cmp #maxwalkLO
	bcc @returnNormal      ; SpeedXLow < maxwalkHI
@returnReduce:
	lda #1
	rts

@checkMinus:
	cmp #maxwalkNHI
	bcc @returnReduce
	bne @returnNormal
	
	lda player_vs_x
	cmp #maxwalkNLO
	bcc @returnReduce

@returnNormal:
	lda #0
	rts

gm_acceltable:
	.byte accelair     ; air, no reduce
	.byte accelredair  ; air, reduce
	.byte accel        ; ground, no reduce
	.byte accelred     ; ground, reduce

; ** SUBROUTINE: gm_updatexvel
; desc:    Makes the 16-bit X velocity approach a value based on the buttons held.
gm_updatexvel:
	lda #pl_climbing
	bit playerctrl
	beq @notClimbing
	
	lda game_cont
	and #cont_down
	; while holding down, don't move towards the wall
	bne @zeroAndReturn
	
	ldx #0
	stx player_vs_x
	inx
	stx player_vl_x
	
	lda #pl_left
	bit playerctrl
	beq :+
	
	dex
	dex
	stx player_vl_x
	
:	rts

@zeroAndReturn:
	lda #0
	sta player_vl_x
	sta player_vs_x
	rts
	
@notClimbing:
	; we need to calculate two things:
	; first, the target velocity
	; second, the thing we want to add to get to the target velocity
	
	; check if the velocity should be REDUCED
	jsr gm_shouldreduce
	sta temp1
	
	; note: gm_shouldreduce ALSO placed the index corresponding to
	; the held buttons in the X register!
	
	; determine the facing based on the X register
	cpx #0
	beq @donefacing       ; no buttons pressed
	cpx #1
	beq @right
	; facing left
	lda playerctrl
	ora #pl_left
	sta playerctrl
	bne @donefacing

@right:
	; facing right
	lda #(pl_left ^ $FF)
	and playerctrl
	sta playerctrl

@donefacing:
	; determine the thing added to reach the target velocity
	lda #pl_ground
	and playerctrl        ; NOTE INVARIANT: pl_ground is $02!
	ora temp1
	tay
	; now Y can be used directly as an index into an array.
	
	; check if we should SUBTRACT or ADD to the velocity.
	lda player_vl_x
	sec
	sbc gm_targetsHI, x   ; signed comparison betwene player_vl_x and gm_targetsHI+x
	bvc :+                ; if V is 0, N eor V = N, otherwse N eor V = N eor 1
	eor #$80
:	bmi @shouldAdd        ; player_vl_x < gm_targetsHI+x, so need to add
	bne @shouldSubtract   ; player_vl_x > gm_targetsHI+x, so need to subtract
	
	; now check the low byte
	lda player_vs_x
	sec
	sbc gm_targetsLO, x
	bvc :+
	eor #$80
:	bmi @shouldSubtract   ; player_vs_x < gm_targetsLO+x, so need to add

@shouldAdd:
	; Add.  If the result is bigger than the target velocity,
	; set to the target velocity and return.
	clc
	lda player_vs_x
	adc gm_acceltable, y
	sta player_vs_x
	lda player_vl_x
	adc #0
	sta player_vl_x
	
	; check if we overshot.
	lda gm_targetsHI, x
	bmi @shouldAdd_targetMinus
	
	; target is positive.
	lda player_vl_x    ; if it's still negative after the addition, return
	bmi @return
	cmp gm_targetsHI, x
	bcc @return
	bne @setToTarget

@shouldAdd_compareSubpixel:
	lda player_vs_x
	cmp gm_targetsLO, x
	bcs @setToTarget

@return:
	rts

@shouldAdd_targetMinus:
	lda player_vl_x
	bpl @setToTarget   ; it somehow ended up being positive, and target is negative. just set
	cmp gm_targetsHI, x; ^^ note that we are ADDING, therefore this should never happen
	beq @shouldAdd_compareSubpixel
	bcs @setToTarget
	rts

@shouldSubtract:
	; Subtract.  If the result is smaller than the target velocity,
	; set to the target velocity and return.
	sec
	lda player_vs_x
	sbc gm_acceltable, y
	sta player_vs_x
	lda player_vl_x
	sbc #0
	sta player_vl_x
	
	; check if we overshot.
	lda gm_targetsHI, x
	bpl @shouldSubtract_targetPlus
	
	; target is negative.
	lda player_vl_x
	bpl @return        ; if it's still positive after the subtraction, return
	cmp gm_targetsHI, x
	bcc @setToTarget
	bne @return

@shouldSubtract_compareSubpixel:
	lda player_vs_x
	cmp gm_targetsLO, x
	bcc @setToTarget
	rts

@shouldSubtract_targetPlus:
	lda player_vl_x
	bmi @setToTarget   ; it somehow ended up negative, and target is positive. just set.
	cmp gm_targetsHI, x; ^^ note that we are SUBTRACTING, therefore this should never happen
	beq @shouldSubtract_compareSubpixel
	bcc @setToTarget
	rts

@setToTarget:
	lda gm_targetsHI, x
	sta player_vl_x
	lda gm_targetsLO, x
	sta player_vs_x

; ** SUBROUTINE: gm_getdownforce
; desc:    Gets the down force applied to the player.
gm_getdownforce:
	lda #cont_a
	bit game_cont
	beq @normal        ; not holding the A button, use normal gravity
	
	lda player_vs_y
	sta temp1
	lda player_vl_y
	bpl @dontinvert
	eor #$FF
	pha
	lda temp1
	eor #$FF
	sta temp1
	pla
@dontinvert:
	bne @normal        ; use normal gravity if >= $0100
	lda temp1
	cmp #lograthresh
	bcc @low
@normal:
	lda #gravity
	rts
@low:
	lda #(gravity >> 1)
	rts

; ** SUBROUTINE: gm_gravity
; desc:    If player is not grounded, applies a constant downward force.
gm_gravity:
	lda jcountdown
	beq @nojumpcountdown
@nogravity:
	rts
@nojumpcountdown:
	lda #pl_ground
	bit playerctrl
	beq @apply_gravity
	rts
@apply_gravity:
	lda playerctrl
	and #pl_climbing
	bne @nogravity
	
	jsr gm_getdownforce
	clc
	adc player_vs_y
	sta player_vs_y
	lda #0
	adc player_vl_y
	sta player_vl_y
	
	lda player_vl_y
	bmi @return
	cmp #maxfallHI
	bcc @proceed
	bne @cap
	
	lda player_vs_y
	cmp #maxfallLO
	bcc @proceed
@cap:
	lda #maxfallHI
	sta player_vl_y
	lda #maxfallLO
	sta player_vs_y
@proceed:
	lda #pl_pushing
	bit playerctrl
	beq @return
	lda player_vl_y
	bne @slide            ; player_vl_x > 0
	lda player_vs_y
	cmp #maxslidespd
	bcc @return           ; player_vl_x == 0, player_vs_x < maxslidespd
@slide:
	lda #maxslidespd
	sta player_vs_y
	lda #0
	sta player_vl_y
@return:
	rts

; ** SUBROUTINE: gm_controls
; desc:    Check controller input and apply forces based on it.
gm_controls:
	lda cjwindow
	beq @noClimbJumpWindow
	
	; check if we are holding a direction
	lda game_cont
	and #(cont_left | cont_right)
	cmp cjwalldir
	bne @noClimbJumpRefund
	
	; this is a wall jump!  prepare the wall-jump, add stamina, then do the wall jump
	lda cjwalldir
	and #1
	eor #1
	sta cjwalldir
	
	lda playerctrl
	and #<~pl_left
	ora cjwalldir
	sta playerctrl
	
	lda #1
	sta wjumpcoyote
	sta cjwindow
	
	lda #stamchgjump
	clc
	adc stamina
	sta stamina
	bcc :+
	inc stamina+1
	
:	jsr gm_walljump
	
@noClimbJumpRefund:
	dec cjwindow
@noClimbJumpWindow:
	jsr gm_updatexvel
	lda jumpbuff
	bne gm_jump       ; If player buffered a jump, then try to perform it.
gm_dontjump:
	lda #cont_b
	bit game_cont
	beq gm_dontdash   ; if the player pressed B
	bit game_conto
	bne gm_dontdash   ; if the player wasn't pressing B last frame
	lda dashcount
	cmp #maxdashes
	bcs gm_dontdash   ; and if the dashcount is < maxdashes
	
	; dash!!
	jsr gm_add_lift_boost
	inc dashcount
	ldx #defdashtime
	stx dashtime
	lda #pl_dashed
	ora playerctrl
	sta playerctrl
gm_dontdash:
	rts

gm_jump:
	lda wjumpcoyote
	bne gm_maybewalljump
gm_normaljump:
	lda jumpcoyote
	beq gm_dontjump   ; if no coyote time, then can't jump
gm_normaljmp2:
	jsr gm_jump_sfx
	lda #jumpvelHI
	sta player_vl_y
	lda #jumpvelLO
	sta player_vs_y
	jsr gm_add_lift_boost
	lda #jumpsustain
	sta jcountdown
	lda #0
	sta jumpbuff      ; consume the buffered jump input
	sta jumpcoyote    ; consume the existing coyote time
	sta wjumpcoyote   ; or the wall coyote time
	lda playerctrl
	and #<~(pl_ground|pl_climbing)
	sta playerctrl
	lda #%00000011
	bit game_cont
	beq gm_dontjump   ; don't give a boost if we aren't moving
	lda player_vl_x
	bmi gm_jumpboostneg; if velocity < 0 pixels, then apply the leftward jump boost
	bne gm_applyjumpboost ; if velocity >= 1 pixel, then apply the jump boost
	beq gm_dontjump   ; 0 < velocity < 1 so dont do a jump boost
gm_jumpboostneg:
	cmp #$FF
	beq gm_dontjump   ; if -1 <= velocity, then don't apply a jump boost
gm_applyjumpboost:
	lda #pl_left
	bit playerctrl
	beq gm_jumphboostR
	sec               ; apply the small jump boost to the right
	lda player_vs_x
	sbc #jmphboost
	sta player_vs_x
	lda player_vl_x
	sbc #0
	sta player_vl_x
	jmp gm_dontjump   ; that would be pretty stupid as it would
gm_jumphboostR:       ; allow speed buildup up to the physical limit
	clc
	lda #jmphboost
	adc player_vs_x
	sta player_vs_x
	lda #0
	adc player_vl_x
	sta player_vl_x
	jmp gm_dontjump

gm_maybewalljump:
	lda #pl_ground
	bit playerctrl
	bne gm_normaljump
	
	lda climbbutton
	beq gm_walljump
	
	; climb button is held, do we have stamina?
	lda stamina+1
	bne :+
	lda stamina
	beq gm_walljump

:	; we do.
	; set the climbing flag and fall into gm_walljump
	lda playerctrl
	ora #pl_climbing
	sta playerctrl
	
gm_walljump:
	lda #pl_ground
	bit playerctrl
	bne gm_normaljump ; if player is grounded, ALWAYS perform a standard jump
	
	; check if player is climbing right now
	lda playerctrl
	and #pl_climbing
	beq @notClimbing
	
	; climbing, check if the held direction is different from the facing direction
	lda game_cont
	and #(cont_left|cont_right)
	beq @climbJump    ; not holding any buttons, so standard jump
	
	and #cont_left    ; cont_left == $02
	lsr
	sta temp1
	
	lda playerctrl
	and #pl_left      ; pl_left == $01
	eor temp1
	bne @notClimbing  ; if they match (player was holding left while facing left), then climb jump
	
	; climb jump, but charge the correct stamina if they have it
@climbJump:
	lda stamina+1
	bne @ahead
	lda stamina
	beq @notClimbing
	
@ahead:
	; charge the jump stamina
	lda stamina
	sec
	sbc #stamchgjump
	sta stamina
	bcs :+
	dec stamina+1
	bpl :+
	
	; withdrew too much? return to 0
	lda #0
	sta stamina
	sta stamina+1
	
	; set up climb-jump window
:	lda #12
	sta cjwindow
	
	lda #0
	sta player_vl_x
	sta player_vs_x
	
	; note: cjwalldir is the direction you must hold for a wall jump stamina refund!
	lda playerctrl
	and #pl_left    ; pl_left is equal to 1
	sta cjwalldir
	eor #1
	asl
	ora cjwalldir
	sta cjwalldir
	
	jmp gm_normaljmp2
	
@notClimbing:
	jsr gm_jump_sfx
	
	; the facing direction IS the one the player is currently pushing against.
	; that means that the opposite direction is the one they should be flinged against
	lda playerctrl
	and #pl_wallleft
	eor #pl_wallleft
	lsr
	lsr
	lsr               ; move bit 3 (pl_wallleft) into bit 0 (pl_left)'s position
	sta temp1
	lda playerctrl
	and #((pl_left|pl_dashed|pl_climbing)^$FF) ; also clear the pl_dashed flag to allow the wall jump at full force
	ora temp1
	sta playerctrl
	
	lda #pl_left
	bit playerctrl
	bne @walljumpboostL
	lda #walljumpLO
	sta player_vs_x
	lda #walljumpHI
	sta player_vl_x
	bne @walljumpvert
@walljumpboostL:
	lda #walljumpNLO
	sta player_vs_x
	lda #walljumpNHI
	sta player_vl_x
@walljumpvert:
	lda #jumpvelHI
	sta player_vl_y
	lda #jumpvelLO
	sta player_vs_y
	jsr gm_add_lift_boost
	lda #jumpsustain
	sta jcountdown
	lda #0
	sta jumpbuff      ; consume the buffered jump input
	sta jumpcoyote    ; consume the existing coyote time
	sta wjumpcoyote   ; or the wall coyote time
	
	jsr gm_gettargetindexforce ; check the current move direction
	beq @return
	
	lda playerctrl
	and #pl_left
	tax
	inx               ; 1 - right, 2 - left
	stx forcemovex
	lda #wjfxtval
	sta forcemovext
@return:
	rts

; ** SUBROUTINE: gm_jumpgrace
; desc:    Update the jump grace state.  If the A button is held, start buffering a jump.
;          If necessary, decrement the coyote timer.
gm_jumpgrace:
	lda #cont_a
	bit game_conto
	bne gm_nosetbuff  ; (game_conto & #cont_a) = 0
	bit game_cont
	beq gm_nosetbuff  ; if A was just pressed, then assign the default buff time
	lda #defjmpbuff
	sta jumpbuff
gm_nosetbuff:
	ldx jumpbuff
	beq gm_nodecbuff  ; if there is buff time to deduct, deduct 1 point this frame
	dex
	stx jumpbuff
gm_nodecbuff:
	ldx jumpcoyote
	beq gm_nodeccoyote
	dex
	stx jumpcoyote
gm_nodeccoyote:
	ldx wjumpcoyote
	beq gm_nodecwcoyote
	dex
	stx wjumpcoyote
gm_nodecwcoyote:
	rts

; ** SUBROUTINE: gm_sanevels
; desc:    Uphold velocity limits.  This is especially of importance for the X component.
;          Due to the limited bandwidth of the PPU (we can't effectively copy more than
;          1 column of tiles or so to PPU VRAM), we're forced to uphold this limit.
;          Technically we could do up to 8, but only if we disable the palette feature.
gm_sanevels:
	ldy #0
	jsr gm_sanevelx
	jmp gm_sanevely
	
gm_sanevelx:
	lda player_vl_x
	bmi gm_negvelx
	; positive x velocity
	cmp #maxvelxhi
	bcc gm_nocorvelx
	lda #maxvelxhi
	sta player_vl_x
	sty player_vs_x
gm_nocorvelx:
	rts
gm_negvelx:
	cmp #(maxvelxhi^$FF + 1)
	bcs gm_nocorvelx
	lda #(maxvelxhi^$FF + 1)
	sta player_vl_x
	sty player_vs_x
	rts
gm_sanevely:
	lda player_vl_y
	bmi gm_negvely
	; positive y velocity
	cmp #maxvelyhi
	bcc gm_nocorvely
	lda #maxvelyhi
	sta player_vl_y
	sty player_vs_y
gm_nocorvely:
	rts
gm_negvely:
	cmp #(maxvelyhi^$FF + 1)
	bcs gm_nocorvely
	lda #(maxvelyhi^$FF + 1)
	sta player_vl_y
	sty player_vs_y
	rts

; ** SUBROUTINE: gm_getleftx
; desc: Gets the tile X position where the left edge of the player's hitbox resides
; returns: A - the X coordinate
gm_getleftx:
	clc
	lda player_x
	adc #plr_x_left   ; determine leftmost hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_hi
	adc #0
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getrightx
; desc:     Gets the tile X position where the right edge of the player's hitbox resides
; returns:  A - the X coordinate
; note:     this is NOT ALWAYS the same as the result of gm_getleftx!! though perhaps
;           some optimizations are possible..
gm_getrightx:
	clc
	lda player_x
	adc #plr_x_right ; determine right hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_hi
	adc #0
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getleftxceil
; desc: Gets the tile X position where the left edge of the player's hitbox resides
; returns: A - the X coordinate
gm_getleftxceil:
	clc
	lda player_x
	adc #plr_x_leftC  ; determine leftmost hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_hi
	adc #0
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getrightxceil
; desc:     Gets the tile X position where the right edge of the player's hitbox resides
; returns:  A - the X coordinate
; note:     this is NOT ALWAYS the same as the result of gm_getleftx!! though perhaps
;           some optimizations are possible..
gm_getrightxceil:
	clc
	lda player_x
	adc #plr_x_rightC; determine right hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_hi
	adc #0
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getleftwjx
; desc: Gets the tile X position where the left of the wall jump check hitbox resides.
; returns: A - the X coordinate.
gm_getleftwjx:
	clc
	lda player_x
	adc #plr_x_wj_left ; determine leftmost hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_hi
	adc #0
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getrightwjx
; desc: Gets the tile X position where the right of the wall jump check hitbox resides.
; returns: A - the X coordinate.
gm_getrightwjx:
	clc
	lda player_x
	adc #plr_x_wj_right ; determine right hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_hi
	adc #0
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getfacex_wj
; desc:    Gets the tile X position of either the left or right of the player's hitbox, depending on
;          which way they're facing. Used for climb hop checking
gm_getfacex_wj:
	lda playerctrl
	and #pl_left
	beq gm_getrightwjx
	jmp gm_getleftwjx

; ** SUBROUTINE: gm_getmidy
; desc:     Gets the tile Y position at the middle of the player's hitbox, used for wall jump checking
; returns:  A - the Y coordinate
gm_getmidy:
	clc
	lda player_y
	adc #plr_y_mid
	bcs xt_gety_wraparound
	cmp #240
	bcs xt_gety_wraparound
	lsr
	lsr
	lsr
	rts
xt_gety_wraparound:
	lda #$FF
	rts

; ** SUBROUTINE: xt_collide
; desc:      Checks for collision.
; arguments: X - tile's x position, Y - tile's y position, A - direction
; returns:   zero flag set - collided
; direction: 0 - floor, 1 - ceiling, 2 - left, 3 - right
; note:      temp1, temp2 & temp7 are used by caller
; note:      collision functions rely on the Y register staying as the Y position of the tile!
; reserves:  temp3, temp4, temp5, temp6
; clobbers:  A, X, Y (not in this func)
xt_collide:
	pha                 ; store the collision direction
	stx temp5
	
	jsr h_get_tile      ; get the tile
	tax
	lda metatile_info,x ; get collision information
	asl
	tax
	lda xt_colljumptable,x
	sta temp3
	inx
	lda xt_colljumptable,x
	sta temp4
	
	pla
	jmp (temp3)         ; use temp3 as an indirect jump pointer

; Arguments for these jump table subroutines:
; * A - The direction of collision
xt_colljumptable:
	.word xt_collidenone
	.word xt_collidefull
	.word xt_collidespikesUP
	.word xt_collidejthru
	.word xt_collidespikesDOWN
	.word xt_collidespikesLEFT
	.word xt_collidespikesRIGHT

xt_collidefull:
	lda #1
	rts

xt_collidejthru:
	sty $FF
	tax
	lda player_vl_y
	bmi xt_collidenone; if player is moving UP, don't do collision checks at all
	cpx #gc_floor
	bne xt_collidenone; no collision for anything but the floor
	tya               ; the tile's Y position now in A
	asl
	asl
	asl               ; it's a pixel position now
	sec
	sbc #(plr_y_bot - jtheight)
	sta temp3
	ldx player_yo
	cpx player_y
	beq xt_colljtnochg
xt_colljtloop:
	cpx temp3
	bcc xt_collidefull; if player failed to fall below tileX - 16 + 3
	inx
	cpx player_y
	bne xt_colljtloop
xt_collidenone:
	lda #0
	rts
xt_colljtnochg:
	; no change in Y
	lda temp3
	sec
	sbc #3            ; take off the rest
	sta temp3
	lda player_y
	cmp temp3
	beq xt_collidefull; might be above or below, we only return collision if we're exactly
	lda #0            ; on the platform's level.
	rts

xt_collidespikesUP:
	tax
	lda gamectrl4
	and #g4_nodeath
	bne @returnNone
	
	lda player_vl_y
	bmi @returnNone   ; if player is going UP, then don't do collision checks at all.
	cpx #gc_ceil      ; if NOT moving up, then kill the player and return
	beq @return       ; (N.B.: not loading 0 because zf would already be set)
	cpx #gc_floor
	bne @walls
	
	tya
	asl
	asl
	asl
	clc
	adc #6
	sta temp3
	
	lda player_yo     ; get the player old Y bottom position
	clc
	adc #15
	cmp temp3
	bcs @returnNone   ; if player's hitbox WAS inside the spike the previous frame, return none
	
	lda player_y
	clc
	adc #15
	cmp temp3
	bcs @kill         ; if player's hitbox is NOW inside the spike, then return
	
@returnNone:
	lda #0            ; clear the zero flag
@return:
	rts
@walls:
	lda player_vl_y
	bmi @returnNone
	lda #pl_ground
	bit playerctrl
	beq @returnNone   ; if wasn't grounded, then it's fine
	; is grounded, check if they are climbing or pushing now or were before
	; if they were pushing it means they were pushing a tile *different* from ours.
	lda prevplrctrl
	ora playerctrl
	and #(pl_climbing | pl_pushing)
	bne @returnNone
@kill:
	jmp gm_killplayer

xt_collidespikesDOWN:
	tax
	lda gamectrl4
	and #g4_nodeath
	bne @returnNone
	
	lda player_vl_y
	bmi :+            ; if player is going DOWN, then don't do collision checks at all.
	bne @returnNone
:	cpx #gc_floor     ; if NOT moving down, then kill the player and return
	beq @return       ; (N.B.: not loading 0 because zf would already be set)
	cpx #gc_ceil
	bne @returnNone   ; @walls
	
	tya
	asl
	asl
	asl
	clc
	adc #2
	sta temp3
	
	lda player_yo     ; get the player old Y top position
	clc
	adc #plr_y_top
	cmp temp3
	bcc @returnNone   ; if player's hitbox WAS inside the spike in the previous frame, return none
	
	lda player_y
	clc
	adc #plr_y_top
	cmp temp3
	bcc @kill
	
@returnNone:
	lda #0
@return:
	rts

;@walls:
;	lda player_vl_x
;	bpl @returnNone
@kill:
	jmp gm_killplayer

; the spikes point right
xt_collidespikesRIGHT:
	tax
	lda gamectrl4
	and #g4_nodeath
	bne @returnNone
	
	lda player_vl_x
	bmi :+            ; if player is going RIGHT, then don't do collision checks at all
	bne @returnNone
:	cpx #gc_right     ; if NOT moving right, then kill the player and return
	beq @return       ; (N.B.: not loading 0 because zf would already be set)
	cpx #gc_left
	bne @returnNone
	
	lda temp5
	asl
	asl
	asl
	sta temp5
	
	lda player_x
	sec
	sbc player_xo
	sta temp6
	
	lda player_xo
	clc
	adc #plr_x_left
	clc
	adc camera_x
	sec
	sbc temp5
	cmp #8            ; if the checking X is >=6 from the tile, then return
	bcs @returnNone
	
	and #7
	
	; check if the old thing is less than 4. if yes, then we're already inside the spike
	cmp #4
	bcc @returnNone
	
	clc
	adc temp6
	bmi @kill         ; if it became negative then <4
	
	; now compare it with two. if it's still bigger than 4, then not inside the hitbox
	cmp #4
	bcc @kill
	
@returnNone:
	lda #0
@return:
	rts
@kill:
	jmp gm_killplayer

; the spikes point left
xt_collidespikesLEFT:
	tax
	lda gamectrl4
	and #g4_nodeath
	bne @returnNone
	
	lda player_vl_x
	bmi @returnNone   ; if player is going LEFT, then don't do collision checks at all
	cpx #gc_left      ; if NOT moving right, then kill the player and return
	beq @return       ; (N.B.: not loading 0 because zf would already be set)
	cpx #gc_right
	bne @returnNone
	
	lda temp5
	asl
	asl
	asl
	sta temp5
	
	lda player_x
	sec
	sbc player_xo
	sta temp6
	
	lda player_xo
	clc
	adc #plr_x_right
	clc
	adc camera_x
	sec
	sbc temp5
	bmi @returnNone
	;cmp #2            ; if the checking X is <2 from the tile, then return
	;bcc @returnNone
	
	and #7
	
	; check if the old thing is more than 4. if yes, then we're already inside the spike
	cmp #4
	bcs @returnNone
	
	clc
	adc temp6
	;bmi @kill         ; if it became negative then <2
	
	; now compare it with two. if it's still bigger than 4, then not inside the hitbox
	cmp #4
	bcs @kill
	
@returnNone:
	lda #0
@return:
	rts
@kill:
	jmp gm_killplayer

; ** SUBROUTINE: gm_applyy
; desc:     Apply the velocity in the Y direction.
gm_velminus:
	adc player_y      ; Velocity is minus. X contains whether the old position was >= $F0
	sta player_y
	cmp #$F0
	bcs gm_velapplied ; if the position is now more than #$F1, then we don't need to do anything
	cpx #0            ; if X is 0, then the old position was < $F1, therefore we're done
	beq gm_velapplied
	lda #$F0
	sta player_y      ; otherwise, cap our position up to $F1
	jmp gm_velapplied
	
gm_applyy:
	; clear entground, because this is run first
	ldy #$FF
	sty entground
	sty temp9
	
	lda player_y
	sta player_yo     ; backup the old Y position. Used for spike collision
	cmp #$F0
	rol               ; A = (A << 1) | carry [set if A >= $F0]
	and #1            ; A = A & 1
	tax               ; X = (player_y >= $F0)
	lda playerctrl
	and #(pl_ground ^ $FF)
	sta playerctrl    ; remove the grounded flag - it'll be added back if we are on the ground
	clc
	lda player_vs_y
	adc player_sp_y
	sta player_sp_y
	lda player_vl_y
	bmi gm_velminus   ; if player_vl_y < 0, then handle the minus case separately
	adc player_y      ; player_vl_y >= 0
	sta player_y
	cmp #$F0          ; if A >= $F0 && X, then die
	bcc gm_velapplied
	cpx #1
	beq :+
	jmp gm_killplayer
:
gm_leaveroomU_:
	jmp gm_leaveroomU

gm_velapplied:        ; this is the return label from gm_velminus4
	lda player_y
	cmp #$F0
	bcs gm_leaveroomU_
	lda player_vl_y
	bpl gm_checkfloor

;gm_checkceil:
	jsr gm_getleftxceil
	sta temp1
	jsr gm_getrightxceil
	sta temp2
	
	jsr xt_collentceil
	bne @snapToCeilArbitrary
	
	jsr gm_gettopy
	tay
	sty y_crd_temp
	
	ldx temp1         ; check block 1
	lda #gc_ceil
	jsr xt_collide
	bne @snapToCeil
	
	ldy y_crd_temp    ; check block 2
	ldx temp2
	lda #gc_ceil
	jsr xt_collide
	bne @snapToCeil
	beq gm_applyy_checkdone

@snapToCeil:
	lda y_crd_temp    ; load the y position of the tile that was collided with
	asl
	asl
	asl               ; turn it into a screen coordinate

@snapToCeilArbitrary: ; snap to a ceiling whose position is arbitrary
	clc
	adc #(8-(16-plrheight)) ; add the height of the tile, minus the top Y offset of the player hitbox
	sta player_y
	lda #0            ; set the subpixel to zero
	sta player_sp_y
	sta player_vl_y   ; also clear the velocity
	sta player_vs_y   ; since we ended up here it's clear that velocity was negative.
	sta jcountdown    ; also clear the jump timer
	beq gm_applyy_checkdone

gm_checkfloor:
	jsr gm_getleftx
	sta temp1
	jsr gm_getrightx
	sta temp2
	jsr xt_collentfloor
	bne @snapToFloorArbitrary
	
	jsr gm_getbottomy_f
	tay               ; keep the Y position into the Y register
	sty y_crd_temp
	
	ldx temp1         ; check block 1
	lda #gc_floor
	jsr xt_collide
	bne @snapToFloor
	
	ldy y_crd_temp    ; check block 2
	ldx temp2
	lda #gc_floor
	jsr xt_collide
	bne @snapToFloor
	beq gm_applyy_checkdone
	
@snapToFloor:
	lda #%11111000    ; round player's position to lower multiple of 8
	and player_y
	pha
	lda #0            ; set the subpixel to zero
	sta player_sp_y
	pla
	
@snapToFloorArbitrary:; snap to floor where the 
	sta player_y
	lda dashtime
	cmp #(defdashtime-dashgrndtm)
	bcs @done         ; until the player has started their dash, exempt from ground check
	lda #pl_ground    ; set the grounded bit, only thing that can remove it is jumping
	ora playerctrl
	and #(pl_dashed^$FF) ; clear the dashed flag
	sta playerctrl
	lda #defjmpcoyot
	sta jumpcoyote    ; assign coyote time because we're on the ground
	lda #0
	sta wjumpcoyote   ; can't perform a wall jump while on the ground
	sta player_vl_y
	sta player_vs_y
	sta hopcdown
	sta dashcount
	lda #<staminamax
	sta stamina
	lda #>staminamax
	sta stamina+1
	lda gamectrl2
	and #<~g2_autojump
	sta gamectrl2
	
@done:
gm_applyy_checkdone:
	jsr xt_scroll_u_cond
	jmp xt_scroll_d_cond

; ** SUBROUTINE: gm_applyx
; desc:    Apply the velocity in the X direction. 
.proc gm_applyx
	; Climb Hop Solid Movement
	ldy chopentity
	bmi applyXSub
	
	lda sprspace+sp_flags, y
	and #ef_collidable
	bne isCHopEntCollidable
	
	lda #$FF
	sta chopentity
	bne applyXSub

isCHopEntCollidable:
	lda player_vl_x
	pha
	lda player_vl_y
	pha
	
	; add the amount the climb hop solid moved in 1 frame, to the vel, then
	; apply that new velocity, then restore the old one
	lda sprspace+sp_x, y
	sec
	sbc choplastX
	clc
	adc player_vl_x
	sta player_vl_x
	
	lda sprspace+sp_y, y
	sec
	sbc choplastY
	clc
	adc player_vl_y
	sta player_vl_y
	
	lda sprspace+sp_x, y
	sta choplastX
	lda sprspace+sp_y, y
	sta choplastY
	
	jsr applyXSub
	
	pla
	sta player_vl_y
	pla
	sta player_vl_x
	rts
	
applyXSub:
	lda player_x
	sta player_xo
	
	clc
	lda player_vl_x
	rol                      ; store the upper bit in carry
	lda #$FF
	adc #0                   ; add the carry bit if needed
	eor #$FF                 ; flip it because we need the reverse
	tay                      ; This is the "screenfuls" part that we need to add to the player position
	
	lda playerctrl
	and #(pl_pushing^$FF)
	sta playerctrl           ; clear the pushing flag - it will be set on collision
	
	clc
	lda player_vs_x
	adc player_sp_x
	sta player_sp_x
	lda player_vl_x
	adc player_x
	
	bcs dontCheckOffs        ; If the addition didn't overflow, we need to detour.
	ldx player_vl_x          ; check if the velocity was positive
	bpl dontCheckOffs        ; yeah, of course it wouldn't overflow, it's positive!
	lda #0                   ; we have an underflow, means the player is trying to leave the screen
	ldy #0                   ; through the left side. we can't let that happen!
	clc                      ; zero out the player's new position
dontCheckOffs:
	sta player_x
	jsr gm_gettopy
	sta temp1                ; temp1 - top Y
	jsr gm_getbottomy_w
	sta temp2                ; temp2 - bottom Y
	lda player_vl_x
	bmi checkLeft
	; >=0
	bne checkRight
	lda player_vs_x
	beq checkLeft

checkRight:
	lda #(maxvelxhi+2)
	sta temp10

checkRightLoop:
	dec temp10
	beq checkDone            ; nope, out of here with your stupid games
	lda player_x
	cmp #$F0
	bcs callLeaveRoomR       ; try to leave the room
	
doneLeavingRoom:
	jsr gm_collentright
	bne collidedRight
	
	jsr gm_getrightx
	tax
	stx y_crd_temp           ; note: x_crd_temp is clobbered by xt_collide!
	ldy temp1
	lda #gc_right
	jsr xt_collide
	bne collidedRight        ; if collided, move a pixel back and try again
	
	ldy temp2                ;  snapping to the nearest tile is a BIT more complicated so
	ldx y_crd_temp           ;  I will not bother
	lda #gc_right
	jsr xt_collide
	beq checkDone

collidedRight:
	lda hopcdown
	bne :+
	
	ldx #0                   ; set the velocity to a minuscule value to
	stx player_vl_x          ; ensure the player doesn't look idle
	inx
	stx player_vs_x
	
:	lda playerctrl
	ora #pl_pushing
	and #(pl_wallleft^$FF)   ; the wall wasn't found on the left.
	sta playerctrl
	
	jsr gm_check_attach_wall
	
	lda #defwjmpcoyo
	sta wjumpcoyote
	ldx player_x
	beq checkDone            ; if the player X is zero... we're stuck inside a wall
	
	dex
	stx player_x
	ldx #$FF                 ; set the subpixel to $FF.  This allows our minuscule velocity to
	stx player_sp_x          ; keep colliding with this wall every frame and allow the push action to continue
	jmp checkRightLoop       ; !! note: in case of a potential clip, this might cause lag frames!
	                         ; loops will be used to avoid this unfortunate case as much as possible.
;

checkDone:
	jsr xt_scroll_l_cond
	jmp xt_scroll_r_cond

checkDone2:
	lda player_vl_x
	bne checkDone
	lda player_vs_x
	bne checkDone
	beq checkRight          ; also check right, if player is not moving at all

callLeaveRoomR:
	jsr gm_leaveroomR
	bne doneLeavingRoom
	rts

checkLeft:
	lda #(maxvelxhi+2)
	sta temp10

checkLeftLoop:
	dec temp10
	beq checkDone2           ; nope, out of here with your stupid games
	
	jsr gm_collentleft
	bne collidedLeft
	
	jsr gm_getleftx
	tax
	stx y_crd_temp
	ldy temp1
	lda #gc_left
	jsr xt_collide
	bne collidedLeft         ; if collided, move a pixel to the right & try again
	ldy temp2
	ldx y_crd_temp
	lda #gc_left
	jsr xt_collide
	beq checkDone2

collidedLeft:
	lda hopcdown
	bne :+
	
	ldx #$FF                 ; set the velocity to a minuscule value to
	stx player_vl_x          ; ensure the player doesn't look idle
	stx player_vs_x
	
:	lda playerctrl
	ora #(pl_pushing | pl_wallleft) ; the wall was found on the left.
	sta playerctrl
	
	jsr gm_check_attach_wall
	
	lda #defwjmpcoyo
	sta wjumpcoyote
	ldx player_x
	cpx #$F0                 ; compare to [screenWidth-16]
	bcs checkDone2           ; if bigger or equal, just bail, we might be stuck in a wall
	inx
	stx player_x
	ldx #0                   ; set the subpixel to 0.  This allows our minuscule velocity to
	stx player_sp_x          ; keep colliding with this wall every frame and allow the push action to continue
	jmp checkLeftLoop
.endproc

gm_appx_checkleft  := gm_applyx::checkLeft
gm_appx_checkright := gm_applyx::checkRight

; ** SUBROUTINE: gm_checkwjump
; desc: Assigns coyote time if wall is detected near the player.
gm_checkwjump:
	lda playerctrl
	and #<~pl_nearwall
	sta playerctrl
	
	lda gamectrl4
	ora #g4_nodeath
	sta gamectrl4
	
	and #pl_ground
	beq @alwaysSet           ; if player is grounded, and they aren't pushing the climb button, simply return.
	
	; is grounded
	lda climbbutton
	beq @dontSet
	
@alwaysSet:
	jsr gm_gettopy
	sta temp1
	jsr gm_getbottomy_wjc
	sta temp2
	
	lda playerctrl
	and #pl_left
	
	; preferentially check the left wall first, if the player is facing left
	beq @checkRightFirst
	
	; check the left side first
	; left side
	jsr gm_wjckentleft
	bne @setL
	
	jsr gm_getleftwjx
	sta temp7
	tax
	lda #gc_left
	ldy temp1
	jsr xt_collide
	bne @setL
	
	lda #gc_left
	ldx temp7
	ldy temp2
	jsr xt_collide
	bne @setL
	
	; right side
	jsr gm_wjckentright
	bne @setR
	
	jsr gm_getrightwjx
	sta temp7
	tax
	lda #gc_right
	ldy temp1
	jsr xt_collide
	bne @setR
	
	lda #gc_right
	ldx temp7
	ldy temp2
	jsr xt_collide
	beq @dontSet
	
@setR:
	lda playerctrl
	and #(pl_wallleft^$FF)   ; set that a wall was found on the RIGHT side
@set:
	ora #pl_nearwall
	sta playerctrl
	lda #defwjmpcoyo
	sta wjumpcoyote
@dontSet:
	lda gamectrl4
	and #<~g4_nodeath
	sta gamectrl4
	rts
@setL:
	lda playerctrl
	ora #pl_wallleft         ; set that a wall was found on the LEFT side
	jmp @set

@checkRightFirst:
	; check the right side first
	; right side
	jsr gm_wjckentright
	bne @setR
	
	jsr gm_getrightwjx
	sta temp7
	tax
	lda #gc_right
	ldy temp1
	jsr xt_collide
	bne @setR
	
	lda #gc_right
	ldx temp7
	ldy temp2
	jsr xt_collide
	bne @setR
	
	; left side
	jsr gm_wjckentleft
	bne @setL
	
	jsr gm_getleftwjx
	sta temp7
	tax
	lda #gc_left
	ldy temp1
	jsr xt_collide
	bne @setL
	
	lda #gc_left
	ldx temp7
	ldy temp2
	jsr xt_collide
	bne @setL
	beq @dontSet

; ** SUBROUTINE: gm_calchorzplat
; desc: Calculates the edges of a platform entity in plattemp1, plattemp2, screen coordinates.
;       These can be used to check whether the player is standing on a platform.
; arguments: Y register - the index of the Entity
; returns:   plattemp1 - Left edge, plattemp2 - Right edge, ZF - Are they valid
gm_calchorzplat:
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

; ** SUBROUTINE: xt_collentfloor
; desc: Checks ground collision with entities.
; note: can't use: temp1, temp2
; note: Currently this only detects the first sprite the player has collided with,
;       not the closest.
; returns: ZF - the player has collided (BNE). A - the Y position of the floor minus 16
xt_collentfloor:
	ldy #0
@loop:
	lda #ef_collidable
	and sprspace+sp_flags, y ; if the flag isn't set then why should we bother?
	beq @noHitBox
	
	; also check the type
	lda sprspace+sp_kind, y
	beq @noHitBox
	
	; check if the bottom of the player's hit box is between the top and bottom of this platform.
	lda player_y
	clc
	adc #$10
	sta temp4
	
	lda sprspace+sp_y, y
	cmp temp4
	bcc :+                    ; sprites[y].y <= player_y + $10
	beq :+
	bne @noHitBox

:	clc
	adc sprspace+sp_hei, y
	cmp temp4
	bcc @noHitBox             ; sprites[y].y + sprites[y].height <= player_y + $10
	
	jsr gm_calchorzplat
	beq @noHitBox
	
	; ok. now do the checks themselves.
	lda player_x
	clc
	adc #(7+plrwidth/2)
	cmp plattemp1
	bcc @noHitBox            ; playerX + 8 + plrWidth/2 < platformLeftEdge
	
	lda player_x
	sec
	adc #(8-plrwidth/2)
	cmp plattemp2
	bcc @haveHitBox          ; playerX + 8 - plrWidth/2 + 1 >= platformRightEdge
	
@noHitBox:
	iny
	cpy #sp_max
	bne @loop
	; note: here, the zero flag is set. Means there was no collision
	rts

@haveHitBox:
	; Have a hitbox!
	sty entground
	lda sprspace+sp_y_lo, y
	sta player_sp_y
	lda sprspace+sp_y, y
	sec
	sbc #$10
	ldx #1                   ; load X to 1 to clear the zero flag. probably superfluous
	rts

; ** SUBROUTINE: xt_collentceil
; desc: Checks ceiling collision with entities.
; note: can't use: temp1, temp2
; note: Currently this only detects the first sprite the player has collided with,
;       not the closest.
; returns: ZF - the player has collided (BNE). A - ceilingY + entityHeight - 8
xt_collentceil:
	ldy #0
@loop:
	lda #ef_collidable
	and sprspace+sp_flags, y ; if the flag isn't set then why should we bother?
	beq @noHitBox
	
	; also check the type
	lda sprspace+sp_kind, y
	beq @noHitBox
	
	; check if the top of the player's hit box is between the top and bottom of this platform.
	lda player_y
	clc
	adc #(16-plrheight)
	sta temp4
	
	lda sprspace+sp_y, y
	cmp temp4
	bcc :+                    ; sprites[y].y <= player_y
	beq :+
	bne @noHitBox

:	clc
	adc sprspace+sp_hei, y
	cmp temp4
	bcc @noHitBox             ; sprites[y].y + sprites[y].height <= player_y
	;beq @noHitBox
	
	jsr gm_calchorzplat
	beq @noHitBox
	
	; ok. now do the checks themselves.
	lda player_x
	clc
	adc #(7+plrwidth/2)
	cmp plattemp1
	bcc @noHitBox            ; playerX + 8 + plrWidth/2 < platformLeftEdge
	
	lda player_x
	sec
	adc #(8-plrwidth/2)
	cmp plattemp2
	bcc @haveHitBox          ; playerX + 8 - plrWidth/2 + 1 >= platformRightEdge
	
@noHitBox:
	iny
	cpy #sp_max
	bne @loop
	; note: here, the zero flag is set. Means there was no collision
	rts

@haveHitBox:
	; Have a hitbox!
	lda sprspace+sp_y, y
	clc
	adc sprspace+sp_hei, y
	sec
	sbc #$7
	ldx #1                   ; load X to 1 to clear the zero flag. probably superfluous
	rts

; ** SUBROUTINE: gm_collentleft
; ** SUBROUTINE: gm_collentright
; ** SUBROUTINE: gm_wjckentleft
; ** SUBROUTINE: gm_wjckentright
; desc: Wrappers for gm_collentside.
;       gm_coll* check regular collision, gm_wjck* check for wall jump ability.
; clobbers: temp5, temp6, temp7
gm_collentleft:
	lda #plr_x_left
	sta temp5
	lda #plr_y_top
	sta temp6
	lda #plr_y_bot_wall
	sta temp7
	jmp gm_collentside

gm_collentright:
	lda #plr_x_right
	sta temp5
	lda #plr_y_top
	sta temp6
	lda #plr_y_bot_wall
	sta temp7
	jmp gm_collentside

gm_wjckentleft:
	lda #plr_x_wj_left
	sta temp5
	lda #plr_y_top
	sta temp6
	lda #plr_y_bot_wall
	sta temp7
	jmp gm_collentside

gm_wjckentright:
	lda #plr_x_wj_right
	sta temp5
	lda #plr_y_top
	sta temp6
	lda #plr_y_bot_wall
	sta temp7
	;jmp gm_collentside

; ** SUBROUTINE: gm_collentside
; desc: Checks rightward collision with entities.
; note: can't use: temp1, temp2, temp7
; note: Currently this only detects the first sprite the player has collided with,
;       not the closest.
; parameters: temp5 (offset for player X), temp6 (offset for player Y), temp7 (second offset for player Y)
; returns: ZF - the player has collided (BNE)
gm_collentside:
	ldy #0
@loop:
	lda #ef_collidable
	and sprspace+sp_flags, y ; if the flag isn't set then why should we bother?
	beq @noHitBox
	
	; also check the type
	lda sprspace+sp_kind, y
	beq @noHitBox
	
	; do we touch the wall with EITHER top or bottom?
	lda player_y
	clc
	adc temp6
	jsr gm_checkthisenty
	bne @isHitting
	
	lda player_y
	clc
	adc temp7
	jsr gm_checkthisenty
	beq @noHitBox
	
@isHitting:
	lda sprspace+sp_x, y
	sec
	sbc camera_x
	sta temp4
	
	lda sprspace+sp_x_pg, y
	sbc camera_x_pg
	bne @noHitBox
	
	lda player_x
	clc
	adc temp5
	cmp temp4
	bcc @noHitBox
	
	pha
	lda temp4
	clc
	adc sprspace+sp_wid, y
	bcc :+
	lda #$FF
:	sta temp4
	
	pla
	cmp temp4
	bcc @haveHitBox
	
@noHitBox:
	iny
	cpy #sp_max
	bne @loop
	; note: here, the zero flag is set. Means there was no collision
	rts

@haveHitBox:
	sty temp9
	ldx #1                   ; load X to 1 to clear the zero flag. probably superfluous
	rts

; ** SUBROUTINE: gm_checkthisenty
; desc:       Checks if the Y value provided in the A register is inside of the current entity.
; parameters: A register - the Y value to check, Y register - the index of the entity.
; returns:    ZF - is inside the entity (BNE).
; clobbers:   A, temp4
gm_checkthisenty:
	cmp sprspace+sp_y, y
	bcc @noHitBox
	sta temp4
	
	lda sprspace+sp_y, y
	clc
	adc sprspace+sp_hei, y
	cmp temp4
	bcc @noHitBox             ; sprites[y].y + sprites[y].height <= player_y + $10
	
	lda #1
	rts
	
@noHitBox:
	lda #0
	rts

gm_dash_lock:
	ldx #0
	stx player_vl_x
	stx player_vl_y
	stx player_vs_x
	stx player_vs_y
	jmp gm_dash_update_done

gm_dash_over:
	; dash has terminated.
	
	; if (DashDir.Y <= 0f) Speed = DashDir * 160f (when begun, it would be DashDir * 240f)
	lda #(cont_down << 2)
	bit dashdir
	bne :+
	
	jsr gm_rem25pcvel
	
	; if (Speed.Y < 0f) Speed.Y *= 0.75f;
	lda player_vl_y
	bpl :+
	jsr gm_rem25pcvelYonly
	
:	jmp gm_dash_update_done

gm_defaultdir:
	ldy #0                  ; player will not be dashing up or down
	lda #pl_left
	and playerctrl          ; bit 0 will be the facing direction
	sec                     ; shift it left by 1 and append a 1
	rol                     ; this will result in either 1 or 3. we handle the L+R case by dashing left
	jmp gm_dash_nodir

gm_superjump:
	lda #pl_ground
	bit playerctrl
	beq @return            ; if player wasn't grounded, then ...
	lda #(cont_down << 2)  ; if she was dashing down
	bit dashdir
	beq @normal
	; half the jump height here
	lda #sjumpvelHI
	sta player_vl_y
	lda #sjumpvelLO
	sta player_vs_y
	bne @continue
@normal:
	lda #jumpvelHI
	sta player_vl_y
	lda #jumpvelLO
	sta player_vs_y         ; super jump speed is the same as normal jump speed
@continue:
	jsr gm_add_lift_boost
	lda #superjmphhi
	sta player_vl_x
	lda #superjmphlo
	sta player_vs_x
	lda #pl_left
	bit playerctrl
	beq :+
	lda player_vl_x
	eor #$FF
	sta player_vl_x
	lda player_vs_x
	eor #$FF
	sta player_vs_x
:	lda #jumpsustain
	sta jcountdown
	lda #0
	sta dashtime            ; no longer dashing. do this to avoid our speed being taken away.
@return:
	rts

gm_dash_update:
	dec dashtime
	beq gm_dash_over        ; if dashtime is now 0, then finish the dash
	cmp #(defdashtime-dashchrgtm)
	beq gm_dash_read_cont   ; if it isn't exactly defdashtime-dashchrgtm, let physics run its course
	bcs gm_dash_lock        ; dash hasn't charged
	jmp gm_dash_after
gm_dash_read_cont:
	jsr gm_dash_sfx
	lda #6
	sta quaketimer
	lda game_cont
	and #%00001111          ; check if holding any direction
	beq gm_defaultdir       ; if not, determine the dash direction from the facing direction	
	lda game_cont
	and #%00001111          ; get all directional flags
	; if horizontal flags are 0, then the vertical flags must NOT be zero, otherwise we ended up in gm_defaultdir
gm_dash_nodir:
	sta quakeflags
	asl
	asl                     ; multiply by four
	tax                     ; this is now an index into the dash_table
	stx dashdir
	; assign all the velocities
	lda dash_table, x
	sta player_vl_x
	pha
	inx
	lda dash_table, x
	sta player_vs_x
	inx
	lda dash_table, x
	sta player_vl_y
	inx
	lda dash_table, x
	sta player_vs_y
	inx
	; we pushed the value of player_vl_x such that it can be quickly loaded and checked
	pla
	bpl gm_dash_update_done
	; dashing left
	lda playerctrl
	ora #pl_left
	sta playerctrl
	jmp gm_dash_update_done
gm_dash_after:
	; this label is reached when the dash is "completed", i.e. it gives no more
	; boost to the player and physics are enabled.
	lda #%00000011
	bit game_cont
	beq gm_dash_noflip  ; not pressing a direction, so no need to flip the character
	lda playerctrl
	ora #pl_left
	sta playerctrl      ; set the left bit...
	lda #cont_right     ; assumes cont_right == 1
	and game_cont
	eor playerctrl
	sta playerctrl      ; so that, if right is pressed, then we can flip it back
gm_dash_noflip:
	lda jumpcoyote
	beq gm_dash_nosj
	lda jumpbuff
	beq gm_dash_nosj    ; if there is jump buffer and coyote time, then perform a super jump
	jsr gm_superjump
gm_dash_nosj:
	jmp gm_dash_update_done

; ** SUBROUTINE: xt_physics
; desc: Runs one frame of player physics.
.proc xt_physics
	lda #pl_dead
	bit playerctrl
	bne return
	lda respawntmr
	bne return
	
	jsr gm_jumpgrace
	lda dashtime
	bne gm_dash_update
	jsr gm_gravity
	jsr gm_controls
dash_update_done:
	jsr gm_sanevels
	jsr gm_applyy
	jsr gm_applyx
	jsr gm_checkoffgnd
	jsr gm_checkwjump
	jsr gm_climbcheck
	jsr gm_addtrace
	jmp gm_timercheck
return:
	rts
.endproc

gm_dash_update_done := xt_physics::dash_update_done

; ** SUBROUTINE: gm_timercheck
; desc: Checks and decreases relevant timers.
gm_timercheck:
	lda playerctrl
	sta prevplrctrl
	
	lda forcemovext
	
	; if forcemovext == 0, then remove the reference to the climb hop entity
	bne @fmxtNotZero
	lda #$FF
	sta chopentity
	bne @doneWithFmxt
	
@fmxtNotZero:
	; if forcemovext != 0, then decrement forcemovext
	dec forcemovext

@doneWithFmxt:
	lda hopcdown
	beq :+
	dec hopcdown
:	lda jcountdown
	beq @return

	; jump countdown is active. Check if the A button is still being held.
	lda #g2_autojump
	bit gamectrl2
	bne @decJumpCd
	
	lda #cont_a
	bit game_cont
	beq @dontDecJumpCd

@decJumpCd:
	dec jcountdown
	
@return:
	rts
	
@dontDecJumpCd:
	lda #0
	sta jcountdown        ; nope, so clear the jump countdown and proceed with gravity as usual
	rts

; ** SUBROUTINE: gm_rem25pcvel
; desc: Removes 25% of the player's velocity.
; take off 25% of the X velocity
gm_rem25pcvel:
	lda player_vl_x
	sta temp1
	lda player_vs_x
	sta temp2
	
	lsr temp1
	ror temp2
	lsr temp1
	ror temp2
	
	; minor correction
	lda #%11100000
	bit temp1
	beq :+
	ora temp1
	sta temp1
	
:	sec
	lda player_vl_x
	sbc temp1
	sta player_vl_x
	lda player_vs_x
	sbc temp2
	sta player_vs_x
	
gm_rem25pcvelYonly:
	; take off 25% of the Y velocity
	lda player_vl_y
	sta temp1
	lda player_vs_y
	sta temp2
	
	lsr temp1
	ror temp2
	lsr temp1
	ror temp2
	
	; minor correction
	lda #%11100000
	bit temp1
	beq :+
	ora temp1
	sta temp1
	
:	sec
	lda player_vl_y
	sbc temp1
	sta player_vl_y
	lda player_vs_y
	sbc temp2
	sta player_vs_y
	rts

; ** SUBROUTINE: gm_check_attach_wall
; desc: After a sideways collision check, check if the player is holding the climb button, and if so,
;       initiate the climbing action.
.proc gm_check_attach_wall
	; Note: The collided entity's index is stored in temp9.
	lda climbbutton
	beq noEffect
	
	; check if there is stamina
	lda stamina+1
	bne haveStamina
	lda stamina
	beq noEffect
	
	; check if we are jumping
haveStamina:
	lda jcountdown
	bne noEffect
	lda hopcdown
	bne noEffect
	
	lda temp9
	sta entground ; attach the player to this entity
	
	; set the climbing flag now
	lda playerctrl
	and #pl_climbing
	tax
	
	lda playerctrl
	ora #pl_climbing
	sta playerctrl
	
	and #pl_left
	tay
	lda table, y
	sta temp9
	
	jsr gm_gettopy
	sta temp1                ; temp1 - top Y
	jsr gm_getbottomy_w
	sta temp2                ; temp2 - bottom Y
	
	; don't reduce the velocity if pl_climbing was set already
	txa
	bne noEffect
	jsr gm_reduce_vel_climb
noEffect:
	rts

table:	.byte 3, 5  ; no left, left
.endproc

; ** SUBROUTINE: gm_climbcheck
; desc: If the climbing flag is set, checks if the player should release the climbed wall.
; This happens if one of the following conditions is met:
; 1. The player let go of L/Up/Select
; 2. The object the player is climbing on has disappeared
; 3. There is no wall in the facing direction (in case Madeline is climbing a wall)
;
; This also checks the UP/DOWN directions to move the player up and down, and deducts points
; of stamina.
.proc gm_climbcheck
	lda #stamchgdef
	sta temp10
	
	ldx #0
	lda stamina+1
	bne noLowStaminaFlash
	lda stamina
	cmp #stamlowthre
	bcs noLowStaminaFlash
	
	; Low Stamina Flash Timer
	ldx stamflashtm
	inx
	
noLowStaminaFlash:
	stx stamflashtm
	
	lda dashtime
	bne return
	lda jcountdown
	bne return
	lda hopcdown
	bne return
	
	lda playerctrl
	and #pl_climbing
	bne alreadyClimbing
	
	; not already climbing, check wall
	lda playerctrl
	and #pl_nearwall
	beq return
	
	; check if that wall is in the direction of the character
	lda playerctrl
	and #pl_wallleft
	lsr
	lsr
	lsr
	eor playerctrl
	and #pl_left
	bne return       ; if they are different, then return
	
	; has a wall!
	lda climbbutton
	beq return
	
	lda stamina+1
	bne :+
	lda stamina
	beq return
	
	; we can start climbing!!
:	lda playerctrl
	ora #pl_climbing
	sta playerctrl
	
	jsr gm_reduce_vel_climb
	
	lda gamectrl2
	and #<~g2_autojump
	sta gamectrl2
	
	; ensure that Madeline's position resides entirely on the wall
	lda playerctrl
	and #pl_wallleft
	bne left
	
	; right
	lda player_x
	clc
	adc #6
	bcc :+
	lda #$FF
:	sta player_x
	jmp gm_appx_checkright

left:
	lda player_x
	sec
	sbc #6
	bcs :+
	lda #0
:	sta player_x
	jmp gm_appx_checkleft
	
alreadyClimbing:
	; clear the autojump flag
	lda gamectrl2
	and #<~g2_autojump
	sta gamectrl2
	
	lda climbbutton
	bne noRelease
release:
	lda playerctrl
	and #<~pl_climbing
	sta playerctrl
	lda gamectrl4
	and #<~g4_nodeath
	sta gamectrl4
	lda #$FF
	sta entground
return:
	rts
	
noRelease:
	; player is still holding climb.
	lda stamina+1
	bne haveStamina
	lda stamina
	beq release     ; CLIMB should be released if there is no stamina left
	
haveStamina:
	; player has stamina. Check if the entity disappeared
	ldy entground
	bmi noEntity
	
	; POTENTIAL BUG: If this slot is immediately replaced with a different slot,
	; Madeline might inherit the climb on this object. Does that really matter?
	; Probably not.
	lda sprspace+sp_kind, y
	beq release     ; If the entity's type is just zero, then release the climb.
	
	lda sprspace+sp_flags, y
	and #ef_collidable
	beq release     ; If this entity is no longer collidable, then release the climb.
	
noEntity:
	
	; The gm_checkwjump function, called above this one, tells us if a wall is near.
	lda playerctrl
	and #pl_nearwall
	bne hasWall
	
	; No wall was detected!
	; Release the wall but set the vel to zero
noWallRelease:
	lda #0
	sta player_vl_x
	sta player_vs_x
	beq release
	
	; tables:
tableDirs:	.byte gc_right, gc_right, gc_left, gc_right
velsLo:		.byte <climbhopX, <(-climbhopX)
velsHi:		.byte >climbhopX, >(-climbhopX)
ledgeCheckX:.byte $0F, $00

hasWall:
	; Ok, we have a wall.  Is it in our facing direction?
	; (Note: gm_checkwjump no longer checks the left wall first, it checks the wall in our facing direction first
	; INVARIANT: pl_left == $01
	lda playerctrl
	and #pl_left
	tay
	
	lda playerctrl
	and #pl_wallleft
	cmp table, y
	
	; if there is no wall *in our facing direction*, then release.
	bne noWallRelease
	
	; check for climb hop
	lda player_vl_y
	bmi :+
	jmp noForcedRelease
	
:	lda game_cont
	and #cont_up
	beq noForcedReleaseBeq
	
	; Are we on the ground?  If yes, there are no possibilities for climb hopping.
	lda gamectrl
	and #pl_ground
	bne noForcedReleaseBne
	
	; Are we on an entity? We must be climbing it, if so. Otherwise, we would be
	; standing on that entity and pl_ground would be set.
	ldy entground
	bpl handleEntityClimbHop
	
	lda game_cont
	and #(cont_left | cont_right)
	tax
	stx temp7
	lda tableDirs, x
	pha
	
	lda gamectrl4
	ora #g4_nodeath
	sta gamectrl4
	
	jsr gm_getfacex_wj
	sta temp1
	tax
	jsr gm_getbottomy_cc
	tay
	
	pla
	sta temp2
	jsr xt_collide
	
	bne noForcedReleaseBne
	
	; are we at least colliding with the top?
	jsr gm_gettopy
	tay
	ldx temp1
	lda temp2
	jsr xt_collide
	bne noForcedReleaseBne
	
	; not colliding with the middle OR top of our hitbox, we must check for climb hop
	; reset the Y velocity
	lda #0
	sta player_vl_y
	sta player_vs_y
	sta player_vl_x
	sta player_vs_x
	
	; but first, ensure the climb hop can happen
	jsr checkClimbHopSafety
	bne moveDownAndNoRelease
	
initiateClimbHop:
	lda playerctrl
	and #pl_left     ; invariant: pl_left == $01
	tax
	lda velsLo, x
	sta player_vs_x
	lda velsHi, x
	sta player_vl_x
	
	lda #<climbhopY
	sta player_vs_y
	lda #>climbhopY
	sta player_vl_y
	
	; Add lift boost, if we were riding an entity
	ldy entground
	sty chopentity
	bmi @noEntity
	
	lda sprspace+sp_x, y
	sta choplastX
	lda sprspace+sp_y, y
	sta choplastY
	
@noEntity:
	lda #12
	sta forcemovext
	lda #5
	sta hopcdown
	lda #0
	sta forcemovex
	
	jmp release

noForcedReleaseBeq:
	beq noForcedRelease
noForcedReleaseBne:
	bne noForcedRelease

handleEntityClimbHop:
	; We are on an entity (whose index is loaded into Y), and we need to check for climb hopping
	; This check is much simpler than the tile based check, as all we need to do is check whether
	; the player is above a certain Y position relative to the entity.
	lda player_y
	clc
	adc #plr_y_bot_cc
	cmp sprspace+sp_y, y
	bcs noForcedRelease   ; lower than the top Y of the entity
	
	; Higher, so check if the climb hop is safe
	jsr checkClimbHopSafety
	beq initiateClimbHop

moveDownAndNoRelease:
	inc player_y
	
noForcedRelease:
	lda gamectrl4
	and #<~g4_nodeath
	sta gamectrl4
	
	lda game_cont
	and #(cont_up | cont_down)
	pha
	
	cmp #cont_up
	bne notGoingUp
	
	lda #stamchgup
	sta temp10
	
notGoingUp:
	; Decrement stamina.  Further stamina will be deducted when a player performs an action such as jumping.
	lda stamina
	sec
	sbc temp10
	sta stamina
	bcs dontDecrementHighByte
	dec stamina+1
	bpl dontDecrementHighByte
	lda #0
	sta stamina
	sta stamina+1

dontDecrementHighByte:
	pla
	lsr
	lsr
	
	; I don't understand what llvm-mos cooked here. You might not either.
	; original C code:
	; if (player_vy > target) {
	; 	player_vy -= climbvelamt;
	; 	if (player_vy < target)
	; 		player_vy = target;
	; }
	; else {
	; 	player_vy += climbvelamt;
	; 	if (player_vy > target)
	; 		player_vy = target;
	; }
	tay
	ldx table2lo, y
	lda table2hi, y
	stx temp3
	ldx player_vs_y
	ldy player_vl_y
	stx temp4
	stx temp2
	ldx temp3
	cpx temp2
	sty temp3
	sty temp2
	sta temp5
	sbc temp2
	bvc @LBB0_2
	eor #$80
@LBB0_2:
	tay
	bpl @LBB0_8
	clc
	lda temp4
	adc #$C0
	tay
	lda temp3
	adc #$FF
	sty player_vs_y
	sta player_vl_y
	stx temp2
	cpy temp2
	sbc temp5
	bvc @LBB0_5
@LBB0_4:
	eor #$80
@LBB0_5:
	tay
	bpl @LBB0_7
	stx player_vs_y
	ldy temp5
	sty player_vl_y
@LBB0_7:
	lda gamectrl4
	and #<~g4_nodeath
	sta gamectrl4
	rts
@LBB0_8:
	clc
	lda temp4
	adc #$40
	sta temp2
	tay
	lda temp3
	adc #0
	sta temp3
	sty player_vs_y
	sta player_vl_y
	cpx temp2
	lda temp5
	sbc temp3
	bvs @LBB0_4
	bvc @LBB0_5 ; jmp @LBB0_5
	brk
	
table: .byte 0, pl_wallleft
table2lo: .byte $00,$55,$40,$00
table2hi: .byte $00,$01,$FF,$00

checkClimbHopSafety:
	lda camera_x_pg
	and #1
	sta temp10
	
	; load tile X
	lda playerctrl
	and #pl_left
	tax
	lda player_x
	clc
	adc camera_x
	bcc :+
	inc temp10
:	clc
	adc ledgeCheckX, x
	bcc :+
	inc temp10
:	pha
	lda temp10
	lsr
	pla
	ror
	lsr
	lsr
	tax
	; load tile Y
	lda player_y
	clc
	adc #10
	lsr
	lsr
	lsr
	tay
	lda temp7
	; get the tile, and then its collision type
	jsr h_get_tile
	tax
	lda metatile_info, x
	; if it's not ct_none, then unsafe
	rts

.endproc

; ** SUBROUTINE: gm_reduce_vel_climb
; desc: Reduce the velocity by 0.25x (Celeste normally does 0.2x) when initiating a climb.
.proc gm_reduce_vel_climb
	; get 1/4 the Y velocity (Celeste does 0.2X but whatever)
	lda player_vl_y
	bmi velocityIsMinus
	
	; velocity positive
	lsr player_vl_y
	ror player_vs_y
	lsr player_vl_y
	ror player_vs_y
	rts
velocityIsMinus:
	sec
	ror player_vl_y
	ror player_vs_y
	sec
	ror player_vl_y
	ror player_vs_y
	rts
.endproc

; ** SUBROUTINE: gm_add_lift_boost
; desc: Adds lift boost to player velocity.
.proc gm_add_lift_boost
	lda player_vl_x
	clc
	adc liftboostX
	sta player_vl_x
	
	; Now for Y it's a bit more complicated.
	; You see, lift boost Y should be more than -0x022A == 0xFDD6.
	lda liftboostY
	bpl normalLiftBoostY
	cmp #$FE
	bcs normalLiftBoostY
	
	; it's $FD, so add #$FDD6
	lda player_vs_y
	clc
	adc #$D6
	sta player_vs_y
	lda player_vl_y
	adc #$FD
	sta player_vl_y
	rts	
	
normalLiftBoostY:
	lda player_vl_y
	clc
	adc liftboostY
	sta player_vl_y
	rts
.endproc

; ** SUBROUTINE: gm_checkoffgnd
; desc: Checks if the player ran off a ledge and apply lift boost if so.
;
; if (LiftBoost.Y < 0f && wasOnGround && !onGround && Speed.Y >= 0f)
;     Speed.Y = LiftBoost.Y;
.proc gm_checkoffgnd
	lda playerctrl
	eor prevplrctrl
	and #pl_ground
	beq return        ; if the grounded state differs
	
	lda playerctrl
	and #pl_ground
	bne return        ; if you are on the ground NOW
	
	lda liftboostY
	bpl return        ; liftboostY negative
	
	lda player_vl_y
	bmi return        ; and player Y vel positive
	
	jmp gm_add_lift_boost
return:
	rts
.endproc
