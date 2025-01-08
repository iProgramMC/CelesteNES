; Copyright (C) 2024 iProgramInCpp

; This code belongs in the MAIN segment and is an
; interface to things in the PRG_XTRA bank.

.proc xt_gener_col_r
	lda #<h_gener_col_r
	sta farcalladdr
	lda #>h_gener_col_r
	sta farcalladdr+1
	ldy lvldatabank
	jmp far_call
.endproc

.proc xt_palette_data_column
	lda #<h_palette_data_column
	sta farcalladdr
	lda #>h_palette_data_column
	sta farcalladdr+1
	ldy lvldatabank
	jmp far_call
.endproc

.proc xt_gener_tiles_below
	lda #<gm_gener_tiles_below
	sta farcalladdr
	lda #>gm_gener_tiles_below
	sta farcalladdr+1
	ldy lvldatabank
	jmp far_call
.endproc

.proc xt_gener_tiles_above
	lda #<gm_gener_tiles_above
	sta farcalladdr
	lda #>gm_gener_tiles_above
	sta farcalladdr+1
	ldy lvldatabank
	jmp far_call
.endproc

.proc xt_gener_mts_ents_r
	lda #<x_gener_mts_ents_r_fixed
	sta farcalladdr
	lda #>x_gener_mts_ents_r_fixed
	sta farcalladdr+1
	ldy lvldatabank
	jmp far_call
.endproc

.proc xt_leave_doframe
	lda #<gm_leave_doframe
	sta farcalladdr
	lda #>gm_leave_doframe
	sta farcalladdr+1
	ldy lvldatabank
	jmp far_call
.endproc

.proc xt_gener_row_u
	lda #<h_gener_row_u
	sta farcalladdr
	lda #>h_gener_row_u
	sta farcalladdr+1
	ldy lvldatabank
	jmp far_call
.endproc

.proc xt_set_room
	tya
	tax                 ; save room # in X
	
	ldy lvldatabank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
	txa
	tay                 ; restore room # in X
	jsr gm_set_room
	
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back
.endproc

.proc x_gener_mts_ents_r_fixed
	jsr h_gener_ents_r
	jmp h_gener_mts_r
.endproc

.proc gm_draw_player
	ldx #<sgm_draw_player
	ldy #>sgm_draw_player
	lda #prgb_paus
	jmp far_call2
.endproc

.proc gm_anim_and_draw_player
	ldx #<sgm_anim_and_draw_player
	ldy #>sgm_anim_and_draw_player
	lda #prgb_paus
	jmp far_call2
.endproc

.proc sgm_anim_and_draw_player
	jsr sgm_anim_player
	jsr sgm_anim_banks
	jmp sgm_draw_player
.endproc

; generate palette data for vertical transition
xt_generate_palette_data_V:
@loadCount := trantmp5
	ldy lvldatabank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
	; pre-generate all palette data
	ldy #0
@palloop:
	sty temp6
	
	lda ntwrhead
	pha
	tya
	asl
	asl
	clc
	adc ntwrhead
	sta ntwrhead
	
	jsr h_palette_data_column
	
	pla
	sta ntwrhead
	
	; an inner loop to copy from temppal to loadedpals
	lda temp6
	asl
	asl
	asl
	tax
	ldy #0
	
:	lda temppal, y
	sta loadedpals, x
	inx
	iny
	cpy #8
	bne :-
	
	ldy temp6
	iny
	cpy @loadCount
	bne @palloop
	
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back
