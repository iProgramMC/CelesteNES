; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_scroll_r_cond
gm_scroll_r_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet    ; if camera is locked
	
	lda player_x
	cmp #scrolllimit
	bcc @scrollRet    ; A < scrolllimit
	beq @scrollRet    ; A = scrolllimit
	sec
	sbc #scrolllimit
	cmp #camspeed     ; see the difference we need to scroll
	bcc @noFix        ; A < camspeed
	lda #camspeed
@noFix:               ; A now contains the delta we need to scroll by
	sta temp1
	clc
	tax               ; save the delta as we'll need it later
	adc camera_x      ; add the delta to the camera X
	sta camera_x
	lda #0
	adc camera_x_pg
	sta camera_x_pg
	and #1
	sta camera_x_hi
	lda #gs_scrstopR  ; check if we overstepped the camera boundary, if needed
	bit gamectrl
	beq @noLimit
	
	lda camlimit
	sta scrchklo
	lda camlimithi
	sta scrchkhi
	lda camlimithi    ; check if [camlimithi,camlimit] < [camera_x_hi,camera_x]
	cmp camera_x_hi
	bcs :+
	lda camlimit
	cmp camera_x
	bcs :+
	lda #2            ; note: carry clear here
	adc scrchkhi
	sta scrchkhi
:	sec
	lda scrchklo
	sbc camera_x
	sta scrchklo
	lda scrchkhi
	sbc camera_x_hi
	bmi @camXLimited
	;sta scrchkhi
	
@noLimit:
	;lda #scrolllimit  ; set the player's X relative-to-the-camera to scrolllimit
	lda player_x
	sec
	sbc temp1
	sta player_x
	txa               ; restore the delta to add to camera_rev
	pha
	lda temp1
	jsr gm_shifttrace
	pla
	clc
	adc camera_rev
	sta camera_rev
	cmp #8
	bcs @goGenerate   ; if camera_rev+diff < 8 return
@scrollRet:
	rts
@goGenerate:
	lda camera_rev    ; subtract 8 from camera_rev
	sec
	sbc #8
	sta camera_rev
	jmp h_gener_col_r
@camXLimited:
	lda camlimithi
	sta camera_x_hi
	lda camlimit
	sta camera_x
	lda #gs_scrstodR
	bit gamectrl
	bne :+
	ora gamectrl
	sta gamectrl
:	rts

; ** SUBROUTINE: gm_scroll_l_cond
gm_scroll_l_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet    ; if camera is locked
	
	lda roomsize
	beq @scrollRet    ; if this is a "long" room, then we CANNOT scroll left.
	
	lda player_x
	cmp #scrolllimit
	bcs @scrollRet
	;bcc @scrollRet
	
	lda #scrolllimit
	sec
	sbc player_x
	cmp #camspeed     ; see the difference we need to scroll
	bcc @noFix
	lda #camspeed
@noFix:
	sta temp1
	
	lda #(gs_scrstodR^$FF)
	and gamectrl
	sta gamectrl
	
	sec
	lda camera_x
	tax               ; save the delta as we'll need it later
	sbc temp1         ; take the delta from the camera X
	sta camera_x
	lda camera_x_pg
	sbc #0
	bmi @limit
	
	sta camera_x_pg
	and #1
	sta camera_x_hi
	
	lda camleftlo
	sta scrchklo
	lda camlefthi
	sta scrchkhi
	
	lda camlefthi     ; check if [camlefthi, camleftlo] < [camera_x_pg, camera_x]
	cmp camera_x_pg
	bne :+
	lda camleftlo
	cmp camera_x
:	; if camleft > cameraX then limit
	bcs @limit
	
	; no limitation. also move the PLAYER's x coordinate
@shouldNotLimit:
	lda player_x
	clc
	adc temp1
	sta player_x
	
	lda temp1
	jsr gm_shiftrighttrace
	
@scrollRet:
	rts
	
@limit:
	lda camleftlo
	sta camera_x
	lda camlefthi
	sta camera_x_pg
	and #1
	sta camera_x_hi
	rts

; ** SUBROUTINE: gm_scroll_d_cond
gm_scroll_d_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet
	
	lda #gs_lvlend
	bit gamectrl
	beq @scrollRet    ; if level data hasn't actually ended
	
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
	; carry set
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

; ** SUBROUTINE: gm_scroll_u_cond
gm_scroll_u_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet
	
	lda #gs_lvlend
	bit gamectrl
	beq @scrollRet    ; if level data hasn't actually ended
	
	lda #g2_scrstopD
	bit gamectrl2
	bne @scrollRet
	
	lda #rf_goup
	bit roomflags
	beq @scrollRet
	
	lda player_y
	sec
	sbc camera_y_sub
	bcc @scrollRet
	
	cmp #vscrolllimit
	bcs @scrollRet
	
	sta temp1
	lda #vscrolllimit
	sec
	sbc temp1
	
	cmp #camspeed
	bcc @noFix
	lda #camspeed
@noFix:
	
	sta temp1          ; store the difference here as we'll need it later
	
	; take it from the camera Y sub coord
	lda camera_y_sub
	sec
	sbc temp1
	sta camera_y_sub
	
	; if it's still above, then just return
	bcs @scrollRet
	
	; nope, pull it back in the 0-7 range, decrement camera_y by 8,
	; and all our other shenanigans
	lda camera_y_sub
	; carry clear
	adc #8
	sta camera_y_sub
	
	lda camera_y
	sec
	sbc #8
	bcs :+
	sbc #15            ; subtract 16 more because this is surely in the 240-256 range
:	sta camera_y
	
	; move player down
	lda player_y
	clc
	adc #8
	sta player_y
	
	; move all entities down
	ldy #0
@entShiftLoop:
	lda sprspace+sp_y, y
	clc
	adc #8
	bcs @clearType     ; if it went above 256, don't clear
	cmp #240
	bcc @dontSet
@clearType:
	lda #0
	sta sprspace+sp_kind, y
@dontSet:
	sta sprspace+sp_y, y
	iny
	cpy #sp_max
	bne @entShiftLoop
	
	lda #g2_loadvrow
	bit gamectrl2
	bne @generateTilesAbove
	
	ora gamectrl2
	sta gamectrl2
	bne @scrollRet
	
@generateTilesAbove:
	; load a new set of tiles
	jsr gm_gener_tiles_above
	
@scrollRet:
	jmp gm_calculate_vert_offs