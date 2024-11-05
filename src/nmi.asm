; Copyright (C) 2024 iProgramInCpp

; ** NMI
nmi_:
	inc nmicount
	sta mmc3_irqdi  ; disable IRQ for this frame
	pha
	txa
	pha
	tya
	pha
	
	lda nmienable
	beq @onlyAudioPlease ; if NMIs are softly disabled, then ONLY run audio
	
	jsr nmi_check_flags
	jsr nmi_check_gamemodes
	
	jsr nmi_scrollsplit
	jsr oam_dma_and_read_cont
	jsr nmi_anims_update
	
@onlyAudioPlease:
	lda dialogsplit
	bne @dontRunAudio
	
	; Audio is NOT run after vblank during NMI split. Why?
	; Sometimes, it just takes too long (like 25 scanlines!)
	; So we'll delay it to the IRQ.
	jsr aud_run
	
@dontRunAudio:
	pla
	tay
	pla
	tax
	pla
	rti

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
	jsr h_flush_row_u

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
	beq @trySetICr
	
	eor nmictrl2
	sta nmictrl2
	jsr h_clear_2cols
	jmp @end

@trySetICr:
	lda #nc2_setl0ic
	bit nmictrl2
	beq @tryClear256
	
	eor nmictrl2
	sta nmictrl2
	jsr level0_nmi_set_icr
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
	jmp @end

@tryCheckCols:
	lda #nc2_dlgupd
	bit nmictrl2
	beq @end
	
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

nmi_check_gamemodes:
	lda gamemode
	beq @return
	cmp #gm_titletra
	beq @titleTra
	cmp #gm_overwld
	beq @overwld
	cmp #gm_prologue
	beq @prologue
@return:
	rts

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
	ldy #$3F
	ldx #$01
	jsr ppu_loadaddr
	tay
	lda alt_colors, y
	sta ppu_data
	lda alt_colors+2, y
	sta ppu_data
	lda alt_colors+4, y
	sta ppu_data
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
	lda #0
	sta irqcounter
	
	lda scrollsplit
	beq @normalScrolling
	
	lda ctl_flags   ; ctl_flags notably does NOT set X-high, Y-high. they're controlled separately
	ora scroll_flags
	
	ldx dialogsplit
	beq @noDialogSplit
	
	; have dialog split
	eor #%00000001
	sta ppu_ctrl
	lda camera_x
	sta ppu_scroll
	lda #0
	beq @ahead
	
@noDialogSplit:
	sta ppu_ctrl
	
	lda #0
	sta ppu_scroll
@ahead:
	sta ppu_scroll
	
	sta mmc3_irqdi  ; disable IRQ
	lda dialogsplit ; -- dialogsplit takes priority over scrollsplit
	bne :+
	lda scrollsplit
:	sta mmc3_irqla  ; latch
	sta mmc3_irqrl  ; reload
	sta mmc3_irqen  ; enable IRQs!
	rts
	
@normalScrolling:
	lda scroll_flags
	ora ctl_flags
	sta ppu_ctrl
	lda scroll_x
	sta ppu_scroll
	lda scroll_y
	sta ppu_scroll
	sta mmc3_irqdi  ; disable IRQ for this frame
	rts