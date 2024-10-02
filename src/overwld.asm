; Copyright (C) 2024 iProgramInCpp

; ** GAMEMODE: gamemode_overwd
gamemode_overwd:
	lda #os_1stfr
	bit owldctrl
	bne gamemode_overwd_update
	
	lda #0
	sta camera_x
	sta camera_x_hi
	sta camera_y
	sta ow_sellvl
	sta ppu_mask     ; disable rendering
	jsr vblank_wait
	ldy #(owld_palette - lastpage)
	jsr load_palette
	lda #$20
	jsr clear_nt
	
	jsr ow_draw_mtn
	jsr ow_draw_level_name
	;jsr tl_init_snow
	jsr ppu_rstaddr
	lda owldctrl
	ora #(os_1stfr | os_turnon)
	sta owldctrl
	lda #bank_sprow
	jsr mmc1_selsprbank
	lda #bank_owld
	jsr mmc1_selcharbank
	jsr vblank_wait
	
gamemode_overwd_update:
	;jsr tl_update_snow
	;jsr tl_render_snow
	
	; draw features
	inc ow_timer
	jsr ow_switch_level
	jsr ow_draw_player
	jsr ow_draw_c0_hut
	jsr ow_draw_c1_city
	jsr ow_draw_c2_tower
	jsr ow_draw_c3_hotel
	jsr ow_draw_c4_cliff
	jsr ow_draw_c5_temple
	jsr ow_draw_c7_summit
	
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

; ** SUBROUTINE: ow_switch_level
; desc: Switches the selected level depending on joypad presses.
ow_switch_level:
	lda p1_cont
	eor p1_conto
	and p1_cont
	sta ow_temp5
	
	lda #cont_left
	bit ow_temp5
	beq :+
	lda ow_sellvl
	beq :+
	dec ow_sellvl
	jsr ow_queue_lvlnm_upd
	
:	lda #cont_right
	bit ow_temp5
	beq :+
	lda ow_sellvl
	cmp #ow_maxlvl
	bcs :+
	inc ow_sellvl
	jsr ow_queue_lvlnm_upd
	
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

ow_levels_lo:
	.byte <level0
	.byte <level0
	.byte <level0
	.byte <level0
	.byte <level0
	.byte <level0
	.byte <level0
	.byte <level0

ow_levels_hi:
	.byte >level0
	.byte >level0
	.byte >level0
	.byte >level0
	.byte >level0
	.byte >level0
	.byte >level0
	.byte >level0

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
