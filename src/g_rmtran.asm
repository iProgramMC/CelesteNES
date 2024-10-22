; Copyright (C) 2024 iProgramInCpp

gm_leave_doframe:
	jsr gm_draw_player
	jsr gm_unload_os_ents
	jsr gm_draw_entities
	
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	
	jmp com_clear_oam

cspeed = 8

; ** SUBROUTINE: gm_leaveroomR
; desc: Performs a transition, across multiple frames, going right.
gm_leaveroomR:
	lda #$F0
	sta player_x
	; now leave the room through the right side
	ldy warp_r_y
	sty transoff
	ldy warp_r
	cpy #$FF
	bne :+
	rts                      ; no warp was assigned there so return
:	jsr gm_set_room
	
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
	
	clc
	lda camera_x_pg
	adc #1
	sta roombeghi
	
	lda #0
	sta tr_scrnpos
	sta quaketimer
	
	clc
	lda transoff
	bmi gm_roomRtransneg
	lda lvlyoff              ; transoff is a positive value.
	adc transoff
	cmp #$1E
	bcc gm_roomRtransdone
	sbc #$1E                 ; carry set, means it's >= 28
	jmp gm_roomRtransdone
gm_roomRtransneg:
	lda lvlyoff              ; transoff is a negative value.
	adc transoff
	bcs gm_roomRtransdone
	adc #$1E                 ; carry clear, means it went into the negatives
	jmp gm_roomRtransdone
gm_roomRtransdone:
	sta lvlyoff
	lda gamectrl             ; clear the camera stop bits
	and #((gs_scrstopR|gs_scrstodR)^$FF)
	sta gamectrl
	lda camera_x
	and #%11111100
	sta camera_x
	jsr h_gener_ents_r
	jsr h_gener_mts_r
	ldy #4
gm_roomRtranloopI:
	sty transtimer
	jsr h_gener_col_r
	jsr gm_leave_doframe
	ldy transtimer
	dey
	bne gm_roomRtranloopI
	ldy #32
gm_roomRtranloop:
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
	
	lda transoff
	ror
	ror
	ror                      ; lvlyoff: 11000000
	and #%11000000
	sta trantmp1
	lda transoff
	lsr
	lsr                      ; lvlyoff: 00111111
	sta trantmp2
	lda #%11100000
	bit trantmp2
	beq :+
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
	bcc gm_roomRtrannocap
	lda trantmp2
	bpl gm_roomRtranpluscap
	lda camera_y
	sbc #$10
	sta camera_y
	jmp gm_roomRtrannocap
gm_roomRtranpluscap:
	lda camera_y
	clc
	adc #$10
	sta camera_y
gm_roomRtrannocap:
	sec
	lda player_sp_y
	sbc trantmp1
	sta player_sp_y
	lda player_y
	sbc trantmp2
	sta player_y
	
	lda #cspeed
	adc camera_rev
	sta camera_rev
	cmp #8
	bcs gm_roomRtrangen
gm_roomRtrangenbk:
	jsr gm_leave_doframe
	ldy transtimer
	dey
	bne gm_roomRtranloop
	lda #0
	sta dashcount            ; reset some things on room transition
	lda lvlyoff
	asl
	asl
	asl
	sta camera_y
	rts

gm_roomRtrangen:
	jsr h_gener_col_r
	lda camera_rev
	sec
	sbc #8
	sta camera_rev
	jmp gm_roomRtrangenbk

; ** SUBROUTINE: gm_leaveroomU
; desc: Performs a transition, across multiple frames, going up.
gm_leaveroomU:
	; try to leave the room above
	ldy warp_u
	cpy #$FF
	bne :+
	rts                   ; no warp assigned, continue with normal logic
:	lda #0
	sta player_y
	
	ldy warp_u_x
	sty temp3
	
	ldy warp_u
	jsr gm_set_room
	
	lda lvlyoff
	clc
	adc #29               ; ntrowhead += 20
	cmp #$1E
	bcc :+
	sbc #$1E
:	sta ntrowhead
	
	lda #29
	sta ntrowhead2
	
	lda ntwrhead
	sec
	sbc #$20
	and #$3F
	sta ntwrhead
	lda arwrhead
	sec
	sbc #$21
	and #$3F
	sta arwrhead
	
	; add the X offset of this room to the name table and area table write heads
	lda temp3
	clc
	adc ntwrhead
	and #$3F
	sta ntwrhead
	
	lda temp3
	clc
	adc arwrhead
	and #$3F
	sta arwrhead
	
	; add the X offset to the current camera X.
	lda temp3
	asl
	asl
	asl
	sta temp1
	lda temp3
	lsr
	lsr
	lsr
	lsr
	lsr
	sta temp2
	
	clc
	lda camera_x
	adc temp1
	sta camdst_x
	lda camera_x_pg
	adc temp2
	sta camdst_x_pg
	
	; subtract it from the player X to determine the destination player X
	sec
	lda player_x
	sbc temp1
	sta player_x_d
	
	; calculate camoff - the increment we should add over a span of 32 frames to smoothly
	; scroll the camera
	jsr @compute_camoff
	
	; shift the entirety of camoff by 3 to allow for a course correction during some frames
	jsr @compute_camoff2
	
	lda #0
	sta temp7                ; temp7 will now hold the camera's "sub X" position
	
	; load the room beginning pixel
	lda ntwrhead             ; NOTE: assumes arwrhead in [0, 64)
	sta roombeglo2
	asl
	asl
	asl                      ; multiply by 8
	sta roombeglo
	
	clc
	lda camera_x_pg
	adc #1
	sta roombeghi
	
	lda #0
	sta tr_scrnpos
	sta quaketimer
	
	; set the player's velocity to jump into the stage.
	lda #0
	sta player_vl_x
	sta player_vs_x
	sta dashcount
	
	; set the auto jump flag. it'll be cleared when the player lands
	lda #g2_autojump
	ora gamectrl2
	sta gamectrl2
	
	lda #jumpvelHI
	sta player_vl_y
	lda #jumpvelLO
	sta player_vs_y
	lda #jumpsustain
	sta jcountdown
	
	; clear the camera stop bits
	lda gamectrl
	and #((gs_scrstopR|gs_scrstodR|gs_flstcolR|gs_flstpalR)^$FF)
	sta gamectrl
	
	; pre-generate all metatiles
	ldy #0
@genloop:
	sty transtimer
	jsr h_gener_ents_r
	jsr h_gener_mts_r
	ldy transtimer
	iny
	cpy #36
	bne @genloop
	
	; pre-generate all palette data
	ldy #0
@palloop:
	sty temp6
	jsr h_palette_data_column
	
	; an inner loop to copy from temppal to loadedpals
	lda temp6
	asl
	asl
	asl
	tax
	ldy #0
	
:	lda temppal, y
	sta loadedpals, x
	inx
	iny
	cpy #8
	bne :-
	
	ldy temp6
	iny
	cpy #8
	bne @palloop
	
	; now, we will want to wait for vblank. NMIs are disabled at this point
	; sometimes the code above is too slow so we may end up calling gm_leave_doframe
	; during vblank, the NMI is fired, but the NMI ends up sending stuff to the
	; PPU even after vblank.
	;
	; this is a HACK.
	jsr vblank_wait
	
	; preserve the camera stop bits temporarily.
	; we'll clear them so that h_gener_col_r does its job.
	lda gamectrl
	and #(gs_scrstopR|gs_scrstodR)
	sta temp9
	
	lda gamectrl
	and #((gs_flstcolR|gs_flstpalR)^$FF)
	eor temp9
	ora #gs_dontgen
	sta gamectrl
	
	; write 30 rows - these are not subject to camera limitations
	ldy #0
@writeloop:
	sty transtimer
	jsr h_gener_row_u
	
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
	sec
	sbc #$10
:	sta camera_y
	
	; add the relevant displacement [camoff_H, camoff_M, camoff_L] to the camera's position...
	; camoff_H is the low byte, camoff_M is the high byte.
	jsr @addtocameraX
	
	; every some frames, add slightly more to the camera and player X to perform a course correction
	lda transtimer
	and #1
	bne :+
	jsr @add2ndtocameraX
	
:	dec ntrowhead2
	jsr gm_leave_doframe
	
@dontdeccamy:
	ldy transtimer
	iny
	cpy #30
	bne @writeloop
	
	; add 32 to the name table write head
	lda ntwrhead
	clc
	adc #32
	sta ntwrhead
	
	; restore the camera flags
	lda gamectrl
	ora temp9
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
	bne @dontdomore
	; camera wasn't stopped so draw 4 more cols
	ldy #0
:	sty transtimer
	jsr h_gener_col_r
	jsr gm_leave_doframe
	ldy transtimer
	iny
	cpy #4
	bne :-
	
	; generate one more column
	lda #gs_scrstopR
	bit gamectrl
	bne @dontdomore
	
	jsr h_gener_ents_r
	jsr h_gener_mts_r
	
@dontdomore:
	lda gamectrl
	and #(gs_dontgen ^ $FF)
	sta gamectrl
	
	; pranked. we will do one final loop to bring the player Y up to the start
	lda player_y
	cmp startpy
	bcc @finalloopdone
	
@finalloop:
	lda player_y
	sec
	sbc #4
	sta player_y
	bcc @messedupcase
	cmp startpy
	bcc @finalloopdone
	beq @finalloopdone
	
	jsr gm_leave_doframe
	jmp @finalloop
	
@finalloopdone:
	lda lvlyoff
	asl
	asl
	asl
	sta camera_y
	rts
	
@messedupcase:
	lda #0
	sta player_y
	beq @finalloopdone

@addtocameraX:
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
	
	rts

@add2ndtocameraX:
	lda camoff_sub
	clc
	adc camoff2_L
	sta camoff_sub
	lda camera_x
	adc camoff2_M
	sta camera_x
	lda camera_x_pg
	adc #0
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

@compute_camoff:
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
	
	lda camoff_M
	asl
	asl
	asl
	sta camoff_L
	
	lda camoff_M
	rol
	rol
	rol
	rol
	and #%00000111
	sta temp7
	
	lda camoff_H
	asl
	asl
	asl
	ora temp7
	sta camoff_M
	
	lda camoff_H
	lsr
	lsr
	lsr
	sta camoff_H

@compute_camoff2:
	; calculate the difference in [camoff_H, camoff_M] (high to low)
	lda camdst_x
	sec
	sbc camera_x
	sta camoff2_L
	lda camdst_x_pg
	sbc camera_x_pg
	sta camoff2_M
	rts
