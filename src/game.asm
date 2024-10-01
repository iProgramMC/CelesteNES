; Copyright (C) 2024 iProgramInCpp

.include "g_level.asm"
.include "g_rmtran.asm"
.include "e_draw.asm"
.include "e_update.asm"
.include "e_spawn.asm"
.include "p_draw.asm"
.include "p_physic.asm"

; ** SUBROUTINE: gamemode_init
gm_game_init:
	ldx #$FF
	stx animmode
	inx
	stx ppu_mask      ; disable rendering
	jsr gm_game_clear_all_wx
	jsr vblank_wait
	lda #$20
	jsr clear_nt      ; clear the two nametables the game uses
	lda #$24
	jsr clear_nt
	ldy #(init_palette - lastpage)
	jsr load_palette  ; load game palette into palette RAM
	jsr gm_set_level_1
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
	
	lda #(gs_1stfr|gs_turnon)
	sta gamectrl
	jsr vblank_wait
	jmp gm_game_update

; ** GAMEMODE: gamemode_game
gamemode_game:
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	jsr gm_physics
	jsr gm_anim_player
	jsr gm_draw_player
	jsr gm_draw_dead
	jsr gm_unload_os_ents
	jsr gm_draw_entities
	jsr gm_allocate_palettes
	
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

dashX:
	.byte $00  ; --
	.byte $04  ; -R
	.byte $FC  ; L-
	.byte $FC  ; LR
dashY:
	.byte $00  ; --
	.byte $05  ; -D
	.byte $FB  ; U-
	.byte $00  ; UD

; ** SUBROUTINE: gm_game_clear_all_wx
; desc: Clears ALL game variables with the X register.
;       Unlike gm_game_clear_all_wx, this clears data that's necessary across,
;       for example, respawn transitions.
gm_game_clear_all_wx:
	stx transoff
	stx lvlyoff

; ** SUBROUTINE: gm_game_clear_wx
; desc: Clears game variables with the X register.
gm_game_clear_wx:
	stx gamectrl      ; clear game related fields to zero
	stx ntwrhead
	stx arwrhead
	stx player_y
	stx player_sp_x
	stx player_sp_y
	stx camera_x
	stx camera_y
	stx camera_x_hi
	stx camera_x_pg
	stx player_x_hi
	stx tr_scrnpos
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
	
	; before waiting on vblank, clear game reserved spaces ($0300 - $0700)
	; note: ldx #$00 was removed because it's already 0!
gm_game_clear:
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
	inx
	bne gm_game_clear
