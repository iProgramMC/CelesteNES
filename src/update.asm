; Copyright (C) 2024 iProgramInCpp

gamemodes_LO:
	.byte <gamemode_game
	.byte <gamemode_title
	.byte <gamemode_titletr
	.byte <gamemode_overwd
	.byte <gamemode_prologue
	
gamemodes_HI:
	.byte >gamemode_game
	.byte >gamemode_title
	.byte >gamemode_titletr
	.byte >gamemode_overwd
	.byte >gamemode_prologue

; ** SUBROUTINE: jump_engine
; desc: Jumps to the address corresponding to the current game mode.
jump_engine:
	ldx gamemode
	lda gamemodes_LO, x
	sta temp1
	lda gamemodes_HI, x
	sta temp1+1
	jmp (temp1)

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
.include "overwld.asm"
.include "prologue.asm"

; ** SUBROUTINE: game_update
; arguments: none
; clobbers: all registers
game_update:
	jsr com_clear_oam    ; clear OAM
	jsr jump_engine      ; jump to the corresponding game mode
	jmp com_calc_camera  ; calculate the visual camera position

; ** SUBROUTINE: tl_select_banks
; desc: Selects the banks required to display the title screen.
tl_select_banks:
	ldy #chrb_bgttl
	sty bg0_bknum
	
	ldy #chrb_bgttl+2
	sty bg1_bknum
	
	ldy #chrb_plrsp0
	sty spr0_bknum
	
	;ldy #chrb_gensp2
	;sty spr1_bknum
	
	ldy #chrb_gensp1
	sty spr2_bknum
	
	;ldy #chrb_anisp0
	;sty spr3_bknum
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
