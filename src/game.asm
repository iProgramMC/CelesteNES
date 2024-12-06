; Copyright (C) 2024 iProgramInCpp

.include "g_level.asm"
.include "e_draw.asm"
.include "e_update.asm"
.include "e_physic.asm"
.include "e_spawn.asm"
.include "p_draw.asm"
.include "p_physic.asm"
.include "g_sfx.asm"
.include "g_palloc.asm"
.include "xtraif.asm"

; ** SUBROUTINE: gm_update_ptstimer
gm_update_ptstimer:
	lda ptstimer
	beq :+            ; if ptstimer != 0, then just decrement it
	dec ptstimer
	rts
:	lda #0            ; if they're both 0, reset the points count and return
	sta ptscount
	rts

; ** SUBROUTINE: gm_load_room_fully
gm_load_room_fully:
	jsr h_gener_ents_r
	jsr h_gener_mts_r
	ldy #$00          ; generate tilesahead columns
:	tya
	pha
	jsr h_gener_col_r
	jsr h_flush_col_r
	jsr h_flush_pal_r_cond
	lda nmictrl
	and #<~(nc_flushcol|nc_flshpalv|nc_flushrow|nc_flushpal)
	sta nmictrl
	pla
	tay
	iny
	cpy #tilesahead
	bne :-
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
	
	ldy #<init_palette
	sty paladdr
	ldy #>init_palette
	sty paladdr+1
	jsr load_palette  ; load game palette into palette RAM
	
	lda #$20
	jsr clear_nt
	lda #$24
	jsr clear_nt
	
@clearDone:
	
	lda #0
	sta ntwrhead
	sta arwrhead
	asl
	asl
	asl
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
	and #(gs_scrstodR|gs_scrstopR)
	ora #gs_1stfr
	sta gamectrl
	
	lda nmictrl
	and #((nc_flushcol|nc_flshpalv|nc_flushrow|nc_flushpal)^$FF)
	ora #nc_turnon
	sta nmictrl
	
	jsr vblank_wait
	jmp gm_game_update

; ** GAMEMODE: gamemode_game
gamemode_game:
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	lda camera_y_hi
	sta camera_y_ho
	
	jsr gm_clear_palette_allocator
	jsr gm_update_game_cont
	jsr gm_check_climb_input
	inc framectr
	lda scrollsplit
	beq :+
	jsr gm_calc_camera_split ; calculate the position of the camera so that the IRQ can pick it up
:	jsr gm_physics
	jsr gm_anim_player
	jsr gm_anim_banks
	jsr gm_draw_player
	jsr gm_unload_os_ents
	jsr gm_draw_entities
	jsr gm_update_ptstimer
	jsr gm_draw_dead
	jsr gm_update_dialog
	jsr gm_load_level_if_vert
	
	; note: by this point, palettes should have been calculated.
	jsr gm_check_updated_palettes
	
	; note: at this point, camera positioning should have been calculated.
	; calculate the position of the camera so that the NMI can pick it up
	; if scrollsplit is not zero then it was already calculated for the IRQ
	lda scrollsplit
	bne @dontCalcNoSplit
	jsr gm_calc_camera_nosplit
@dontCalcNoSplit:

	; here, handle pause input, etc.
	rts

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
	sta game_cont
	lda p1_cont+1
	sta game_cont+1
	lda p1_conto
	sta game_conto
	lda p1_conto+1
	sta game_conto+1
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

; ** SUBROUTINE: gm_game_clear_wx
; desc: Clears game variables with the X register.
gm_game_clear_wx:
	;stx gamectrl2
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
	stx camera_x_pg
	stx lvladdr
	stx lvladdrhi
	stx playerctrl
	stx player_vl_x
	stx player_vs_x
	stx player_vl_y
	stx player_vs_y
	stx dashtime
	stx dashcount
	stx animmode
	stx jumpbuff
	stx jumpcoyote
	stx wjumpcoyote
	stx roombeglo
	stx roombeghi
	stx roombeglo2
	jsr gm_clear_aux
	
	lda #<~g3_transitX
	and gamectrl3
	sta gamectrl3
	
	; before waiting on vblank, clear game reserved spaces ($0300 - $0700)
	; note: ldx #$00 was removed because it's already 0!
	txa
:	sta $200,x
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
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
	sta gamectrl2
	rts

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
	jsr gm_unload_os_ents
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
	.byte $04, $00, $FD, $24 ; U--R
	.byte $FD, $24, $FD, $24 ; U-L-
	.byte $FD, $24, $FD, $24 ; U-LR

	.byte $00, $00, $00, $00 ; UD--
	.byte $04, $00, $00, $00 ; UD-R
	.byte $FC, $00, $00, $00 ; UDL-
	.byte $FC, $00, $00, $00 ; UDLR

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
