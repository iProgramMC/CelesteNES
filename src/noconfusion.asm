
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
