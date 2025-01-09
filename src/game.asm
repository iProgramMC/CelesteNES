; Copyright (C) 2024 iProgramInCpp

.include "g_level.asm"
.include "e_draw.asm"
.include "e_update.asm"
.include "e_physic.asm"
.include "e_spawn.asm"
;.include "p_draw.asm"
.include "p_physic.asm"
.include "g_palloc.asm"
.include "g_wipe.asm"
.include "xtraif.asm"

; ** SUBROUTINE: gm_update_ptstimer
gm_update_ptstimer:
	lda ptstimer
	beq :+            ; if ptstimer != 0, then just decrement it
	dec ptstimer
	rts
:	sta ptscount      ; if they're both 0, reset the points count and return
	rts

; ** SUBROUTINE: gm_load_room_fully
gm_load_room_fully:
	jsr h_gener_ents_r
	jsr h_gener_mts_r
	
	lda #tilesahead
	clc
	adc roomloffs
	sta tmpRoomTran
	
	ldy #$00          ; generate tilesahead columns
@writeLoop:
	tya
	pha
	jsr h_gener_col_r
	jsr h_flush_col_r_cond
	jsr h_flush_pal_r_cond
	lda nmictrl
	and #<~(nc_flushcol|nc_flshpalv|nc_flushrow|nc_flushpal)
	sta nmictrl
	pla
	tay
	iny
	cpy roomloffs
	bne @dontMarkBeginning
	
	lda roomloffs
	asl
	asl
	asl
	clc
	adc camera_x
	sta camera_x
	bcc @dontMarkBeginning
	inc camera_x_pg
@dontMarkBeginning:
	cpy tmpRoomTran
	bne @writeLoop
	rts

; ** SUBROUTINE: gamemode_init
gm_game_init:
	ldx #$FF
	stx animmode
	inx
	stx ppu_mask      ; disable rendering
	
	lda #g2_noclrall
	bit gamectrl2
	beq @clearAll
	
	jsr gm_game_clear_wx
	jmp @clearDone
	
@clearAll:
	jsr gm_game_clear_all_wx
	
	jsr vblank_wait
	
	jsr load_palette  ; load game palette into palette RAM
	
	lda #$20
	jsr clear_nt
	lda #$24
	jsr clear_nt
	
@clearDone:
	
	lda #0
	sta ntwrhead
	sta arwrhead
	sta camera_x
	
	lda rm_paloffs
	asl
	asl
	sta lvlyoff
	asl
	asl
	asl
	sta camera_y
	sta camera_y_bs
	
	jsr gm_calculate_vert_offs
	jsr gm_load_room_fully
	
	lda gamectrl
	and #(gs_scrstodR|gs_scrstopR|gs_lvlend)
	ora #gs_1stfr
	sta gamectrl
	
	lda nmictrl
	and #((nc_flushcol|nc_flshpalv|nc_flushrow|nc_flushpal)^$FF)
	ldy respawntmr
	bne :+          ; do not instantly turn on the screen if we're respawning. Let that routine handle it
	ora #nc_turnon
:	sta nmictrl

	jsr gm_update_bg_bank
	
	jsr vblank_wait
	jmp gm_game_update

; ** GAMEMODE: gamemode_game
gamemode_game:
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	jsr gm_update_game_cont
	jsr gm_check_pause
	
	lda paused
	bne @gamePaused
	
	jsr gm_calc_camera_split ; calculate the position of the camera so that the IRQ can pick it up
	jsr gm_draw_respawn
	
	lda camera_y_hi
	sta camera_y_ho
	
	jsr gm_clear_palette_allocator
	inc framectr
	lda scrollsplit
	beq :+
:	jsr gm_update_lift_boost
	jsr gm_check_climb_input
	jsr gm_clear_collided
	jsr gm_physics
	jsr gm_anim_and_draw_player
	jsr gm_draw_dead
	jsr gm_unload_os_ents
	jsr gm_draw_entities
	jsr gm_update_ptstimer
	jsr gm_update_dialog
	jsr gm_load_level_if_vert
	jsr gm_check_level_banks
	
	; note: by this point, palettes should have been calculated.
	jsr gm_check_updated_palettes
	
	; note: at this point, camera positioning should have been calculated.
	; calculate the position of the camera so that the NMI can pick it up
	; if scrollsplit is not zero then it was already calculated for the IRQ
	lda scrollsplit
	bne @dontCalcNoSplit
	jsr gm_calc_camera_nosplit
	
@dontCalcNoSplit:
	; add more here?
	rts

@gamePaused:
	; game is paused.
	lda #<pause_update
	sta farcalladdr
	lda #>pause_update
	sta farcalladdr+1
	lda #mmc3bk_prg1
	ldy #prgb_paus
	jmp far_call

; ** SUBROUTINE: gm_update_game_cont
; desc: Updates the game_cont variables to the state of p1_cont.  If input is blocked, then
;       it's actually set to zero.
gm_update_game_cont:
	lda #g3_blockinp
	bit gamectrl3
	beq @normalInput
	
	lda #0
	sta game_cont
	sta game_cont+1
	sta game_conto
	sta game_conto+1
	rts
	
@normalInput:
	lda p1_cont
	ora game_cont_force
	sta game_cont
	lda p1_cont+1
	ora game_cont_force+1
	sta game_cont+1
	
	lda p1_conto
	sta game_conto
	lda p1_conto+1
	sta game_conto+1
	
	lda #0
	sta game_cont_force
	sta game_cont_force+1
	rts

; ** SUBROUTINE: gm_update_dialog
; desc: Updates the active dialog if needed.
gm_update_dialog:
	lda gamectrl3
	and #g3_updcuts
	beq @dontUpdateCutscene
	
	eor gamectrl3
	sta gamectrl3
	jsr dlg_run_cutscene_g
	
@dontUpdateCutscene:
	lda dialogsplit
	beq @return
	jmp dlg_update_g
@return:
	rts

; ** SUBROUTINE: gm_game_clear_all_wx
; desc: Clears ALL game variables with the X register.
;       Unlike gm_game_clear_all_wx, this clears data that's necessary across,
;       for example, respawn transitions.
gm_game_clear_all_wx:
	stx lvlyoff
	stx dbenable

; ** SUBROUTINE: gm_game_clear_wx
; desc: Clears game variables with the X register.
gm_game_clear_wx:
	;stx gamectrl2
	stx gamectrl4
	stx transoff
	stx tr_scrnpos
	stx gamectrl      ; clear game related fields to zero
	stx ntwrhead
	stx arwrhead
	stx player_sp_x
	stx player_sp_y
	stx camera_x
	stx camera_y
	stx camera_x_hi
	;stx lvladdr
	;stx lvladdrhi
	stx playerctrl
	stx player_vl_x
	stx player_vs_x
	stx player_vl_y
	stx player_vs_y
	stx dashtime
	stx dashcount
	stx jumpbuff
	stx jumpcoyote
	stx wjumpcoyote
	stx roombeglo
	stx roombeghi
	stx roombeglo2
	stx liftboosttm
	stx liftboostX
	stx liftboostY
	stx lastlboostX
	stx lastlboostY
	stx currlboostX
	stx currlboostY
	stx player_x_d
	stx hopcdown
	stx cjwindow
	stx climbcdown
	stx camera_x_lo
	stx camera_y_lo
	stx camlefthi
	stx plrtrahd
	stx plrstrawbs
	stx scrollsplit
	stx dialogsplit
	stx camera_y_sub
	stx stamflashtm
	stx camleftlo
	stx irqtmp1
	stx irqtmp2
	stx irqtmp3
	stx irqtmp4
	stx irqtmp5
	stx irqtmp6
	stx irqtmp7
	stx irqtmp8
	stx deathwipe
	stx deathwipe2
	stx miscsplit
	stx abovescreen
	stx paused
	stx pauseanim
	stx dredeatmr
	stx dreinvtmr
	stx game_cont_force
	stx game_cont_force+1
	stx amodeforce
	
	lda #<~g3_transitX
	and gamectrl3
	sta gamectrl3
	
	; before waiting on vblank, clear game reserved spaces ($0300 - $05FF)
	; note: ldx #$00 was removed because it's already 0!
	txa
:	sta $200,x  ; OAMBUF
	sta $300,x  ; ENTITIES
	sta $400,x  ; PLTRACES + DLGRAM
	; N.B. don't clear $500 as it holds the "MORERAM" segment which can't be restored
	sta $600,x  ; last 0x100 bytes of DRAWTEMP
	inx
	bne :-
	dex
	stx animmode      ; set to 0xFF
	
	ldy #0
:	sta spritepals, y
	iny
	cpy #9
	bne :-
	
	lda #<staminamax
	sta stamina
	lda #>staminamax
	sta stamina+1
	
	lda #g2_flashed
	ldx levelnumber
	cpx #0
	bne :+
	ora #g2_nodash
:	sta gamectrl2
	
	lda #$FF
	sta entground
	sta chopentity
	
	; start from 64 screens ahead, remaining with 192 screens to scroll right
	; and 64 screens to scroll left.  While most things still work if camera_x_pg
	; overflows to the negatives, it turns out that my screen scroll check code
	; does not. And I'm too lazy to fix it.
	lda #$40
	sta camera_x_pg
	sta roombeghi
	sta camlefthi
	
	jmp com_clear_oam

; ** SUBROUTINE: gm_calc_camera_nosplit
; desc: Calculate the quake scroll offsets, and adds them to cameraX/cameraY.
;       Then calculates the cameraX/cameraY and prepares it for upload to the PPU.
; note: Does not handle scroll splits.
gm_calc_camera_nosplit:
	; scroll X
	lda camera_x
	sta scroll_x
	
	; scroll Y
	lda camera_y
	clc
	adc camera_y_sub
	cmp #240
	bcc :+
	adc #15     ; adds 16 because carry is set
:	sta scroll_y
	
	jmp gm_calc_camera_shake_and_hi

; ** SUBROUTINE: gm_calc_camera
; desc: Calculates the cameraX/cameraY and prepares it for upload to the PPU.
; note: Does not calculate quake offsets.
gm_calc_camera_split:
	; scroll X
	lda camera_x
	sta scroll_x
	
	; scroll Y
	lda camera_y
	clc
	adc camera_y_sub
	cmp #240
	bcc :+
	adc #15
:	sta scroll_y
	
	; add the scroll split offset if needed.
	lda scrollsplit
	beq @doneAdding
	
	sec
	adc scroll_y
	sta scroll_y
	bcs @carryIsSet
	
	; carry clear, just check if >$F0
	cmp #$F0
	bcc @doneAdding
	
	sec
	sbc #$F0
	sta scroll_y
	
@flipHighBitAndDone:
	lda temp2
	eor #1
	sta temp2

@doneAdding:
	jmp gm_calc_camera_shake_and_hi
	
@carryIsSet:
	; carry was set
	adc #$0F   ; add +$10
	sta scroll_y
	; TODO: carry might be set again. I don't think it matters right now
	; but if you set scrolllimit to > like 80, then look here first.
	jmp @flipHighBitAndDone

; ** SUBROUTINE: gm_leave_doframe
; desc: Completes processing of this frame early, waits for the frame to elapse, and returns.
gm_leave_doframe:
	jsr gm_load_hair_palette
	jsr gm_draw_player
	jsr gm_draw_entities
	jsr gm_calc_camera_nosplit
	jsr gm_check_updated_palettes
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	
	jsr com_clear_oam
	jmp gm_clear_palette_allocator

; ** SUBROUTINE: gm_calc_camera_shake_and_hi
; desc: Shakes the camera according to quakeflags, and calculates the high bits of scroll.
.proc gm_calc_camera_shake_and_hi
	; scroll X/Y high
	lda camera_x_hi
	sta temp1
	lda camera_y_hi
	sta temp2
	
	lda quaketimer
	beq noQuake
	
	dec quaketimer
	
	lda #cont_up
	bit quakeflags
	beq notUp
	
	jsr rand_m2_to_p1
	clc
	adc scroll_y
	sta scroll_y
	lda temp2
	adc temp5
	and #1
	sta temp2
	
notUp:
	lda #cont_down
	bit quakeflags
	beq notDown
	
	jsr rand_m1_to_p2
	clc
	adc scroll_y
	sta scroll_y
	lda temp2
	adc temp5
	and #1
	sta temp2
	
notDown:
	lda #cont_left
	bit quakeflags
	beq notLeft
	
	jsr rand_m2_to_p1
	clc
	adc scroll_x
	sta scroll_x
	lda temp1
	adc temp5
	and #1
	sta temp1
	
notLeft:
	lda #cont_right
	bit quakeflags
	beq notRight
	
	jsr rand_m1_to_p2
	clc
	adc scroll_x
	sta scroll_x
	lda temp1
	adc temp5
	and #1
	sta temp1
	
notRight:
	lda scroll_y
	cmp #240
	bcc noQuake
	sbc #16
	sta scroll_y
	
noQuake:
	lda #0
	ldx temp1
	beq :+
	ora #pctl_highx
	
:	ldx temp2
	beq :+
	ora #pctl_highy
	
:	sta scroll_flags
	rts
.endproc

init_palette:
	.byte $0f,$20,$10,$00 ; grey tiles
	.byte $0f,$37,$16,$06 ; brown tiles
	.byte $0f,$20,$21,$11 ; blue tiles
	.byte $0f,$39,$29,$19 ; green tiles
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$00,$00,$00 ; red/strawberry sprite
	.byte $0f,$00,$00,$00 ; blue sprite
	.byte $0f,$00,$00,$00 ; green/refill sprite
owld_palette:
	.byte $0f,$0c,$01,$00
	.byte $0f,$0c,$10,$30
	.byte $0f,$0c,$00,$10
	.byte $0f,$00,$10,$30
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$36,$16,$06 ; red/strawberry sprite
	.byte $0f,$31,$21,$01 ; blue sprite
	.byte $0f,$30,$29,$09 ; green/refill sprite

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

; ** SUBROUTINE: gm_check_climb_input
; desc: Depending on the control scheme, checks the state of the CLIMB button.
;
; For the SNES controller, checks the state of the L or R buttons.
; For the NES controller, if emulator mode is selected, the state of the SELECT button is checked.
; Otherwise, the UP button is checked.
gm_check_climb_input:
	lda climbcdown
	beq :+
	dec climbcdown
	lda #0
	sta climbbutton
	rts
	
:	lda ctrlscheme
	cmp #cns_snes
	beq @isSNES
	cmp #cns_emulat
	beq @isEmulator
	
	lda game_cont
	and #cont_up
	sta climbbutton
	rts

@isSNES:
	lda game_cont+1
	and #(cont_lsh|cont_rsh)
	sta climbbutton
	rts

@isEmulator:
	lda game_cont
	and #cont_select
	sta climbbutton
	rts

; ** SUBROUTINE: gm_update_lift_boost
; desc: Updates the lift boost.
.proc gm_update_lift_boost
	lda currlboostX
	bne notZero
	lda currlboostY
	bne notZero
	
	; it's zero, check if the lift boost is zero
	lda liftboosttm
	bne liftBoostGraceNonZero
	
	; lift boost grace is zero
	sta liftboostX
	sta liftboostY
	jmp ensureSane

liftBoostGraceNonZero:
	; not zero, so copy the last boost
	lda lastlboostX
	sta liftboostX
	lda lastlboostY
	sta liftboostY
	dec liftboosttm
	jmp ensureSane

notZero:
	; lift boost is not zero right now.
	lda liftboostX
	sta lastlboostX
	lda liftboostY
	sta lastlboostY
	
	lda currlboostX
	sta liftboostX
	lda currlboostY
	sta liftboostY
	
	lda #0
	sta currlboostX
	sta currlboostY
	
	lda #8
	sta liftboosttm

ensureSane:
	lda liftboostY
	bpl boostPositive
	rts

boostPositive:
	lda #0
	sta liftboostY
	rts
.endproc

; ** SUBROUTINE: gm_pause
; desc: Pauses the game.
.proc gm_pause
	lda dialogsplit
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

; ** SUBROUTINE: gm_draw_2xsprite
; arguments: x - offset into zero page with sprite structure
;            a - x position, y - y position
; structure:  [shared attributes] [left sprite] [right sprite]
gm_draw_2xsprite:
	sta x_crd_temp
	sty y_crd_temp
	lda $00,x       ; get shared attributes into a
	inx
	ldy $00,x       ; get left sprite
	inx
	stx temp7
	jsr oam_putsprite
	ldx temp7
	ldy $00,x       ; get right sprite
	lda x_crd_temp  ; add 8 to x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	dex
	dex
	lda $00,x       ; get shared attributes again
	jmp oam_putsprite

; ** SUBROUTINE: gm_draw_respawn
.proc gm_draw_respawn
	lda playerctrl
	and #pl_dead
	bne return
	
	lda respawntmr
	beq return
	
	jmp gm_do_respawn
	
return:
	rts
.endproc

; ** SUBROUTINE: gm_dead_sub2
; desc: Does some math to reduce the result of sine/cosine.
; It's like (temp1 >> 3) + (temp1 >> 4) basically
.proc gm_dead_sub2
	; divide each component by 8
	lda temp1
	cmp #128
	ror
	cmp #128
	ror
	cmp #128
	ror
	sta temp1
	cmp #128
	ror
	;cmp #128
	;ror
	clc
	adc temp1
	sta temp1
	
	lda temp2
	cmp #128
	ror
	cmp #128
	ror
	cmp #128
	ror
	sta temp2
	cmp #128
	ror
	;cmp #128
	;ror
	clc
	adc temp2
	sta temp2
	rts
.endproc

; ** SUBROUTINE: gm_dead_sub3
; desc: Does some more math to interpolate towards temp1, temp2
.proc gm_dead_sub3
	lda deathtimer
	cmp plattemp1
	bcs return
	
	lda #0
	sta temp5
	sta temp6
	
	ldy temp11
loop:
	lda temp1
	cmp #128
	ror
	sta temp1
	ror temp5
	
	lda temp2
	cmp #128
	ror
	sta temp2
	ror temp6
	
	dey
	bne loop
	
	ldy deathtimer
	beq return
	lda #0
	sta temp7
	sta temp8
	sta temp9
	sta temp10
loop2:
	lda temp9
	clc
	adc temp5
	sta temp9
	
	lda temp7
	adc temp1
	sta temp7
	
	lda temp10
	clc
	adc temp6
	sta temp10
	
	lda temp8
	adc temp2
	sta temp8
	
	dey
	bne loop2
	
	lda temp7
	sta temp1
	lda temp8
	sta temp2

return:
	rts
.endproc

; ** SUBROUTINE: gm_dead_shake
.proc gm_dead_shake
	lda #%00001111
	sta quakeflags
	lda #10
	sta quaketimer
	rts
.endproc

; ** SUBROUTINE: gm_draw_dead
.proc gm_draw_dead
	lda #pl_dead
	bit playerctrl
	bne notDead
return:
	rts

notDead:
	lda #8
	sta plattemp1
	lda #3
	sta temp11
	
	lda deathtimer
	bne :+
	jsr gm_dead_shake
:	cmp #32
	bcs return

respawnOverride:
	lda deathangle
	sta temp4
	inc deathangle
	inc deathangle
	
	; load the dead-player-bank. the player isn't being drawn anymore so just reuse its slots
	lda #chrb_dpldi
	sta spr0_bknum
	
	ldy #0
deadLoop:
	lda temp4
	jsr sine
	sta temp1
	
	lda temp4
	jsr cosine
	sta temp2
	
	lda temp4
	clc
	adc #32
	sta temp4
	
	sty temp3
	jsr gm_dead_sub2
	jsr gm_dead_sub3
	ldy temp3
	
	lda player_x
	clc
	adc temp1
	sta x_crd_temp
	ldx #0
	lda temp1
	bpl :+
	dex
:	txa
	adc #0
	bne doneLoop
	
	lda x_crd_temp
	clc
	adc #4
	sta x_crd_temp
	bcs doneLoop
	
	lda player_y
	clc
	adc temp2
	sta y_crd_temp
	
	ldx #0
	lda temp2
	bpl :+
	dex
:	txa
	adc #0
	bne doneLoop
	
	lda y_crd_temp
	cmp #240
	bcs doneLoop
	clc
	adc #4
	sta y_crd_temp
	
	lda plh_attrs
	sty temp3

	lda deathtimer
	cmp #24
	bcc :+
	lda #24
:	lsr
	tay
	lda tableT, y
	tay
	lda #1
	
	jsr oam_putsprite
	ldy temp3
	
doneLoop:
	iny
	cpy #8
	bne deadLoop
	
	; increment death timer
done:
	ldx respawntmr
	bne return2
	
	ldx deathtimer
	inx
	cpx #24
	bne dontRespawn
	jmp gm_respawn
dontRespawn:
	stx deathtimer
return2:
	rts

tableT:	.byte $10,$10,$06,$06,$00,$00,$00,$00,$06,$06,$08,$08,$12,$12
.endproc

; ** SUBROUTINE: gm_init_respawn
; desc: Performs the respawn animation.
.proc gm_do_respawn
	lda nmictrl
	ora #nc_turnon
	sta nmictrl
	
	jsr gm_init_death_wipe
	
	lda deathwipe
	ldx deathwipe2
	sta deathwipe2
	stx deathwipe
	
	;lda #0
	;sta miscsplit
	
	jsr gm_respawn_leave_doframe2
	
loop:
	lda respawntmr
	sta deathtimer
	sta transtimer
	
	; temp11 is the divider count in like gm_dead_sub3 or something
	lda #16
	sta plattemp1
	lda #4
	sta temp11
	
	jsr gm_draw_dead::respawnOverride
	
	lda respawntmr
	cmp #$10
	bcs doWindWipeUpdate
	
	lda #0
	sta miscsplit
	lda #def_ppu_msk
	sta deathwipe
	sta deathwipe2
	
	lda #<irq_death_wipe
	sta irqaddr
	lda #>irq_death_wipe
	sta irqaddr+1
	
	bne doneWipe
	
doWindWipeUpdate:
	jsr gm_wind_wipe_update

doneWipe:
	jsr gm_respawn_leave_doframe2
	
	dec respawntmr
	bne loop
	
	lda #0
	sta miscsplit
	sta deathwipe
	sta deathwipe2
	lda #def_ppu_msk
	sta ppu_mask
	
	jsr gm_leave_doframe
	rts
.endproc

; ** SUBROUTINE: gm_load_hair_palette
; desc: Loads Madeline's hair's palette
gm_load_hair_palette:
	lda plh_forcepal
	bne :+
	lda #maxdashes
	sec
	sbc dashcount
:	jsr gm_allocate_palette
	sta plh_attrs
	rts

; ** SUBROUTINE: gm_check_level_banks
; desc: Checks the loaded background banks for levels.
.proc gm_check_level_banks
	lda levelnumber
	cmp #2
	beq @level2
	rts

@level2:
	ldx #chrb_lvl2+2
	lda dbenable
	bne :+
	ldx #chrb_lvl2e
:	stx bg1_bknum
	
	rts
.endproc
