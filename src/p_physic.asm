
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
	sec
	sbc camera_y_sub
	sta plr_trace_y, x
	rts

; ** SUBROUTINE: gm_shifttrace
; desc: Shifts the player X trace left by an amount of pixels.
; parameters:
;     A - the amount of pixels to decrease the player X trace by
; note: The player X trace is capped to 0. It will never overflow.
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

; ** SUBROUTINE: gm_shiftrighttrace
; desc: Shifts the player X trace right by an amount of pixels.
; parameters:
;     A - the amount of pixels to increase the player X trace by
; note: The player X trace is capped to $FF. It will never overflow.
gm_shiftrighttrace:
	pha
	ldx #0
	sta temp1
:	lda plr_trace_x, x
	clc
	adc temp1
	bcc :+
	lda #$FF
:	sta plr_trace_x, x
	inx
	cpx #$40
	bne :--
	pla
	rts
	
; ** SUBROUTINE: gm_shifttraceYP
; desc: Shifts the player Y trace down by an amount of pixels
; parameters:
;     A - the amount of pixels to increase the player Y trace by
; note: The player X trace is capped to $F0. It will never overflow.
gm_shifttraceYP:
	pha
	ldx #0
	sta temp1
@loop:
	lda plr_trace_y, x
	
	clc
	adc temp1
	
	bcc :+
	lda #$F0
	
:	cmp #$F0
	bcc :+
	lda #$F0
	
:	sta plr_trace_y, x
	inx
	cpx #$40
	bne @loop
	pla
	rts
	
; ** SUBROUTINE: gm_shifttraceYN
; desc: Shifts the player Y trace up by an amount of pixels
; parameters:
;     A - the amount of pixels to increase the player Y trace by
; note: The player X trace is capped to 0. It will never overflow.
gm_shifttraceYN:
	pha
	ldx #0
	sta temp1
@loop:
	lda plr_trace_y, x
	sec
	sbc temp1	
	bcs :+
	lda #0
:	sta plr_trace_y, x
	inx
	cpx #$40
	bne @loop
	pla
	rts

; ** SUBROUTINE: gm_killplayer
; desc:     Initiates the player death sequence.
gm_killplayer:
	lda #pl_dead
	bit playerctrl
	bne @return
	
	ora playerctrl
	sta playerctrl
	
	jsr gm_death_sfx
	lda #pl_dead
	lda #0
	sta deathtimer

@return:
	rts

; ** SUBROUTINE: gm_physics
; desc: Runs one frame of player physics.
gm_physics:
	lda #<xt_physics
	sta temp1
	lda #>xt_physics
	sta temp2
	ldy #prgb_xtra
	jmp far_call

; ** SUBROUTINE: gm_collide
; desc: Calls xt_collide.
; parameters: See xt_collide.
gm_collide:
	sta temp11
	stx temp9
	sty temp10
	lda #<xt_collide_kludge
	sta temp1
	lda #>xt_collide_kludge
	sta temp2
	ldy #prgb_xtra
	jsr far_call
	lda temp11
	rts

xt_collide_kludge:
	lda temp11
	ldx temp9
	ldy temp10
	jsr xt_collide
xt_kludge_zeroflag:
	bne :+
	lda #0
	sta temp11
	rts
:	lda #1
	sta temp11
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
	adc #plr_y_bot_wall
	bcs gm_gety_wraparound
	cmp #240
	bcs gm_gety_wraparound
	lsr
	lsr
	lsr
	rts
gm_gety_wraparound:
	lda #$FF
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
	adc #plr_y_bot
	bcs gm_gety_wraparound
	cmp #240
	bcs gm_gety_wraparound
	lsr
	lsr
	lsr
	rts

; ** SUBROUTINE: gm_getbottomy_cc
; desc:     Gets the tile Y position in the middle of the player's hitbox, used for climb hop checks
gm_getbottomy_cc:
	lda player_y
	clc
	adc #plr_y_bot_cc
	bcs gm_gety_wraparound
	cmp #240
	bcs gm_gety_wraparound
	lsr
	lsr
	lsr
	rts

; ** SUBROUTINE: gm_getbottomy_wjc
; desc:     Gets the tile Y position in the middle of the player's hitbox, used for climb hop checks
gm_getbottomy_wjc:
	lda player_y
	clc
	adc #plr_y_bot_wjc
	bcs gm_gety_wraparound
	cmp #240
	bcs gm_gety_wraparound
	lsr
	lsr
	lsr
	rts

; ** SUBROUTINE: gm_gettopy
; desc:     Gets the tile Y position where the top edge of the player's hitbox resides
; returns:  A - the Y coordinate
gm_gettopy:
	clc
	lda player_y
	adc #plr_y_top
	bcs gm_gety_wraparound
	cmp #240
	bcs gm_gety_wraparound
	lsr
	lsr
	lsr
	rts

; ** SUBROUTINE: gm_getmidx
; desc:     Gets the tile X position at the middle of the player's hitbox, used for squish checking
; returns:  A - the X coordinate
gm_getmidx:
	clc
	lda player_x
	adc #plr_x_mid    ; determine leftmost hitbox position
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

; ** SUBROUTINE: gm_collentceil
; desc: Checks ceiling collision with entities. Calls xt_collentceil
gm_collentceil:
	lda #<xt_collentceil_kludge
	sta temp1
	lda #>xt_collentceil_kludge
	sta temp2
	ldy #prgb_xtra
	jsr far_call
	lda temp10
	ldx temp11
	rts
xt_collentceil_kludge:
	jsr xt_collentceil
	sta temp10
	jmp xt_kludge_zeroflag

; ** SUBROUTINE: gm_collentfloor
; desc: Checks ground collision with entities. Calls xt_collentfloor
gm_collentfloor:
	lda #<xt_collentfloor_kludge
	sta temp1
	lda #>xt_collentfloor_kludge
	sta temp2
	ldy #prgb_xtra
	jsr far_call
	lda temp10
	ldx temp11
	rts
xt_collentfloor_kludge:
	jsr xt_collentfloor
	sta temp10
	jmp xt_kludge_zeroflag

; ** SUBROUTINE: gm_superbounce
; desc: Bounces the player from a specific height. Equivalent to Player.SuperBounce(float) in Celeste.
; parameters:
;      A - the Y coordinate to bounce from -- `fromY`
.proc gm_superbounce
	; note: Celeste does a MoveY(fromY - Bottom) which is, uh, expensive.
	sec
	sbc #16
	sta player_y
	
	lda #0
	sta dashcount
	sta jumpcoyote
	sta wjumpcoyote
	
	lda #14
	sta jcountdown
	
	lda gamectrl2
	ora #g2_autojump
	sta gamectrl2
	
	lda #0
	sta player_vl_x
	sta player_vs_x
	
	lda #<staminamax
	sta stamina
	lda #>staminamax
	sta stamina+1
	
	lda #<springspd
	sta player_vs_y
	lda #>springspd
	sta player_vl_y

	rts
.endproc
