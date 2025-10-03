; Copyright (C) 2024-2025 iProgramInCpp

; note: gm_xaxisfixup is indexed [0-3], but gm_targetsLO has a 0 byte we can use instead.
; gm_targetsLO and gm_targetsHI should never be indexed [0-3], they're made for [0-2]
gm_xaxisfixup:	.byte $00, $01, $02
gm_targetsLO:	.byte $00, maxwalkLO, maxwalkNLO
gm_targetsHI:	.byte $00, maxwalkHI, maxwalkNHI

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
	beq @returnNormal
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
	lda #g3_nogradra
	bit gamectrl3
	bne @return2
	
	lda #pl_climbing
	bit playerctrl
	beq @notClimbing
	
	lda game_cont
	and #cont_down
	; while holding down, don't move towards the wall
	bne @zeroAndReturn
	
	; set player_v_x to $00FF
	ldx #0
	stx player_vl_x
	dex
	stx player_vs_x
	
	lda #pl_left
	bit playerctrl
	beq :+
	
	; set it to $FF01
	stx player_vl_x
	ldx #1
	stx player_vs_x
	
:	rts

@zeroAndReturn:
	lda #0
	sta player_vl_x
	sta player_vs_x

@return2:
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
	lda #g2_autojump
	bit gamectrl2
	bne @checkanyway
	
	lda #cont_a
	bit game_cont
	beq @normal        ; not holding the A button, use normal gravity
	
@checkanyway:
	; get the absolute
	lda player_vl_y
	bmi @checknegative
	bne @normal
	
	lda player_vs_y
	cmp #lograthresh
	bcc @low
	bcs @normal
	
@checknegative:
	cmp #$FF
	bne @normal
	
	lda player_vs_y
	cmp #$80
	bcc @normal
	bcs @low
	
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
	lda #g3_nogradra
	bit gamectrl3
	bne @nogravity
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
	
	; check if that climb jump window is valid
	lda playerctrl
	and #pl_nearwall
	bne @isNearWall
	
	lda #0
	sta cjwindow
	beq @noClimbJumpWindow
	
@isNearWall:
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
	lda #g2_nodash
	bit gamectrl2
	bne gm_dontdash
	
	lda levelnumber
	bne @mayDash
	
	lda p1_cont ; not game_cont, that may be influenced by game_cont_force
	and #(cont_left | cont_right | cont_up | cont_down)
	cmp #(cont_right | cont_up)
	bne gm_dontdash
	
	; dash!!
@mayDash:
	jsr gm_add_lift_boost
	inc dashcount
	ldx #defdashtime
	stx dashtime
	ldx #defdshatktm
	stx dshatktime
	lda player_vl_x
	sta dshold_vl_x
	lda player_vs_x
	sta dshold_vs_x
	jsr gm_clear_vel
	lda playerctrl
	and #<~(pl_climbing|pl_nearwall|pl_pushing|pl_wallleft)
	sta playerctrl
	lda playerctrl2
	and #<~(p2_ducking)
	sta playerctrl2
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
	lda #jumpsustain
	sta jcountdown
	lda #0
	sta jumpbuff      ; consume the buffered jump input
	sta jumpcoyote    ; consume the existing coyote time
	sta wjumpcoyote   ; or the wall coyote time
	lda playerctrl
	and #<~(pl_ground|pl_climbing)
	sta playerctrl
	lda gamectrl4
	and #<~g4_nosjump
	sta gamectrl4
	lda #%00000011
	bit game_cont
	beq gm_dontjump2  ; don't give a boost if we aren't moving
	lda player_vl_x
	bmi gm_jumpboostneg; if velocity < 0 pixels, then apply the leftward jump boost
	bne gm_applyjumpboost ; if velocity >= 1 pixel, then apply the jump boost
	beq gm_dontjump2  ; 0 < velocity < 1 so dont do a jump boost
gm_jumpboostneg:
	cmp #$FF
	beq gm_dontjump2  ; if -1 <= velocity, then don't apply a jump boost
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
	jmp gm_dontjump2  ; that would be pretty stupid as it would
gm_jumphboostR:       ; allow speed buildup up to the physical limit
	clc
	lda #jmphboost
	adc player_vs_x
	sta player_vs_x
	lda #0
	adc player_vl_x
	sta player_vl_x
	;jmp gm_dontjump2
gm_dontjump2:
	jsr gm_add_lift_boost
	jmp gm_dontjump

gm_maybewalljump:
	lda #pl_ground
	bit playerctrl
gm_normaljump_bne:
	bne gm_normaljump
	
	lda climbbutton
	beq gm_walljump
	
	; climb button is held, do we have stamina?
	lda stamina+1
	bne :+
	lda stamina
	beq gm_walljump

:	; finally, check if we're facing the right way
	lda playerctrl
	and #pl_left
	sta temp11
	lda playerctrl
	and #pl_wallleft
	lsr
	lsr
	lsr        ; pl_wallleft == $08
	eor temp11 ; the condition is: (wallLeft && !left) || (!wallLeft && left) <==> wallLeft != left
	bne gm_walljump
	
	; set the climbing flag and fall into gm_walljump
	lda playerctrl
	ora #pl_climbing
	and #<~pl_ground
	sta playerctrl
	
gm_walljump:
	lda playerctrl2
	and #<~p2_ducking
	sta playerctrl2
	
	lda #pl_ground
	bit playerctrl
	bne gm_normaljump_bne ; if player is grounded, ALWAYS perform a standard jump
	
	; check if player is climbing right now
	lda playerctrl
	and #pl_climbing
	beq gm_notclimbing
	
	; climbing, check if the held direction is different from the facing direction
	lda game_cont
	and #(cont_left|cont_right)
	beq gm_climbjump  ; not holding any buttons, so standard jump
	
	and #cont_left    ; cont_left == $02
	lsr
	sta temp1
	
	lda playerctrl
	and #pl_left      ; pl_left == $01
	eor temp1
	bne gm_notclimbing; if they match (player was holding left while facing left), then climb jump
	
	; climb jump, but charge the correct stamina if they have it
gm_climbjump:
	lda stamina+1
	bne @ahead
	lda stamina
	beq gm_notclimbing
	
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
	
	lda gamectrl4
	and #<~g4_nosjump
	sta gamectrl4
	
	lda #0
	;sta player_vl_x
	;sta player_vs_x
	sta dashtime
	sta dshatktime
	
	; note: cjwalldir is the direction you must hold for a wall jump stamina refund!
	lda playerctrl
	and #pl_left    ; pl_left is equal to 1
	sta cjwalldir
	eor #1
	asl
	ora cjwalldir
	sta cjwalldir
	
	jmp gm_normaljmp2
	
gm_notclimbing:
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
	and #((pl_left|pl_climbing)^$FF)
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
	lda gamectrl4
	and #<~(g4_movedX|g4_movedY)
	sta gamectrl4
	
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
	lda camera_x_pg
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
	lda camera_x_pg
	adc #0
	ror               ; rotate it into carry
	jmp gm_commondividexcrdtemp
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
	lda camera_x_pg
	adc #0
	ror               ; rotate it into carry
gm_commondividexcrdtemp:
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
	lda camera_x_pg
	adc #0
	ror               ; rotate it into carry
	jmp gm_commondividexcrdtemp

; ** SUBROUTINE: gm_getleftwjx
; desc: Gets the tile X position where the left of the wall jump check hitbox resides.
; returns: A - the X coordinate.
gm_getleftwjx:
	lda dshatktime
	bne @dashing
	clc
	lda player_x
	adc #plr_x_wj_left ; determine leftmost hitbox position
@restOfCode:
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_pg
	adc #0
	ror               ; rotate it into carry
	jmp gm_commondividexcrdtemp
@dashing:
	clc
	lda player_x
	adc #plr_x_wjd_left ; determine leftmost hitbox position
	jmp @restOfCode

; ** SUBROUTINE: gm_getrightwjx
; desc: Gets the tile X position where the right of the wall jump check hitbox resides.
; returns: A - the X coordinate.
gm_getrightwjx:
	lda dshatktime
	bne @dashing
	clc
	lda player_x
	adc #plr_x_wj_right ; determine right hitbox position
@restOfCode:
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_pg
	adc #0
	ror               ; rotate it into carry
	jmp gm_commondividexcrdtemp
@dashing:
	clc
	lda player_x
	adc #plr_x_wjd_right ; determine right hitbox position
	jmp @restOfCode

; ** SUBROUTINE: gm_getbottomy_cc
; desc:     Gets the tile Y position in the middle of the player's hitbox, used for climb hop checks
gm_getbottomy_cc:
	lda player_y
	clc
	adc #plr_y_bot_cc
	bcs xt_gety_wraparound
	cmp #240
	bcs xt_gety_wraparound
	lsr
	lsr
	lsr
	cmp #$1D
	bcc :+
	lda abovescreen
	beq :+
	lda #$1D
:	rts

; ** SUBROUTINE: gm_getbottomy_short
; desc:     Gets the tile Y position at the bottom but slightly higher than the normal hitbox. Unused?
gm_getbottomy_short:
	lda player_y
	clc
	adc #plr_y_bot_wjc
	bcs xt_gety_wraparound
	cmp #240
	bcs xt_gety_wraparound
	lsr
	lsr
	lsr
	cmp #$1D
	bcc :+
	lda abovescreen
	beq :+
	lda #$1D
:	rts

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
	.word xt_collidedream
	.word xt_collidecass1
	.word xt_collidecass2
	.word xt_collidespinnerstatic
	.word xt_collidefthru

xt_collidecass1:
	lda cassrhythm
	and #1
	rts
xt_collidecass2:
	lda cassrhythm
	and #1
	eor #1
	rts

xt_collidefull:
	lda #1
	rts

xt_collidefthru:
	cmp #gc_ceil
	bne :+
	lda #1
	rts
:	lda #0
	rts

xt_collidejthru:
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

xt_collidespinnerstatic:
	lda gamectrl4
	and #g4_nodeath
	bne @returnNone
	
	; ok, check if one of two centre points is inside this tile
	;jmp gm_killplayer
	
@returnNone:
	lda #0
	rts
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

.proc xt_collidedream
	tax
	lda dbenable
	beq thisSolid
	
	lda gamectrl4
	and #g4_dreamdsh
	bne isDreamDashing
	
	; not dream dashing, check if we can initiate a dream dash
	lda dshatktime
	beq thisSolid
	
	; depending on direction, check if there is a dream block in the middle
	jsr checkDreamBlockInMiddle
	bne thisSolid
	
	lda gamectrl4
	ora #(g4_dreamdsh | g4_hasdrdsh)
	sta gamectrl4
	lda #0
	rts

thisSolid:
	lda #1
	rts
	
isDreamDashing:
	lda dashtime
	cmp #(defdashtime-dashchrgtm)
	bcs dontCorrect
	
	ldx dashdir
	lda dash_table, x
	sta player_vl_x
	inx
	lda dash_table, x
	sta player_vs_x
	inx
	lda dash_table, x
	sta player_vl_y
	inx
	lda dash_table, x
	sta player_vs_y
	
dontCorrect:
	lda gamectrl4
	ora #g4_hasdrdsh
	sta gamectrl4
	
	lda #0
	rts

; this checks whether there is a dream block in the direction the player is dashing
; returns: ZF set - there is a dream block
checkDreamBlockInMiddle:
	; X contains the collision direction... but we will ignore that
	; and instead check the dash directions ourselves
	
	; determine X coordinate
	lda dashdir
	lsr
	lsr
	tax
	lda @validCombinations, x
	pha
	and #(cont_up|cont_down)
	
	cmp #cont_up
	beq @goesUp
	cmp #cont_down
	beq @goesDown
	; middle
	jsr gm_getmidy
	jmp @doneY
@goesUp:
	jsr gm_gettopy
	jmp @doneY
@goesDown:
	jsr gm_getbottomy_f
@doneY:
	tay
	
	pla
	and #(cont_left|cont_right)
	cmp #cont_left
	beq @goesLeft
	cmp #cont_right
	beq @goesRight
	; middle
	jsr gm_getmidx
	jmp @doneX
@goesLeft:
	jsr gm_getleftwjx
	jmp @doneX
@goesRight:
	jsr gm_getrightwjx
@doneX:
	tax
	
	; do the check now
	jsr h_get_tile
	tax
	lda metatile_info, x
	eor #ct_dream
	rts

; left AND right must always be 0!  left precedes right.
@validCombinations:
	.byte $00, $01, $02, $02
	.byte $04, $05, $06, $06
	.byte $08, $09, $0A, $0A
	.byte $0C, $0D, $0E, $0E
.endproc

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
	eor #1
	sta abovescreen
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
	
	lda warp_d
	cmp #$FF
	bne gm_leaveroomD_
	jmp gm_killplayer
:
gm_leaveroomU_:
	jmp ph_leaveroomU
gm_leaveroomD_:
	jmp ph_leaveroomD

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
	;bne @snapToCeil
	beq @gm_applyy_checkdone_

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
	lda gamectrl5
	ora #g5_collideY
	sta gamectrl5
	beq gm_applyy_checkdone

@gm_applyy_checkdone_:
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
	;bne @snapToFloor
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
	
	; is the player climbing? if so, don't actually set the ground flag
	lda playerctrl
	and #pl_climbing
	bne :+
	
	lda playerctrl
	ora #pl_ground    ; set the grounded bit, only thing that can remove it is jumping
	sta playerctrl
	
:	lda gamectrl4
	and #<~g4_nosjump
	sta gamectrl4
	
	lda #defjmpcoyot
	sta jumpcoyote    ; assign coyote time because we're on the ground
	ldx #0
	lda player_vl_y
	bmi :+
	stx player_vl_y
	stx player_vs_y
:	stx wjumpcoyote   ; can't perform a wall jump while on the ground
	stx hopcdown
	jsr gm_reset_dash_and_stamina
	lda gamectrl2
	and #<~g2_autojump
	sta gamectrl2
	lda gamectrl5
	ora #g5_collideY
	sta gamectrl5
	
@done:
gm_applyy_checkdone:
	lda player_yo
	cmp player_y
	beq :+
	
	lda gamectrl4
	ora #g4_movedY
	sta gamectrl4
	
:	jsr ph_scroll_u_cond
	jmp ph_scroll_d_cond

; ** SUBROUTINE: gm_applyx
; desc:    Apply the velocity in the X direction. 
.proc gm_applyx
	; Climb Hop Solid Movement
	ldy chopentity
	bmi applyXSub
	
	lda sprspace+sp_flags, y
	and #(ef_collidable|ef_limbo|ef_platform)
	cmp #ef_collidable
	beq isCHopEntCollidable
	
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
	
	lda #$FF
	sta temp9
	
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
	sta player_x
	
	bcs @dontCheckOffs       ; If the addition didn't overflow, we need to detour.
	ldx player_vl_x          ; check if the velocity was positive
	bpl @dontCheckOffs       ; yeah, of course it wouldn't overflow, it's positive!
	
	lda #0                   ; we have an underflow, means the player is trying to leave the screen
	sta player_x
	jsr ph_leaveroomL
	bne @dontCheckOffs
	rts

@dontCheckOffs:
	jsr gm_gettopy
	sta temp1                ; temp1 - top Y
	jsr gm_getbottomy_w
	sta temp2                ; temp2 - bottom Y
	jsr gm_getmidy
	sta temp12
	
	lda player_vl_x
	bmi @dontLeaveRoomR
	bne :+
	lda player_vs_x
	beq @dontLeaveRoomR
	
:	lda player_x
	cmp #$F0
	bcs @callLeaveRoomR      ; try to leave the room
	
@dontLeaveRoomR:
	lda player_vl_x
	bmi @checkLeft
	; >= 0
	bne @checkRight
	; == 0
	lda player_vs_x
	beq @checkBoth
	bne @checkRight

@checkLeft:
	jsr checkLeft
	jmp @checkDoneX
@checkRight:
	jsr checkRight
	jmp @checkDoneX
@checkBoth:
	jsr checkLeft
	jsr checkRight

@checkDoneX:
	lda player_xo
	cmp player_x
	beq :+
	
	lda gamectrl4
	ora #g4_movedX
	sta gamectrl4
	
:	jsr ph_scroll_l_cond
	jmp ph_scroll_r_cond

@callLeaveRoomR:
	jsr ph_scroll_r_cond
	jmp ph_leaveroomR

; routine: check right
checkRight:
	lda #(maxvelxhi+2)
	sta temp10

checkRightLoop:
	dec temp10
	beq checkRDoneReturn     ; nope, out of here with your stupid games
	
	lda #pl_noentchk
	bit playerctrl
	bne :+
	
	jsr gm_collentright
	bne collidedRight
	
:	jsr gm_getrightx
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
	bne collidedRight
	
	ldy temp12
	ldx y_crd_temp
	lda #gc_right
	jsr xt_collide
	beq checkRDoneReturn

collidedRight:
	jsr gm_startretent
	
	lda hopcdown
	bne :+
	
	; collided on the right side
	lda player_vl_x
	bmi @dontModVel
	
	ldx #0
	stx player_vl_x
	stx player_vs_x
	
:	lda playerctrl
	and #(pl_wallleft^$FF)   ; the wall wasn't found on the left.
	sta playerctrl
	
	lda gamectrl5
	ora #g5_collideX
	sta gamectrl5
	
	; if holding left, mark as pushing
	lda game_cont
	and #cont_right
	beq :+
	
	lda playerctrl
	ora #pl_pushing
	sta playerctrl
	
:	jsr gm_check_attach_wall
	
@dontModVel:
	lda #defwjmpcoyo
	sta wjumpcoyote
	ldx player_x
	beq checkRDoneReturn     ; if the player X is zero... we're stuck inside a wall
	
	dex
	stx player_x
	ldx #$FF                 ; set the subpixel to $FF.  This allows our minuscule velocity to
	stx player_sp_x          ; keep colliding with this wall every frame and allow the push action to continue
	jmp checkRightLoop       ; !! note: in case of a potential clip, this might cause lag frames!
	                         ; loops will be used to avoid this unfortunate case as much as possible.
;
checkRDoneReturn:
	rts

; routine: check left
checkLeft:
	lda #(maxvelxhi+2)
	sta temp10

checkLeftLoop:
	dec temp10
	beq checkRDoneReturn     ; nope, out of here with your stupid games
	
	lda #pl_noentchk
	bit playerctrl
	bne :+
	
	jsr gm_collentleft
	bne collidedLeft
	
:	jsr gm_getleftx
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
	bne collidedLeft
	
	ldy temp12
	ldx y_crd_temp
	lda #gc_left
	jsr xt_collide
	beq checkRDoneReturn

collidedLeft:
	jsr gm_startretent
	
	lda hopcdown
	bne :+
	
	lda player_vl_x
	bpl @dontModVel
	
	ldx #0
	stx player_vl_x
	stx player_vs_x
	
:	lda playerctrl
	ora #pl_wallleft         ; the wall was found on the left.
	sta playerctrl
	lda gamectrl5
	ora #g5_collideX
	sta gamectrl5
	
	; if holding left, mark as pushing
	lda game_cont
	and #cont_left
	beq :+
	
	lda playerctrl
	ora #pl_pushing
	sta playerctrl
	
:	jsr gm_check_attach_wall
	
@dontModVel:
	lda #defwjmpcoyo
	sta wjumpcoyote
	ldx player_x
	cpx #$F0                 ; compare to [screenWidth-16]
	bcs checkRDoneReturn     ; if bigger or equal, just bail, we might be stuck in a wall
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
	lda #(ef_collidable|ef_limbo)
	and sprspace+sp_flags, y ; if the flag isn't set then why should we bother?
	cmp #ef_collidable
	bne @noHitBox
	
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
	lda sprspace+sp_flags, y
	ora #ef_collided
	sta sprspace+sp_flags, y
	
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
	lda #(ef_collidable|ef_limbo|ef_platform)
	and sprspace+sp_flags, y ; if the flag isn't set then why should we bother?
	cmp #ef_collidable
	bne @noHitBox
	
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
	lda sprspace+sp_flags, y
	ora #ef_collided
	sta sprspace+sp_flags, y
	
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
	bne :+

gm_collentright:
	lda #plr_x_right
	sta temp5
	bne :+

gm_wjckentleft:
	lda #plr_x_wj_left
	sta temp5
	bne :+

gm_wjckentright:
	lda #plr_x_wj_right
	sta temp5
:	lda #plr_y_top
	sta temp6
	lda wallhboxybot
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
	lda #(ef_collidable|ef_limbo|ef_platform)
	and sprspace+sp_flags, y ; if the flag isn't set then why should we bother?
	cmp #ef_collidable
	bne @noHitBox
	
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
	
	lda sprspace+sp_flags, y
	ora #ef_collided
	sta sprspace+sp_flags, y
	
	ldx #1                   ; load X to 1 to clear the zero flag.
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

; ** SUBROUTINE: gm_invert_x_vel
; desc: Inverts the X velocity.
gm_invert_x_vel:
	lda #0
	sec
	sbc player_vs_x
	sta player_vs_x
	lda #0
	sbc player_vl_x
	sta player_vl_x
	rts

gm_dash_over:
	; dash has terminated.
	lda gamectrl2
	ora #g2_autojump
	sta gamectrl2
	
	; if (DashDir.Y <= 0f) Speed = DashDir * 160f (when begun, it would be DashDir * 240f)
	lda #(cont_down << 2)
	bit dashdir
	bne :+
	
	lda dbouttimer
	bne :+
	
	; Speed = DashDir * 160f;
	jsr gm_load_two_thirds_dash_dir
	
	; if (Speed.Y < 0f) Speed.Y *= 0.75f;
	lda player_vl_y
	bpl :+
	jsr gm_rem25pcvelYonly
	
:	jmp gm_dash_update_done

gm_defaultdir:
	;ldy #0                  ; player will not be dashing up or down
	lda #pl_left
	and playerctrl          ; bit 0 will be the facing direction
	sec                     ; shift it left by 1 and append a 1
	rol                     ; this will result in either 1 or 3. we handle the L+R case by dashing left
	jmp gm_dash_nodir

gm_superjump:
	lda jumpcoyote
	beq @return            ; if player wasn't grounded, then ...
	lda #g4_nosjump
	bit gamectrl4
	beq :+
	jmp gm_jump
:	lda #(cont_down << 2)  ; if she was dashing down
	bit dashdir
	beq @normal
	; half the jump height here
	lda #sjumpvelHI
	sta player_vl_y
	lda #sjumpvelLO
	sta player_vs_y
	lda #wavedashhi
	sta player_vl_x
	lda #wavedashlo
	sta player_vs_x
	bne @continue
@normal:
	lda #jumpvelHI
	sta player_vl_y
	lda #jumpvelLO
	sta player_vs_y         ; super jump Y speed is the same as normal jump Y speed
	lda #superjmphhi
	sta player_vl_x
	lda #superjmphlo
	sta player_vs_x
@continue:
	lda #pl_left
	bit playerctrl
	beq :+
	jsr gm_invert_x_vel
:	jmp gm_superjumpepilogue
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
	sta temp1
	sta temp3
	inx
	lda dash_table, x
	sta temp2
	sta temp4
	inx
	
	jsr gm_dash_determine_x_speed
	
	; Y velocity
	lda dash_table, x
	sta player_vl_y
	inx
	lda dash_table, x
	sta player_vs_y
	
	lda player_vl_x
	bpl :+
	; dashing left
	lda playerctrl
	ora #pl_left
	sta playerctrl
:	jmp gm_dash_update_done

gm_dash_lock:
	jsr gm_clear_vel
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
	jmp gm_dash_update_done

gm_dash_update_:
	jmp gm_dash_update

; ** SUBROUTINE: xt_physics
; desc: Runs one frame of player physics.
.proc xt_physics
	lda gamectrl5
	and #<~(g5_collideX | g5_collideY)
	sta gamectrl5
	ldx #plr_y_bot_wall
	lda dshatktime
	beq :+
	ldx #plr_y_bot_wjc
:	stx wallhboxybot
	
	jsr gm_death_hacks
	
	lda #pl_dead
	bit playerctrl
	bne return
	lda respawntmr
	bne return
	lda #g4_nophysic
	bit gamectrl4
	bne return
	
	jsr gm_jumpgrace
	lda dashtime
	bne gm_dash_update_
dash_update_done:
	jsr gm_dashjumpcheck
	lda dashtime
	bne :+
	jsr gm_gravity
	jsr gm_controls
:	jsr gm_sanevels
	jsr gm_applyy
	jsr gm_applyx
	jsr gm_checkretent
	jsr gm_checkoffgnd
	jsr gm_checkwjump
	jsr gm_climbcheck
	jsr gm_duckcheck
	jsr gm_addtrace
	jsr gm_dreamcheck
	jmp gm_timercheck
return:
	rts
.endproc

gm_dash_update_done := xt_physics::dash_update_done

gm_dashjumpcheck:
	lda jumpbuff
	beq @noJumpAtAll    ; if there is no jump buffer, then exit
	lda dshatktime
	beq @noJumpAtAll
	
	; check for any jumps during the dash
	lda wjumpcoyote
	bne @maybeDoSuperWallJump
	lda jumpcoyote
	beq @noSuperJump
	lda dashdir
	and #(cont_left|cont_right)<<2
	beq @normalJumpOnly ; if there is a jump buffer and the player wasn't dashing left or right
	jmp gm_superjump

@maybeDoSuperWallJump:
	; the player must only dash up to do that
	lda dashdir
	and #(cont_left|cont_right)<<2
	bne @noJumpAtAll
	
	jmp gm_superwalljump
	
@noSuperJump:
	; maybe they should do a climb jump instead
	
	; NOTE: This logic is probably reusable
	jsr gm_getfacex_wj
	tax
	stx temp1
	jsr gm_gettopy
	tay
	jsr xt_collide
	bne @doClimbJump
	jsr gm_getbottomy_wjc
	tay
	ldx temp1
	jsr xt_collide
	beq @noJumpAtAll
	
@doClimbJump:
	lda climbbutton
	beq @noJumpAtAll
	; well they're definitely dashing
	jmp gm_climbjump

@normalJumpOnly:
	jmp gm_normaljump

@noJumpAtAll:
	rts

gm_superwalljump:
	; TODO: A lot of it is copied from gm_walljump/gm_notclimbing.
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
	and #((pl_left|pl_climbing)^$FF)
	ora temp1
	sta playerctrl
	
	lda #pl_left
	bit playerctrl
	bne @walljumpboostL
	lda #swalljmpLO
	sta player_vs_x
	lda #swalljmpHI
	sta player_vl_x
	bne @walljumpvert
@walljumpboostL:
	lda #swalljmpNLO
	sta player_vs_x
	lda #swalljmpNHI
	sta player_vl_x
@walljumpvert:
	lda #>swvjumpvel
	sta player_vl_y
	lda #<swvjumpvel
	sta player_vs_y
	jsr gm_add_lift_boost
	lda #jumpsustain
	sta jcountdown
	lda #0
	sta jumpbuff      ; consume the buffered jump input
	sta jumpcoyote    ; consume the existing coyote time
	sta wjumpcoyote   ; or the wall coyote time
	sta dashtime
	sta dshatktime
	lda playerctrl2
	and #<~p2_ducking
	sta playerctrl2
	
	; super wall jumps don't force a direction
	rts

gm_superjumpepilogue:
	jsr gm_add_lift_boost
	lda gamectrl4
	and #<~g4_nosjump
	sta gamectrl4
	lda playerctrl2
	and #<~p2_ducking
	sta playerctrl2
	lda #jumpsustain
	sta jcountdown
	lda #0
	sta dashtime            ; no longer dashing. do this to avoid our speed being taken away.
	sta dshatktime
	sta jumpcoyote
	sta wjumpcoyote
	rts

; ** SUBROUTINE: gm_timercheck
; desc: Checks and decreases relevant timers.
gm_timercheck:
	inc dustrhythm
	
	lda playerctrl
	sta prevplrctrl
	
	and #pl_ground
	beq @notOnGround
	bne @onGround

@gndReturn:
	lda dbouttimer
	beq :+
	dec dbouttimer
	
:	lda dreinvtmr
	beq :+
	dec dreinvtmr
	
:	lda chasercdown
	beq :+
	dec chasercdown
	
:	lda dshatktime
	beq :+
	dec dshatktime
	
:	lda forcemovext
	
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

@notOnGround:
	lda groundtimer
	bmi @gndReturn
	lda #0
	sta groundtimer
	beq @gndReturn

@onGround:
	ldx groundtimer
	inx
	bmi :+
	cpx #9
	bcc :+
	ldx #9
:	stx groundtimer
	bne @gndReturn        ; you MUST have incremented to non-zero!

.ifdef DEBUG
:	nop
	jmp :-
.endif

; ** SUBROUTINE: gm_load_two_thirds_dash_dir
; desc: Gives the player 2/3 the dash speed.  Used when terminating a dash.
.proc gm_load_two_thirds_dash_dir
	ldx dashdir
	lda dash_table_two_thirds, x
	sta player_vl_x
	inx
	lda dash_table_two_thirds, x
	sta player_vs_x
	inx
	lda dash_table_two_thirds, x
	sta player_vl_y
	inx
	lda dash_table_two_thirds, x
	sta player_vs_y
	rts
.endproc

; ** SUBROUTINE: gm_rem25pcvelYonly
; desc: Removes 25% of the player's Y velocity.
gm_rem25pcvelYonly:
	; take off 25% of the Y velocity
	lda player_vs_y
	sta temp2
	lda player_vl_y
	cmp #$80
	ror
	ror temp2
	cmp #$80
	ror
	ror temp2
	sta temp1

	lda player_vs_y
	sec
	sbc temp2
	sta player_vs_y
	lda player_vl_y
	sbc temp1
	sta player_vl_y
	rts

; ** SUBROUTINE: gm_check_attach_wall
; desc: After a sideways collision check, check if the player is holding the climb button, and if so,
;       initiate the climbing action.
.proc gm_check_attach_wall
	; Note: The collided entity's index is stored in temp9.
	lda climbbutton
	beq noEffect
	lda dashtime
	bne noEffect
	
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
	and #<~pl_ground
	sta playerctrl
	
	jsr gm_gettopy
	sta temp1                ; temp1 - top Y
	jsr gm_getbottomy_w
	sta temp2                ; temp2 - bottom Y
	jsr gm_getmidy
	sta temp12               ; temp12 - middle Y
	
	; don't reduce the velocity if pl_climbing was set already
	txa
	bne noEffect
	jsr gm_reduce_vel_climb
noEffect:
	rts

table:	.byte 3, 5  ; no left, left
.endproc

; ** SUBROUTINE: gm_duckcheck
; desc: Checks if the player should be ducking right now.
.proc gm_duckcheck
	lda playerctrl2
	and #p2_ducking
	bne isDucking
	
	; If not ducking, check if she is on the ground, holding down, and moving down.
	lda playerctrl
	and #pl_ground
	beq @return
	
	lda game_cont
	and #cont_down
	beq @return
	
	lda player_vl_y
	bmi @return
	
	lda playerctrl2
	ora #p2_ducking
	sta playerctrl2
@return:
	rts
	
isDucking:
	; if on ground, and not holding down
	lda playerctrl
	and #pl_ground
	beq @return
	
	lda game_cont
	and #cont_down
	bne @return
	
	; TODO: check if can unduck here.
	; always assumed to be true for now.
	
	; TODO: duck correct check?
	
	lda playerctrl2
	and #<~p2_ducking
	sta playerctrl2
	
@return:
	rts
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
	bne :+
	lda jcountdown
:	bne return
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
	and #<~pl_ground
	sta playerctrl
	lda playerctrl2
	and #<~p2_ducking
	sta playerctrl2
	
	jsr gm_reduce_vel_climb
	
	lda gamectrl2
	and #<~g2_autojump
	sta gamectrl2
	
	; ensure that Madeline's position resides entirely on the wall
	lda playerctrl
	and #pl_wallleft
	bne onleft
	
	; right
	lda player_x
	clc
	adc #6
	bcc :+
	lda #$FF
:	sta player_x
	jmp gm_appx_checkright

onleft:
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
	and #(ef_collidable|ef_limbo|ef_platform)
	cmp #ef_collidable
	bne release     ; If this entity is no longer collidable, then release the climb.
	
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
	ldy entground
	bmi @skipEntityChecking
	
	lda sprspace+sp_kind, y
	sec
	sbc #e_l1zipmovr
	cmp #2
	bcs @notZipMover
	
	lda sprspace+sp_l1zm_flags, y
	and #sp_l1zmf_spikyUP
	beq @skipEntityChecking
	
	; spikey! so, don't allow climb hops
	rts

@notZipMover:
	lda sprspace+sp_kind, y
	cmp #e_fallblock
	bne @skipEntityChecking
	
	lda sprspace+sp_fall_spike, y
	; and #$80
	beq @skipEntityChecking
	
	; spikey!
	rts
	
@skipEntityChecking:
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
return:
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

; ** SUBROUTINE: gm_dreamcheck
; desc: Checks if we should reset the dream dash state.
.proc gm_dreamcheck
	; is the velocity zero
	lda player_vl_x
	bne @notZero
	lda player_vl_y
	bne @notZero
	lda player_vs_x
	bne @notZero
	lda player_vs_y
	bne @notZero
	
	; it's not zero, therefore we are just charging up the dash
	rts

@notZero:
	lda #g4_hasdrdsh
	bit gamectrl4
	beq resetDreamDash
	
	lda gamectrl4
	and #<~g4_hasdrdsh
	ora #g4_dreamdsh
	sta gamectrl4
	
	lda dashtime
	cmp #(defdashtime-dashchrgtm)
	bcs return
	
	lda #(defdashtime-dashchrgtm-2)
	sta dashtime
	sta dshatktime
	
	lda #1
	sta plattemp2
	
	lda dreinvtmr
	bne returnClearTimer
	
	; Check if the player's position changed
	lda gamectrl4
	and #(g4_movedX | g4_movedY)
	beq noMovement
	
	; what do we expect based on the move direction
	pha
	lda dashdir
	lsr
	lsr
	tay
	lda expectedMovement, y
	sta plattemp1
	pla
	eor plattemp1
	beq returnClearTimer  ; if they are equal
	
	lda #4
	sta plattemp2
	
noMovement:
	; they're the same, increment the death counter and see
	inc dredeatmr
	lda dredeatmr
	cmp plattemp2
	bcc return
	
	jmp gm_killplayer

returnClearTimer:
	lda #0
	sta dredeatmr

return:
	rts
	
resetDreamDash:
	lda gamectrl4
	and #g4_dreamdsh
	beq return          ; if the dream dash flag wasn't set
	
	jsr gm_reset_dash_and_stamina
	lda #5
	sta jumpcoyote
	sta dbouttimer
	lda #3
	sta dashtime
	sta dshatktime
	
	; check the dash direction, only horizontal directions may super dream jump
	lda dashdir
	and #%00110000
	beq @skipNoSJump
	cmp #%00110000
	beq @skipNoSJump
	
	lda gamectrl4
	ora #g4_nosjump
	sta gamectrl4
	
	lda #0
	sta dredeatmr
	
@skipNoSJump:
	lda dashdir
	; check if the player dashed up
	and #%00100000
	beq @skipBoostUp
	
	lda #12
	sta jcountdown
	lda gamectrl2
	ora #g2_autojump
	sta gamectrl2
	
	; set vel to jump height
	lda #jumpvelLO
	sta player_vs_y
	lda #jumpvelHI
	sta player_vs_y
	
@skipBoostUp:
	lda gamectrl4
	and #<~g4_dreamdsh
	sta gamectrl4
	rts

expectedMovement:
	; $10 - movedX, $20 - movedY
	.byte $00,$10,$10,$10
	.byte $20,$30,$30,$30
	.byte $20,$30,$30,$30
	.byte $00,$10,$10,$10
.endproc

.proc gm_addtrace
	lda advtracesw
	beq advancedTraceDisabled
	
	ldy advtracehd
	
	lda camera_x
	clc
	adc player_x
	sta adv_trace_x, y
	
	lda camera_x_pg
	adc #0
	sta adv_trace_x_pg, y
	
	ldx #0
	lda player_y
	clc
	adc camera_y
	bcs @add16
	cmp #240
	bcc @dontAdd
@add16:
	ldx #1
	adc #15
@dontAdd:
	sta adv_trace_y, y
	txa
	eor camera_y_hi
	sta adv_trace_y_hi, y
	
	lda plr_spr_l
	sta adv_trace_sl, y
	lda plr_spr_r
	sta adv_trace_sr, y
	lda plh_spr_l
	sta adv_trace_hl, y
	lda plh_spr_r
	sta adv_trace_hr, y
	
	; get the sprxoff and spryoff
	lda sprxoff
	ror
	ror
	ror
	and #%11000000
	sta adv_trace_pc, y
	
	lda spryoff
	and #%00000111
	asl
	asl
	asl
	ora adv_trace_pc, y
	sta adv_trace_pc, y
	
	; the format of the final bitset will be XXYYYBBF
	;   X - sprxoff
	;   Y - spryoff
	;   B - bank number
	;   F - facing left
	
	; get the facing
	lda playerctrl
	ror ; rotate the facing into the carry
	
	; then the bank number
	lda spr0_bknum
	rol ; rotate the facing into the 1st bit
	and #%00000111
	ora adv_trace_pc, y
	sta adv_trace_pc, y
	
	; finally, increment the head
	iny
	tya
	and #(adv_trace_hist_size-1)
	sta advtracehd
	
advancedTraceDisabled:
	lda #g2_notrace
	bit gamectrl2
	bne @return
	
	ldx plrtrahd
	inx
	txa
	and #$3F ; mod 64
	sta plrtrahd
	tax
	
	lda player_x
	sta plr_trace_x, x
	lda player_y
	sec
	sbc camera_y_sub
	sta plr_trace_y, x

@return:
	rts
.endproc

; ** SUBROUTINE: gm_death_hacks
; desc: Checks the player for conditions that may kill her.  This is marked a hack
;       because other things are supposed to handle such deaths.
.proc gm_death_hacks
	; Are we already dead?
	lda #pl_dead
	bit playerctrl
	bne @return
	
	; Check if placed inside a fully solid block
	jsr gm_getmidx
	tax
	jsr gm_getmidy
	tay
	jsr h_get_tile
	tax
	lda metatile_info, x
	cmp #ct_deadlyXX
	beq @kill
	cmp #ct_full
	beq @kill
	
	; If we are on the ground, check if we are standing inside spikes.
	lda #pl_ground
	bit playerctrl
	beq @notOnGround
	
	jsr gm_getleftx
	tax
	jsr gm_getbottomy_w
	tay
	jsr h_get_tile
	tax
	lda metatile_info, x
	cmp #ct_deadlyUP
	beq @kill
	
	jsr gm_getrightx
	tax
	jsr gm_getbottomy_w
	tay
	jsr h_get_tile
	tax
	lda metatile_info, x
	cmp #ct_deadlyUP
	beq @kill
	
@notOnGround:
@return:
	rts
@kill:
	jmp gm_killplayer
.endproc

; ** SUBROUTINE: gm_checkretent
; desc: Checks the wall speed retention timer.
.proc gm_checkretent
	; check if the retention timer is zero
	lda retain_timer
	beq @return
	
	lda gamectrl5
	and #g5_collideX
	beq @noCollision
	
	; collided. the retain timer needs to be decremented
	dec retain_timer

@return:
	rts
	
@noCollision:
	dec retain_timer
	
	; check if the speed's sign and the retain speed's sign match
	lda retain_vl_x
	eor player_vl_x
	bmi @return
	
	; they do
	; check if there is any collision in that direction
	; note: this is kinda slow but screw it
	lda player_x
	clc
	adc #plr_x_wj_left
	adc retain_vl_x
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda camera_x_pg
	adc #0
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr               ; finish dividing by the tile size
	
	; store the left X coordinate
	sta temp1
	
	lda player_x
	clc
	adc #plr_x_wj_right
	adc retain_vl_x
	clc
	adc camera_x
	sta x_crd_temp
	lda camera_x_pg
	adc #0
	ror
	lda x_crd_temp
	ror
	lsr
	lsr
	; store the right X coordinate
	sta temp2
	
	lda player_y
	clc
	adc #plr_y_top
	lsr
	lsr
	lsr
	; top Y coordinate
	sta temp3
	
	lda player_y
	clc
	adc #plr_y_bot
	lsr
	lsr
	lsr
	; bottom Y coordinate
	sta temp4
	
	lda player_y
	clc
	adc #plr_y_mid
	lsr
	lsr
	lsr
	; middle Y coordinate
	sta temp5
	
	lda gamectrl4
	pha
	ora #g4_nodeath
	sta gamectrl4
	
	; TODO: maybe you can remove some of these depending on the direction
	; TODO: this seems kinda slow...
	
	ldx temp1
	ldy temp3
	jsr xt_collide
	bne @hadcoll
	
	ldx temp1
	ldy temp4
	jsr xt_collide
	bne @hadcoll
	
	ldx temp1
	ldy temp5
	jsr xt_collide
	bne @hadcoll
	
	ldx temp2
	ldy temp3
	jsr xt_collide
	bne @hadcoll
	
	ldx temp2
	ldy temp4
	jsr xt_collide
	bne @hadcoll
	
	ldx temp2
	ldy temp5
	jsr xt_collide
	bne @hadcoll
	
	pla
	sta gamectrl4
	lda retain_vl_x
	sta player_vl_x
	lda retain_vs_x
	sta player_vs_x

@clearTimer:
	lda #0
	sta retain_timer
	rts

@hadcoll:
	pla
	sta gamectrl4
	rts
.endproc

; ** SUBROUTINE: gm_startretent
; desc: Starts the wall speed retention timer, if needed.
.proc gm_startretent
	lda retain_timer
	bne @return
	
	; check if the vel is significant (ie. if >=$0100 or <=$FF00)
	lda player_vl_x
	beq @return
	cmp #$FF
	bne :+
	lda player_vs_x
	bne @return
	
:	lda #maxrettmr
	sta retain_timer
	lda player_vl_x
	sta retain_vl_x
	lda player_vs_x
	sta retain_vs_x
	
@return:
	rts
.endproc

; ** SUBROUTINE: gm_clear_vel
; Clears the velocity of the player.
.proc gm_clear_vel
	lda #0
	sta player_vl_x
	sta player_vs_x
	sta player_vl_y
	sta player_vs_y
	rts
.endproc

; ** SUBROUTINE: gm_dash_determine_x_speed
; desc: Determines the X speed when dashing.
; parameters:
;     temp1, temp3 - Dash X speed high byte
;     temp2, temp4 - Dash X speed low byte
.proc gm_dash_determine_x_speed
	; does the player speed's sign match the dash speed's?
	lda temp3
	beq @setDashSpeed
	eor dshold_vl_x
	bmi @setDashSpeed
	
	; yes, get the absolute 
	lda temp3
	bpl @comparePositive
	
	; compare negative
	; player_speed < dash_speed
	lda dshold_vl_x
	cmp temp3
	bcc @dontChangeSpeed
	bne @setDashSpeed
	
	lda dshold_vs_x
	cmp temp4
	bcc @dontChangeSpeed
	bcs @setDashSpeed
	
@comparePositive:
	; player_speed > dash_speed
	lda dshold_vl_x
	cmp temp3
	bcc @setDashSpeed
	bne @dontChangeSpeed
	
	lda dshold_vs_x
	cmp temp4
	bcs @dontChangeSpeed
	
@setDashSpeed:
	; store the player velocity and see if she should be facing left
	lda temp2
	sta player_vs_x
	lda temp1
	sta player_vl_x
	rts
	
@dontChangeSpeed:
	lda dshold_vl_x
	sta player_vl_x
	lda dshold_vs_x
	sta player_vs_x
	rts
.endproc

; Note: The LR row must match the L row because gm_defaultdir requires it.
; This corresponds to DashDir*240 in the original Celeste.
dash_table:
	.byte $00, $00, $00, $00 ; ----
	.byte $04, $00, $00, $00 ; ---R
	.byte $FC, $00, $00, $00 ; --L-
	.byte $FC, $00, $00, $00 ; --LR

	.byte $00, $00, $04, $00 ; -D--
	.byte $02, $D4, $02, $D4 ; -D-R
	.byte $FD, $2C, $02, $D4 ; -DL-
	.byte $FD, $2C, $02, $D4 ; -DLR

	.byte $00, $00, $FC, $00 ; U---
	.byte $02, $D4, $FD, $2C ; U--R
	.byte $FD, $2C, $FD, $2C ; U-L-
	.byte $FD, $2C, $FD, $2C ; U-LR

	.byte $00, $00, $00, $00 ; UD--
	.byte $04, $00, $00, $00 ; UD-R
	.byte $FC, $00, $00, $00 ; UDL-
	.byte $FC, $00, $00, $00 ; UDLR

; This corresponds to DashDir*160 in the original Celeste (160/240 == 2/3)
dash_table_two_thirds:
	.byte $00, $00, $00, $00 ; ----
	.byte $02, $AA, $00, $00 ; ---R
	.byte $FD, $56, $00, $00 ; --L-
	.byte $FD, $56, $00, $00 ; --LR

	.byte $00, $00, $02, $AA ; -D--
	.byte $01, $E2, $01, $E2 ; -D-R
	.byte $FE, $1E, $01, $E2 ; -DL-
	.byte $FE, $1E, $01, $E2 ; -DLR

	.byte $00, $00, $FD, $56 ; U---
	.byte $01, $E2, $FE, $1E ; U--R
	.byte $FE, $1E, $FE, $1E ; U-L-
	.byte $FE, $1E, $FE, $1E ; U-LR

	.byte $00, $00, $00, $00 ; UD--
	.byte $02, $AA, $00, $00 ; UD-R
	.byte $FD, $56, $00, $00 ; UDL-
	.byte $FD, $56, $00, $00 ; UDLR
