; Copyright (C) 2024-2025 iProgramInCpp

.include "g_level.asm"
.include "e_draw.asm"
.include "e_update.asm"
.include "e_physic.asm"
.include "e_spawn.asm"
.include "g_physic.asm"
.include "g_palloc.asm"
.include "g_wipe.asm"
.include "g_sfx.asm"
.include "g_save.asm"
.include "g_camera.asm"
.include "g_wait.asm"
.include "g_control.asm"
.include "g_pause.asm"
.include "g_draw.asm"
.include "g_respawn.asm"
.include "g_util.asm"
.include "g_palette.asm"
.include "g_math.asm"
.include "xtraif.asm"

; ** SUBROUTINE: gm_update_ptstimer
gm_update_ptstimer:
	lda ptstimer
	beq :+            ; if ptstimer != 0, then just decrement it
	dec ptstimer
	rts
:	sta ptscount      ; if it's 0, also reset the points count and return
	rts

; ** SUBROUTINE: gm_load_room_fully
gm_load_room_fully:
	jsr x_gener_mts_ents_r_fixed ; calls h_gener_ents_r and h_gener_mts_r
	
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
	
	lda gamectrl2
	and #g2_noclrall
	pha               ; the stack will now contain a flag whether or not we respawned here or just started
	beq @clearAll     ; we will have to play "hot potato" with it for a bit.
	
	; if we just respawned, call just clear_wx, and skip the rest of the code
	jsr gm_game_clear_wx
	; note: gm_game_clear_wx ends with com_clear_oam which returns with ZF set
	beq @clearDone
	
@clearAll:
	jsr gm_game_clear_all_wx
	
	lda #$20
	jsr clear_nt
	lda #$24
	jsr clear_nt
	
@clearDone:
	lda rm_paloffs
	asl
	asl
	sta lvlyoff
	sta old_lvlyoff
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
	and #((nc_flushcol|nc_flshpalv|nc_flushrow|nc_flushpal|nc_turnon)^$FF)
	; do not instantly turn on the screen if we're respawning. Let that routine handle it
	; also don't instantly turn on if we just arrived in here. Let the fade_in routine handle it
	sta nmictrl
	
	jsr gm_update_bg_bank
	
	; pull the "have we just respawned here?" flag? if it's false, then fade in
	pla
	bne :+
	
	jsr gm_calc_camera_nosplit
	lda #0
	sta fadeupdrt+1
	lda #16
	jsr fade_in_smaller_palette
	
:	; check if we should restart the music
	lda levelnumber
	bne @notPrologue
	
	lda dbenable
	beq @notPrologue
	
	lda #0
	jsr aud_play_music_by_index
	lda #1
	sta dbenable
	
@notPrologue:
	jsr gm_copyplayerpostodeath
	jmp gm_game_update

; ** GAMEMODE: gamemode_game
gamemode_game:
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	inc framectr
	jsr gm_update_game_cont
	jsr gm_check_pause
	
	lda paused
	bne @gamePaused
	
	jsr gm_draw_respawn
	
	lda camera_y_hi
	sta camera_y_ho
	
	jsr gm_clear_palette_allocator
	jsr gm_update_lift_boost
	jsr gm_check_climb_input
	jsr gm_clear_collided
	jsr gm_physics
	jsr gm_anim_and_draw_player
	jsr gm_draw_dead
	jsr gm_unload_os_ents
	jsr gm_draw_entities
	jsr gm_update_ptstimer
	jsr gm_update_dialog
	
	lda rununimport
	bne @dontRunUnimportant
	
	jsr gm_load_level_if_vert
	jsr gm_check_level_banks
	jsr gm_update_bg_effects
	
@dontRunUnimportant:
	; note: by this point, palettes should have been calculated.
	jsr gm_check_updated_palettes
	
	; note: at this point, camera positioning should have been calculated.
	; calculate the position of the camera so that the NMI can pick it up
	; if scrollsplit is not zero then it was already calculated for the IRQ
	lda scrollsplit
	bne @dontCalcNoSplit
	jsr gm_calc_camera_nosplit
	
@dontCalcNoSplit:
	; if an exit to map is requested, so be it
	lda exitmaptimer
	cmp #1
	bne @returnDontExit
	
	lda #0
	sta fadeupdrt+1
	jsr fade_out
	
	lda gamectrl2
	and #g2_exitlvl
	bne @justReturnToOverworld
	
	jsr gm_level_end
	
	lda levelnumber
	bne @justReturnToOverworld
	
	; return to the prologue with a special message.
	lda #gm_prologue
	sta gamemode
	lda #ps_candoit
	sta gamestate
	bne @returnDontExit
	
@justReturnToOverworld:
	; NOTE: this is redundant in case that g2_exitlvl isn't set
	jsr save_file_flush_berries
	
@returnToOverworld:
	lda #gm_overwld
	sta gamemode
	lda #0
	sta gamestate
	
@returnDontExit:
	lda exitmaptimer
	beq :+
	dec exitmaptimer
:	rts

@gamePaused:
	; game is paused.
	lda #<pause_update
	sta farcalladdr
	lda #>pause_update
	sta farcalladdr+1
	lda #mmc3bk_prg1
	ldy #prgb_paus
	jmp far_call

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
	stx old_lvlyoff
	stx dbenable
	stx gamectrl2
	stx gamectrl3
	stx deaths+0
	stx deaths+1
	stx strawberries+0
	stx strawberries+1
	stx strawberries+2
	stx strawberries+3

; ** SUBROUTINE: gm_game_clear_wx
; desc: Clears game variables with the X register.
gm_game_clear_wx:
	stx scrollsplit
	stx dialogsplit
	stx miscsplit
	stx deathwipe
	stx deathwipe2
	stx irqtmp1
	stx irqtmp2
	stx irqtmp3
	stx irqtmp4
	stx irqtmp5
	stx irqtmp6
	stx irqtmp7
	stx irqtmp8
	stx abovescreen
	stx pauseanim
	stx game_cont_force
	stx game_cont_force+1
	stx amodeforce
	stx advtracesw
	stx starsbgctl
	stx exitmaptimer
	stx dlg_cutsptr
	stx dlg_cutsptr+1
	stx ntwrhead
	stx arwrhead
	stx camera_x
	stx gamectrl      ; clear game related fields to zero
	stx retain_timer
	;stx bgcurroffs
	
	txa
	ldy #<zero_on_respawn_zp_begin
:	sta $00, y
	iny
	cpy #<zero_on_respawn_zp_end
	bne :-
	
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
	
	jsr gm_reset_stamina
	
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
