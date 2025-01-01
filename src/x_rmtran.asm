; Copyright (C) 2024 iProgramInCpp

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
.endproc

; ** SUBROUTINE: xt_get_warp_r
; desc: Gets the Right warp number and Y offset, depending on the player's Y position,
;       and stores them in the A register, and transoff, respectively.
.proc xt_get_warp_r
	lda warp_ralt_y
	beq justReturnNormal
	
	cmp player_y
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
	
	lda #g3_transitR
	ora gamectrl3
	sta gamectrl3
	
	lda trarwrhead
	sta arwrhead
	sta ntwrhead
	
	; load the room beginning pixel
	lda ntwrhead             ; NOTE: assumes arwrhead in [0, 64)
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
	and #1
	sta camera_x_hi
	
	lda #cspeed
	jsr gm_shifttrace
	
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
	
	lda #0
	sta dashcount            ; reset some things on room transition
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
	jsr gm_unload_ents_room
	
	jsr gm_calculate_vert_offs
	
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
	rts
.endproc

; ** SUBROUTINE: gm_leaveroomU_FAR
; desc: Performs a transition, across multiple frames, going up.
.proc gm_leaveroomU_FAR
loadCount := trantmp5
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
	jsr gm_unload_ents_room
	
	lda #g3_transitU
	ora gamectrl3
	sta gamectrl3
	
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
	lda #rf_nicevert
	bit roomflags
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
	
	lda #0
	sta roomloffs
	
	jmp @dontCalculateXOffset

@normalTransition:
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
	lda #0
	sta player_vl_x
	sta player_vs_x
	sta dashcount
	
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
	cpy loadCount
	bne genloop
	
	lsr loadCount
	lsr loadCount
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
	
	; also bring the player down
	lda player_y
	clc
	adc #cspeed
	cmp #$E0
	bcc :+
	lda #$E0
:	sta player_y
	
	lda #cspeed
	jsr gm_shifttraceYP
	
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
	and #$3F
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
	
	lda #rf_nicevert
	bit roomflags
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
	lda player_y
	cmp startpy
	bcc finalloopdone
	
finalloop:
	lda player_y
	sec
	sbc #4
	sta player_y
	jsr gm_addtrace
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
	
	lda roomnumber
	eor #1
	jsr gm_unload_ents_room
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
	and #1
	sta camera_x_hi
	
	lda player_sp_x
	sec
	sbc camoff_L
	sta player_sp_x
	lda player_x
	sbc camoff_M
	sta player_x
	
	lda camoff_M
	jsr gm_shifttrace
	
	
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
	and #1
	sta camera_x_hi
	
	lda player_sp_x
	sec
	sbc camoff2_L
	sta player_sp_x
	lda player_x
	sbc camoff2_M
	sta player_x
	
	lda camoff2_M
	jsr gm_shifttrace
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
	rts
.endproc

.include "noconfusion.asm"
