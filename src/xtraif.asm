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
