; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: prepare_vmcpy_fade
; desc: Set the video memory copy operation's address to the temprow1 array's,
;       set the count to 32, set the dest to $3F00, and return zero.
.proc prepare_vmcpy_fade
	lda #32
	sta vmccount
	lda #<temprow1
	sta vmcsrc
	lda #>temprow1
	sta vmcsrc+1
	lda #$3F
	sta vmcaddr+1
	lda #$00
	sta vmcaddr
	rts
.endproc

; ** SUBROUTINE: fade_in
; desc: Fades in to a palette.
; parameters: paladdr - The palette to fade into
.proc fade_in
	jsr copyPalette
	
	; set up the video memory copy addresses
	jsr prepare_vmcpy_fade
	
	sta scroll_x
	sta scroll_y
	sta ppu_mask
	sta tempmaskover
	
	jsr vblank_wait
	
	ldx #24
@loop:
	stx transtimer
	txa
	and #%00000111
	bne @dontfade
	
	jsr copyPalette
	cpx #%00001000
	beq @fade0x
	cpx #%00010000
	beq @fade1x
	;   #%00011000 -- fade2x
	
@fade2x:
	jsr fadeTempRow
@fade1x:
	jsr fadeTempRow
@fade0x:
	jsr requestPush
@dontfade:
	
	; Well, as it turns out, we have to do it the dumb way.
	; We need to prepare ppuaddrHR1, ppuaddrHR2
	
	; every 4 frames, determine whether the emphasis bits are set
	ldy #0
	lda transtimer
	sec
	sbc #1
	and #%00000100
	beq :+
	ldy #%11100000
:	sty tempmaskover
	lda nmictrl
	ora #nc_turnon
	sta nmictrl
	
	jsr waitOneFrame
	
	ldx transtimer
	dex
	
	cpx #0
	bne @loop
	
	jsr copyPalette
	jsr requestPush
	jmp waitOneFrame

fadeTempRow:
	ldx #0
:	lda temprow1, x
	jsr fade_twice_if_high
	sta temprow1, x
	inx
	cpx #32
	bne :-
	;rts

requestPush:
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
	rts

copyPalette:
	ldy #31
@loopCopy:
	lda (paladdr), y
	sta temprow1, y
	dey
	bpl @loopCopy ; it has to go to $FF first
	rts

waitOneFrame:
	jsr soft_nmi_on
	jsr nmi_wait
	jmp soft_nmi_off
.endproc

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
	jsr prepare_vmcpy_fade
	
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
