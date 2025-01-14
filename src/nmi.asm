; Copyright (C) 2024 iProgramInCpp

; ** NMI
.proc nmi_
	inc nmicount
	sta mmc3_irqdi       ; disable IRQ for this frame
	pha
	
	lda nmi_disable
	bne dontRunNmi       ; if the game is resetting, don't run the NMI thread
	
	txa
	pha
	tya
	pha
	
	lda nmienable
	beq onlyAudioPlease  ; if NMIs are softly disabled, then ONLY run audio
	
	jsr nmi_check_flags
	jsr nmi_check_gamemodes
	
	jsr nmi_scrollsplit
	jsr oam_dma_and_read_cont
	jsr nmi_anims_update
	
	lda scrollsplit
	beq onlyAudioPlease
	
	jsr gm_calc_camera_split
	
onlyAudioPlease:
	; Enable interrupts to run audio. Sometimes, running audio takes a long time
	; (25 scanlines+!), so let it be interrupted, since our IRQs won't mess with it.
	cli
	jsr aud_run
	
dontRunAudio:
	pla
	tay
	pla
	tax
dontRunNmi:
	pla
	rti
.endproc

nmi_check_flags:
	lda #nc_flushcol
	bit nmictrl
	beq @tryPal
	
	eor nmictrl
	sta nmictrl
	jsr h_flush_col_r
	
@tryPal:
	lda #nc_flshpalv
	bit nmictrl
	beq @tryRow
	
	eor nmictrl
	sta nmictrl
	jsr h_flush_pal_r

@tryRow:
	lda #nc_flushrow
	bit nmictrl
	beq @tryHPal
	
	eor nmictrl
	sta nmictrl
	jsr h_flush_row

@tryHPal:
	lda #nc_flushpal
	bit nmictrl
	beq @tryClearEnq
	
	eor nmictrl
	sta nmictrl
	jsr h_flush_pal_u

@tryClearEnq:
	lda #nc_clearenq
	bit nmictrl
	beq @tryClearCol
	
	eor nmictrl
	sta nmictrl
	jsr h_enqueued_clear
	jmp @end

@tryClearCol:
	lda #nc2_clrcol
	bit nmictrl2
	beq @tryClear256
	
	eor nmictrl2
	sta nmictrl2
	jsr h_clear_2cols
	jmp @end

@tryClear256:
	lda #nc2_clr256
	bit nmictrl2
	beq @tryCheckCols
	
	eor nmictrl2
	sta nmictrl2
	
	lda currA000bank
	pha
	
	lda #mmc3bk_prg1
	ldy #prgb_dial
	jsr mmc3_set_bank_nmi
	
	; now the bank is loaded, actually clear!
	jsr dlg_nmi_clear_256
	
	pla
	tay
	lda #mmc3bk_prg1
	jsr mmc3_set_bank_nmi
	jmp @endForceReturn

@tryCheckCols:
	lda #nc2_dlgupd
	bit nmictrl2
	beq @tryUpdPal1
	
	lda currA000bank
	pha
	
	lda #mmc3bk_prg1
	ldy #prgb_dial
	jsr mmc3_set_bank_nmi
	
	jsr dlg_nmi_check_upds
	
	lda dlg_updates
	bne :+
	lda #nc2_dlgupd
	eor nmictrl2
	sta nmictrl2
	
:	pla
	tay
	lda #mmc3bk_prg1
	jsr mmc3_set_bank_nmi

@end:
@tryUpdPal1:
	; finally, update loaded palettes.
	lda #nc2_updpal1
	bit nmictrl2
	beq @tryUpdPal2
	
	eor nmictrl2
	sta nmictrl2
	lda #$3F
	sta ppu_addr
	lda #$15
	sta ppu_addr
	
	lda spritepals+0
	sta ppu_data
	lda spritepals+1
	sta ppu_data
	lda spritepals+2
	sta ppu_data

@tryUpdPal2:
	lda #nc2_updpal2
	bit nmictrl2
	beq @tryUpdPal3
	
	eor nmictrl2
	sta nmictrl2
	lda #$3F
	sta ppu_addr
	lda #$19
	sta ppu_addr
	
	lda spritepals+3
	sta ppu_data
	lda spritepals+4
	sta ppu_data
	lda spritepals+5
	sta ppu_data

@tryUpdPal3:
	lda #nc2_updpal3
	bit nmictrl2
	beq @tryVMemCpy
	
	eor nmictrl2
	sta nmictrl2
	lda #$3F
	sta ppu_addr
	lda #$1D
	sta ppu_addr
	
	lda spritepals+6
	sta ppu_data
	lda spritepals+7
	sta ppu_data
	lda spritepals+8
	sta ppu_data

@tryVMemCpy:
	lda #nc2_vmemcpy
	bit nmictrl2
	beq @tryTurnOn
	
	eor nmictrl2
	sta nmictrl2
	lda vmcaddr+1
	sta ppu_addr
	lda vmcaddr
	sta ppu_addr
	ldy #0
:	lda (vmcsrc), y
	sta ppu_data
	iny
	cpy vmccount
	bne :-
	
@tryTurnOn:
	lda #nc_turnon
	bit nmictrl
	beq @noTurnOn
	
	; turn on bit is set, set PPUMASK to the default
	eor nmictrl
	sta nmictrl
	lda #def_ppu_msk
	sta ppu_mask
	
@noTurnOn:
	rts

@endForceReturn:
	; do this hacky stuff to avoid doing OAM DMA and reading controllers
	; (frees up bandwidth for more advanced patterns in dlg_nmi_clear_256)
	
	; skip return address from nmi_check_flags call
	pla
	pla
	jsr nmi_scrollsplit
	jsr nmi_anims_update
	jmp nmi_::onlyAudioPlease

nmi_check_gamemodes:
	lda gamemode
	beq @game
	cmp #gm_titletra
	beq @titleTra
	cmp #gm_overwld
	beq @overwld
	cmp #gm_prologue
	beq @prologue
@return:
	rts

@game:
	jmp @game_

@overwld:
	lda #nc_updlvlnm
	bit nmictrl
	beq @return
	eor nmictrl
	sta nmictrl
	jmp ow_draw_level_name
	
@prologue:
	lda #nc_prolclr
	bit nmictrl
	beq @prol_dontClear
	eor nmictrl
	sta nmictrl
	ldx pl_ppuaddr
	ldy pl_ppuaddr+1
	sty ppu_addr
	stx ppu_addr
	
	lda #0
	ldy #32
:	sta ppu_data
	dey
	bne :-
	
@prol_dontClear:
	ldx pl_ppuaddr+1
	beq @return       ; nothing to write
	ldy pl_ppuaddr
	stx ppu_addr
	sty ppu_addr
	ldx pl_ppudata
	stx ppu_data
	rts

@titleTra:
	lda tl_timer
	and #$08
	lsr
	lsr
	lsr
	lda #$3F
	sta ppu_addr
	lda #$01
	sta ppu_addr
	tay
	lda alt_colors, y
	sta ppu_data
	lda alt_colors+2, y
	sta ppu_data
	lda alt_colors+4, y
	sta ppu_data
	rts

@game_:
	lda stamflashtm
	beq @unFlash
	
	and #%00000100
	beq @unFlash
	
	; do flash
	lda #g2_flashed
	bit gamectrl2
	bne @returnUnFlash ; if already set
	
	ora gamectrl2
	sta gamectrl2
	
	; NOTE: hardcoded but I'm lazy
	jsr @setPPUAddrTo3F11
	lda #$26
	sta ppu_data
	lda #$16
	sta ppu_data
	lda #$06
	sta ppu_data
	rts
	
@unFlash:
	lda gamectrl2
	and #g2_flashed
	beq @returnUnFlash
	
	; unset the bit
	eor gamectrl2
	sta gamectrl2
	; program the correct color
	; NOTE: hardcoded but I'm lazy
	jsr @setPPUAddrTo3F11
	lda #$37
	sta ppu_data
	lda #$14
	sta ppu_data
	lda #$21
	sta ppu_data
	
@returnUnFlash:
	rts

@setPPUAddrTo3F11:
	lda #$3F
	sta ppu_addr
	lda #$11
	sta ppu_addr
	rts

; ** SUBROUTINE: nmi_anims_update
; desc: Selects the correct graphics banks during gameplay.
;
; question: Why is this near the END of the NMI routine, where it can potentially spill out of vblank?
; answer:   Because updating MMC3 banks is always safe.  Even updating CHR banks is safe.  The only problem
;           is tearing, but it only happens when the NMI routine takes too long, and the artifact will likely
;           stay off in overscan anyway.
nmi_anims_update:
	lda scrollsplit
	bne nmi_anims_scrollsplit
	
nmi_anims_normal:
	ldy spr0_bknum
	lda #mmc3bk_spr0
	jsr mmc3_set_bank_nmi
	
	ldy spr3_bknum
	lda #mmc3bk_spr3
	jsr mmc3_set_bank_nmi
	
	ldy spr1_bknum
	lda #mmc3bk_spr1
	jsr mmc3_set_bank_nmi
	
	ldy spr2_bknum
	lda #mmc3bk_spr2
	jsr mmc3_set_bank_nmi
	
	ldy bg0_bknum
	lda #mmc3bk_bg0
	jsr mmc3_set_bank_nmi
	
	ldy bg1_bknum
	lda #mmc3bk_bg1
	jmp mmc3_set_bank_nmi
	
nmi_anims_scrollsplit:
	ldy bg0_bkspl
	lda #mmc3bk_bg0
	jsr mmc3_set_bank_nmi
	
	ldy bg1_bkspl
	lda #mmc3bk_bg1
	jsr mmc3_set_bank_nmi
	
	ldy spr0_bkspl
	lda #mmc3bk_spr0
	jsr mmc3_set_bank_nmi
	
	ldy spr1_bkspl
	lda #mmc3bk_spr1
	jsr mmc3_set_bank_nmi
	
	ldy spr2_bkspl
	lda #mmc3bk_spr2
	jsr mmc3_set_bank_nmi
	
	ldy spr3_bkspl
	lda #mmc3bk_spr3
	jmp mmc3_set_bank_nmi
	

; ** SUBROUTINE: nmi_scrollsplit
; desc: Determines if the scroll should be split.
; NOTE NOTE NOTE: AVOID LAG AT ALL COSTS WHILE A SCROLL SPLIT TAKES PLACE!
; ELSE YOU WILL SEE GRAPHICS GLITCHES!
nmi_scrollsplit:
	ldy #0
	sty rununimport
	sty irqcounter
	sty mmc3_irqdi  ; disable IRQ for this frame, except when we need to enable it
	
	lda scrollsplit
	beq @almostNormalScrolling
	
	lda ctl_flags   ; ctl_flags notably does NOT set X-high, Y-high. they're controlled separately
	ora scroll_flags
	
	ldx dialogsplit
	beq @noDialogSplit
	
	; have dialog split
	eor #%00000001
	sta ppu_ctrl
	lda camera_x
	sta ppu_scroll
	
	lda #<irq_dialog_split_2
	sta irqaddr
	lda #>irq_dialog_split_2
	sta irqaddr+1
	lda #$E8
	sta ppu_scroll
	lda #%00010100 ; only enable sprites
	sta ppu_mask
	bne @ahead
	
@noDialogSplit:
	sta ppu_ctrl
	sty ppu_scroll
	sty ppu_scroll
	
@ahead:
	lda dialogsplit ; -- dialogsplit takes priority over scrollsplit
	bne :+
	lda scrollsplit
:	sta mmc3_irqla  ; latch
	sta mmc3_irqrl  ; reload
	sta mmc3_irqen  ; enable IRQs!
	rts

@almostNormalScrolling:
	lda miscsplit
	beq @normalScrollingWithIRQ
	
	sta mmc3_irqla
	sta mmc3_irqrl
	sta mmc3_irqen
	; fall through to normal scrolling
	
	lda #36
	sta irqcounter
	lda #0
	sta miscsplit
	
	lda #def_ppu_msk
	sta ppu_mask
	bne @normalScrolling

@normalScrollingWithIRQ:
	; schedule the idle IRQ after $C0 scanlines. This IRQ will block the
	; running of unimportant services
	lda #$C0
	sta mmc3_irqla
	sta mmc3_irqrl
	
	lda #<irq_idle
	sta irqaddr
	lda #>irq_idle
	sta irqaddr+1
	
	sta mmc3_irqen
	
@normalScrolling:
	lda scroll_flags
	ora ctl_flags
	sta ppu_ctrl
	lda scroll_x
	sta ppu_scroll
	lda scroll_y
	sta ppu_scroll
	rts
