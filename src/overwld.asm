; Copyright (C) 2024 iProgramInCpp

; ** GAMEMODE: gamemode_overwd
gamemode_overwd:
	lda #os_1stfr
	bit owldctrl
	bne gamemode_overwd_update
	
	lda #0
	sta ow_sellvl
	
	lda #0
	sta camera_x
	sta camera_x_hi
	sta camera_y
	sta ppu_mask     ; disable rendering
	jsr vblank_wait
	ldy #(owld_palette - palettepage)
	jsr load_palette
	lda #$20
	jsr clear_nt
	
	jsr ow_draw_mtn
	jsr ow_draw_level_name
	jsr ow_draw_icon_fadeout
	;jsr tl_init_snow
	jsr ppu_rstaddr
	lda owldctrl
	ora #(os_1stfr | os_turnon)
	sta owldctrl
	jsr ow_select_banks
	jsr vblank_wait
	
gamemode_overwd_update:
	;jsr tl_update_snow
	;jsr tl_render_snow
	
	; draw features
	inc ow_timer
	jsr ow_handle_input
	jsr ow_level_slide
	jsr ow_draw_player
	jsr ow_draw_c0_hut
	jsr ow_draw_c1_city
	jsr ow_draw_c2_tower
	jsr ow_draw_c3_hotel
	jsr ow_draw_c4_cliff
	jsr ow_draw_c5_temple
	jsr ow_draw_c7_summit
	jsr ow_draw_icons
	
	lda #(os_leftmov | os_rightmov)
	bit owldctrl
	bne @return         ; don't handle controller input during a transition
	
	lda #(cont_a | cont_start)
	bit ow_temp5
	bne @startGame
@return:
	jmp game_update_return
	
@startGame:
	; now enter the game!
	jsr vblank_wait
	lda #0
	sta ppu_mask        ; disable rendering to obscure that gm_set_level sets the bank early
	
	ldx ow_sellvl
	;beq @isPrologue
	
	jmp tl_gameswitch

@isPrologue:
	jmp tl_prolswitch

; ** SUBROUTINE: ow_level_slide
; desc: Handles left/right slide of the level scroller.
ow_level_slide:
	lda #os_leftmov
	bit owldctrl
	beq @right
	
	; left
	lda ow_slidetmr
	bne :+
	lda ow_sellvl
	beq @cancel_slide   ; if level is already 0, then cancel!
	lda ow_slidetmr
:	cmp #12
	beq @cancel_slide
	cmp #4
	beq @left_frame4
	
	inc ow_slidetmr
	inc ow_iconoff
	inc ow_iconoff
	rts
	
@right:
	
	lda #os_rightmov
	bit owldctrl
	beq @ret
	
	; right
	lda ow_slidetmr
	bne :+
	lda ow_sellvl
	cmp #ow_maxlvl
	beq @cancel_slide   ; if level is already max, then cancel!
	lda ow_slidetmr
:	cmp #12
	beq @cancel_slide
	cmp #4
	beq @right_frame4
	
	inc ow_slidetmr
	dec ow_iconoff
	dec ow_iconoff
	rts
	
@ret:
	rts

@left_frame4:
	inc ow_slidetmr
	dec ow_sellvl
	lda #$F0
	sta ow_iconoff
	jsr ow_queue_lvlnm_upd
	rts

@right_frame4:
	inc ow_slidetmr
	inc ow_sellvl
	lda #$10
	sta ow_iconoff
	jsr ow_queue_lvlnm_upd
	rts

@cancel_slide:
	lda #((os_leftmov | os_rightmov) ^ $FF)
	and owldctrl
	sta owldctrl     ; clear the overworld control and return
	lda #0
	sta ow_iconoff
	sta ow_slidetmr
	rts

; ** SUBROUTINE: ow_draw_level_icon
; desc: Draws the icon corresponding to a level.
; params:
;     x_crd_temp: The X position of the left of the metasprite.
;     y_crd_temp: The Y position of the top  of the metasprite.
;     reg A: The level number in question.
;     reg Y: 
; clobbers: X, Y
ow_draw_level_icon:
	pha
	tax
	asl
	asl
	clc
	adc #$60
	pha
	tay
	lda ow_icon_pals, x
	jsr oam_putsprite
ow_draw_level_icon_rs_:
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	pla
	tay
	iny
	iny
	pla
	tax
	lda ow_icon_pals, x
	jmp oam_putsprite
ow_draw_level_icon_rs:
	pha
	tax
	asl
	asl
	clc
	adc #$60
	pha
	jmp ow_draw_level_icon_rs_
ow_draw_level_icon_ls:
	tax
	asl
	asl
	clc
	adc #$60
	tay
	lda ow_icon_pals, x
	jmp oam_putsprite

; ** SUBROUTINE: ow_draw_icon_fadeout
ow_Xof3A:
	lda #$3A
	ldx #11
:	sta ppu_data
	dex
	bne :-
	rts

ow_draw_icon_fadeout:
	ldy #0
:	lda #$20
	sta ppu_addr
	tya
	asl
	asl
	asl
	asl
	asl
	clc
	adc #$40
	sta ppu_addr
	; left side
	jsr ow_Xof3A
	lda #$FB
	sta ppu_data
	; skip a bunch
	lda #0
	ldx #8
:	sta ppu_data
	dex
	bne :-
	; right side
	lda #$FC
	sta ppu_data
	jsr ow_Xof3A
	iny
	cpy #2
	bne :--
	rts

; ** SUBROUTINE: ow_draw_icons
; desc: Draws the icons corresponding to the selected level and surrounding
;       levels to the screen.
ow_draw_icons:
	lda #((256-16)/2)
	clc
	adc ow_iconoff
	sta x_crd_temp          ; calculate the center coordinates
	
	lda #14                 ; note: ow_draw_level_icon clobbers x_crd_temp.
	sta y_crd_temp
	
	lda ow_sellvl
	jsr ow_draw_level_icon  ; draws the center icon.
	
	ldx ow_sellvl
	beq :+
	
	; draw the previous one
	lda #(((256-16)/2)-24)
	clc
	adc ow_iconoff
	sta x_crd_temp
	dex
	txa
	jsr ow_draw_level_icon
	
	lda ow_iconoff
	bmi :+
	beq :+
	
	ldx ow_sellvl
	dex
	dex
	bmi :+
	lda #(((256-16)/2)-24-24)
	clc
	adc ow_iconoff
	sta x_crd_temp
	txa
	jsr ow_draw_level_icon_rs
	
:	ldx ow_sellvl
	cpx #ow_maxlvl
	beq :+
	
	; draw the next one
	lda #(((256-16)/2)+24)
	clc
	adc ow_iconoff
	sta x_crd_temp
	inx
	txa
	jsr ow_draw_level_icon
	
	lda ow_iconoff
	bpl :+
	
	ldx ow_sellvl
	inx
	inx
	cpx #ow_maxlvl
	bcs :+
	lda #(((256-16)/2)+24+24)
	clc
	adc ow_iconoff
	sta x_crd_temp
	txa
	jsr ow_draw_level_icon_ls
	
:	; draw the arrows on the current level
	lda #((256-8)/2)
	sta x_crd_temp
	lda #4
	sta y_crd_temp
	
	lda #%00010000
	bit ow_timer
	beq :+
	inc y_crd_temp
	
:	lda #1
	ldy #$1E
	jsr oam_putsprite
	
	lda #((256-8)/2)
	sta x_crd_temp
	lda #24
	sta y_crd_temp
	
	lda #%00010000
	bit ow_timer
	beq :+
	dec y_crd_temp
	
:	lda #(1 | obj_flipvt)
	ldy #$1E
	jsr oam_putsprite
	
	rts

; ** SUBROUTINE: ow_draw_level_name
; desc: Draws the new level name.
; assumes: Inside of NMI
ow_draw_level_name:
	ldy #$20
	ldx #$C8
	jsr ppu_loadaddr
	
	lda ow_sellvl
	asl
	asl
	asl
	asl
	clc
	adc #<ow_level_names
	tax
	
	lda #>ow_level_names
	adc #0
	tay
	
	lda #16
	jmp ppu_wrstring

; ** SUBROUTINE: ow_handle_input
; desc: Handles input.
ow_handle_input:
	lda #(os_leftmov | os_rightmov)
	bit owldctrl
	beq :+
	rts
	
:	lda p1_cont
	eor p1_conto
	and p1_cont
	sta ow_temp5
	
	lda #0
	sta ow_slidetmr
	
	lda #cont_left
	bit ow_temp5
	beq :+
	
	lda owldctrl
	ora #os_leftmov
	and #(os_rightmov ^ $FF)
	sta owldctrl
	
:	lda #cont_right
	bit ow_temp5
	beq :+
	
	lda owldctrl
	ora #os_rightmov
	and #(os_leftmov ^ $FF)
	sta owldctrl
	
:	rts

ow_queue_lvlnm_upd:
	lda #os_updlvlnm
	ora owldctrl
	sta owldctrl
	rts

; ** SUBROUTINE: ow_anim_frame
; desc: Gets the current animation frame from the timer.
ow_anim_frame:
	lda ow_timer
	lsr
	lsr
	lsr
	and #3
	rts

; ** SUBROUTINE: ow_draw_player
; desc: Draws the player on the selected level's relevant waypoint.
ow_draw_player:
	lda #0
	sta ow_temp1
	jsr ow_anim_frame
	asl
	asl
	clc
	adc #$02
	sta ow_temp2
	clc
	adc #$02
	sta ow_temp3
	
	ldx ow_sellvl
	lda ow_waypoints_x, x
	ldy ow_waypoints_y, x
	ldx #<ow_temp1
	jsr gm_draw_2xsprite
	
	; draw hair
	lda #1
	sta ow_temp1
	lda #$1A
	sta ow_temp2
	lda #$1C
	sta ow_temp3
	
	ldx ow_sellvl
	lda ow_waypoints_y, x
	sta ow_temp4
	
	jsr ow_anim_frame
	and #1
	beq :+
	inc ow_temp4
	
:	ldy ow_temp4
	lda ow_waypoints_x, x
	ldx #<ow_temp1
	jsr gm_draw_2xsprite
	
	; draw arrow
	ldx ow_sellvl
	lda ow_waypoints_y, x
	clc
	adc #16
	sta y_crd_temp
	
	jsr ow_anim_frame
	and #1
	beq :+
	inc y_crd_temp
	
:	lda ow_waypoints_x, x
	clc
	adc #4
	sta x_crd_temp
	
	ldy #$1E
	lda #3
	jsr oam_putsprite
	
	rts

; ** SUBROUTINE: ow_draw_mtn
; desc: Draws a mountain to the screen.
ow_draw_mtn:
	lda #$21
	sta ow_temp1
	lda #$23
	sta ow_temp2
	
	lda #<MTN_data
	sta ow_temp3
	lda #>MTN_data
	sta ow_temp4
	
	lda #0
	sta ow_temp5
	
:	ldy ow_temp1
	ldx ow_temp2
	jsr ppu_loadaddr
	ldx ow_temp3
	ldy ow_temp4
	lda #26
	jsr ppu_wrstring
	
	clc
	lda ow_temp3
	adc #26
	sta ow_temp3
	lda ow_temp4
	adc #0
	sta ow_temp4
	
	clc
	lda ow_temp2
	adc #$20
	sta ow_temp2
	lda ow_temp1
	adc #0
	sta ow_temp1
	
	clc
	lda ow_temp5
	adc #1
	sta ow_temp5
	
	cmp #20
	bne :-
	
	; finally write palette data
	ldy #$23
	ldx #$C0
	jsr ppu_loadaddr
	ldx #<MTN_attr
	ldy #>MTN_attr
	lda #64
	jsr ppu_wrstring

	rts

; These routines draw features found on the world map.
yoff = 16
ow_draw_c0_hut:
	lda #100
	sta x_crd_temp
	lda #180+yoff
	sta y_crd_temp
	lda #1
	ldy #$32
	jmp oam_putsprite

ow_draw_c1_city:
	lda #111
	sta x_crd_temp
	lda #170+yoff
	sta y_crd_temp
	lda #3
	ldy #$28
	jsr oam_putsprite
	
	lda #125
	sta x_crd_temp
	lda #173+yoff
	sta y_crd_temp
	lda #1
	ldy #$30
	jsr oam_putsprite
	
	lda #129
	sta x_crd_temp
	lda #170+yoff
	sta y_crd_temp
	lda #3
	ldy #$28
	jsr oam_putsprite
	
	lda #122
	sta x_crd_temp
	lda #166+yoff
	sta y_crd_temp
	lda #2
	ldy #$2E
	jsr oam_putsprite
	
	lda #130
	sta x_crd_temp
	lda #161+yoff
	sta y_crd_temp
	lda #2
	ldy #$28
	jsr oam_putsprite
	
	lda #114
	sta x_crd_temp
	lda #158+yoff
	sta y_crd_temp
	lda #1
	ldy #$30
	jsr oam_putsprite
	
	lda #122
	sta x_crd_temp
	lda #155+yoff
	sta y_crd_temp
	lda #1
	ldy #$2A
	jsr oam_putsprite
	
	lda #130
	sta x_crd_temp
	lda #155+yoff
	sta y_crd_temp
	lda #1
	ldy #$2C
	jsr oam_putsprite
	
	lda #119
	sta x_crd_temp
	lda #153+yoff
	sta y_crd_temp
	lda #2
	ldy #$2E
	jsr oam_putsprite
	
	lda #111
	sta x_crd_temp
	lda #151+yoff
	sta y_crd_temp
	lda #2
	ldy #$28
	jmp oam_putsprite

ow_draw_c2_tower:
	lda #94
	sta x_crd_temp
	lda #132+yoff
	sta y_crd_temp
	
	lda #2
	ldy #$28
	jmp oam_putsprite

ow_draw_c3_hotel:
	lda #150
	sta x_crd_temp
	lda #106+yoff
	sta y_crd_temp
	
	lda #1          ; use pink color
	ldy #$20
	jsr oam_putsprite
	
	lda #158
	sta x_crd_temp
	lda #1
	ldy #$22
	jsr oam_putsprite
	
	lda #166
	sta x_crd_temp
	lda #1
	ldy #$24
	jsr oam_putsprite
	
	lda #174
	sta x_crd_temp
	lda #1
	ldy #$26
	jmp oam_putsprite

ow_draw_c4_cliff:
	lda #130
	sta x_crd_temp
	lda #88+yoff
	sta y_crd_temp
	ldy #$34
	lda #(1 | obj_backgd)
	jsr oam_putsprite
	
	lda #138
	sta x_crd_temp
	lda #92+yoff
	sta y_crd_temp
	ldy #$34
	lda #1
	jsr oam_putsprite
	
	lda #146
	sta x_crd_temp
	lda #96+yoff
	sta y_crd_temp
	ldy #$36
	lda #1
	jsr oam_putsprite
	
	lda #154
	sta x_crd_temp
	lda #100+yoff
	sta y_crd_temp
	ldy #$34
	lda #(1 | obj_backgd)
	jmp oam_putsprite

ow_draw_c5_temple:
	lda #100
	sta x_crd_temp
	lda #74+yoff
	sta y_crd_temp
	ldy #$38
	lda #1
	jmp oam_putsprite


ow_draw_c7_summit:
	lda #115
	sta x_crd_temp
	lda #49+yoff
	sta y_crd_temp
	
	jsr ow_anim_frame
	asl
	clc
	adc #$40
	tay
	lda #1
	jmp oam_putsprite

ow_waypoints_x:
	.byte 84    ; prologue
	.byte 122   ; chapter 1
	.byte 82    ; chapter 2
	.byte 158   ; chapter 3
	.byte 138   ; chapter 4
	.byte 88    ; chapter 5
	.byte 49    ; chapter 6
	.byte 109   ; chapter 7

ow_waypoints_y:
	.byte 164-4+yoff   ; prologue
	.byte 137-4+yoff   ; chapter 1
	.byte 122-4+yoff   ; chapter 2
	.byte  96-4+yoff   ; chapter 3
	.byte  76-4+yoff   ; chapter 4
	.byte  67-4+yoff   ; chapter 5
	.byte 137-4+yoff   ; chapter 6
	.byte  36-4+yoff   ; chapter 7

; note: each space is 16 bytes wide
ow_level_names:
	.charmap $20, $00
	.byte "    PROLOGUE    "
	.byte "  FORSAKEN CITY "
	.byte "    OLD SITE    "
	.byte "CELESTIAL RESORT"
	.byte "  GOLDEN RIDGE  "
	.byte " MIRROR  TEMPLE "
	.byte "   REFLECTION   "
	.byte "   THE SUMMIT   "
	.byte "    EPILOGUE    "
	.charmap $20, $20

ow_icon_pals:
	; note: bit 0x20 SHOULD be set else the level select effect won't work.
	.byte $21, $23, $21, $21, $22, $21, $22, $23

; ** SUBROUTINE: ow_select_banks
; desc: Selects the banks required to display the title screen.
ow_select_banks:
	lda #mmc3bk_bg0
	ldy #chrb_bgowd
	jsr mmc3_set_bank
	lda #mmc3bk_bg1
	ldy #chrb_bgowd+2
	jsr mmc3_set_bank
	
	lda #mmc3bk_spr0
	ldy #chrb_owsp00
	jsr mmc3_set_bank
	
	lda #mmc3bk_spr1
	ldy #chrb_owsp01
	jsr mmc3_set_bank
	
	lda #mmc3bk_spr2
	ldy #chrb_owsp02
	jsr mmc3_set_bank
	
	lda #mmc3bk_spr3
	ldy #chrb_owsp03
	jsr mmc3_set_bank
	rts
