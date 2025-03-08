; Copyright (C) 2025 iProgramInCpp

; This module implements the Chapter Complete screen at the end of each stage.
.include "endgfx.asm"

; ** SUBROUTINE: level_end_rain_init
; desc: Initializes the particles for the raining part of the cutscene.
.proc level_end_rain_init
	ldx #0
@loop:
	jsr rand
	sta plr_trace_x, x
	jsr rand
	sta plr_trace_y, x
	inx
	cpx #64
	bne @loop
	rts
.endproc

; ** SUBROUTINE: level_end_rain
; desc: Plays the raining part of the cutscene.
.proc level_end_rain
	ldx #0
@loop:
	lda plr_trace_x, x
	sta x_crd_temp
	lda plr_trace_y, x
	sta y_crd_temp
	txa
	and #1
	lsr
	lda levelnumber
	rol
	tay
	lda level_end_rain_par, y
	sta temp11
	ldy levelnumber
	lda level_end_rain_pal, y
	ldy temp11
	jsr oam_putsprite
	txa
	and #1
	tay
	lda speeds, y
	clc
	adc plr_trace_y, x
	sta plr_trace_y, x
	
	bcc :+
	jsr rand
	sta plr_trace_x, x
:	inx
	cpx #64
	bne @loop
	rts

speeds:	.byte 12, 20
.endproc

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
	
	lda #prgb_xtra
	sta musicbank
	
	ldx #<music_data_chapter_complete
	ldy #>music_data_chapter_complete
	lda #1 ; NTSC
	jsr famistudio_init
	
	lda #0
	sta scroll_x
	sta scroll_y
	sta scroll_flags
	sta camera_x
	sta camera_y
	sta camera_x_pg
	sta camera_y_hi
	jsr famistudio_music_play
	
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
	jsr nexxt_rle_decompress_XTRA
	
	; clear the other nametable to black, we'll need it that way.
	lda #$24
	jsr clear_nt
	
	jsr level_end_rain_init
	
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
	
	; Firstly, do 4-5 seconds of raining
	lda #180
	sta ow_timer
	
	; load the sprite bank now
	ldx levelnumber
	
	ldy level_end_bank_spr, x
	sty spr0_bknum
	iny
	sty spr1_bknum
	
	; switch to the other bank
	lda scroll_flags
	ora #pctl_highx
	sta scroll_flags
	lda #1
	sta camera_x_pg
	
	lda #>level_end_rain
	sta fadeupdrt+1
	lda #<level_end_rain
	sta fadeupdrt
	jsr fade_in
	
@loopRainInitial:
	jsr level_end_rain
	jsr @nmiWait
	
	dec ow_timer
	bne @loopRainInitial
	
	; Fade out, then fade back in to the actual complete screen.
	jsr fade_out
	
	lda #0
	sta camera_x_pg
	sta scroll_flags
	
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
	
	lda #60
	sta ow_timer

@wait:
	jsr level_end_fade_update
	jsr @nmiWait
	
	; check if the timer expired
	lda ow_timer
	beq @checkButtonPress
	
	dec ow_timer
	bne @wait
	
@checkButtonPress:
	; check if A or Start are pressed
	lda p1_conto
	and #(cont_a | cont_start)
	bne @wait
	lda p1_cont
	and #(cont_a | cont_start)
	beq @wait
	
	; ok, time to exit
	lda #>level_end_fade_update
	sta fadeupdrt+1
	lda #<level_end_fade_update
	sta fadeupdrt
	jsr fade_out
	
	jsr aud_reset
	
	lda #<irq_idle
	sta irqaddr
	lda #>irq_idle
	sta irqaddr+1
	lda #0
	sta miscsplit
@return:
	rts

@nmiWait:
	jsr soft_nmi_on
	jsr nmi_wait
	jmp soft_nmi_on
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
