; Copyright (C) 2024 iProgramInCpp

; This code belongs in the MAIN segment and is an
; interface to things in the PRG_XTRA bank.

gm_leaveroomR:
	lda #<gm_leaveroomR_FAR
	sta temp1
	lda #>gm_leaveroomR_FAR
	sta temp1+1
	ldy #prgb_xtra
	jmp far_call

gm_leaveroomU:
	lda #<gm_leaveroomU_FAR
	sta temp1
	lda #>gm_leaveroomU_FAR
	sta temp1+1
	ldy #prgb_xtra
	jmp far_call

gm_gener_tiles_below:
	lda #<gm_gener_tiles_below_FAR
	sta temp1
	lda #>gm_gener_tiles_below_FAR
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
	
	lda currA000bank
	pha
	
	ldy musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
	txa
	tay                 ; restore room # in X
	jsr gm_set_room
	
	pla
	tay
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back

x_gener_mts_ents_r_fixed:
	jsr h_gener_ents_r
	jmp h_gener_mts_r
