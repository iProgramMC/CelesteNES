; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: fade_in
; desc: Fades in to a palette with the default speed.
; parameters: paladdr - The palette to fade into
; NOTE: clobbers temp12
.proc fade_in
	lda #1
	sta fadeinspeed
	lda #32
	; fall through
.endproc

; ** SUBROUTINE: fade_in_smaller_palette
; desc: Fades in to a palette with a smaller palette and the default speed.
; parameters: paladdr - The palette to fade into
;             A reg - The size of the palette.
; NOTE: clobbers temp12
.proc fade_in_smaller_palette
	ldx #1
	; fall through
.endproc

; ** SUBROUTINE: fade_in_smaller_palette_and_speed
; desc: Fades in to a palette.
; parameters: paladdr - The palette to fade into
;             A reg - The size of the palette.
;             X reg - The speed of the fadein.
; NOTE: clobbers temp12
.proc fade_in_smaller_palette_and_speed
	sta temp12
	stx fadeinspeed
	ldx #<fade_in_kludge
	ldy #>fade_in_kludge
	lda #prgb_xtra
	jmp far_call2

fade_in_kludge:
	lda temp12
	jmp u_fade_in_smaller_palette_and_speed
.endproc

; ** SUBROUTINE: fade_out
; desc: Initiates a fadeout at the default speed.
.proc fade_out
	ldx #1
.endproc

; ** SUBROUTINE: fade_out_speed
; desc: Initiates a fadeout at a custom speed.  Default is 1, for that, call fade_out.
; parameters: X register - The fade out speed.
.proc fade_out_speed
	stx fadeinspeed
	ldx #<u_fade_out_speed
	ldy #>u_fade_out_speed
	lda #prgb_xtra
	jmp far_call2
.endproc

.proc fade_reset_pal_upds
	lda nmictrl2
	and #<~nc2_updpal1|nc2_updpal2|nc2_updpal3
	sta nmictrl2
	rts
.endproc
