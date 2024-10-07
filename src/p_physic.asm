; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_getdownforce
; desc:    Gets the downward force in the A register depending on their state.
gm_getdownforce:
	lda player_vl_y
	bpl gm_defaultgrav
	lda #pl_dashed
	bit playerctrl
	bne gm_dashgrav     ; if dashed before touching the ground, return the strong gravity
	lda #cont_a
	bit p1_cont
	bne gm_defaultgrav  ; if A isn't held, then use a stronger gravity force
gm_stronggrav:
	lda #gravitynoA
	rts
gm_dashgrav:
	lda #$FF
	rts
gm_defaultgrav:
	lda #gravity
	rts
	
; ** SUBROUTINE: gm_gravity
; desc:    If player is not grounded, applies a constant downward force.
gm_gravity:
	lda #pl_ground
	bit playerctrl
	beq gm_apply_gravity
	rts
gm_apply_gravity:
	jsr gm_getdownforce
	clc
	adc player_vs_y
	sta player_vs_y
	lda #0
	adc player_vl_y
	sta player_vl_y
	lda #pl_pushing
	bit playerctrl
	beq gm_gravityreturn
	lda player_vl_y
	bmi gm_gravityreturn
	bne gm_gravityslide   ; player_vl_x > 0
	lda player_vs_y
	cmp #maxslidespd
	bcc gm_gravityreturn  ; player_vl_x == 0, player_vs_x < maxslidespd
gm_gravityslide:
	lda #maxslidespd
	sta player_vs_y
	lda #0
	sta player_vl_y
gm_gravityreturn:
	rts

; ** SUBROUTINE: gm_dragshift
; desc:    Shifts the 16-bit number at (temp2, temp1) by 1.
gm_dragshift:
	clc
	lda temp2
	ror
	sta temp2
	lda temp1
	ror
	sta temp1
	rts
	
; ** SUBROUTINE: gm_drag
; desc:    Apply a constant dragging force that makes the X velocity tend to zero.
gm_drag:
	lda dashtime
	bne gm_drag4      ; while dashing, ensure drag doesn't take hold
	lda #%00000011    ; check if any direction on the D-pad is held
	bit p1_cont       ; don't apply drag while holding buttons (the
	bne gm_drag4      ; button routines pull the player towards maxwalk)
	lda player_vl_x
	bne gm_drag5
	lda player_vs_x
	beq gm_drag4      ; if both vl_x nor vs_x are zero, then return
gm_drag5:
	lda player_vl_x   ; perform one shift to the right, this divides by 2
	clc
	ror
	sta temp2
	lda player_vs_x
	ror
	sta temp1
	jsr gm_dragshift  ; perform another shift to the right
	lda #%00100000
	bit temp2         ; check if the high bit of the result is 1
	beq gm_drag2
	lda temp2
	ora #%11000000    ; extend the sign
	sta temp2
gm_drag2:
	ldx temp2
	bne gm_drag3
	ldx temp1         ; make sure the diff in question is not zero
	bne gm_drag3      ; this can't happen with a negative velocity vector
	inx               ; because it is not null. but it can happen with a
	stx temp1         ; positive velocity vector less than $00.$04
gm_drag3:
	sec
	lda player_vs_x
	sbc temp1
	sta player_vs_x
	lda player_vl_x
	sbc temp2
	sta player_vl_x
gm_drag4:
	rts

gm_appmaxwalkL:
	; this label was reached because the velocity is < -maxwalk.
	; if we are on the ground, we need to approach maxwalk.
	lda #pl_ground
	bit playerctrl
	beq gm_appmaxwalkrtsL
	lda player_vl_x
	bpl gm_appmaxwalkrtsL  ; If the player's velocity is >= 0, don't perform any adjustments
	clc
	lda player_vs_x
	adc #maxwalkad
	sta player_vs_x
	lda player_vl_x
	adc #0
	sta player_vl_x
	cmp #(maxwalk^$FF+1)
	bcc gm_appmaxwalkrtsL  ; A < -maxwalk, so there's still some approaching to be done
	beq gm_appmaxwalkrtsL  ; A == -maxwalk
gm_setmaxwalkL:            ; <--- referenced by gm_walljump
	lda #(maxwalk^$FF+1)
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_appmaxwalkrtsL:
	rts

gm_appmaxwalkR:
	; this label was reached because the velocity is > maxwalk.
	; if we are on the ground, we need to approach maxwalk.
	lda #pl_ground
	bit playerctrl
	beq gm_appmaxwalkrtsR
	lda player_vl_x
	bmi gm_appmaxwalkrtsR  ; If the player's velocity is negative, don't perform any adjustments
	beq gm_appmaxwalkrtsR  ; Ditto with zero
	sec
	lda player_vs_x
	sbc #maxwalkad
	sta player_vs_x
	lda player_vl_x
	sbc #0
	sta player_vl_x
	cmp #maxwalk
	bcs gm_appmaxwalkrtsR  ; A >= maxwalk, so there's still some approaching to be done
gm_setmaxwalkR:            ; <--- referenced by gm_walljump
	lda #maxwalk
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_appmaxwalkrtsR:
	rts

gm_add3xL:
	beq gm_dontadd3xL
	sec
	lda player_vs_x
	sbc #(accel*3)
	jmp gm_added3xL

gm_add3xR:
	cmp #$FF
	beq gm_dontadd3xR
	clc
	lda player_vs_x
	adc #(accel*3)
	jmp gm_added3xR

gm_appmaxwalkR_BEQ:
	beq gm_appmaxwalkR

; ** SUBROUTINE: gm_pressedleft
gm_pressedleft:
	ldx #0
	lda player_vl_x
	bpl gm_lnomwc
	cmp #(maxwalk^$FF+1) ; compare it to the max walking speed
	bcc gm_lnomwc    ; carry clear if A < -maxwalk.
	ldx #1           ; if it was bigger than the walking speed already,
gm_lnomwc:           ; then we don't need to check the cap
	lda player_vl_x
	bpl gm_add3xL
gm_dontadd3xL:
	sec
	lda player_vs_x
	sbc #accel
gm_added3xL:
	sta player_vs_x
	lda player_vl_x
	sbc #accelhi
	sta player_vl_x
	lda #pl_left
	ora playerctrl
	sta playerctrl
	cpx #0           ; check if we need to cap it to -maxwalk
	beq gm_lnomwc2   ; no, instead, approach -maxwalk
gm_capmaxwalkL:      ; <-- referenced by gm_jump
	lda player_vl_x  ; load the player's position
	cmp #(maxwalk^$FF+1)
	bcs gm_lnomwc2   ; carry set if A >= -maxwalk meaning we don't need to
	lda #(maxwalk^$FF+1)
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_lnomwc2:
	rts

; ** SUBROUTINE: gm_pressedright
gm_pressedright:
	ldx #0
	lda player_vl_x
	bmi gm_rnomwc    ; if the player was moving left a comparison would lead to an overcorrectiom
	cmp #(maxwalk+1) ; compare it to the max walking speed
	bcs gm_rnomwc    ; if it was bigger than the walking speed already,
	ldx #1           ; then we don't need to check the cap
gm_rnomwc:
	lda player_vl_x
	bmi gm_add3xR    ; A < 0, then add stronger accel
gm_dontadd3xR:
	clc
	lda player_vs_x
	adc #accel
gm_added3xR:
	sta player_vs_x
	lda player_vl_x
	adc #accelhi
	sta player_vl_x
	lda #(pl_left ^ $FF)
	and playerctrl
	sta playerctrl
	cpx #0           ; check if we need to cap it to maxwalk
	beq gm_appmaxwalkR_BEQ ; no, instead, approach maxwalk
gm_capmaxwalkR:      ; <-- referenced by gm_jump
	lda player_vl_x  ; load the player's position
	cmp #maxwalk
	bcc gm_rnomwc2   ; carry set if A >= maxwalk meaning we don't need to
	lda #maxwalk     ; cap it at maxwalk
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_rnomwc2:
	rts

; ** SUBROUTINE: gm_controls
; desc:    Check controller input and apply forces based on it.
gm_dontdash:
	lda #cont_right
	bit p1_cont
	bne gm_pressedright
	lda #cont_left
	bit p1_cont
	bne gm_pressedleft
	rts
gm_controls:
	lda jumpbuff
	bne gm_jump       ; If player buffered a jump, then try to perform it.
gm_dontjump:
	lda #cont_b
	bit p1_cont
	beq gm_dontdash   ; if the player pressed B
	bit p1_conto
	bne gm_dontdash   ; if the player wasn't pressing B last frame
	lda dashcount
	cmp #maxdashes
	bcs gm_dontdash   ; and if the dashcount is < maxdashes
	inc dashcount
	ldx #defdashtime
	stx dashtime
	lda #pl_dashed
	ora playerctrl
	sta playerctrl
	jmp gm_dontdash

gm_jump:
	lda wjumpcoyote
	bne gm_walljump
gm_normaljump:
	lda jumpcoyote
	beq gm_dontjump   ; if no coyote time, then can't jump
gm_actuallyjump:
	lda #(jumpvel ^ $FF + 1)
	sta player_vl_y
	lda #(jumpvello ^ $FF + 1)
	sta player_vs_y
	lda #0
	sta jumpbuff      ; consume the buffered jump input
	sta jumpcoyote    ; consume the existing coyote time
	sta wjumpcoyote   ; or the wall coyote time
	lda #%00000011
	bit p1_cont
	beq gm_dontjump   ; don't give a boost if we aren't moving
	lda player_vl_x
	bmi gm_jumpboostneg; if velocity < 0 pixels, then apply the leftward jump boost
	bne gm_applyjumpboost ; if velocity >= 1 pixel, then apply the jump boost
	jmp gm_dontjump   ; 0 < velocity < 1 so dont do a jump boost
gm_jumpboostneg:
	cmp #$FF
	beq gm_dontjump   ; if -1 <= velocity, then don't apply a jump boost
gm_applyjumpboost:
	lda #pl_left
	bit playerctrl
	beq gm_jumphboostR
	sec               ; apply the small jump boost to the right
	lda #jmphboost
	sbc player_vs_x
	sta player_vs_x
	lda #0
	sbc player_vl_x
	sta player_vl_x
	jsr gm_capmaxwalkL; ensure that it doesn't go over maxwalk
	jmp gm_dontjump   ; that would be pretty stupid as it would
gm_jumphboostR:       ; allow speed buildup up to the physical limit
	clc
	lda #jmphboost
	adc player_vs_x
	sta player_vs_x
	lda #0
	adc player_vl_x
	sta player_vl_x
	jsr gm_capmaxwalkR
	jmp gm_dontjump
	
gm_walljump:
	lda #pl_ground
	bit playerctrl
	bne gm_normaljump ; if player is grounded, ALWAYS perform a standard jump
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
	and #((pl_left|pl_dashed)^$FF) ; also clear the pl_dashed flag to allow the wall jump at full force
	ora temp1
	sta playerctrl
	
	lda #pl_left
	bit playerctrl
	bne gm_walljumpboostL
	jsr gm_setmaxwalkR; going right, so set vel to +maxwalk
	jmp gm_actuallyjump
gm_walljumpboostL:
	jsr gm_setmaxwalkL; going left, so set vel to -maxwalk
	jmp gm_actuallyjump

; ** SUBROUTINE: gm_jumpgrace
; desc:    Update the jump grace state.  If the A button is held, start buffering a jump.
;          If necessary, decrement the coyote timer.
gm_jumpgrace:
	lda #cont_a
	bit p1_conto
	bne gm_nosetbuff  ; (p1_conto & #cont_a) = 0
	bit p1_cont
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
	adc #(8-plrwidth/2); determine leftmost hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda player_x_hi
	adc camera_x_hi
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr
	;lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getrightx
; desc:     Gets the tile X position where the right edge of the player's hitbox resides
; returns:  A - the X coordinate
; note:     this is NOT ALWAYS the same as the result of gm_getleftx!! though perhaps
;           some optimizations are possible..
gm_getrightx:
	clc
	lda player_x
	adc #(15-plrwidth/2); determine right hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda player_x_hi
	adc camera_x_hi
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr
	;lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getleftwjx
; desc: Gets the tile X position where the left of the wall jump check hitbox resides.
; returns: A - the X coordinate.
gm_getleftwjx:
	clc
	lda player_x
	adc #(8-plrwidth/2-wjgrace); determine leftmost hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda player_x_hi
	adc camera_x_hi
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr
	;lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getrightwjx
; desc: Gets the tile X position where the right of the wall jump check hitbox resides.
; returns: A - the X coordinate.
gm_getrightwjx:
	clc
	lda player_x
	adc #(15+wjgrace-plrwidth/2); determine right hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda player_x_hi
	adc camera_x_hi
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr
	;lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_gettopy
; desc:     Gets the tile Y position where the top edge of the player's hitbox resides
; returns:  A - the Y coordinate
gm_gettopy:
	clc
	lda player_y
	adc #(16-plrheight)
	lsr
	lsr
	lsr
	;lsr
	rts

; ** SUBROUTINE: gm_getbottomy_w
; desc:     Gets the tile Y position where the bottom edge of the player's hitbox resides,
;           when checking for collision with walls.
; returns:  A - the Y coordinate
; note:     this is NOT ALWAYS the same as the result of gm_gettopy!! though perhaps
;           some optimizations are possible..
; note:     to allow for a bit of leeway, I took off one pixel from the wall check.
gm_getbottomy_w:
	clc
	lda player_y
	adc #14
	lsr
	lsr
	lsr
	;lsr
	rts

; ** SUBROUTINE: gm_getbottomy_g
; desc:     Gets the tile Y position where the bottom edge of the player's hitbox resides,
;           when checking for collision with ground objects.
; returns:  A - the Y coordinate
gm_getbottomy_g:
	clc
	lda player_y
	adc #15
	lsr
	lsr
	lsr
	;lsr
	rts

; ** SUBROUTINE: gm_getmidy
; desc:     Gets the tile Y position at the middle of the player's hitbox, used for wall jump checking
; returns:  A - the Y coordinate
gm_getmidy:
	clc
	lda player_y
	adc #(14-plrheight/2)
	lsr
	lsr
	lsr
	;lsr
	rts

; ** SUBROUTINE: gm_getbottomy_f
; desc:     Gets the tile Y position where the bottom edge of the player's hitbox resides,
;           when checking for collision with floors.
; returns:  A - the Y coordinate
; clobbers: A
; note:     this is NOT ALWAYS the same as the result of gm_gettopy!! though perhaps
;           some optimizations are possible..
gm_getbottomy_f:
	clc
	lda player_y
	adc #$10
	lsr
	lsr
	lsr
	;lsr
	rts

; ** SUBROUTINE: gm_collide
; desc:      Checks for collision.
; arguments: X - tile's x position, Y - tile's y position, A - direction
; returns:   zero flag set - collided
; direction: 0 - floor, 1 - ceiling, 2 - left, 3 - right
; note:      temp1, temp2 & temp7 are used by caller
; note:      collision functions rely on the Y register staying as the Y position of the tile!
; reserves:  temp3, temp4, temp5, temp6
; clobbers:  A, X
gc_floor = $00
gc_ceil  = $01
gc_left  = $02
gc_right = $03
gm_collide:
	pha                 ; store the collision direction
	jsr h_get_tile      ; get the tile
	tax
	lda metatile_info,x ; get collision information
	asl
	tax
	lda gm_colljumptable,x
	sta temp3
	inx
	lda gm_colljumptable,x
	sta temp4
	pla
	jmp (temp3)         ; use temp3 as an indirect jump pointer

; Arguments for these jump table subroutines:
; * A - The direction of collision
gm_colljumptable:
	.word gm_collidenone
	.word gm_collidefull
	.word gm_collidespikes
	.word gm_collidejthru

gm_collidefull:
	lda #1
	rts
gm_collidejthru:
	tax
	lda player_vl_y
	bmi gm_collidenone; if player is moving UP, don't do collision checks at all
	cpx #gc_floor
	bne gm_collidenone; no collision for anything but the floor
	tya               ; the tile's Y position now in A
	asl
	asl
	asl               ; it's a pixel position now
	sec
	sbc #(16-3)
	sta temp3
	ldx player_yo
	cpx player_y
	beq gm_colljtnochg
gm_colljtloop:
	cpx temp3
	bcc gm_collidefull; if player failed to fall below tileX - 16 + 3
	inx
	cpx player_y
	bne gm_colljtloop
gm_collidenone:
	lda #0
	rts
gm_colljtnochg:
	; no change in Y
	lda temp3
	sec
	sbc #3            ; take off the rest
	sta temp3
	lda player_y
	cmp temp3
	beq gm_collidefull; might be above or below, we only return collision if we're exactly
	lda #0            ; on the platform's level.
	rts

gm_collidespikes:
	tax
	lda player_vl_y
	bmi gm_collidenone; if player is going UP, then don't do collision checks at all.
	cpx #gc_ceil      ; if NOT moving up, then kill the player and return
	beq gm_colliderts
	cpx #gc_floor
	bne gm_collidespkw
	clc
	lda player_yo     ; get the player old Y position, MOD 8. the bottom pixel's
	and #$7           ; position is exactly the same as the player old Y position mod 8
	adc player_vl_y   ; add the Y velocity that was added to get to player_y.
	cmp #$6           ; a spike's hit box is like 2 px tall
	bcs gm_killplayer
gm_collideno:
	lda #0            ; clear the zero flag
gm_colliderts:
	rts
gm_collidespkw:
	lda #pl_ground
	bit playerctrl
	beq gm_collideno  ; if wasn't grounded, then it's fine
	;jmp gm_killplayer
	; fall through to killplayer

; ** SUBROUTINE: gm_killplayer
; desc:     Initiates the player death sequence.
gm_killplayer:
	lda #pl_dead
	ora playerctrl
	sta playerctrl
	lda #0
	sta deathtimer
	rts

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
	jsr gm_getleftx
	sta temp1
	jsr gm_getrightx
	sta temp2
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
	bne gm_killplayer
gm_leaveroomU_:
	jmp gm_leaveroomU
gm_velapplied:        ; this is the return label from gm_velminus4
	lda player_y
	cmp #$F0
	bcs gm_leaveroomU_
	lda player_vl_y
	bmi gm_checkceil
	jmp gm_checkfloor
gm_fellout:           ; if the player fell out of the world
	sta player_y
	lda player_vl_y
	bpl gm_killplayer
	rts
gm_checkceil:
	jsr gm_gettopy
	tay
	sty y_crd_temp
	ldx temp1         ; check block 1
	lda #gc_ceil
	jsr gm_collide
	bne gm_snaptoceil
	ldy y_crd_temp    ; check block 2
	ldx temp2
	lda #gc_ceil
	jsr gm_collide
	bne gm_snaptoceil
	rts
gm_snaptoceil:
	clc
	lda y_crd_temp    ; load the y position of the tile that was collided with
	asl
	asl
	asl               ; turn it into a screen coordinate
	adc #(8-(16-plrheight)) ; add the height of the tile, minus the top Y offset of the player hitbox
	sta player_y
	lda #0            ; set the subpixel to zero
	sta player_sp_y
	sta player_vl_y   ; also clear the velocity
	sta player_vs_y   ; since we ended up here it's clear that velocity was negative.
	rts
gm_checkfloor:
	jsr gm_getbottomy_f
	tay               ; keep the Y position into the Y register
	sty y_crd_temp
gm_checkgdfloor:
	ldx temp1         ; check block 1
	lda #gc_floor
	jsr gm_collide
	bne gm_snaptofloor
	ldy y_crd_temp    ; check block 2
	ldx temp2
	lda #gc_floor
	jsr gm_collide
	bne gm_snaptofloor
	rts
gm_snaptofloor:
	lda #%11111000    ; round player's position to lower multiple of 8
	and player_y
	sta player_y
	lda #0            ; set the subpixel to zero
	sta player_sp_y
	lda dashtime
	cmp #(defdashtime-dashchrgtm-2)
	bcs gm_sfloordone ; until the player has started their dash, exempt from ground check
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
	sta dashcount
gm_sfloordone:
	rts

gm_leaveroomR_:
	jmp gm_leaveroomR

; ** SUBROUTINE: gm_applyx
; desc:    Apply the velocity in the X direction. 
gm_applyx:
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
	bcs gm_nocheckoffs       ; If the addition didn't overflow, we need to detour.
	ldx player_vl_x          ; check if the velocity was positive
	bpl gm_nocheckoffs       ; yeah, of course it wouldn't overflow, it's positive!
	lda #0                   ; we have an underflow, means the player is trying to leave the screen
	ldy #0                   ; through the left side. we can't let that happen!
	clc                      ; zero out the player's new position
gm_nocheckoffs:
	sta player_x
	jsr gm_gettopy
	sta temp1                ; temp1 - top Y
	jsr gm_getbottomy_w
	sta temp2                ; temp2 - bottom Y
	lda player_vl_x
	bmi gm_checkleft
gm_checkright:
	lda player_x
	cmp #$F0
	bcs gm_leaveroomR_       ; try to leave the room
	jsr gm_getrightx
	tax
	stx y_crd_temp           ; note: x_crd_temp is clobbered by gm_collide!
	ldy temp1
	lda #gc_right
	jsr gm_collide
	bne gm_collright         ; if collided, move a pixel back and try again
	ldy temp2                ;  snapping to the nearest tile is a BIT more complicated so
	ldx y_crd_temp           ;  I will not bother
	lda #gc_right
	jsr gm_collide
	beq gm_checkdone
gm_collright:
	ldx #0                   ; set the velocity to a minuscule value to
	stx player_vl_x          ; ensure the player doesn't look idle
	inx
	stx player_vs_x
	lda playerctrl
	ora #pl_pushing
	and #(pl_wallleft^$FF)   ; the wall wasn't found on the left.
	sta playerctrl
	lda #defwjmpcoyo
	sta wjumpcoyote
	ldx player_x
	beq gm_checkdone         ; if the player X is zero... we're stuck inside a wall
	dex
	stx player_x
	ldx #$FF                 ; set the subpixel to $FF.  This allows our minuscule velocity to
	stx player_sp_x          ; keep colliding with this wall every frame and allow the push action to continue
	jmp gm_checkright        ; !! note: in case of a potential clip, this might cause lag frames!
gm_checkleft:
	jsr gm_getleftx
	tax
	stx y_crd_temp
	ldy temp1
	lda #gc_left
	jsr gm_collide
	bne gm_collleft          ; if collided, move a pixel to the right & try again
	ldy temp2
	ldx y_crd_temp
	lda #gc_left
	jsr gm_collide
	beq gm_checkdone
gm_collleft:
	ldx #$FF                 ; set the velocity to a minuscule value to
	stx player_vl_x          ; ensure the player doesn't look idle
	stx player_vs_x
	lda playerctrl
	ora #pl_pushing
	ora #pl_wallleft         ; the wall was found on the left.
	sta playerctrl
	lda #defwjmpcoyo
	sta wjumpcoyote
	ldx player_x
	cpx #$F0                 ; compare to [screenWidth-16]
	bcs gm_checkdone         ; if bigger or equal, just bail, we might be stuck in a wall
	inx
	stx player_x
	ldx #0                   ; set the subpixel to 0.  This allows our minuscule velocity to
	stx player_sp_x          ; keep colliding with this wall every frame and allow the push action to continue
	jmp gm_checkleft
gm_checkdone:
	lda player_vl_x
	bpl gm_scroll_r_cond    ; if moving positively, scroll if needed
	rts

; ** SUBROUTINE: gm_checkwjump
; desc: Assigns coyote time if wall is detected near the player.
gm_checkwjump:
	lda #pl_ground
	bit playerctrl
	bne gm_dontsetwcoyote    ; if player is grounded, simply return
	jsr gm_getmidy
	tay
	sty y_crd_temp
	jsr gm_getleftwjx        ; handle the left tile
	tax
	lda #gc_left
	jsr gm_collide
	bne gm_setwcoyoteL
	ldy y_crd_temp
	jsr gm_getrightwjx       ; and now the right tile
	tax
	lda #gc_right
	jsr gm_collide
	beq gm_dontsetwcoyote
	lda playerctrl
	and #(pl_wallleft^$FF)
	sta playerctrl           ; set that a wall was found on the RIGHT side
gm_setwcoyote:
	lda #defwjmpcoyo
	sta wjumpcoyote
gm_dontsetwcoyote:
	rts
gm_setwcoyoteL:
	lda playerctrl
	ora #pl_wallleft
	sta playerctrl           ; set that a wall was found on the LEFT side
	jmp gm_setwcoyote

; ** SUBROUTINE: gm_scroll_r_cond
gm_scroll_r_cond:
	lda player_x
	cmp #scrolllimit
	bcc gm_scroll_ret ; A < scrolllimit
	beq gm_scroll_ret ; A = scrolllimit
gm_scroll_do:
	sec
	sbc #scrolllimit
	cmp #camspeed     ; see the difference we need to scroll
	bcc gm_scr_nofix  ; A < camspeed
	lda #camspeed
gm_scr_nofix:         ; A now contains the delta we need to scroll by
	sta temp1
	clc
	tax               ; save the delta as we'll need it later
	adc camera_x      ; add the delta to the camera X
	sta camera_x
	lda #0
	adc camera_x_pg
	sta camera_x_pg
	and #1
	sta camera_x_hi
	lda #gs_scrstopR  ; check if we overstepped the camera boundary, if needed
	bit gamectrl
	beq gm_scrollnolimit
	lda camlimit
	sta scrchklo
	lda camlimithi
	sta scrchkhi
	lda camlimithi    ; check if [camlimithi,camlimit] < [camera_x_hi,camera_x]
	cmp camera_x_hi
	bcs :+
	lda camlimit
	cmp camera_x
	bcs :+
	lda #2            ; note: carry clear here
	adc scrchkhi
	sta scrchkhi
:	sec
	lda scrchklo
	sbc camera_x
	sta scrchklo
	lda scrchkhi
	sbc camera_x_hi
	bmi gm_camxlimited
	sta scrchkhi
gm_scrollnolimit:
	lda #scrolllimit  ; set the player's X relative-to-the-camera to scrolllimit
	sta player_x
	txa               ; restore the delta to add to camera_rev
	pha
	lda temp1
	jsr gm_shifttrace
	pla
	adc camera_rev
	sta camera_rev
	cmp #8
	bcs gm_go_generate; if camera_rev+diff < 8 return
gm_scroll_ret:
	rts
gm_go_generate:
	lda camera_rev    ; subtract 8 from camera_rev
	sec
	sbc #8
	sta camera_rev
	jmp h_gener_col_r
gm_camxlimited:
	lda camlimithi
	sta camera_x_hi
	lda camlimit
	sta camera_x
	lda #gs_scrstodR
	bit gamectrl
	bne :+
	ora gamectrl
	sta gamectrl
:	rts

gm_dash_lock:
	ldx #0
	stx player_vl_x
	stx player_vl_y
	stx player_vs_x
	stx player_vs_y
	jmp gm_dash_update_done
gm_dash_over:
	jmp gm_dash_update_done

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
	beq gm_sjret            ; if player wasn't grounded, then ...
	lda dashdiry
	cmp #1
	bne gm_sj_normal
	; half the jump height here
	lda #((jumpvel >> 1) ^ $FF + 1)
	sta player_vl_y
	lda #((((jumpvel << 7) | (jumpvello >> 1)) ^ $FF + 1) & $FF)
	sta player_vs_y
	jmp gm_superjumph
gm_sj_normal:
	lda #(jumpvel ^ $FF + 1)
	sta player_vl_y
	lda #(jumpvello ^ $FF + 1)
	sta player_vs_y         ; super jump speed is the same as normal jump speed
gm_superjumph:
	lda #superjmphhi
	sta player_vl_x
	lda #superjmphlo
	sta player_vs_x
	lda #pl_left
	bit playerctrl
	beq gm_sjret
	lda player_vl_x
	eor #$FF
	sta player_vl_x
	lda player_vs_x
	eor #$FF
	sta player_vs_x
gm_sjret:
	rts

gm_dash_update:
	; NOTE: dashtime is loaded into A
	sec
	sbc #1
	sta dashtime
	beq gm_dash_over        ; if dashtime is now 0, then finish the dash
	cmp #(defdashtime-dashchrgtm)
	beq gm_dash_read_cont   ; if it isn't exactly defdashtime-dashchrgtm, let physics run its course
	bcs gm_dash_lock        ; dash hasn't charged
	jmp gm_dash_after
gm_dash_read_cont:
	lda p1_cont
	and #%00001111          ; check if holding any direction
	beq gm_defaultdir       ; if not, determine the dash direction from the facing direction	
	lda p1_cont
	and #%00001100          ; get just the up/down flags
	lsr
	lsr
	tay                     ; use them as an index into the dashY table
	lda p1_cont
	and #%00000011          ; get just the left/right flags
	; if horizontal flags are 0, then the vertical flags must NOT be zero, otherwise we ended up in gm_defaultdir
gm_dash_nodir:
	tax                     ; this is now an index into the X table
	stx dashdirx
	sty dashdiry
	lda #0
	sta player_vs_x
	sta player_vs_y
	lda dashY, y
	sta player_vl_y
	lda dashX, x
	bmi gm_leftdash
	sta player_vl_x
	jmp gm_dash_update_done
gm_leftdash:
	sta player_vl_x
	lda playerctrl
	ora #pl_left
	sta playerctrl
	jmp gm_dash_update_done
gm_dash_after:
	; this label is reached when the dash is "completed", i.e. it gives no more
	; boost to the player and physics are enabled.
	lda #%00000011
	bit p1_cont
	beq gm_dash_noflip  ; not pressing a direction, so no need to flip the character
	lda playerctrl
	ora #pl_left
	sta playerctrl      ; set the left bit...
	lda #cont_right     ; assumes cont_right == 1
	and p1_cont
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

gm_physics:
	lda #pl_dead
	bit playerctrl
	beq :+
	rts
:	jsr gm_jumpgrace
	lda dashtime
	bne gm_dash_update
	jsr gm_gravity
	jsr gm_controls
gm_dash_update_done:
	jsr gm_drag
	jsr gm_sanevels
	jsr gm_applyy
	jsr gm_applyx
	jsr gm_addtrace
	jmp gm_checkwjump

gm_addtrace:
	ldx plrtrahd
	inx
	txa
	and #$3F ; mod 64
	sta plrtrahd
	tax
	
	lda player_x
	sta plr_trace_x, x
	lda player_y
	sta plr_trace_y, x
	rts

; ** SUBROUTINE: gm_shifttrace
; desc: Shifts the player X trace left by an amount of pixels.
; parameters:
;     A - the amount of pixels to decrease the player X trace by
; note: The player X trace is capped to 0. It will not overflow.
gm_shifttrace:
	pha
	ldx #0
	sta temp1
:	lda plr_trace_x, x
	sec
	sbc temp1
	bcs :+
	lda #0
:	sta plr_trace_x, x
	inx
	cpx #$40
	bne :--
	pla
	rts
	
