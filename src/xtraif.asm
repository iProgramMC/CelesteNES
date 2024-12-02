; Copyright (C) 2024 iProgramInCpp

; This code belongs in the MAIN segment and is an
; interface to things in the PRG_XTRA bank.

gm_leaveroomR:
	lda temp1
	pha
	lda temp2
	pha
	
	lda #<gm_leaveroomR_FAR
	sta temp1
	lda #>gm_leaveroomR_FAR
	sta temp1+1
	ldy #prgb_xtra
	jsr far_call
	
	pla
	sta temp2
	pla
	sta temp1
	rts

gm_leaveroomU:
	lda #<gm_leaveroomU_FAR
	sta temp1
	lda #>gm_leaveroomU_FAR
	sta temp1+1
	ldy #prgb_xtra
	jmp far_call

xt_gener_col_r:
	lda #<h_gener_col_r
	sta temp1
	lda #>h_gener_col_r
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_gener_tiles_below:
	lda #<gm_gener_tiles_below
	sta temp1
	lda #>gm_gener_tiles_below
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_gener_tiles_above:
	lda #<gm_gener_tiles_above
	sta temp1
	lda #>gm_gener_tiles_above
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_gener_mts_ents_r:
	lda #<x_gener_mts_ents_r_fixed
	sta temp1
	lda #>x_gener_mts_ents_r_fixed
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_leave_doframe:
	lda #<gm_leave_doframe
	sta temp1
	lda #>gm_leave_doframe
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_gener_row_u:
	lda #<h_gener_row_u
	sta temp1
	lda #>h_gener_row_u
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_set_room:
	tya
	tax                 ; save room # in X
	
	ldy musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
	txa
	tay                 ; restore room # in X
	jsr gm_set_room
	
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back

x_gener_mts_ents_r_fixed:
	jsr h_gener_ents_r
	jmp h_gener_mts_r

; generate palette data for vertical transition
xt_generate_palette_data_V:
	ldy musicbank
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
	cpy #8
	bne @palloop
	
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back
