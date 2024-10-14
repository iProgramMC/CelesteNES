; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_draw_2xsprite
; arguments: x - offset into zero page with sprite structure
;            a - x position, y - y position
; structure:  [shared attributes] [left sprite] [right sprite]
gm_draw_2xsprite:
	sta x_crd_temp
	sty y_crd_temp
	lda $00,x       ; get shared attributes into a
	inx
	ldy $00,x       ; get left sprite
	inx
	stx temp7
	jsr oam_putsprite
	ldx temp7
	ldy $00,x       ; get right sprite
	lda x_crd_temp  ; add 8 to x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	dex
	dex
	lda $00,x       ; get shared attributes again
	jsr oam_putsprite
	rts

deathtable1: .byte $FC, $FD, $00, $03, $04, $03, $00, $FD
deathtable2: .byte $00, $FD, $FC, $FD, $00, $03, $04, $03

gm_dead_sub1:
	lda deathtimer
	tay
	lda temp1
	beq :++
:	clc
	adc temp1
	dey
	bne :-
	sta temp1
:	rts
gm_dead_sub2:
	lda deathtimer
	tay
	beq :++
	lda temp2
:	clc
	adc temp2
	dey
	bne :-
	sta temp2
:	rts

; ** SUBROUTINE: gm_draw_dead
gm_draw_dead:
	lda #pl_dead
	bit playerctrl
	bne :+
	rts
:	ldy #0
gm_draw_dead_loop:
	lda deathtable1, y ; the X coordinate offset
	sta temp1
	lda deathtable2, y ; the Y coordinate offset
	sta temp2
	
	sty temp3
	jsr gm_dead_sub1
	jsr gm_dead_sub2
	ldy temp3
	
	lda player_x
	clc
	adc #4
	clc
	adc temp1
	sta x_crd_temp
	
	lda player_y
	clc
	adc #4
	clc
	adc temp2
	sta y_crd_temp
	
	; hackhack
	lda player_y
	cmp #$C0
	bcc :+
	cpy #4
	bcc :+
	jmp gm_draw_dead_done
	
:	lda plh_attrs
	sty temp3

	ldy deathtimer
	cpy #8
	bcc :+
	ldy #$96
	bne :++
:	ldy #$94
:	jsr oam_putsprite
	ldy temp3
	
	iny
	cpy #8
	bne gm_draw_dead_loop
	
	; increment death timer
gm_draw_dead_done:
	ldx deathtimer
	inx
	cpx #16
	bne :+
	jsr gm_respawn
:	stx deathtimer
	rts

; ** SUBROUTINE: gm_draw_player
gm_draw_player:
	lda #pl_dead
	bit playerctrl       ; don't draw player if dead
	beq :+
	rts
:	lda #pl_left
	bit playerctrl
	bne gm_facingleft
	lda #0
	ldx plr_spr_l
	ldy plr_spr_r
	sta temp1
	stx temp2
	sty temp3
	lda plh_attrs
	ldx plh_spr_l
	ldy plh_spr_r
	sta temp4
	stx temp5
	sty temp6
	jmp gm_donecomputing
gm_facingleft:
	lda #obj_fliphz
	ldx plr_spr_r
	ldy plr_spr_l
	sta temp1
	stx temp2
	sty temp3
	ora plh_attrs
	ldx plh_spr_r
	ldy plh_spr_l
	sta temp4
	stx temp5
	sty temp6
gm_donecomputing:
	ldx #temp1           ; draw player
	lda player_x
	ldy player_y
	jsr gm_draw_2xsprite
	ldx #temp4           ; draw hair
	clc
	lda player_y
	adc spryoff
	tay
	lda #pl_left
	bit playerctrl
	bne gm_sprxoffleft
	clc
	lda player_x
	adc sprxoff
	jmp gm_sprxoffdone
gm_sprxoffleft:
	sec
	lda player_x
	sbc sprxoff
gm_sprxoffdone:
	jsr gm_draw_2xsprite
	rts

gm_walktbl:
	.byte plr_walk1_l, plr_walk1_r
	.byte plr_walk1_l, plr_walk1_r
	.byte plr_walk2_l, plr_walk2_r
	.byte plr_walk2_l, plr_walk2_r

gm_anim_table:
	; format: player L, player R, hair L, hair R, hair X off, hair Y off, flags, unused.
	.byte plr_idle1_l, plr_idle1_r, plr_hasta_l, plr_hasta_r, $00, $00, af_none,   $00  ; IDLE
	.byte <gm_walktbl, >gm_walktbl, plr_hamvr_l, plr_hamvr_r, $00, $00, af_4frame|af_wlkspd|af_oddryth, $00  ; WALK
	.byte plr_jump_l,  plr_jump_r,  plr_hamvu_l, plr_hamvu_r, $00, $00, af_lock,   $00  ; JUMP
	.byte plr_fall_l,  plr_fall_r,  plr_hamvd_l, plr_hamvd_r, $00, $00, af_lock,   $00  ; FALL
	.byte plr_push1_l, plr_push1_r, plr_hasta_l, plr_hasta_r, $01, $00, af_none|af_oddryth, $00  ; PUSH
	.byte plr_clim1_l, plr_clim1_r, plr_hasta_l, plr_hasta_r, $01, $00, af_none,   $00  ; CLIMB
	.byte plr_dash_l,  plr_dash_r,  plr_hadsh_l, plr_hadsh_r, $00, $00, af_lock,   $00  ; DASH
	.byte plr_flip_l,  plr_flip_r,  plr_haflp_l, plr_haflp_r, $00, $00, af_lock,   $00  ; FLIP
	.byte plr_clim1_l, plr_clim1_r, plr_hasta_l, plr_hasta_r, $01, $00, af_lock,   $00  ; CLIMB IDLE

gm_anim_advwalkL:
	sec
	lda animtimersb
	sbc temp1
	sta animtimersb
	lda animtimer
	sbc temp2
	sta animtimer
	jmp gm_timeradvanced
gm_anim_advwalk:
	; advance the animation timer by the walk speed divided by 8
	lda player_vs_x
	sta temp1
	lda player_vl_x
	sta temp2
	clc
	ldy #3
gm_advwalkloop:
	lda temp2
	ror
	sta temp2
	lda temp1
	ror
	sta temp1
	dey
	bne gm_advwalkloop
	lda #pl_left         ; shift loop done, check which direction we should advance
	bit playerctrl
	bne gm_anim_advwalkL
	clc
	lda animtimersb
	adc temp1
	sta animtimersb
	lda animtimer
	adc temp2
	sta animtimer
	jmp gm_timeradvanced

; ** SUBROUTINE: gm_anim_mode
; desc:      Sets the current animation mode.  Resets the animation timer if necessary.
; arguments: A - new animation mode
gm_anim_mode:
	cmp animmode         ; check if the animation mode is the same
	beq gm_sameanim
	sta animmode         ; animation is different
	lda #0               ; clear animation timer
	sta animtimer
	sta animtimersb
	lda animmode         ; load animation data
	asl
	asl
	asl                  ; 8 bytes per animation state
	tax                  ; use as index into table
	lda gm_anim_table, x ; load animation frame pointer or left/right sprite
	inx
	sta anfrptrlo
	lda gm_anim_table, x
	inx
	sta anfrptrhi
	lda gm_anim_table, x
	inx
	sta plh_spr_l
	lda gm_anim_table, x
	inx
	sta plh_spr_r
	lda gm_anim_table, x
	inx
	sta sprxoff
	lda gm_anim_table, x
	inx
	sta spryoff
	sta spryoffbase
	lda gm_anim_table, x
	inx
	sta animflags
	;                      8th byte unused
	jmp gm_donetimer
gm_sameanim:
	lda #af_wlkspd
	bit animflags
	bne gm_anim_advwalk
	lda #af_lock         ; check if animtimer should be locked to 0
	bit animflags
	beq :+
	lda #0
	sta animtimer
	beq gm_donetimer
:	lda #af_lockto1      ; check if animtimer should be locked to 1
	bit animflags
	beq :+
	lda #1
	sta animtimer
	bne gm_donetimer
:	clc
	lda #animspd
	adc animtimersb
	sta animtimersb
	lda #0
	adc animtimer
	sta animtimer
gm_timeradvanced:
	ldx #$FF
	lda #af_2frame       ; load the 2 frame limit into X if needed
	bit animflags
	beq gm_timerNOT2f
	ldx #1
gm_timerNOT2f:
	lda #af_4frame       ; load the 4 frame limit into X if needed
	bit animflags
	beq gm_timerNOT4f
	ldx #3
gm_timerNOT4f:
	lda #af_noloop
	bit animflags
	beq gm_timernomax
	cpx animtimer        ; af_noloop set, so need to cap
	bcs gm_donetimer     ; X >= animtimer, so it's fine
	stx animtimer
	jmp gm_donetimer
gm_timernomax:
	txa                  ; af_noloop not set, so this is a loop
	and animtimer
	sta animtimer
gm_donetimer:
	lda #(af_2frame|af_4frame)
	bit animflags
	beq gm_regularload
	lda animtimer
	asl
	tay
	iny
	lda (anfrptrlo),y
	tax
	dey
	lda (anfrptrlo),y
	jmp gm_loaded
gm_regularload:
	lda anfrptrlo
	ldx anfrptrhi
gm_loaded:
	sta plr_spr_l
	stx plr_spr_r
	lda #af_oddryth
	bit animflags
	beq gm_nooddrhythm
	clc
	lda animtimer
	and #1
	adc spryoffbase
	sta spryoff
gm_nooddrhythm:
	rts

; ** SUBROUTINE: gm_anim_player
; desc: Updates the sprite numbers for the player character and their hair.
; note: gm_anim_player starts a little below.
gm_anim_player:
	lda #0
	sta spryoff
	ldx dashcount
	inx
	stx plh_attrs    ; set the palette to the dash count + 1
	lda dashtime
	cmp #0
	bne gm_dashing
	lda #pl_pushing
	bit playerctrl
	bne gm_pushing
	lda player_vl_y
	bmi gm_jumping   ; if it's <0, then jumping
	lda #pl_ground
	bit playerctrl
	beq gm_falling   ; if pl_ground set, then moving only in X direction
	lda player_vl_x  ; check if both components of the velocity are zero
	bne gm_anim_notidle
	lda player_vs_x
	beq gm_idle
gm_anim_notidle:
	lda #pl_left     ; check if facing left
	bit playerctrl
	beq gm_anim_right
	lda player_vl_x  ; load the player's velocity but flip its sign
	eor #$FF
	clc
	adc #1
	bmi gm_flip      ; if A <= 0, then flipping
	beq gm_flip
	jmp gm_right
gm_anim_right:
	lda player_vl_x
	bmi gm_flip      ; if A < 0, then flipping
	jmp gm_right     ; if A >= 0, then running. vl_x==vs_x==0 case is already handled.
gm_idle:
	lda #am_idle
	jmp gm_anim_mode
gm_flip:
	lda #am_flip
	jmp gm_anim_mode
gm_dashing:
	lda #am_dash
	jmp gm_anim_mode
gm_right:
	lda #am_walk
	jmp gm_anim_mode
gm_jumping:
	lda #am_jump
	jmp gm_anim_mode
gm_falling:
	lda #am_fall
	jmp gm_anim_mode
gm_pushing:
	lda #pl_ground
	bit playerctrl
	beq gm_sliding
	lda #am_push
	jmp gm_anim_mode
gm_sliding:
	lda #am_climbidl
	jmp gm_anim_mode
