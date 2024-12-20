; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_leaveroomD_FAR
; desc: Performs a transition, across multiple frames, going down.
.proc gm_leaveroomD_FAR
	lda #gs_camlock
	bit gamectrl
	bne returnEarly
	
	; try to leave the room above
	ldy warp_d
	cpy #$FF
	bne actuallyWarp
	; no warp assigned, return and continue with normal logic

returnEarly:
	rts

actuallyWarp:
	lda #0
	sta player_y
	
	lda warp_d_x
	pha
	
	lda #0
	sta camera_y_min
	sta camera_y_max
	
	jsr gm_calculate_lvlyoff
	
	ldy warp_d
	jsr xt_set_room
	
	pla
	sta temp3
	
	inc roomnumber
	
	; TODO: screw it, just do this. if we keep this hack in, also reduce the hacks that I did to try to make things work
	lda roomnumber
	eor #1
	jsr gm_unload_ents_room
	
	lda #g3_transitD
	ora gamectrl3
	sta gamectrl3
	
	lda lvlyoff
	sta ntrowhead

	lda #0
	sta ntrowhead2
	
	; add the X offset of this room to the name table and area table write heads
	lda temp3
	clc
	adc roombeglo2
	and #$3F
	sta roombeglo2
	sta ntwrhead
	sta arwrhead
	
	; multiply the X offset by 8, then add it to [roombeglo, roombeghi], and store to [camdst_x_pg, camdst_x]
	ldx #0
	lda temp3
	bpl :+
	dex
:	stx temp4	
	asl
	rol temp4
	asl
	rol temp4
	asl
	rol temp4
	sta temp3
	
	lda roombeglo
	clc
	adc temp3
	sta camdst_x
	lda roombeghi
	adc temp4
	sta camdst_x_pg
	
	lda camdst_x
	sta roombeglo
	sta camleftlo
	lda camdst_x_pg
	sta roombeghi
	sta camlefthi
	
	lda roomloffs
	asl
	asl
	asl
	clc
	adc camdst_x
	sta camdst_x
	bcc :+
	inc camdst_x_pg
	
:	; subtract it from the player X to determine the destination player X
	lda player_x
	clc
	adc camera_x
	sec
	sbc camdst_x
	sta player_x_d
	
	; calculate camoff - the increment we should add over a span of 32 frames to smoothly
	; scroll the camera
	jsr gm_leaveroomU_FAR::compute_camoff
	
	lda #0
	sta temp7                ; temp7 will now hold the camera's "sub X" position
	
	lda #0
	sta tr_scrnpos
	sta quaketimer
	
	; set the player's velocity to jump into the stage.
	lda #0
	sta player_vl_x
	sta player_vs_x
	sta dashcount
	
	; clear the camera stop bits
	lda gamectrl
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend|gs_dontgen)^$FF)
	sta gamectrl
	
	lda nmictrl
	and #((nc_flushcol|nc_flshpalv)^$FF)
	sta nmictrl
	
	; generate left offset, if needed.
	lda roomloffs
	pha
	beq @dontOffsetLeft
	
	jsr xt_gener_mts_ents_r

@offsetLeftLoop:
	jsr xt_gener_col_r
	jsr xt_leave_doframe
	
	dec roomloffs
	bne @offsetLeftLoop
	
@dontOffsetLeft:
	pla
	sta roomloffs
	
	; pre-generate all metatiles
	ldy #0
genloop:
	sty transtimer
	jsr xt_gener_mts_ents_r
	ldy transtimer
	iny
	cpy #36
	bne genloop
	
	jsr xt_generate_palette_data_V
	
	; now, we will want to wait for vblank. NMIs are disabled at this point
	; sometimes the code above is too slow so we may end up calling xt_leave_doframe
	; during vblank, the NMI is fired, but the NMI ends up sending stuff to the
	; PPU even after vblank.
	;
	; this is a HACK.
	jsr vblank_wait
	
	; preserve the camera stop bits temporarily.
	; we'll clear them so that xt_gener_col_r does its job.
	lda gamectrl
	and #(gs_scrstopR|gs_scrstodR|gs_lvlend)
	sta temp11
	
	lda nmictrl
	and #((nc_flushcol|nc_flshpalv)^$FF)
	sta nmictrl
	
	lda gamectrl
	eor temp11
	ora #gs_dontgen
	sta gamectrl
	
	lda roomflags
	and #rf_new
	beq skipNewMode
	jsr newModeTran
	
skipNewMode:
	; write 30 rows - these are not subject to camera limitations
	ldy #0
writeloop:
	sty transtimer
	jsr xt_gener_row_u
	
	; also bring the player up
	lda player_y
	sec
	sbc #cspeed
	cmp #$F0
	bcc :+
	;sec
	sbc #$10
:	sta player_y
	
	lda #cspeed
	jsr gm_shifttraceYN
	
	; and the camera down
	lda camera_y
	clc
	adc #cspeed
	cmp #$F0
	bcc :+
	clc
	adc #$10
:	sta camera_y
	sta camera_y_bs
	
	; add the relevant displacement [camoff_H, camoff_M, camoff_L] to the camera's position...
	; camoff_H is the low byte, camoff_M is the high byte.
	jsr gm_leaveroomU_FAR::addtocameraX
	
	; every some frames, add slightly more to the camera and player X to perform a course correction
	lda transtimer
	and #1
	bne :+
	jsr gm_leaveroomU_FAR::add2ndtocameraX
	
:	inc ntrowhead2
	jsr xt_leave_doframe
	
dontdeccamy:
	ldy transtimer
	iny
	cpy #30
	bne writeloop
	
	; add 32 to the name table write head
	lda ntwrhead
	clc
	adc #32
	sta ntwrhead
	
	; restore the camera flags
	lda gamectrl
	ora temp11
	sta gamectrl
	
	; snap the camera position properly
	lda camdst_x
	sta camera_x
	lda camdst_x_pg
	sta camera_x_pg
	and #1
	sta camera_x_hi
	
	lda player_x_d
	sta player_x
	lda #0
	sta player_sp_x
	
	lda #gs_scrstopR
	bit gamectrl
	bne dontdomore
	; camera wasn't stopped so draw 4 more cols
	ldy #0
:	sty transtimer
	jsr xt_gener_col_r
	jsr xt_leave_doframe
	ldy transtimer
	iny
	cpy #4
	bne :-
	
	; generate one more column
	lda #gs_scrstopR
	bit gamectrl
	bne dontdomore
	
	jsr xt_gener_mts_ents_r
	
dontdomore:
	lda gamectrl
	and #(gs_dontgen ^ $FF)
	sta gamectrl
	
	lda lvlyoff
	asl
	asl
	asl
	sta camera_y
	sta camera_y_bs
	
	lda #(g3_transitD ^ $FF)
	and gamectrl3
	sta gamectrl3
	
	lda roomnumber
	eor #1
	jsr gm_unload_ents_room
	jmp gm_calculate_vert_offs

newModeTran:
	; prepare row to generate
	lda #1
	ldy #0
@newModeLoop2:
	sta temprow1, y
	sta temprow2, y
	iny
	cpy #32
	bne @newModeLoop2
	
	lda #32
	sta wrcountHR1
	sta wrcountHR2
	
@newModeLoop:
	lda camera_y
	beq @endNewModeLoop
	sec
	sbc #8
	sta camera_y
	
	lda camera_y_hi
	and #1
	sta ppuaddrHR1+1
	
	lda camera_y
	and #%11111000
	; sta temp10
	; --- here camera_y_tile * 8
	asl
	rol ppuaddrHR1+1
	asl
	rol ppuaddrHR1+1
	sta ppuaddrHR1
	; boom, now it's 32
	lda #$20
	clc
	adc ppuaddrHR1+1
	sta ppuaddrHR1+1
	
	eor #$04
	sta ppuaddrHR2+1
	lda ppuaddrHR1
	sta ppuaddrHR2
	
	lda #nc_flushrow
	ora nmictrl
	sta nmictrl
	
	jsr xt_leave_doframe
	jmp @newModeLoop

@endNewModeLoop:
	lda #29
	sta ntrowhead
	lda #0
	sta lvlyoff
	rts
.endproc

; ** SUBROUTINE: gm_leaveroomL_FAR
; desc: Performs a transition, across multiple frames, going left.
.proc gm_leaveroomL_FAR
	lda #$00
	sta player_x
	
	; * If the camera is locked then we have no reason to leave
	lda #gs_camlock
	bit gamectrl
	bne returnEarly
	
	; * If the rightward camera limit wasn't reached yet then we have no reason to leave
	lda camera_x
	cmp camleftlo
	bne returnEarly
	lda camera_x_pg
	cmp camlefthi
	bne returnEarly
	
	; Now leave the room through the right side
	ldy warp_l_y
	sty transoff
	ldy warp_l
	cpy #$FF
	bne actuallyTransition
	
returnEarly:
	lda #1
	rts                      ; no warp was assigned there so return
actuallyTransition:
	lda #0
	sta camera_y_min
	sta camera_y_max
	
	jsr gm_calculate_lvlyoff
	
	jsr xt_set_room
	
	inc roomnumber
	
	; disable player climbing
	lda playerctrl
	and #<~(pl_climbing|pl_nearwall|pl_wallleft)
	sta playerctrl
	
	lda #g3_transitL
	ora gamectrl3
	sta gamectrl3
	
	; set the beginning of the room to the proper place
	lda roombeglo2
	sta plattemp1   ; keep the old beginning for now
	sta plattemp2
	
	sec
	sbc roomsize
	and #$3F
	sta roombeglo2
	sta ntwrhead
	sta arwrhead
	
	; need to move the camera to [cameraXpg, cameraX] - [256]
	lda camera_x
	sta camdst_x
	lda camera_x_pg
	
	sec
	sbc #1
	sta camdst_x_pg
	
	; the room itself starts at [cameraXpg, cameraX] - [roomsize*8]
	lda #0
	sta temp2
	lda roomsize
	asl
	rol temp2
	asl
	rol temp2
	asl
	rol temp2
	sta temp1
	
	lda camera_x
	sec
	sbc temp1
	sta roombeglo
	sta camleftlo
	
	lda camera_x_pg
	sbc temp2
	sta roombeghi
	sta camlefthi
	
	; now, the offset is constant: 8 pixels across 32 frames.
	lda #0
	sta tr_scrnpos
	sta quaketimer
	
	; calculate the new level Y offset
	lda transoff
	bmi transneg
	
	lda lvlyoff              ; transoff is a positive value.
	clc
	adc transoff
	cmp #$1E
	bcc transdone
	sbc #$1E                 ; carry set, means it's >= 30
	jmp transdone
	
transneg:
	lda lvlyoff              ; transoff is a negative value.
	adc transoff
	bcs transdone
	adc #$1E                 ; carry clear, means it went into the negatives
	;jmp transdone

transdone:
	sta lvlyoff
	
	lda gamectrl             ; clear the camera stop bits
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend|gs_dontpal)^$FF)
	sta gamectrl
	
	lda camera_x
	and #%11111100
	sta camera_x
	
	; pre-generate all metatiles
	ldy #0
generateLoop:
	sty transtimer
	
	jsr xt_gener_mts_ents_r
	
	; hopefully this'll solve some potential issues
	lda nmictrl
	and #<~nc_flshpalv
	sta nmictrl
	
	lda arwrhead
	sta ntwrhead
	and #3
	cmp #3
	bne noPalette
	
	jsr xt_palette_data_column
	
noPalette:
	ldy transtimer
	iny
	cpy roomsize
	bne generateLoop
	
	lda gamectrl             ; clear these bits to allow for generation
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend)^$FF)
	sta gamectrl
	
	ldy #32
transLoopMain:
	sty transtimer
	
	lda player_x
	clc
	adc #cspeed
	bcc :+
	lda #$F0
:	cmp #$F0
	bcc :+
	lda #$F0
:	sta player_x
	
	lda camera_x
	sec
	sbc #cspeed
	sta camera_x
	lda camera_x_pg
	sbc #0
	sta camera_x_pg
	and #1
	sta camera_x_hi
	
	lda #cspeed
	jsr gm_shiftrighttrace
	
	jsr gm_leaveroomR_FAR::shiftPlayerY
	
	ldx plattemp1
	dex
	txa
	and #$3F
	sta plattemp1
	sta ntwrhead
	
	; don't actually try to generate new tiles now
	; also don't try to generate palettes, we'll do that separely below
	lda gamectrl
	pha
	ora #(gs_dontgen | gs_dontpal)
	sta gamectrl
	
	jsr xt_gener_col_r
	
	pla
	sta gamectrl
	
	lda plattemp1
	and #$03
	cmp #$03
	bne :+
	lda plattemp1
	jsr updatePalettes
	
	; wait for a frame to prepare more graphics
:	jsr xt_leave_doframe
	ldy transtimer
	dey
	bne transLoopMain
	
	lda gamectrl             ; clear the camera stop bits
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend)^$FF)
	sta gamectrl
	
	; ok, but we have like a couple more columns to generate
	lda roombeglo2
	sta ntwrhead
	sta arwrhead
	
	lda gamectrl             ; clear these bits to allow for generation
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend)^$FF)
	ora #(gs_dontgen|gs_dontpal)
	sta gamectrl
	
	ldy roomsize
transLoopAfter:
	sty transtimer
	
	jsr xt_gener_col_r
	
	lda ntwrhead
	and #$03
	cmp #$03
	bne :+
	lda ntwrhead
	jsr updatePalettes
	
:	jsr xt_leave_doframe
	
	ldy transtimer
	dey
	cpy #32
	bne transLoopAfter
	
	lda gamectrl
	ora #(gs_scrstopR|gs_scrstodR|gs_lvlend)
	and #<~(gs_dontgen|gs_dontpal)
	sta gamectrl
	
	lda camera_x
	sta camlimit
	lda camera_x_pg
	and #1
	sta camera_x_hi
	sta camlimithi
	
	; finally, done.
	lda plattemp2
	sta ntwrhead
	sta arwrhead
	sta trarwrhead
	
	lda #0
	sta dashcount
	lda lvlyoff
	asl
	asl
	asl
	sta camera_y
	sta camera_y_bs
	
	lda gamectrl3
	and #<~g3_transitL
	sta gamectrl3
	
	lda roomnumber
	eor #1
	jsr gm_unload_ents_room
	
	lda #2
	sta climbcdown
	
	lda #0
	sta climbbutton
	rts

updatePalettes:
	; ntwrhead: 00HXXXxx (x - ignored)
	; index into ntattrdata: 0HYYYXXX
	pha
	and #%00100000
	asl
	sta temp1
	
	pla
	lsr
	lsr
	and #%00000111
	ora temp1
	tay
	
	ldx #0
generatePalettesLoop:
	lda ntattrdata, y
	sta temppal, x
	
	; increment the Y register, Y-wise, to move to the next row within ntattrdata
	tya
	clc
	adc #%00001000
	tay
	
	inx
	cpx #8
	bne generatePalettesLoop
	
	lda nmictrl
	ora #nc_flshpalv
	sta nmictrl
	rts
.endproc
