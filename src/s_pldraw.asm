; Copyright (C) 2024-2025 iProgramInCpp

; ** SUBROUTINE: sgm_draw_player
sgm_draw_player:
	; Initial conditions to prevent this function from running
	lda #pl_dead
	bit playerctrl
	beq @dontReturn
@return:
	rts

@dontReturn:
	lda respawntmr
	bne @return
	
	lda #pl_left
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
	lda player_y
	sec
	sbc camera_y_sub
	tay
	ldx #temp1           ; draw player
	lda player_x
	jsr gm_draw_2xsprite
	ldx #temp4           ; draw hair
	lda player_y
	sec
	sbc camera_y_sub
	clc
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

gm_climtbl:
	.byte plr_clim1_l, plr_clim1_r
	.byte plr_clim2_l, plr_clim2_r
	.byte plr_clim3_l, plr_clim3_r
	.byte plr_clim4_l, plr_clim4_r
	.byte plr_clim5_l, plr_clim5_r
	.byte plr_clim6_l, plr_clim6_r

gm_anim_table:
	; format: player L, player R, hair L, hair R, hair X off, hair Y off, flags, unused.
	.byte plr_idle1_l, plr_idle1_r, plr_hasta_l, plr_hasta_r, $00, $00, af_oddryth,$00  ; IDLE
	.byte <gm_walktbl, >gm_walktbl, plr_hamvr_l, plr_hamvr_r, $01, $00, af_4frame|af_wlkspd|af_oddryth, $00  ; WALK
	.byte plr_jump_l,  plr_jump_r,  plr_hamvu_l, plr_hamvu_r, $00, $00, af_lock,   $00  ; JUMP
	.byte plr_fall_l,  plr_fall_r,  plr_hamvd_l, plr_hamvd_r, $00, $00, af_lock,   $00  ; FALL
	.byte plr_push1_l, plr_push1_r, plr_hasta_l, plr_hasta_r, $01, $00, af_none|af_oddryth, $00  ; PUSH
	.byte <gm_climtbl, >gm_climtbl, plr_hasta_l, plr_hasta_r, $01, $00, af_6frame, $00  ; CLIMB
	.byte plr_dash_l,  plr_dash_r,  plr_hadsh_l, plr_hadsh_r, $00, $00, af_lock,   $00  ; DASH
	.byte plr_flip_l,  plr_flip_r,  plr_haflp_l, plr_haflp_r, $00, $00, af_lock,   $00  ; FLIP
	.byte plr_clim1_l, plr_clim1_r, plr_hasta_l, plr_hasta_r, $01, $00, af_lock,   $00  ; CLIMB IDLE
	.byte plr_pant1_l, plr_pant1_r, plr_hasta_l, plr_hasta_r, $00, $02, af_none|af_oddryth, $00  ; PANTING

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
	ldy #3
gm_advwalkloop:
	lsr temp2
	ror temp1
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

; ** SUBROUTINE: sgm_anim_mode
; desc:      Sets the current animation mode.  Resets the animation timer if necessary.
; arguments: A - new animation mode
sgm_anim_mode:
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
:	lda animflags
	and #af_6frame
	asl
	lda #0
	rol
	tay
	lda gm_animspeeds, y
	clc
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
	lda #af_6frame       ; load the 6 frame limit into X if needed
	bit animflags
	beq gm_timerNOT6f
	lda animtimer
	cmp #6
	bcc gm_donetimer
	sec
	sbc #6
	sta animtimer
	jmp gm_donetimer
gm_timerNOT6f:
	lda #af_noloop
	bit animflags
	beq gm_timernomax
	cpx animtimer        ; af_noloop set, so need to cap
	bcs gm_donetimer     ; X >= animtimer, so it's fine
	stx animtimer
	jmp gm_donetimer
gm_timernomax:
	txa
	and animtimer        ; af_noloop not set, so this is a loop
	sta animtimer
gm_donetimer:
	lda #(af_2frame|af_4frame|af_6frame)
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
	lda animmode
	cmp #am_walk
	beq gm_walkCheck
	clc
	lda animtimer
	and #1
	adc spryoffbase
	sta spryoff
gm_nooddrhythm:
	lda animmode
	cmp #am_climb
	bne gm_notclimbing
	lda animtimer
	lsr
	lsr
	eor #1
	sta sprxoff
gm_notclimbing:
	rts
gm_walkCheck:
	lda animtimer
	and #3
	tay
	lda sprYOffTable, y
	clc
	adc spryoffbase
	sta spryoff
	jmp gm_nooddrhythm

sprYOffTable:	.byte $00,$FF,$01,$FF

; ** SUBROUTINE: sgm_anim_player
; desc: Updates the sprite numbers for the player character and their hair.
sgm_anim_player:
	jsr gm_load_hair_palette
	
	lda amodeforce
	beq :+
	
	sta animmode
	jmp sgm_anim_mode
	
:	lda #0
	sta spryoff
	
	lda dashtime
	cmp #0
	bne gm_dashing
	
	lda #pl_climbing
	bit playerctrl
	bne gm_climbing
	
	lda player_vl_y
	bmi gm_jumping   ; if it's <0, then jumping
	
	lda #pl_pushing
	bit playerctrl
	bne gm_pushing
	
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
	jmp sgm_anim_mode

gm_flip:
	lda #am_flip
	jmp sgm_anim_mode

gm_dashing:
	lda #am_dash
	jmp sgm_anim_mode

gm_right:
	lda #am_walk
	jmp sgm_anim_mode

gm_jumping:
	lda #am_jump
	jmp sgm_anim_mode

gm_falling:
	lda #am_fall
	jmp sgm_anim_mode

gm_pushing:
	lda #pl_ground
	bit playerctrl
	beq gm_sliding
	lda #am_push
	jmp sgm_anim_mode

gm_sliding:
	lda #am_climbidl
	jmp sgm_anim_mode

gm_climbing:
	lda player_vl_y
	bne gm_actuallyclimbing
	lda player_vs_y
	bne gm_actuallyclimbing
	
	lda #am_climbidl
	jmp sgm_anim_mode
	
gm_actuallyclimbing:
	lda #am_climb
	jmp sgm_anim_mode

; ** SUBROUTINE: sgm_set_panting
; desc: Start panting.
sgm_set_panting:
	lda #am_panting
	sta amodeforce
	jmp sgm_anim_mode

; ** SUBROUTINE: sgm_anim_banks
; desc: Updates the loaded bank numbers for the current animation.
sgm_anim_banks:
	lda #pl_dead
	bit playerctrl
	bne @alsoUpdateFrameCounter ; don't update the bank if dead
	
	lda respawntmr
	bne @alsoUpdateFrameCounter
	
	lda animmode
	cmp #am_climb
	bne @standardAnimMode
	
	ldx animtimer
	dex
	beq :+
	ldx #1
:	stx spr0_bknum
	jmp @alsoUpdateFrameCounter

@standardAnimMode:
	; Update the current player sprite bank.
	lda animtimer
	and #1
	sta spr0_bknum
	
@alsoUpdateFrameCounter:
	lda framectr
	lsr
	lsr
	lsr
	and #3
	clc
	adc #4
	sta spr3_bknum
	rts

gm_animspeeds:	.byte animspd,animspd2
