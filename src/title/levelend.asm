; Copyright (C) 2025 iProgramInCpp

; This module implements the Chapter Complete screen at the end of each stage.
.include "endgfx.asm"

; ** SUBROUTINE: level_end
; desc: Play the level end cutscene.
; parameters:
;	levelnumber - The level number to play the end cutscene for.
.proc level_end
	ldy levelnumber
	lda level_end_gfx_hi, y
	bne @continue
	
	rts

@continue:
	; prepare the graphics and init the fade
	jsr soft_nmi_off
	
	lda #0
	sta scroll_x
	sta scroll_y
	sta scroll_flags
	
	; disable rendering
	jsr vblank_wait
	sta ppu_mask
	
	ldy levelnumber
	lda level_end_pal_lo, y
	sta paladdr
	lda level_end_pal_hi, y
	sta paladdr+1
	
	; decompress the data
	lda #$20
	sta ppu_addr
	lda #$00
	sta ppu_addr
	
	lda level_end_gfx_hi, y
	tax
	lda level_end_gfx_lo, y
	jsr nexxt_rle_decompress
	
	; TODO do we even need this?
	lda #$23
	sta ppu_addr
	lda #$C0
	sta ppu_addr
	
	ldy levelnumber
	lda level_end_attr_lo, y
	sta lvladdr
	lda level_end_attr_hi, y
	sta lvladdr+1
	
	ldy #0
:	lda (lvladdr), y
	sta ppu_data
	iny
	cpy #64
	bne :-
	
	jsr com_clear_oam
	
	; load the sprites now
	ldx levelnumber
	
	ldy level_end_bank_spr, x
	sty spr0_bknum
	iny
	sty spr1_bknum
	
	lda level_end_oam_sz, x
	sta temp11
	
	lda level_end_oam_lo, x
	sta lvladdr
	lda level_end_oam_hi, x
	sta lvladdr+1
	
	ldy #0
:	lda (lvladdr), y
	sta oam_buf, y
	iny
	cpy temp11
	bne :-
	
	jsr level_end_fade_update
	
	ldy levelnumber
	lda level_end_bank_h2, y
	sta bg0_bkspl
	lda level_end_bank_h1, y
	sta bg0_bknum
	clc
	adc #2
	sta bg1_bknum
	
	lda #>level_end_fade_update
	sta fadeupdrt+1
	lda #<level_end_fade_update
	sta fadeupdrt
	jsr fade_in
	
@wait:
	jsr level_end_fade_update
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	jmp @wait
	
	lda #<irq_idle
	sta irqaddr
	lda #>irq_idle
	sta irqaddr+1
	lda #0
	sta miscsplit
@return:
	rts
.endproc

level_end_gfx_lo:	.byte 0,<level_end_ch1,<level_end_ch2
level_end_gfx_hi:	.byte 0,>level_end_ch1,>level_end_ch2

level_end_bank_h1:	.byte 0, chrb_lvl1ca, chrb_lvl2ca
level_end_bank_h2:	.byte 0, chrb_lvl1cb, chrb_lvl2cb
level_end_bank_spr:	.byte 0, chrb_spl1co, chrb_spl2co

level_end_pal_lo:	.byte 0,<level_end_ch1_pal,<level_end_ch2_pal
level_end_pal_hi:	.byte 0,>level_end_ch1_pal,>level_end_ch2_pal

level_end_attr_lo:	.byte 0,<level_end_ch1_attr,<level_end_ch2_attr
level_end_attr_hi:	.byte 0,>level_end_ch1_attr,>level_end_ch2_attr

level_end_oam_lo:	.byte 0,<level_end_ch1_oam,<level_end_ch2_oam
level_end_oam_hi:	.byte 0,>level_end_ch1_oam,>level_end_ch2_oam
level_end_oam_sz:	.byte 0, level_end_ch1_oam_end-level_end_ch1_oam, level_end_ch2_oam_end-level_end_ch2_oam

.proc level_end_fade_update
	; set up the IRQ
	sei
	lda #<level_end_irq
	sta irqaddr
	lda #>level_end_irq
	sta irqaddr+1
	; it's (almost) cleanly split down line 136
	; due to this "almost" clean split you should ensure that that row
	; has the same tiles in both banks, like I have.
	lda #136
	sta miscsplit
	cli
	rts
.endproc

.proc level_end_irq
	pha
	txa
	pha
	sta mmc3_irqdi
	
	; set the bg0 bank
	ldx #mmc3bk_bg0 | def_mmc3_bn
	lda bg0_bkspl
	
	stx mmc3_bsel
	sta mmc3_bdat
	
	; also the bg1 bank
	inx
	clc
	adc #2
	stx mmc3_bsel
	sta mmc3_bdat
	
	lda mmc3_shadow
	sta mmc3_bsel
	
	; TODO: we may need to show other things so schedule yet another irq later.
	pla
	tax
	pla
	rti
.endproc
