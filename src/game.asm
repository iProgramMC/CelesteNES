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
	
	jsr test_dialog
	
	; note: by this point, palettes should have been calculated.
	jsr gm_check_updated_palettes
	
	; note: at this point, camera positioning should have been calculated.
	; calculate the position of the camera so that the NMI can pick it up
	; if scrollsplit is not zero then it was already calculated for the IRQ
	lda scrollsplit
	bne :+
	jsr gm_calc_camera_nosplit
:

	;lda #cont_start
	;bit p1_cont
	;bne gm_titleswitch
	rts

; ** SUBROUTINE: gm_titleswitch
;gm_titleswitch:
;	bit p1_conto
;	bne @earlyReturn
;	
;	lda scrollsplit
;	eor #80
;	sta scrollsplit
;
;	lda #gm_title
;	sta gamemode
;	lda #0
;	sta titlectrl
;@earlyReturn:
;	rts

test_dialog:
	lda #cont_select
	bit p1_cont
	beq :+
	
	bit p1_conto
	bne :+
	
	lda #0
	ldx #<ch0_granny
	ldy #>ch0_granny
	jsr dlg_begin_cutscene_g

:	rts

; ** SUBROUTINE: gm_update_dialog
; desc: Updates the active dialog if needed.
gm_update_dialog:
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
	stx gamectrl2
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
	stx camleftlo
	stx camlefthi
	stx plrtrahd
	stx plrstrawbs
	stx scrollsplit
	stx dialogsplit
	stx camera_y_sub
	dex
	stx animmode      ; set to 0xFF
	inx
	
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
	
	ldy #0
:	sta spritepals, y
	iny
	cpy #9
	bne :-
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
	
	; scroll X/Y high
	lda #0
	ldx camera_x_hi
	beq :+
	ora #pctl_highx
:	ldx camera_y_hi
	beq :+
	ora #pctl_highy
:	sta scroll_flags
	rts

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
	
	; scroll X/Y high
	lda camera_x_hi
	sta temp1
	lda camera_y_hi
	sta temp2
	
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
	lda #0
	ldx temp1
	beq :+
	ora #pctl_highx
	
:	ldx temp2
	beq :+
	ora #pctl_highy
	
:	sta scroll_flags
	rts
	
@carryIsSet:
	; carry was set
	adc #$0F   ; add +$10
	sta scroll_y
	; TODO: carry might be set again. I don't think it matters right now
	; but if you set scrolllimit to > like 80, then look here first.
	jmp @flipHighBitAndDone

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
