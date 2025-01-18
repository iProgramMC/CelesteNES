; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: fade_prepare_vmcpy
; desc: Set the video memory copy operation's address to the temprow1 array's,
;       set the count to 32, set the dest to $3F00, and return zero.
.proc fade_prepare_vmcpy
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

; ** SUBROUTINE: fade_copy_palette
; desc: Copies the selected palette from [paladdr] to temprow1.
.proc fade_copy_palette
	ldy vmccount
	dey
@loopCopy:
	lda (paladdr), y
	sta temprow1, y
	dey
	bpl @loopCopy ; it has to go to $FF first
	rts
.endproc

; ** SUBROUTINE: fade_in
; desc: Fades in to a palette.
; parameters: paladdr - The palette to fade into
.proc fade_in
	lda #32
differentPaletteSize:
	sta vmccount
	inc fade_active
	jsr fade_copy_palette
	jsr fade_prepare_vmcpy
	
	sta ppu_mask
	sta tempmaskover
	
	jsr vblank_wait
	
	ldx #24
@loop:
	stx transtimer
	txa
	and #%00000111
	bne @dontfade
	
	jsr fade_copy_palette
	cpx #%00001000
	beq @fade0x
	cpx #%00010000
	beq @fade1x
	;   #%00011000 -- fade2x
	
@fade2x:
	jsr fade_fade_temp_row
@fade1x:
	jsr fade_fade_temp_row
@fade0x:
	jsr fade_set_vmc_flag
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
	
	jsr fade_wait_one_frame
	
	ldx transtimer
	dex
	
	cpx #0
	bne @loop
	
	jsr fade_copy_palette
	jsr fade_set_vmc_flag
	dec fade_active
	jmp fade_wait_one_frame
.endproc

fade_in_smaller_palette := fade_in::differentPaletteSize

; ** SUBROUTINE: fade_fade_temp_row
; desc: Fades all colors inside temprow1.
.proc fade_fade_temp_row
	ldx #0
:	lda temprow1, x
	jsr fade_twice_if_high
	sta temprow1, x
	inx
	cpx vmccount
	bne :-
	rts
.endproc

; ** SUBROUTINE: fade_set_vmc_flag
; desc: Requests a video memory copy operation.
.proc fade_set_vmc_flag
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
	rts
.endproc

; ** SUBROUTINE: fade_wait_one_frame
; desc: Waits a single frame.
.proc fade_wait_one_frame
	jsr soft_nmi_on
	jsr nmi_wait
	jmp soft_nmi_off
.endproc

; ** SUBROUTINE: fade_out
; desc: Fades to black.  This is a synchronous routine.
.proc fade_out
	lda #32
	sta vmccount
	inc fade_active
	jsr fade_prepare_vmcpy
	jsr fade_copy_palette
	
	; it will take us 31 frames to do the fade out.
	ldy #31
@loopFadeOut:
	sty transtimer
	
	tya
	and #%00000111
	bne @dontFadePalette
	
	jsr fade_fade_temp_row
	jsr fade_set_vmc_flag
	
@dontFadePalette:
	jsr fade_wait_one_frame
	
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
	
	sty ppu_mask
	
	; the fade out is complete - everything's black now
	; and rendering is disabled
	dec fade_active
	rts
.endproc
