; Copyright (C) 2025 iProgramInCpp

; This bank relates itself to Player Physics.
.segment "PRG_PHYS"

.include "p_physic.asm"
.include "p_trace.asm"
.include "p_scroll.asm"

.proc ph_leaveroomU
	ldx #<gm_leaveroomU_FAR
	ldy #>gm_leaveroomU_FAR
	lda #prgb_xtra
	jmp far_call2
.endproc

.proc ph_leaveroomD
	ldx #<gm_leaveroomD_FAR
	ldy #>gm_leaveroomD_FAR
	lda #prgb_xtra
	jmp far_call2
.endproc

.proc ph_leaveroomL
	ldx #<gm_leaveroomL_FAR
	ldy #>gm_leaveroomL_FAR
	lda #prgb_xtra
	jsr far_call2
	lda temp12
	rts
.endproc

.proc ph_leaveroomR
	ldx #<gm_leaveroomR_FAR
	ldy #>gm_leaveroomR_FAR
	lda #prgb_xtra
	jmp far_call2
.endproc
