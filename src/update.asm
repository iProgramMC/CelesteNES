
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

nmi_game:
	lda #cont_right
	bit p1_cont
	beq nmi_gamemodeend
	;bit p1_conto
	;bne nmi_gamemodeend
	jsr h_generate_column
	jmp nmi_gamemodeend

nmi:
	pha
	txa
	pha
	tya
	pha
	
	lda #oam_buf_hi   ; load the high byte of the OAM DMA address
	sta apu_oam_dma   ; and perform the DMA!
	
	ldx gamemode
	cpx #gm_titletra
	beq nmi_titletra
	cpx #gm_game
	beq nmi_game
	
nmi_gamemodeend:
	jsr ppu_rstaddr
	
	ldx camera_x
	stx ppu_scroll
	ldx camera_y
	stx ppu_scroll
	
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
	