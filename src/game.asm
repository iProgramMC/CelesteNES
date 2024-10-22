; Copyright (C) 2024 iProgramInCpp

.include "g_level.asm"
.include "g_rmtran.asm"
.include "e_draw.asm"
.include "e_update.asm"
.include "e_physic.asm"
.include "e_spawn.asm"
.include "p_draw.asm"
.include "p_physic.asm"
.include "g_sfx.asm"

; ** SUBROUTINE: gm_update_ptstimer
gm_update_ptstimer:
	lda ptstimer
	beq :+            ; if ptstimer != 0, then just decrement it
	dec ptstimer
	rts
:	lda #0            ; if they're both 0, reset the points count and return
	sta ptscount
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
	
	stx gamectrl2
	jsr gm_game_clear_wx
	jmp @clearDone
	
@clearAll:
	stx gamectrl2
	jsr gm_game_clear_all_wx
	
	jsr vblank_wait
	ldy #<init_palette
	jsr load_palette  ; load game palette into palette RAM
	lda #$20
	jsr clear_nt      ; clear the two nametables the game uses
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
	
	jsr h_gener_ents_r
	jsr h_gener_mts_r
	ldy #$00          ; generate tilesahead columns
:	tya
	pha
	jsr h_gener_col_r
	jsr h_flush_col_r
	jsr h_flush_pal_r_cond
	pla
	tay
	iny
	cpy #tilesahead
	bne :-
	
	lda gamectrl
	and #(gs_scrstodR|gs_scrstopR)
	ora #(gs_1stfr|gs_turnon)
	sta gamectrl
	jsr vblank_wait
	jmp gm_game_update

; ** GAMEMODE: gamemode_game
gamemode_game:
	inc framectr
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	jsr gm_physics
	jsr gm_anim_player
	jsr gm_draw_player
	jsr gm_unload_os_ents
	jsr gm_draw_entities
	jsr gm_allocate_palettes
	jsr gm_update_ptstimer
	jsr gm_draw_dead
	
	lda #cont_select
	bit p1_cont
	bne gm_titleswitch
	jmp game_update_return

; ** SUBROUTINE: gm_titleswitch
gm_titleswitch:
	lda #gm_title
	sta gamemode
	lda #0
	sta titlectrl
	jmp game_update_return

; ** SUBROUTINE: gm_game_clear_all_wx
; desc: Clears ALL game variables with the X register.
;       Unlike gm_game_clear_all_wx, this clears data that's necessary across,
;       for example, respawn transitions.
gm_game_clear_all_wx:
	stx lvlyoff

; ** SUBROUTINE: gm_game_clear_wx
; desc: Clears game variables with the X register.
gm_game_clear_wx:
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
	stx player_x_hi
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
	stx plrtrahd
	stx plrstrawbs
	dex
	stx animmode      ; set to 0xFF
	inx
	
	; before waiting on vblank, clear game reserved spaces ($0300 - $0700)
	; note: ldx #$00 was removed because it's already 0!
	txa
gm_game_clear:
	sta $200,x
	sta $300,x
	sta $400,x
	sta $500,x
	sta $700,x
	inx
	bne gm_game_clear
	rts
