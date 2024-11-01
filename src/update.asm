; Copyright (C) 2024 iProgramInCpp

;nmi_titletra:
;	lda tl_timer
;	and #$08
;	lsr
;	lsr
;	lsr
;	ldy #$3F
;	ldx #$01
;	jsr ppu_loadaddr
;	tay
;	lda alt_colors, y
;	sta ppu_data
;	lda alt_colors+2, y
;	sta ppu_data
;	lda alt_colors+4, y
;	sta ppu_data
;	jmp nmi_gamemodeend

;nmi_overwld:
;	;lda #os_turnon
;	bit owldctrl
;	beq :+
;	eor owldctrl
;	sta owldctrl
;	lda #def_ppu_msk
;	sta ppu_mask
;:	;lda #os_updlvlnm
;	bit owldctrl
;	beq :+
;	jsr ow_draw_level_name
;:	jmp nmi_gamemodeend

; ** INTERRUPT HANDLER: nmi
nmi:
	inc nmicount
	sta mmc3_irqdi  ; disable IRQ for this frame
	pha
	txa
	pha
	tya
	pha
	
	lda nmienable
	beq @onlyAudioPlease ; if NMIs are softly disabled, then ONLY run audio
	
	ldx gamemode
	beq nmi_game
	cpx #gm_titletra
	;beq nmi_titletra
	cpx #gm_title
	;beq nmi_title
	cpx #gm_overwld
	;beq nmi_overwld
	cpx #gm_prologue
	beq nmi_prologue
	
@gamemode_end:
	jsr oam_dma_and_read_cont
	jsr nmi_scrollsplit
	
@onlyAudioPlease:
	jsr aud_run
	
	pla
	tay
	pla
	tax
	pla
	rti
nmi_gamemodeend = @gamemode_end

nmi_prologue:
	lda #ps_clear
	bit prolctrl
	beq @noClear
	
	eor prolctrl
	sta prolctrl
	ldx pl_ppuaddr
	ldy pl_ppuaddr + 1
	sty ppu_addr
	stx ppu_addr
	
	lda #0
	ldy #32
:	sta ppu_data
	dey
	bne :-
	
@noClear:
	;lda #ps_turnon
	bit prolctrl
	beq @noTurnOn
	eor prolctrl
	sta prolctrl
	lda #def_ppu_msk
	sta ppu_mask

@noTurnOn:
	ldx pl_ppuaddr + 1
	beq @noAddressToWrite
	ldy pl_ppuaddr
	stx ppu_addr
	sty ppu_addr
	ldx pl_ppudata
	stx ppu_data

@noAddressToWrite:
	jmp nmi_gamemodeend

nmi_game:
;	jsr nmi_anims_update
;	
;	; Check game status bits.
;	;lda #gs_turnon
;	bit gamectrl
;	beq @trycols
;	lda gamectrl
;	;eor #gs_turnon
;	sta gamectrl
;	lda #def_ppu_msk
;	sta ppu_mask
;
;@trycols:
;	lda #gs_flstcolR
;	bit gamectrl
;	beq @trypal
;	eor gamectrl
;	sta gamectrl
;	jsr h_flush_col_r
;
;@trypal:
;	lda #gs_flstpalR
;	bit gamectrl
;	beq @tryrow
;	eor gamectrl
;	sta gamectrl
;	jsr h_flush_pal_r
;
;@tryrow:
;	lda #g2_flstrowU
;	bit gamectrl2
;	beq @tryhpal
;	eor gamectrl2
;	sta gamectrl2
;	jsr h_flush_row_u
;
;@tryhpal:
;	lda #g2_flstpalU
;	bit gamectrl2
;	beq @tryclear
;	eor gamectrl2
;	sta gamectrl2
;	jsr h_flush_pal_u
;
;@tryclear:
;	lda #g2_clearcol
;	bit gamectrl2
;	beq @tryclricr
;	eor gamectrl2
;	sta gamectrl2
;	jsr h_clear_2cols
;	
;@tryclricr:
;	lda #g2_clrcru
;	bit gamectrl2
;	beq @tryseticr
;	eor gamectrl2
;	sta gamectrl2
;	jsr h_enqueued_clear
;	
;@tryseticr:
;	lda #g2_setcru
;	bit gamectrl2
;	beq @end
;	eor gamectrl2
;	sta gamectrl2
;	jsr level0_nmi_set_icr

@end:
	jmp nmi_gamemodeend

nmi_anims_update:
	; Update the current player sprite bank.
	lda animtimer
	and #1
	tay
	lda #mmc3bk_spr0
	jsr mmc3_set_bank_nmi
	
	; Update the animated sprite bank.
	lda framectr
	lsr
	lsr
	lsr
	and #3
	tay
	iny
	iny
	lda #mmc3bk_spr3
	jmp mmc3_set_bank_nmi

; ** SUBROUTINE: rand_m2_to_p1
; desc: Gets a random value between [-2, 1]
rand_m2_to_p1:
	ldx #0
	jsr rand
	and #3
	sec
	sbc #2
	bpl :+
	ldx #$FF
:	stx temp5
	rts

; ** SUBROUTINE: rand_m1_to_p2
; desc: Gets a random value between [-1, 2]
rand_m1_to_p2:
	ldx #0
	jsr rand
	and #3
	sec
	sbc #1
	bpl :+
	ldx #$FF
:	stx temp5
	rts

.include "weather.asm"
.include "title.asm"

; ** SUBROUTINE: game_update
; arguments: none
; clobbers: all registers
game_update:
	jsr com_clear_oam    ; clear OAM
	
	; determine which mode we should operate in
	ldx gamemode
	cpx #gm_title
	beq gamemode_title_  ; title screen
	cpx #gm_titletra
	beq gamemode_titletr ; title screen transition
	cpx #gm_overwld
	beq gamemode_overwd  ; overworld
	cpx #gm_prologue
	beq gamemode_prologue_ ; prologue
	
	jmp gamemode_game    ; default handling
	
game_update_return:
	jmp com_calc_camera  ; calculate the visual camera position

gamemode_prologue_:
	jmp gamemode_prologue

.include "overwld.asm"
.include "prologue.asm"

; ** SUBROUTINE: nmi_scrollsplit
; desc: Determines if the scroll should be split.
; NOTE NOTE NOTE: AVOID LAG AT ALL COSTS WHILE A SCROLL SPLIT TAKES PLACE!
; ELSE YOU WILL SEE GRAPHICS GLITCHES!
nmi_scrollsplit:
	lda scrollsplit
	beq @normalScrolling
	
	lda ctl_flags
	sta ppu_ctrl   ; ctl_flags notably does NOT set X-high, Y-high. they're controlled separately
	lda #0
	sta ppu_scroll
	sta ppu_scroll
	
	sta mmc3_irqdi  ; disable IRQ
	lda scrollsplit
	sta mmc3_irqla  ; latch
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

; ** SUBROUTINE: tl_select_banks
; desc: Selects the banks required to display the title screen.
tl_select_banks:
	lda #mmc3bk_bg0
	ldy #chrb_bgttl
	jsr mmc3_set_bank
	
	lda #mmc3bk_bg1
	ldy #chrb_bgttl+2
	jsr mmc3_set_bank
	
	lda #mmc3bk_spr0
	ldy #chrb_plrsp0
	jsr mmc3_set_bank
	
	;lda #mmc3bk_spr1
	;ldy #chrb_gensp2
	;jsr mmc3_set_bank
	
	lda #mmc3bk_spr2
	ldy #chrb_gensp1
	jsr mmc3_set_bank
	
	;lda #mmc3bk_spr3
	;ldy #chrb_anisp0
	;jsr mmc3_set_bank
	rts

; ** SUBROUTINE: com_clear_oam
; arguments: none
; clobbers:  A, X
; desc:      clears CPU's copy of OAM
com_clear_oam:
	lda #$FF
	ldx #$00
	stx oam_wrhead
@loop:
	sta oam_buf, x
	inx
	bne @loop
	rts

; ** SUBROUTINE: com_calc_camera
; desc: Calculate the default scroll X/Y to cameraX/cameraY.
;       This routine is called on every game mode that isn't gm_game.
com_calc_camera:
	lda gamemode
	cmp #gm_game
	beq @return
	
	lda camera_x
	sta scroll_x
	lda camera_y
	sta scroll_y
	lda #0
	ldx camera_x_hi
	beq :+
	ora #pctl_highx
:	ldx camera_y_hi
	beq :+
	ora #pctl_highy
:	sta scroll_flags
@return:
	rts

; ** IRQ
; thanks NESDev Wiki for providing an example of loopy's scroll method
irq:
	pha
	txa
	pha
	tya
	pha
	sta mmc3_irqdi
	
	lda scroll_flags   ; bits 0 and 1 control the high name table address
	asl
	asl
	sta ppu_addr       ; nametable number << 2 to ppu_addr.
	
	; push the Y position to the ppu_scroll
	lda scroll_y
	sta ppu_scroll
	
	; prepare the 2 latter writes. we reuse scroll_x to hold (y & $f8) << 2.
	and #%11111000
	asl
	asl
	ldx scroll_x
	sta scroll_x
	
	; ((y & $f8) << 2) | (x >> 3) in A for ppu_addr later
	txa
	lsr
	lsr
	lsr
	ora scroll_x
	
	; carefully timed code!
	ldy #$9
:	dey
	bne :-
	
	; the last two ppu writes MUST happen during horizontal blank
	stx ppu_scroll
	sta ppu_addr
	
	; restore scroll_x. not sure if this is needed
	stx scroll_x
	
	pla
	tay
	pla
	tax
	pla
	rti
