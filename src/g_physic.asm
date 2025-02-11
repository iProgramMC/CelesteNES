; Copyright (C) 2024-2025 iProgramInCpp
; ** SUBROUTINE: gm_killplayer
; desc:     Initiates the player death sequence.
.proc gm_killplayer
	lda #pl_dead
	bit playerctrl
	bne return
	
	ora playerctrl
	sta playerctrl
	
	inc deaths
	bne :+
	inc deaths+1
	
:	jsr gm_death_sfx
	
	lda #0
	sta deathtimer
	
copy:
	lda player_x
	sta player_dx
	lda player_y
	sta player_dy

return:
	rts
.endproc

gm_copyplayerpostodeath = gm_killplayer::copy

; ** SUBROUTINE: gm_physics
; desc: Runs one frame of player physics.
gm_physics:
	ldy #prgb_phys
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
	ldy #prgb_phys
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
; ** SUBROUTINE: gm_getbottomy_wjc
; desc:     Gets the tile Y position where the bottom edge of the player's hitbox resides,
;           when checking for collision with walls.
; returns:  A - the Y coordinate
; note:     this is NOT ALWAYS the same as the result of gm_gettopy!! though perhaps
;           some optimizations are possible..
; note:     to allow for a bit of leeway, I took off one pixel from the wall check.
; note:     gm_getbottomy_wjc is also defined to be this function.  We'll see what *actually* requires shorter hitboxes.
gm_getbottomy_w:
gm_getbottomy_wjc:
	clc
	lda player_y
	adc wallhboxybot
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
	lda camera_x_pg
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
	ldy #prgb_phys
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
	ldy #prgb_phys
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
	sta dashtime
	sta dshatktime
	
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
	
	jsr gm_reset_stamina
	
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
	sta dshatktime
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

; ** SUBROUTINE: gm_reset_dash_and_stamina
; desc: Resets the dash count and stamina.
gm_reset_dash_and_stamina:
	lda #0
	sta dashcount
; ** SUBROUTINE: gm_reset_stamina
; desc: Resets stamina.
gm_reset_stamina:
	lda #<staminamax
	sta stamina
	lda #>staminamax
	sta stamina+1
	rts
