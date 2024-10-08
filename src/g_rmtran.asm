; Copyright (C) 2024 iProgramInCpp

gm_leave_doframe:
	jsr gm_draw_player
	jsr gm_unload_os_ents
	;jsr gm_draw_entities
	
	lda #1
	sta debug           ; end frame
	
	jsr ppu_nmi_on
	jsr nmi_wait
	jsr ppu_nmi_off	
	
	lda #0
	sta debug           ; start frame
	
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
	;ora #gs_deferpal
	sta gamectrl
	lda camera_x
	and #%11111100
	sta camera_x
	ldx trarwrhead
	stx arwrhead
	stx ntwrhead
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
	
	lda #8
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
	sbc #$24
	and #$3F
	sta ntwrhead
	lda arwrhead
	sec
	sbc #$25
	and #$3F
	sta arwrhead
	
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
	
	; set the player's velocity to jump into the stage.
	lda #0
	sta player_vl_x
	sta player_vs_x
	sta dashcount
	
	; set the auto jump flag. it'll be cleared when the player lands
	lda #g2_autojump
	ora gamectrl2
	sta gamectrl2
	
	lda #(jumpvel ^ $FF + 1)
	sta player_vl_y
	lda #(jumpvello ^ $FF + 1)
	sta player_vs_y
	
	; clear the camera stop bits
	lda gamectrl
	and #((gs_scrstopR|gs_scrstodR|gs_flstcolR|gs_flstpalR)^$FF)
	sta gamectrl
	
	; pre-generate all metatiles
	ldy #0
:	sty transtimer
	jsr h_gener_ents_r
	jsr h_gener_mts_r
	ldy transtimer
	iny
	cpy #36
	bne :-
	
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
	
	; and the camera up
	lda camera_y
	sec
	sbc #cspeed
	cmp #$F0
	bcc :+
	sec
	sbc #$10
:	sta camera_y
	
	dec ntrowhead2
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
	
@dontdomore:
	lda gamectrl
	and #(gs_dontgen ^ $FF)
	sta gamectrl
	
	lda lvlyoff
	asl
	asl
	asl
	sta camera_y
	rts
