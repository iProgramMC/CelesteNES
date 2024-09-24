
; ** INTERRUPT HANDLER: nmi
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
	jmp nmi_gamemodeend
nmi_title_turnon:
	lda titlectrl
	eor #ts_turnon
	sta titlectrl
	lda #def_ppu_msk
	sta ppu_mask
	jmp nmi_gamemodeend

nmi_game:
	lda #gs_turnon
	bit gamectrl
	beq nmi_game_trycols
	lda gamectrl
	eor #gs_turnon
	sta gamectrl
	lda #def_ppu_msk
	sta ppu_mask
nmi_game_trycols:
	lda #gs_flstcols
	bit gamectrl
	beq nmi_game_trypal
	lda #gs_flstcols
	eor gamectrl
	sta gamectrl
	jsr h_flush_column
	;jmp nmi_gamemodeend
nmi_game_trypal:
	lda #gs_flstpal
	bit gamectrl
	beq nmi_gamemodeend
	lda #gs_flstpal
	eor gamectrl
	sta gamectrl
	jsr h_flush_palette
	jmp nmi_gamemodeend

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
	jmp nmi_game
	
nmi_gamemodeend:
	
	ldx camera_x_hi
	beq nmi_nocamhi
	lda ctl_flags
	ora #ctl_highx
	jmp nmi_camhid
nmi_nocamhi:
	lda ctl_flags
	and #(ctl_highx ^ %11111111)  ; can't do "and #~ctl_highy" for some reason!
nmi_camhid:
	sta ctl_flags
	jsr ppu_nmi_on
	
	;jsr ppu_rstaddr
	
	ldx camera_x
	stx ppu_scroll
	ldx camera_y
	stx ppu_scroll
	
	lda #10
	sta debug
	
	pla
	tay
	pla
	tax
	pla
	rti

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
	jmp gamemode_game    ; default handling
game_update_return:
	rts

.include "game.asm"

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
	