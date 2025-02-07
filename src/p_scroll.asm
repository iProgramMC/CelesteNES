; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: ph_scroll_r_cond
ph_scroll_r_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet2   ; if camera is locked
	lda #g3_blockinp
	bit gamectrl3
	beq @dontReturn
@scrollRet2:
	rts
@dontReturn:
	lda #0
	sec
	sbc camera_x_lo
	sta temp2
	
	lda player_x
	cmp #scrolllimit
	bcc @scrollRet2   ; A < scrolllimit
	beq @scrollRet2   ; A = scrolllimit
	;sec
	sbc #scrolllimit
	sta temp1
	
	; A holds the difference. divide it by 1/4
	lda temp2
	lsr temp1
	ror
	lsr temp1
	ror
	lsr temp1
	ror
	sta temp2
	
	lda temp1
	cmp #camspeed
	bcc @noFix
	
	lda #camspeed
	sta temp1
	lda #0
	sta temp2

@noFix:
	lda temp2
	clc
	adc camera_x_lo
	sta camera_x_lo
	
	; note: loads the difference *PLUS* the carry, we need THAT later
	lda temp1
	adc #0
	clc
	sta temp1
	tax               ; save the delta as we'll need it later
	adc camera_x      ; add the delta to the camera X
	sta camera_x
	
	lda camera_x_pg
	adc #0
	sta camera_x_pg
	
	; is there a camera limit yet?
	lda #gs_scrstopR
	bit gamectrl
	beq @noLimit
	
	; figure out the (camera X - camlimit X)
	lda camera_x
	sec
	sbc camlimit
	sta scrchklo
	
	lda camera_x_pg
	sbc camlimithi
	
	; negative value means there's no limit (camera X < camlimit X)
	bmi @noLimit
	
	; limited
	; scrchklo contains the amount the limit was passed by
	lda temp1
	sec
	sbc scrchklo
	sta temp1
	tax
	
	lda gamectrl
	ora #gs_scrstodR
	sta gamectrl
	
	lda camlimit
	sta camera_x
	lda camlimithi
	sta camera_x_pg
	
@noLimit:
	lda player_x
	sec
	sbc temp1
	sta player_x
	lda temp1
	jsr gm_shifttrace
	lda temp1
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
	jmp xt_gener_col_r

; ** SUBROUTINE: ph_scroll_l_cond
ph_scroll_l_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet2   ; if camera is locked
	lda #g3_blockinp
	bit gamectrl3
	beq @dontReturn
@scrollRet2:
	rts
@dontReturn:
	
	lda roomsize
	beq @scrollRet2   ; if this is a "long" room, then we CANNOT scroll left.
	
	lda #0
	sec
	sbc camera_x_lo
	sta temp2
	
	lda player_x
	cmp #scrolllimit
	bcs @scrollRet
	
	lda #scrolllimit
	sec
	sbc player_x
	sta temp1
	
	lda temp2
	lsr temp1
	ror
	lsr temp1
	ror
	lsr temp1
	ror
	sta temp2
	
	lda temp1
	cmp #camspeed
	bcc @noFix
	lda #camspeed
	sta temp1
	lda #0
	sta temp2
@noFix:
	
	lda #(gs_scrstodR^$FF)
	and gamectrl
	sta gamectrl
	
	lda camera_x_lo
	sec
	sbc temp2
	sta camera_x_lo
	
	; carry set - no borrow
	; carry clear - borrow (subtract 1 more)
	bcs :+
	inc temp1
	sec
:	lda camera_x
	sbc temp1
	sta camera_x
	
	lda camera_x_pg
	sbc #0
	bmi @limit
	
	sta camera_x_pg
	
	; figure out if we need to limit
	
	lda camlefthi     ; check if [camlefthi, camleftlo] < [camera_x_pg, camera_x]
	cmp camera_x_pg
	bne :+
	lda camleftlo
	cmp camera_x
	
:	; if camleft > cameraX then limit
	bcc @noLimit

@doLimit:
	lda camleftlo
	sec
	sbc camera_x
	sta scrchklo
	
	lda temp1
	sec
	sbc scrchklo
	sta temp1
	
	lda camleftlo
	sta camera_x
	lda camlefthi
	sta camera_x_pg
	
@noLimit:
	; also move the PLAYER's x coordinate
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
	rts

; ** SUBROUTINE: ph_scroll_d_cond
ph_scroll_d_cond:
	lda #gs_camlock
	bit gamectrl
	beq @dontReturn
@scrollRet2:
	rts

@dontReturn:
	lda #g3_blockinp
	bit gamectrl3
	bne @scrollRet2

	lda #gs_lvlend
	bit gamectrl
	beq @scrollRet2   ; if level data hasn't actually ended
	
	lda #g2_scrstopD
	bit gamectrl2
	bne @scrollRet2
	
	lda #rf_godown
	bit roomflags
	beq @scrollRet2
	
	lda #0
	sec
	sbc camera_x_lo
	sta temp2
	
	lda player_y
	sec
	sbc camera_y_sub
	bcc @scrollRet2
	sta temp1
	
	cmp #vscrolllimit
	bcc @scrollRet2
	beq @scrollRet2
	
	sec
	sbc #vscrolllimit
	sta temp1          ; store the difference here as we'll need it later
	
	; A holds the difference. divide it by 1/4
	lda temp2
	lsr temp1
	ror
	lsr temp1
	ror
	lsr temp1
	ror
	sta temp2
	
	lda temp1
	cmp #camspeed
	bcc @noFix
	
	lda #camspeed
	sta temp1
	lda #0
	sta temp2
@noFix:
	
	lda temp2
	clc
	adc camera_x_lo
	sta camera_x_lo
	bcc :+
	inc temp1
	
	; first of all, check if the camera should be locked
:	lda #rf_new
	bit roomflags
	beq @dontCheckCamLimit
	
	lda camera_y_hi
	lsr
	lda camera_y
	ror
	cmp camera_y_max
	beq @scrollRet
	
@dontCheckCamLimit:
	lda temp1
	jsr gm_shifttraceYN
	
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
	
	; this is a down scroll, so the row that was revealed is the old camera_y, plus 30 tiles
	lda camera_y_hi
	lsr
	lda camera_y
	ror
	lsr
	lsr
	clc
	adc #30
	sta revealedrow
	
	lda camera_y
	clc
	adc #8
	sta temp1
	cmp #240
	bcc :+
	adc #15       ; carry set, so actually adds 16
	pha
	lda camera_y_hi
	eor #$01
	sta camera_y_hi
	pla
:	sta camera_y
	
	jsr xt_shift_entities_and_player_up
	
	; load a new set of tiles
	jsr xt_gener_tiles_below
	
@scrollRet:
	jmp gm_calculate_vert_offs

xt_shift_entities_and_player_up:
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
	bcc @wentOffScreen   ; if it didn't go below zero, don't clear
	;lda #0
	;sta sprspace+sp_kind, y
@dontSet:
	sta sprspace+sp_y, y
	
	lda sprspace+sp_kind, y
	sec
	sbc	#e_l1zipmovr
	cmp #2
	bcs @notZipMover
	
	lda sprspace+sp_l1zm_homey, y
	sec
	sbc #8
	sta sprspace+sp_l1zm_homey, y
	
@notZipMover:
	iny
	cpy #sp_max
	bne @entShiftLoop
	rts

@actuallyClearType:
	pla                  ; pop it because we don't actually need it
	lda #0
	sta sprspace+sp_kind, y
	beq @dontSet

@wentOffScreen:
	pha                  ; push the coord we calculated
	lda roomflags
	and #rf_new
	beq @actuallyClearType
	
	; ok, we're in a new format room, just toggle the limbo bit
	lda sprspace+sp_flags, y
	eor #ef_limbo
	sta sprspace+sp_flags, y
	pla
	jmp @dontSet

; ** SUBROUTINE: ph_scroll_u_cond
ph_scroll_u_cond:
	lda #gs_camlock
	bit gamectrl
	beq @scrollDontReturn
	
@scrollReturn2:
	rts

@scrollDontReturn:
	lda #g3_blockinp
	bit gamectrl3
	bne @scrollReturn2
	
	lda #gs_lvlend
	bit gamectrl
	beq @scrollReturn2   ; if level data hasn't actually ended
	
	lda #g2_scrstopD
	bit gamectrl2
	bne @scrollReturn2
	
	lda #rf_goup
	bit roomflags
	beq @scrollReturn2
	
	lda #0
	sec
	sbc camera_y_lo
	sta temp2
	
	lda player_y
	sec
	sbc camera_y_sub
	bcc @scrollReturn2
	sta temp1
	
	cmp #vscrolllimit
	bcs @scrollReturn2
	
	lda #vscrolllimit
	sec
	sbc temp1
	sta temp1            ; store the difference here as we'll need it later
	
	; A holds the difference. divide it by 1/4
	lda temp2
	lsr temp1
	ror
	lsr temp1
	ror
	lsr temp1
	ror
	sta temp2
	
	lda temp1
	cmp #camspeed
	bcc @noFix
	lda #camspeed
	sta temp1
	lda #0
	sta temp2
@noFix:
	
	lda camera_y_lo
	sec
	sbc temp2
	sta camera_y_lo
	
	; carry set - no borrow
	; carry clear - borrow (subtract 1 more)
	bcs :+
	inc temp1

	; this is an up scroll, so the row that was revealed is the old camera_y
:	jsr @calculateUpScrollRow
	
	; first of all, check if the camera should be locked
	lda #rf_new
	bit roomflags
	beq @dontCheckCamLimit
	
	lda camera_y
	lsr
	lsr
	lsr
	cmp camera_y_min
	bne @notZero
	lda camera_y_hi
	bne @notZero
	; if cameraY == camera_y_min, and cameraYHigh == 0, forbid scrolling more than "camera_y_sub" pixels
	lda temp1
	cmp camera_y_sub
	bcc @notZero
	lda camera_y_sub
	beq @loadRow
	sta temp1
	
@notZero:
@dontCheckCamLimit:
	lda temp1
	jsr gm_shifttraceYP
	
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
	pha
	lda camera_y_hi
	eor #$01
	sta camera_y_hi
	pla
:	sta camera_y
	
	jsr xt_shift_entities_and_player_down
	
@loadRow:
	lda #g2_loadvrow
	bit gamectrl2
	bne @generateTilesAbove
	
	ora gamectrl2
	sta gamectrl2
	bne @scrollRet
	
@generateTilesAbove:
	; load a new set of tiles
	jsr xt_gener_tiles_above
	
@scrollRet:
	jmp gm_calculate_vert_offs

@calculateUpScrollRow:
	lda camera_y_hi
	lsr
	lda camera_y
	ror
	lsr
	lsr
	sta revealedrow
	rts

xt_shift_entities_and_player_down:
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
	bcs @wentOffScreen     ; if it went above 256, don't clear
	;cmp #240
	;bcs @wentOffScreen
@dontSet:
	sta sprspace+sp_y, y
	
	lda sprspace+sp_kind, y
	sec
	sbc	#e_l1zipmovr
	cmp #2
	bcs @notZipMover
	
	lda sprspace+sp_l1zm_homey, y
	clc
	adc #8
	sta sprspace+sp_l1zm_homey, y
	
@notZipMover:
	iny
	cpy #sp_max
	bne @entShiftLoop
	rts
	
@actuallyClearType:
	pla                    ; pop it because we don't actually need it
	lda #0
	sta sprspace+sp_kind, y
	beq @dontSet

@wentOffScreen:
	pha                    ; push the coord we calculated
	lda roomflags
	and #rf_new
	beq @actuallyClearType
	
	; ok, we're in a new format room, just toggle the limbo bit
	lda sprspace+sp_flags, y
	eor #ef_limbo
	sta sprspace+sp_flags, y
	pla
	jmp @dontSet
