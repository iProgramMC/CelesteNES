; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: xt_unload_ents_room
; desc: Unloads all entities with a specific room number.
; arguments: A - the room number to unload entities from.
; note: Can only be used to unload entities from the previous room.
; note: Also marks for collection ALL strawberries.
xt_unload_ents_room:
	and #1
	asl     ; set the ef_oddroom flag, depending on the parity of the room number.
	sta temp1
	
	ldx #0
@loop:
	lda sprspace+sp_kind, x
	beq @skipThisObject
	
	lda sprspace+sp_flags, x
	and #ef_oddroom
	cmp temp1
	bne @skipThisObject
	
	; check if entity is a strawberry. we do not unload strawberries
	lda #e_strawb
	cmp sprspace+sp_kind, x
	beq @isStrawBerry
	
@isStrawBerryRemoveAnyway:
	lda sprspace+sp_kind, x
	cmp #e_cassmgr
	bne :+
	jsr gm_unload_cassette_manager
:	lda #0
	sta sprspace+sp_kind, x
	
@skipThisObject:
	inx
	cpx #sp_max
	bne @loop
	rts
	
@isStrawBerry:
	; check if the berry was collected
	lda sprspace+sp_strawb_flags, x
	and #esb_picked
	beq @isStrawBerryRemoveAnyway
	
	; forcefully pick it up
	jsr gm_pick_up_berry_entity
	jmp @skipThisObject

; ** SUBROUTINE: gm_calculate_lvlyoff
; desc: Calculates the new lvlyoff if this level was a vertically scrolling one
.proc gm_calculate_lvlyoff
	lda lvlyoff
	sta old_lvlyoff
	lda roomflags
	sta old_roomflgs
	
	and #rf_new
	beq dontTouch
	
	; is new format room
	lda camera_y
	lsr
	lsr
	lsr
	sec
	sbc camera_y_min
	; difference now added to lvlyoff
	clc
	adc lvlyoff
	cmp #$1E
	bcc :+
	sbc #$1E
:	sta lvlyoff
dontTouch:
	rts
.endproc

cspeed = 8

; ** SUBROUTINE: xt_get_warp_l
; desc: Gets the Left warp number and Y offset, depending on the player's Y position,
;       and stores them in the A register, and transoff, respectively.
.proc xt_get_warp_l
	lda player_y
	cmp #$F0
	bcs returnNone
	
	lda warp_lalt_y
	beq justReturnNormal
	
	cmp player_y
	bcc justReturnNormal
	
	lda warp_lalt_yo
	sta transoff
	lda warp_lalt
	rts
	
justReturnNormal:
	lda warp_l_y
	sta transoff
	lda warp_l
	rts

returnNone:
	lda #255
	rts
.endproc

; ** SUBROUTINE: xt_get_warp_r
; desc: Gets the Right warp number and Y offset, depending on the player's Y position,
;       and stores them in the A register, and transoff, respectively.
.proc xt_get_warp_r
	jsr get_player_y_for_warp
	sta nitrantmp
	cmp #$F0
	bcs xt_get_warp_l::returnNone
	
	lda warp_ralt_y
	beq justReturnNormal
	
	cmp nitrantmp
	bcc justReturnNormal
	
	lda warp_ralt_yo
	sta transoff
	lda warp_ralt
	rts
	
justReturnNormal:
	lda warp_r_y
	sta transoff
	lda warp_r
	rts
.endproc

; ** SUBROUTINE: xt_calc_player_x
; desc: Gets the player's X position, relative to the room's beginning. Stores the result in temp1.
; clobbers: temp1, temp2, A reg
.proc xt_calc_player_x
	lda player_x
	clc
	adc camera_x
	sta temp1
	lda camera_x_pg
	adc #0
	sta temp2
	
	lda temp1
	sec
	sbc roombeglo
	sta temp1
	lda temp2
	sbc roombeghi
	sta temp2
	
	lda temp2
	bmi @returnZero
	bne @return255
	lda temp1
	rts
@returnZero:
	lda #0
	sta temp1
	rts
@return255:
	lda #$FF
	sta temp1
	rts
.endproc

; ** SUBROUTINE: xt_get_warp_u
; desc: Gets the Up warp number and X offset, depending on the player's X position,
;       and stores them in the A register, and transoff, respectively.
.proc xt_get_warp_u
	lda warp_ualt_x
	beq justReturnNormal
	
	jsr xt_calc_player_x
	lda warp_ualt_x
	cmp temp1
	bcc justReturnNormal
	
	lda warp_ualt_xo
	sta transoff
	lda warp_ualt
	rts
	
justReturnNormal:
	lda warp_u_x
	sta transoff
	lda warp_u
	rts
.endproc

; ** SUBROUTINE: xt_get_warp_d
; desc: Gets the Down warp number and X offset, depending on the player's X position,
;       and stores them in the A register, and transoff, respectively.
.proc xt_get_warp_d
	lda warp_dalt_x
	beq justReturnNormal
	
	jsr xt_calc_player_x
	lda warp_dalt_x
	cmp temp1
	bcc justReturnNormal
	
	lda warp_dalt_xo
	sta transoff
	lda warp_dalt
	rts
	
justReturnNormal:
	lda warp_d_x
	sta transoff
	lda warp_d
	rts
.endproc

; ** SUBROUTINE: gm_leaveroomR_FAR
; desc: Performs a transition, across multiple frames, going right.
.proc gm_leaveroomR_FAR
	lda #$F0
	sta player_x
	
	; * If the camera is locked then we have no reason to leave
	lda #gs_camlock
	bit gamectrl
	bne returnEarly
	
	; * If the rightward camera limit wasn't reached yet then we have no reason to leave
	lda #gs_scrstodR
	bit gamectrl
	beq returnEarly
	
	; Now leave the room through the right side
	jsr xt_get_warp_r
	tay
	cpy #$FF
	bne actuallyTransition
	
returnEarly:
	lda #1
	rts                      ; no warp was assigned there so return
actuallyTransition:
	lda #g3_transitR
	jsr gm_common_side_warp_logic
	
	lda trarwrhead
	sta arwrhead
	sta ntwrhead
	
	; load the room beginning pixel
	;lda ntwrhead             ; NOTE: assumes arwrhead in [0, 64)
	sta roombeglo2
	asl
	asl
	asl                      ; multiply by 8
	sta roombeglo
	sta camleftlo
	
	clc
	lda camera_x_pg
	adc #1
	sta roombeghi
	sta camlefthi
	
	lda #0
	sta tr_scrnpos
	sta quaketimer
	
	lda #3
	sta dreinvtmr
	
	jsr adjustTransitionOffset
	
	clc
	lda transoff
	bmi transneg
	
	lda lvlyoff              ; transoff is a positive value.
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
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend)^$FF)
	sta gamectrl
	
	lda camera_x
	and #%11111100
	sta camera_x
	jsr xt_gener_mts_ents_r
	
	ldy #4
transLoopInitial:
	sty transtimer
	jsr xt_gener_col_r
	jsr gm_unload_os_ents
	jsr xt_leave_doframe
	ldy transtimer
	dey
	bne transLoopInitial

	ldy #32
transLoopMain:
	sty transtimer
	sec
	lda player_x
	sbc #cspeed
	bcs :+
	lda #0
:	sta player_x             ; move the player left by cspeed pixels per transition
	clc
	lda camera_x
	adc #cspeed              ; add cspeed to the camera X
	sta camera_x
	lda camera_x_pg
	adc #0
	sta camera_x_pg
	
	lda #cspeed
	jsr xt_shifttrace
	
	lda camera_y_sub
	beq :+
	dec camera_y_sub
:
	jsr shiftPlayerY
	
	lda #cspeed
	adc camera_rev
	sta camera_rev
	cmp #8
	bcs transGenerate
transGenerateBack:
	
	jsr xt_leave_doframe
	ldy transtimer
	dey
	bne transLoopMain
	
	jsr gm_reset_dash_and_stamina
	
	lda lvlyoff
	asl
	asl
	asl
	sta camera_y
	sta camera_y_bs
	
	lda #(g3_transitR ^ $FF)
	and gamectrl3
	sta gamectrl3
	
	lda roomnumber
	eor #1
	jsr xt_unload_ents_room
	
	jsr gm_calculate_vert_offs
	jsr xt_disable_adv_trace
	jsr gm_update_bg_bank
	
	lda #2
	sta climbcdown
	
	lda #0
	sta climbbutton
	rts

transGenerate:
	jsr xt_gener_col_r
	lda camera_rev
	sec
	sbc #8
	sta camera_rev
	jmp transGenerateBack

shiftPlayerY:
	ldx transoff
	stx trantmp2
	lsr trantmp2
	lda #0
	ror
	lsr trantmp2
	ror
	sta trantmp1
	txa
	bpl :+
	lda #%11100000
	ora trantmp2
	sta trantmp2
:	clc
	lda trantmp3
	adc trantmp1
	sta trantmp3
	lda camera_y
	adc trantmp2
	sta camera_y
	cmp #$F0
	bcc transNoCap
	lda trantmp2
	bpl transAddCap
	lda camera_y
	sbc #$10
	sta camera_y
	jmp transNoCap
transAddCap:
	lda camera_y
	clc
	adc #$10
	sta camera_y
transNoCap:
	sta camera_y_bs
	sec
	lda player_sp_y
	sbc trantmp1
	sta player_sp_y
	lda player_y
	sbc trantmp2
	sta player_y
	rts

adjustTransitionOffset:
	lda #rf_new
	bit old_roomflgs
	beq @return
	
	; In new style rooms, the current scroll Y may be different from what it's supposed to be.
	; Note, we entered the room with a camera Y of 0, so it's enough to see the amount that it diverged by
	lda camera_y
	sec
	sbc camera_y_bs
	cmp #240
	bcc :+
	sbc #16
:	sta warp_t_no
	
	lda #240
	sec
	sbc warp_t_no   ; [0, 239] becomes [239, 0]
	lsr
	lsr
	lsr             ; [0, 29]
	cmp #$1E
	bcc :+
	sbc #$1E
:	sec
	sbc old_lvlyoff ; old_lvlyoff between [0, 29]
	bcs :+
	adc #$1E
:	clc
	adc transoff
	sta transoff
	
@return:
	lda #0
	sta dustrhythm
	rts
.endproc

; ** SUBROUTINE: gm_leaveroomU_FAR
; desc: Performs a transition, across multiple frames, going up.
.proc gm_leaveroomU_FAR
loadCount  := trantmp5
palLoadCnt := trantmp4
	lda #gs_camlock
	bit gamectrl
	bne returnEarly
	
	; try to leave the room above
	jsr xt_get_warp_u
	tay
	cpy #$FF
	bne actuallyWarp
	; no warp assigned, return and continue with normal logic

returnEarly:
	rts

actuallyWarp:
	lda #0
	sta player_y
	
	lda transoff
	pha
	
	lda #0
	sta camera_y_min
	sta camera_y_max
	
	jsr gm_calculate_lvlyoff
	
	lda #g3_transitU
	ora gamectrl3
	sta gamectrl3
	
	lda nmictrl
	and #<~(nc_flushrow|nc_flushpal|nc_flushcol|nc_flshpalv)
	sta nmictrl
	
	;ldy warp_u
	jsr xt_set_room
	
	pla
	sta temp3
	
	lda #36
	sta loadCount
	
	inc roomnumber
	
	; TODO: screw it, just do this. if we keep this hack in, also reduce the hacks that I did to try to make things work
	lda roomnumber
	eor #1
	jsr xt_unload_ents_room
	
	lda lvlyoff
	clc
	adc #29               ; ntrowhead += 20
	cmp #$1E
	bcc :+
	sbc #$1E
:	sta ntrowhead
	
	lda #29
	sta ntrowhead2
	
	; if this room has a "nice" transition (both rooms are located at the same X offset with the same width)
	lda #wf_nicevert
	bit warpflags
	beq @normalTransition
	
	lda camera_x
	sta camdst_x
	lda camera_x_pg
	sta camdst_x_pg
	
	lda roombeglo2
	sta ntwrhead
	sta arwrhead
	
	lda player_x
	sta player_x_d
	
	lda roomsize
	sta loadCount
	lsr
	lsr
	sta palLoadCnt
	
	lda #0
	sta roomloffs
	sta temp3
	
	jmp @dontCalculateXOffset

@normalTransition:
	lda loadCount
	clc
	adc roomloffs
	sta loadCount
	lsr
	lsr
	tax
	dex
	stx palLoadCnt

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
	; the bit that you just shifted out... increment camera_x_pg with it
	bcc :+
	inc camera_x_pg	
:	clc
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

@dontCalculateXOffset:
	; calculate camoff - the increment we should add over a span of 32 frames to smoothly
	; scroll the camera
	jsr compute_camoff

	lda #0
	sta temp7                ; temp7 will now hold the camera's "sub X" position
	
	lda #0
	sta tr_scrnpos
	sta quaketimer
	
	; set the player's velocity to jump into the stage.
	jsr gm_reset_dash_and_stamina
	
	lda #jumpvelHI
	sta player_vl_y
	lda #jumpvelLO
	sta player_vs_y
	lda #jumpsustain
	sta jcountdown
	
	; clear the camera stop bits
	lda gamectrl
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend)^$FF)
	sta gamectrl
	
	lda nmictrl
	and #((nc_flushcol|nc_flshpalv)^$FF)
	sta nmictrl
	
	; pre-generate all metatiles
	ldy #0
genloop:
	sty transtimer
	jsr xt_gener_mts_ents_r
	ldy transtimer
	iny
	cpy loadCount
	bne genloop
	
	lda palLoadCnt
	sta loadCount
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
	
	lda temp11
	pha
	
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
	
	; also bring the player down
	lda player_y
	clc
	adc #cspeed
	cmp #$E0
	bcc :+
	lda #$E0
:	sta player_y
	
	lda #cspeed
	jsr xt_shifttraceYP
	
	; and the camera up
	lda camera_y
	sec
	sbc #cspeed
	cmp #$F0
	bcc :+
	;sec
	sbc #$10
:	sta camera_y
	sta camera_y_bs
	
	; add the relevant displacement [camoff_H, camoff_M, camoff_L] to the camera's position...
	; camoff_H is the low byte, camoff_M is the high byte.
	jsr addtocameraX
	
	lda camera_y_sub
	beq :+
	dec camera_y_sub
:
	; every some frames, add slightly more to the camera and player X to perform a course correction
	lda transtimer
	and #1
	bne :+
	jsr add2ndtocameraX
	
:	dec ntrowhead2
	jsr xt_leave_doframe
	
dontdeccamy:
	ldy transtimer
	iny
	cpy #30
	bne writeloop
	
	; add 32 to the name table write head
	lda ntwrhead
	clc
	adc #$20
	clc
	adc roomloffs
	and #$3F
	sta ntwrhead
	
	; restore the camera flags
	pla
	ora gamectrl
	sta gamectrl
	
	; snap the camera position properly
	lda camdst_x
	sta camera_x
	lda camdst_x_pg
	sta camera_x_pg
	
	;lda camera_x
	;sta roombeglo
	;sta camleftlo
	;lda camera_x_pg
	;sta roombeghi
	;sta camlefthi
	
	lda player_x_d
	sta player_x
	lda #0
	sta player_sp_x
	
	lda #gs_scrstopR
	bit gamectrl
	bne dontdomore
	
	lda #wf_nicevert
	bit warpflags
	bne dontdraw4morecols
	
	; camera wasn't stopped so draw 4 more cols
	ldy #0
:	sty transtimer
	jsr xt_gener_col_r
	jsr xt_leave_doframe
	ldy transtimer
	iny
	cpy #4
	bne :-
	
dontdraw4morecols:
	; generate one more column
	lda #gs_scrstopR
	bit gamectrl
	bne dontdomore
	
	jsr xt_gener_mts_ents_r
	
dontdomore:
	lda gamectrl
	and #(gs_dontgen ^ $FF)
	sta gamectrl
	
	; pranked. we will do one final loop to bring the player Y up to the start
	lda #rf_nobringup
	bit roomflags
	bne finalloopdone
	
	lda player_y
	cmp startpy
	bcc finalloopdone
	
finalloop:
	jsr ph_addtrace_ref_from_xt
	lda player_y
	sec
	sbc #4
	sta player_y
	bcc messedupcase
	cmp startpy
	bcc finalloopdone
	beq finalloopdone
	
	jsr xt_leave_doframe
	jmp finalloop
	
finalloopdone:
	lda lvlyoff
	asl
	asl
	asl
	sta camera_y
	sta camera_y_bs
	
	lda #(g3_transitU ^ $FF)
	and gamectrl3
	sta gamectrl3
	
	lda #2
	sta climbcdown
	sta dreinvtmr
	
	lda roomnumber
	eor #1
	jsr xt_unload_ents_room
	jsr gm_update_bg_bank
	jsr xt_disable_adv_trace
	jmp gm_calculate_vert_offs
	
messedupcase:
	lda #0
	sta player_y
	beq finalloopdone

addtocameraX:
	lda camoff_sub
	clc
	adc camoff_L
	sta camoff_sub
	lda camera_x
	adc camoff_M
	sta camera_x
	lda camera_x_pg
	adc camoff_H
	sta camera_x_pg
	
	lda player_sp_x
	sec
	sbc camoff_L
	sta player_sp_x
	lda player_x
	sbc camoff_M
	sta player_x
	
	lda camoff_M
	jsr xt_shifttrace
	
	
	lda camera_y_sub
	beq @return
	and #7
	tay
	dey
	sty camera_y_sub
@return:
	rts

add2ndtocameraX:
	lda camoff_sub
	clc
	adc camoff2_L
	sta camoff_sub
	lda camera_x
	adc camoff2_M
	sta camera_x
	lda camera_x_pg
	adc camoff2_H
	sta camera_x_pg
	
	lda player_sp_x
	sec
	sbc camoff2_L
	sta player_sp_x
	lda player_x
	sbc camoff2_M
	sta player_x
	
	lda camoff2_M
	jsr xt_shifttrace
	rts

compute_camoff:
	; calculate the difference in [camoff_H, camoff_M] (high to low)
	lda camdst_x
	sec
	sbc camera_x
	sta camoff_M
	lda camdst_x_pg
	sbc camera_x_pg
	sta camoff_H
	
	; divide it by 32. This will make it so that the camera X displacement
	; is applied smoothly over 32 frames.
	
	; eventually, the camera's difference will be stored in [camoff_H, camoff_M, camoff_L] (high to low)
	; camoff_H    camoff_M
	; xxxxxxxx yyyyyyyy
	;   SHALL BECOME:
	; camoff_H    camoff_M    camoff_L
	; 00000xxx xxxxxyyy yyyyy000
	
	lda #0
	sta camoff_L
	
	lda camoff_H
.repeat 5, idx
	cmp #$80
	ror
	ror camoff_M
	ror camoff_L
.endrepeat
	sta camoff_H
	
	; shift the entirety of camoff by 3 to allow for a course correction during some frames
	
	; calculate the difference in [camoff_H, camoff_M] (high to low)
	lda camdst_x
	sec
	sbc camera_x
	sta camoff2_L
	lda camdst_x_pg
	sbc camera_x_pg
	sta camoff2_M
	ldx #0
	cmp #$80
	bcc :+
	dex
:	stx camoff2_H
	rts

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
	sta dustrhythm
	rts
.endproc

; ** SUBROUTINE: gm_leaveroomD_FAR
; desc: Performs a transition, across multiple frames, going down.
.proc gm_leaveroomD_FAR
loadCount  := trantmp5
palLoadCnt := trantmp4
	lda #gs_camlock
	bit gamectrl
	bne returnEarly
	
	; try to leave the room above
	jsr xt_get_warp_d
	tay
	cpy #$FF
	bne actuallyWarp
	; no warp assigned, return and continue with normal logic

returnEarly:
	rts

actuallyWarp:
	lda #0
	sta player_y
	
	lda transoff
	pha
	
	lda #0
	sta camera_y_min
	sta camera_y_max
	
	jsr gm_calculate_lvlyoff
	
	lda #g3_transitD
	ora gamectrl3
	sta gamectrl3
	
	lda nmictrl
	and #<~(nc_flushrow|nc_flushpal|nc_flushcol|nc_flshpalv)
	sta nmictrl
	
	;ldy warp_d
	jsr xt_set_room
	
	pla
	sta temp3
	
	lda #36
	sta loadCount
	
	inc roomnumber
	
	; TODO: screw it, just do this. if we keep this hack in, also reduce the hacks that I did to try to make things work
	lda roomnumber
	eor #1
	jsr xt_unload_ents_room
	
	lda lvlyoff
	sta ntrowhead

	lda #0
	sta ntrowhead2
	
	; if this room has a "nice" transition (both rooms are located at the same X offset with the same width)
	lda #wf_nicevert
	bit warpflags
	beq @normalTransition
	
	lda camera_x
	sta camdst_x
	lda camera_x_pg
	sta camdst_x_pg
	
	lda roombeglo2
	sta ntwrhead
	sta arwrhead
	
	lda player_x
	sta player_x_d
	
	lda roomsize
	sta loadCount
	lsr
	lsr
	sta palLoadCnt
	
	lda #0
	sta roomloffs
	sta temp3
	
	jmp @dontCalculateXOffset

@normalTransition:
	lda loadCount
	clc
	adc roomloffs
	sta loadCount
	lsr
	lsr
	tax
	dex
	stx palLoadCnt
	
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
	; the bit that you just shifted out... increment camera_x_pg with it
	bcc :+
	inc camdst_x_pg	
:	clc
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
	
@dontCalculateXOffset:
	; calculate camoff - the increment we should add over a span of 32 frames to smoothly
	; scroll the camera
	jsr gm_leaveroomU_FAR::compute_camoff
	
	lda #0
	sta temp7                ; temp7 will now hold the camera's "sub X" position
	
	lda #0
	sta tr_scrnpos
	sta quaketimer
	
	jsr gm_reset_dash_and_stamina
	
	; clear the camera stop bits
	lda gamectrl
	and #((gs_scrstopR|gs_scrstodR|gs_lvlend|gs_dontgen)^$FF)
	sta gamectrl
	
	lda nmictrl
	and #((nc_flushcol|nc_flshpalv)^$FF)
	sta nmictrl
	
	lda #3
	sta dreinvtmr
	
	; pre-generate all metatiles
	ldy #0
genloop:
	sty transtimer
	jsr xt_gener_mts_ents_r
	ldy transtimer
	iny
	cpy loadCount
	bne genloop
	
	lda palLoadCnt
	sta loadCount
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
	
	lda temp11
	pha
	
	lda roomflags
	and #rf_new
	beq skipNewMode
	jsr newModeTran
	
skipNewMode:
	; write 30 rows - these are not subject to camera limitations
	ldy #0
writeloop:
	sty transtimer
	jsr generateRowGoingDown
	
	; also bring the player up
	lda player_y
	sec
	sbc #cspeed
	cmp #$F0
	bcc :+
	sbc #$10 ; sec
:	sta player_y
	
	lda #cspeed
	jsr xt_shifttraceYN
	
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
	
	lda camera_y_sub
	beq :+
	dec camera_y_sub
	
:	; every some frames, add slightly more to the camera and player X to perform a course correction
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
	adc #$20
	clc
	adc roomloffs
	and #$3F
	sta ntwrhead
	
	; restore the camera flags
	pla
	ora gamectrl
	sta gamectrl
	
	; snap the camera position properly
	lda camdst_x
	sta camera_x
	lda camdst_x_pg
	sta camera_x_pg
	
	lda player_x_d
	sta player_x
	lda #0
	sta player_sp_x
	
	lda #gs_scrstopR
	bit gamectrl
	bne dontdomore
	
	lda #wf_nicevert
	bit warpflags
	bne dontdraw4morecols
	
	; camera wasn't stopped so draw 4 more cols
	ldy #0
:	sty transtimer
	jsr xt_gener_col_r
	jsr xt_leave_doframe
	ldy transtimer
	iny
	cpy #4
	bne :-
	
dontdraw4morecols:
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
	sta camera_y_bs
	sta camera_y
	
	lda roomflags
	and #(rf_new | rf_inverted)
	cmp #(rf_new | rf_inverted)
	bne @skipNewAndInverted
	
	lda #0
	sta camera_y_hi
	lda #60
	sec
	sbc roomheight
	asl
	asl
	asl
	sta camera_y
	
	jsr correctEntityYPos
	
@skipNewAndInverted:
	lda #(g3_transitD ^ $FF)
	and gamectrl3
	sta gamectrl3
	
	lda roomnumber
	eor #1
	jsr xt_unload_ents_room
	jsr gm_update_bg_bank
	jsr xt_disable_adv_trace
	jmp gm_calculate_vert_offs

newModeTran:
	; prepare row to generate
	lda #1
	ldy #0
	sty nitrantmp
@newModeLoop2:
	sta temprow1, y
	sta temprow2, y
	iny
	cpy #32
	bne @newModeLoop2
	
	lda #32
	sta wrcountHR1
	sta wrcountHR2
	
	; check if the inverted flag is set - means the room starts at the bottom
	lda roomflags
	and #rf_inverted
	beq @newModeLoop
	
	; yes, so we need to calculate the destination camera Y from the room height
	lda #60
	sec
	sbc roomheight
	asl
	asl
	asl
	sta nitrantmp
	
@newModeLoop:
	lda camera_y
	cmp nitrantmp
	beq @endNewModeLoop
	clc
	adc #8
	cmp #240
	bcc :+
	lda #0
:	sta camera_y
	
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
	lda #0
	sta ntrowhead
	sta ntrowhead2
	sta lvlyoff
	sta dustrhythm
	rts

generateRowGoingDown:
	lda roomflags
	and #rf_inverted
	beq @normally
	
	lda ntrowhead
	pha
	lda ntrowhead2
	pha
	
	; calculate (60 - roomheight), then add it to ntrowhead and
	; subtract from ntrowhead2, making sure they don't go over 30
	lda #60
	sec
	sbc roomheight
	sta nitrantmp
	
	clc
	adc ntrowhead
	cmp #30
	bcc :+
	sbc #30
:	sta ntrowhead

	lda nitrantmp
	clc
	adc ntrowhead2
	cmp #30
	bcc :+
	sbc #30
:	sta ntrowhead2
	
	jsr xt_gener_row_u
	
	pla
	sta ntrowhead2
	pla
	sta ntrowhead
	rts

@normally:
	jmp xt_gener_row_u

correctEntityYPos:
	lda roomheight
	sec
	sbc #30
	asl
	asl
	asl
	tax
	beq @returnEarly
	ldy #0
@loop:
	txa
	; add it. if the result is >240, then flip the limbo bit
	clc
	adc sprspace+sp_y, y
	bcs @overflow
	sta sprspace+sp_y, y
@overflowBack:
	iny
	cpy #sp_max
	bne @loop
@returnEarly:
	rts
@overflow:
	sta sprspace+sp_y, y
	lda sprspace+sp_flags, y
	eor #ef_limbo
	sta sprspace+sp_flags, y
	jmp @overflowBack
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
	
	jsr xt_get_warp_l
	
	; Now leave the room through the right side
	tay
	cpy #$FF
	bne actuallyTransition
	
returnEarly:
	lda #1
	rts                      ; no warp was assigned there so return
actuallyTransition:
	lda #g3_transitL
	jsr gm_common_side_warp_logic
	
	; set the beginning of the room to the proper place
	lda roombeglo2
	sta trantmp4    ; keep the old beginning for now
	sta trantmp5
	
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
	
	jsr gm_leaveroomR_FAR::adjustTransitionOffset
	
	; calculate the new level Y offset
	clc
	lda transoff
	bmi transneg
	
	lda lvlyoff              ; transoff is a positive value.
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
	
	lda #cspeed
	jsr xt_shiftrighttrace
	
	lda camera_y_sub
	beq :+
	dec camera_y_sub
:
	jsr gm_leaveroomR_FAR::shiftPlayerY
	
	ldx trantmp4
	dex
	txa
	and #$3F
	sta trantmp4
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
	
	lda trantmp4
	and #$03
	cmp #$03
	bne :+
	lda trantmp4
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
	cpy #$21
	bcc transLoopDone
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

transLoopDone:
	lda gamectrl
	ora #(gs_scrstopR|gs_scrstodR|gs_lvlend)
	and #<~(gs_dontgen|gs_dontpal)
	sta gamectrl
	
	lda camera_x
	sta camlimit
	lda camera_x_pg
	sta camlimithi
	
	; finally, done.
	lda trantmp5
	sta ntwrhead
	sta arwrhead
	sta trarwrhead
	
	jsr gm_reset_dash_and_stamina
	
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
	jsr xt_unload_ents_room
	
	lda #2
	sta climbcdown
	
	lda #0
	sta climbbutton
	
	jsr gm_update_bg_bank
	jsr xt_disable_adv_trace
	jmp gm_calculate_vert_offs

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
	
	lda #0
	sta dustrhythm
	rts
.endproc

.proc xt_disable_adv_trace
	lda #0
	sta advtracesw
	rts
.endproc

; ** SUBROUTINE: gm_common_side_warp_logic
; desc: Handles some common things that both the Left and Right warps do.
; parameters:
;     A Register - The transition flag to OR into gamectrl3.
.proc gm_common_side_warp_logic
	ora gamectrl3
	sta gamectrl3
	
	lda #0
	sta camera_y_min
	sta camera_y_max
	
	lda nmictrl
	and #<~(nc_flushrow|nc_flushpal|nc_flushcol|nc_flshpalv)
	sta nmictrl
	
	jsr gm_calculate_lvlyoff
	jsr xt_set_room
	
	inc roomnumber
	
	; disable player climbing
	lda playerctrl
	and #<~(pl_climbing|pl_nearwall|pl_wallleft)
	sta playerctrl
	
	lda #3
	sta dreinvtmr
	lda #0
	sta dustrhythm
	rts
.endproc

.proc ph_addtrace_ref_from_xt
	ldx #<gm_addtrace
	ldy #>gm_addtrace
	lda #prgb_phys
	jmp far_call2
.endproc

.proc xt_shifttrace
	sta temp12
	ldx #<ph_altshifttrace
	ldy #>ph_altshifttrace
	lda #prgb_phys
	jmp far_call2
.endproc
.proc xt_shiftrighttrace
	sta temp12
	ldx #<ph_altshiftrighttrace
	ldy #>ph_altshiftrighttrace
	lda #prgb_phys
	jmp far_call2
.endproc
.proc xt_shifttraceYN
	sta temp12
	ldx #<ph_altshifttraceYN
	ldy #>ph_altshifttraceYN
	lda #prgb_phys
	jmp far_call2
.endproc
.proc xt_shifttraceYP
	sta temp12
	ldx #<ph_altshifttraceYP
	ldy #>ph_altshifttraceYP
	lda #prgb_phys
	jmp far_call2
.endproc