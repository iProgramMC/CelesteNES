; Copyright (C) 2024 iProgramInCpp


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
