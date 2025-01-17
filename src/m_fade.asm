; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: fade_out
; desc: Fades to black.  This is a synchronous routine.
.proc fade_out
	; The palette will be copied to temprow1.
	
	ldy #31
@loopCopy:
	lda (paladdr), y
	sta temprow1, y
	dey
	bpl @loopCopy ; it has to go to $FF first
	
	; then set up the video memory copy addresses
	lda #<temprow1
	sta vmcsrc
	lda #>temprow1
	sta vmcsrc+1
	lda #$3F
	sta vmcaddr+1
	lda #$00
	sta vmcaddr
	lda #32
	sta vmccount
	
	; it will take us thirty-two frames to do the fade out.
	ldy #31
@loopFadeOut:
	sty transtimer
	
	tya
	and #%00000111
	bne @dontFadePalette
	
	ldx #0
:	lda temprow1, x
	jsr fade_twice_if_high
	sta temprow1, x
	inx
	cpx #32
	bne :-
	
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
	
@dontFadePalette:
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	
	ldy transtimer
	dey
	
	; every 4 frames, determine whether the emphasis bits are set
	ldx #def_ppu_msk
	tya
	and #%00000100
	bne :+
	ldx #(def_ppu_msk | %11100000)
:	stx ppu_mask
	
	cpy #0
	bne @loopFadeOut
	
	; everything is black, also disable rendering
	
	lda #0
	sta ppu_mask
	
	; the fade out is complete - everything's black now
	; and rendering is disabled
	rts
.endproc
