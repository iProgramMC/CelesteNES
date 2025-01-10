
; ** SUBROUTINE: gm_shifttrace
; desc: Shifts the player X trace left by an amount of pixels.
; parameters:
;     A - the amount of pixels to decrease the player X trace by
; note: The player X trace is capped to 0. It will never overflow.
.proc gm_shifttrace
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	cmp #0
	bmi actuallyNegative
nocheck:
	pha
	ldx #0
loop:
	lda plr_trace_x, x
	sec
	sbc temp1
	bcs :+
	lda #0
:	sta plr_trace_x, x
	inx
	cpx #$40
	bne loop
	pla
return:
	jmp gm_shiftbgstarsXN
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp gm_shiftrighttrace_nocheck
.endproc

; ** SUBROUTINE: gm_shiftrighttrace
; desc: Shifts the player X trace right by an amount of pixels.
; parameters:
;     A - the amount of pixels to increase the player X trace by
; note: The player X trace is capped to $FF. It will never overflow.
.proc gm_shiftrighttrace
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	cmp #0
	bmi actuallyNegative
nocheck:
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
return:
	jmp gm_shiftbgstarsXP
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp gm_shifttrace::nocheck
.endproc

gm_shiftrighttrace_nocheck := gm_shiftrighttrace::nocheck

; ** SUBROUTINE: gm_shifttraceYP
; desc: Shifts the player Y trace down by an amount of pixels
; parameters:
;     A - the amount of pixels to increase the player Y trace by
; note: The player X trace is capped to $F0. It will never overflow.
.proc gm_shifttraceYP
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	cmp #0
	bmi actuallyNegative
nocheck:
	pha
	ldx #0
	sta temp1
loop:
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
	bne loop
	pla
return:
	jmp gm_shiftbgstarsYP
	rts
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp gm_shifttraceYN_nocheck
.endproc

; ** SUBROUTINE: gm_shifttraceYN
; desc: Shifts the player Y trace up by an amount of pixels
; parameters:
;     A - the amount of pixels to increase the player Y trace by
; note: The player X trace is capped to 0. It will never overflow.
.proc gm_shifttraceYN
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	bmi actuallyNegative
nocheck:
	pha
	ldx #0
	sta temp1
loop:
	lda plr_trace_y, x
	sec
	sbc temp1	
	bcs :+
	lda #0
:	sta plr_trace_y, x
	inx
	cpx #$40
	bne loop
	pla
return:
	jmp gm_shiftbgstarsYN
	rts
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp gm_shifttraceYP::nocheck
.endproc

gm_shifttraceYN_nocheck := gm_shifttraceYN::nocheck

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
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jsr mmc3_set_bank
	
	jsr xt_physics
	
	; the level data bank CAN CHANGE 
	ldy lvldatabank
	lda #mmc3bk_prg1
	jmp mmc3_set_bank

; ** SUBROUTINE: gm_collide
; desc: Calls xt_collide.
; parameters: See xt_collide.
gm_collide:
	sta temp11
	stx temp9
	sty temp10
	lda #<xt_collide_kludge
	sta farcalladdr
	lda #>xt_collide_kludge
	sta farcalladdr+1
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
	cmp #$1D
	bcc :+
	lda abovescreen
	beq :+
	lda #$1D
:	rts

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
	cmp #$1D
	bcc :+
	lda abovescreen
	beq :+
	lda #$1D
:	rts

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
	cmp #$1D
	bcc :+
	lda abovescreen
	beq :+
	lda #$1D
:	rts

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
	sta farcalladdr
	lda #>xt_collentceil_kludge
	sta farcalladdr+1
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
	sta farcalladdr
	lda #>xt_collentfloor_kludge
	sta farcalladdr+1
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
	
	lda playerctrl
	and #<~(pl_climbing | pl_wallleft | pl_nearwall | pl_pushing)
	sta playerctrl
	
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

; ** SUBROUTINE: gm_rebound
; desc: Rebounds the player after they hit something with a dash
.proc gm_rebound
	lda player_vl_x
	bmi @assignPlus120
	bne @assignMinus120
	lda player_vs_x
	bne @assignMinus120
	; don't modify the vel if it's zero
@doneModdingX:
	; clears the velocity (A must be zero always)
	sta player_vs_y
	lda #$FE ; -120
	sta player_vl_y
	
	lda gamectrl2
	ora #g2_autojump
	sta gamectrl2
	
	lda #9
	sta jcountdown
	
	lda #0
	sta dashtime
	sta forcemovext
	rts

@assignMinus120:
	lda #$FE
	sta player_vl_x
	lda #$00
	sta player_vs_x
	beq @doneModdingX
@assignPlus120:
	lda #$02
	sta player_vl_x
	lda #$00
	sta player_vs_x
	beq @doneModdingX
.endproc

; ** SUBROUTINE: gm_shiftbgstarsXN
; desc: Shifts all starry background elements left.
; parameters: temp1 - Amount to shift by.
.proc gm_shiftbgstarsXN
	
	rts
.endproc

; ** SUBROUTINE: gm_shiftbgstarsXP
; desc: Shifts all starry background elements right.
; parameters: temp1 - Amount to shift by.
.proc gm_shiftbgstarsXP
	
	rts
.endproc

; ** SUBROUTINE: gm_shiftbgstarsYN
; desc: Shifts all starry background elements up.
; parameters: temp1 - Amount to shift by.
.proc gm_shiftbgstarsYN
	
	rts
.endproc

; ** SUBROUTINE: gm_shiftbgstarsYP
; desc: Shifts all starry background elements down.
; parameters: temp1 - Amount to shift by.
.proc gm_shiftbgstarsYP
	
	rts
.endproc
