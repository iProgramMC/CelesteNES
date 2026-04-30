; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: fade_in
; desc: Fades in to a palette.
; parameters: paladdr - The palette to fade into
; NOTE: clobbers temp12
.proc fade_in
	lda #32
	; fall through
.endproc

; ** SUBROUTINE: fade_in_smaller_palette
; desc: Fades in to a palette.
; parameters: paladdr - The palette to fade into
;             A reg - The size of the palette.
; NOTE: clobbers temp12
.proc fade_in_smaller_palette
	sta temp12
	ldx #<fade_in_kludge
	ldy #>fade_in_kludge
	lda #prgb_xtra
	jmp far_call2

fade_in_kludge:
	lda temp12
	jmp u_fade_in_smaller_palette
.endproc

.proc fade_out
	ldx #<u_fade_out
	ldy #>u_fade_out
	lda #prgb_xtra
	jmp far_call2
.endproc

.proc fade_reset_pal_upds
	lda nmictrl2
	and #<~nc2_updpal1|nc2_updpal2|nc2_updpal3
	sta nmictrl2
	rts
.endproc
