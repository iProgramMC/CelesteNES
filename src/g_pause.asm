; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: gm_pause
; desc: Pauses the game.
.proc gm_pause
	lda dialogsplit
	bne return
	lda dlg_cutsptr+1
	bne return
	lda playerctrl
	and #pl_dead
	beq dontreturn
return:
	rts

dontreturn:
	inc paused
	
	lda spr0_bknum
	sta spr0_paubk
	lda spr1_bknum
	sta spr1_paubk
	lda spr2_bknum
	sta spr2_paubk
	lda spr3_bknum
	sta spr3_paubk
	
	lda #$FF
	sta pauseoption
	
	lda #chrb_pause
	sta spr0_bknum
	lda #chrb_pause+1
	sta spr1_bknum
	lda #chrb_pause+2
	sta spr2_bknum
	lda #chrb_pause+3
	sta spr3_bknum
	
	; fill in the first 3 palettes with stuff and reupload
	lda #$10
	sta spritepals+0
	lda #$00
	sta spritepals+1
	; 3rd color of that palette is unused.
	
	lda #$30
	sta spritepals+3
	; 2nd color of that palette are unused
	
	lda #$29
	sta spritepals+6
	; 2nd color of that palette are unused
	
	lda #$0F
	sta spritepals+2
	sta spritepals+5
	sta spritepals+8
	
	lda nmictrl2
	ora #(nc2_updpal1 | nc2_updpal2 | nc2_updpal3)
	sta nmictrl2
	rts
.endproc

; ** SUBROUTINE: gm_unpause
; desc: Unpauses the game.
.proc gm_unpause
	lda paused
	beq return
	
	dec paused
	
	lda spr0_paubk
	sta spr0_bknum
	lda spr1_paubk
	sta spr1_bknum
	lda spr2_paubk
	sta spr2_bknum
	lda spr3_paubk
	sta spr3_bknum
	
	; restore old palette
	ldy #0
palettePrepLoop:
	lda (paladdr), y
	sta temprow1,  y
	iny
	cpy #16
	bne palettePrepLoop
	
	; set that bit
	lda #$3F
	sta ppuaddrHR1+1
	lda #$00
	sta ppuaddrHR1
	lda #$10
	sta wrcountHR1
	lda #$00
	sta wrcountHR2
	sta wrcountHR3
	
	lda nmictrl
	ora #nc_flushrow
	sta nmictrl
	
	; wait for the palette to be shifted
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	
return:
	rts
.endproc

; ** SUBROUTINE: gm_check_pause
; desc: Checks the start button to see if the game should be paused.
.proc gm_check_pause
	lda game_conto
	and #cont_start
	bne gm_unpause::return ; the button was already pressed
	
	lda game_cont
	and #cont_start
	beq gm_unpause::return ; you didn't actually press start
	
	lda paused
	bne gm_unpause
	jmp gm_pause
.endproc

; ** SUBROUTINE: gm_clear_collided
; desc: Clears the collided flag for entities, and updates the old velocities
.proc gm_clear_collided
	ldy #0
:	lda sprspace+sp_flags, y
	and #<~ef_collided
	sta sprspace+sp_flags, y
	iny
	cpy #sp_max
	bne :-
	
	rts
.endproc
