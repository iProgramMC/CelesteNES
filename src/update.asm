; Copyright (C) 2024 iProgramInCpp

nmi_titletra:
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
	jmp nmi_gamemodeend

nmi_title:
	lda #ts_turnon
	bit titlectrl
	bne nmi_title_turnon
	beq nmi_gamemodeend
nmi_title_turnon:
	lda titlectrl
	eor #ts_turnon
	sta titlectrl
	lda #def_ppu_msk
	sta ppu_mask
	beq nmi_gamemodeend

nmi_overwld:
	lda #os_turnon
	bit owldctrl
	beq :+
	eor owldctrl
	sta owldctrl
	lda #def_ppu_msk
	sta ppu_mask
:	lda #os_updlvlnm
	bit owldctrl
	beq :+
	jsr ow_draw_level_name
:	jmp nmi_gamemodeend

; ** INTERRUPT HANDLER: nmi
nmi:
	inc nmicount
	pha
	txa
	pha
	tya
	pha
	
	lda #9
	sta debug
	
	lda #oam_buf_hi   ; load the high byte of the OAM DMA address
	sta apu_oam_dma   ; and perform the DMA!
	
	ldx gamemode
	cpx #gm_titletra
	beq nmi_titletra
	cpx #gm_title
	beq nmi_title
	cpx #gm_overwld
	beq nmi_overwld
	cpx #gm_prologue
	beq nmi_prologue
	bne nmi_game
	
nmi_gamemodeend:
	jsr nmi_calccamerapos
	
	lda #10
	sta debug
	
	jsr aud_run
	
	pla
	tay
	pla
	tax
	pla
	rti

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
	lda #ps_turnon
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
	jsr nmi_anims_update
	
	; Check game status bits.
	lda #gs_turnon
	bit gamectrl
	beq @trycols
	lda gamectrl
	eor #gs_turnon
	sta gamectrl
	lda #def_ppu_msk
	sta ppu_mask
	
@trycols:
	lda #gs_flstcolR
	bit gamectrl
	beq @trypal
	eor gamectrl
	sta gamectrl
	jsr h_flush_col_r
	
@trypal:
	lda #gs_flstpalR
	bit gamectrl
	beq @tryrow
	eor gamectrl
	sta gamectrl
	jsr h_flush_pal_r
	
@tryrow:
	lda #g2_flstrowU
	bit gamectrl2
	beq @tryhpal
	eor gamectrl2
	sta gamectrl2
	jsr h_flush_row_u
	
@tryhpal:
	lda #g2_flstpalU
	bit gamectrl2
	beq :+
	eor gamectrl2
	sta gamectrl2
	jsr h_flush_pal_u
:	jmp nmi_gamemodeend

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

; ** SUBROUTINE: nmi_calccamerapos
; desc: Calculate and send the PPU the new camera position.
nmi_calccamerapos:
	ldx quaketimer
	bne @doQuake
	
	; common fast path
	lda ctl_flags
	and #((pctl_highx | pctl_highy) ^ $FF)
	
	ldx camera_x_hi
	beq :+
	ora #pctl_highx
:	;ldx camera_y_hi
	;beq :+
	;ora #pctl_highy
;:
	sta ctl_flags
	sta ppu_ctrl
	
	lda camera_x
	sta ppu_scroll
	lda camera_y
	sta ppu_scroll
	
	rts
	
@doQuake:
	lda camera_x
	sta temp1
	lda camera_x_hi
	sta temp2
	lda camera_y
	sta temp3
	; lda camera_y_hi
	; sta temp4
	
	; apply a random quake based on the quake flags
	lda #cont_up
	bit quakeflags
	beq @notUp
	
	jsr rand_m2_to_p1
	ora #%11111100
	clc
	adc temp3
	sta temp3
	;lda temp4
	;adc temp5
	;sta temp4

@notUp:
	lda #cont_down
	bit quakeflags
	beq @notDown
	
	jsr rand_m1_to_p2
	clc
	adc temp3
	sta temp3
	;lda temp4
	;adc temp5
	;sta temp4

@notDown:
	
	; do some corrections on the Y axis
	lda temp3
	cmp #$F0
	bcc :+
	sec
	sbc #$10
	sta temp3
	
:	lda #cont_left
	bit quakeflags
	beq @notLeft
	
	jsr rand_m2_to_p1
	clc
	adc temp1
	sta temp1
	lda temp2
	adc temp5
	sta temp2

@notLeft:
	lda #cont_right
	bit quakeflags
	beq @notRight
	
	jsr rand_m1_to_p2
	clc
	adc temp1
	sta temp1
	lda temp2
	adc temp5
	sta temp2
	
@notRight:
	
	; now send the info off!
	;lda temp4
	;and #1
	;sta temp4
	lda temp2
	and #1
	sta temp2
	
	lda ctl_flags
	and #((pctl_highx | pctl_highy) ^ $FF)
	
	ldx temp2
	beq :+
	ora #pctl_highx
:	;ldx temp4
	;beq :+
	;ora #pctl_highy
;:
	sta ctl_flags
	sta ppu_ctrl
	
	lda temp1
	sta ppu_scroll
	lda temp3
	sta ppu_scroll
	
	dec quaketimer
	
	rts

.include "weather.asm"
.include "title.asm"

; ** SUBROUTINE: game_update
; arguments: none
; clobbers: all registers
game_update:
	jsr com_game_log
	ldx gamemode
	cpx #gm_title
	beq gamemode_title   ; title screen
	cpx #gm_titletra
	beq gamemode_titletr ; title screen transition
	cpx #gm_overwld
	beq gamemode_overwd  ; overworld
	cpx #gm_prologue
	beq gamemode_prologue_ ; prologue
	jmp gamemode_game    ; default handling
game_update_return:
	rts

gamemode_prologue_:
	jmp gamemode_prologue

.include "overwld.asm"
.include "prologue.asm"

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
	lda #$00
	ldx #$00
	sta oam_wrhead
cgl_clear_loop:
	sta oam_buf, x
	inx
	bne cgl_clear_loop
	rts

; ** SUBROUTINE: com_game_log
; arguments: none
; clobbers:  all registers
; desc:      handles common game logic such as clearing OAM
com_game_log:
	jsr read_cont
	jsr com_clear_oam
	rts

; ** IRQ
; currently blank.
irq:
	jmp irq
