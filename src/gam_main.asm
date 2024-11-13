; Copyright (C) 2024 iProgramInCpp

; Desc: If you put these functions in the game segment, it will overflow.
; These functions are instead implemented in the main segment.
.include "e_physic.asm"

; ** SUBROUTINE: gm_scroll_d_cond
gm_scroll_d_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet
	
	lda #g2_scrstopD
	bit gamectrl2
	bne @scrollRet
	
	lda #rf_godown
	bit roomflags
	beq @scrollRet
	
	lda player_y
	sec
	sbc camera_y_sub
	bcc @scrollRet
	
	cmp #vscrolllimit
	bcc @scrollRet
	beq @scrollRet
	
	sec
	sbc #vscrolllimit
	cmp #camspeed
	bcc @noFix
	lda #camspeed
@noFix:
	
	sta temp1          ; store the difference here as we'll need it later
	
	; add it to the camera Y sub coord
	lda camera_y_sub
	clc
	adc temp1
	sta camera_y_sub
	
	; if it's still below, then that's fine. just return
	cmp #8
	bcc @scrollRet
	
	; nope, pull it back in the 0-7 range, increment camera_y by 8,
	; and all our other shenanigans.
	lda camera_y_sub
	sec
	sbc #8
	sta camera_y_sub
	
	lda camera_y
	clc
	adc #8
	cmp #240
	bcc :+
	adc #15       ; carry set, so actually adds 16
:	sta camera_y
	
	; move player up
	lda player_y
	sec
	sbc #8
	sta player_y
	
	; move all entities up
	ldy #0
@entShiftLoop:
	lda sprspace+sp_y, y
	sec
	sbc #8
	bcs :+      ; if it didn't go below zero, don't clear
	lda #0
	sta sprspace+sp_kind, y
:	sta sprspace+sp_y, y
	iny
	cpy #sp_max
	bne @entShiftLoop
	
	; load a new set of tiles
	jsr gm_gener_tiles_below
	
@scrollRet:
gm_calculate_vert_offs:
	; calculate vertical offset hack
	lda camera_y
	sec
	sbc camera_y_bs
	lsr
	lsr
	lsr
	sta vertoffshack
	rts

; ** SUBROUTINE: gm_load_level_if_vert
; desc: Loads more of the horizontal level segment, if in vertical mode.
gm_load_level_if_vert:
	lda #(g3_transitA)
	bit gamectrl3
	bne @return      ; if there are transitions going on, then return
	
	lda #(rf_godown | rf_goup)
	bit roomflags
	beq @return      ; if level is horizontal, then return
	
	lda #gs_lvlend
	bit gamectrl
	bne @return      ; if level is over, then return
	
	jmp h_gener_col_r

@return:
	rts

