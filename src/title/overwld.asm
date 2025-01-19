; Copyright (C) 2024 iProgramInCpp

gamemode_overwd_init_FAR:
	lda #0
	sta ow_sellvl
	
	;lda #0
	sta ow_lvlopen
	sta ow_slidetmr
	sta ow_iconoff
	sta ow_timer2
	sta camera_x
	sta camera_x_hi
	sta camera_y
	sta camera_y_hi
	sta scroll_x
	sta scroll_y
	sta scroll_flags
	sta irqtmp1
	sta ppu_mask     ; disable rendering
	jsr vblank_wait
	
	ldy #<owld_palette
	sty paladdr
	ldy #>owld_palette
	sty paladdr+1
	
	lda #$20
	jsr clear_nt
	
	;lda #$24
	;jsr clear_nt
	lda #$24
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldx #>OWL_drawer_data
	lda #<OWL_drawer_data
	jsr nexxt_rle_decompress
	ldy #128
:	sta ppu_data
	dey
	bne :-
	
	lda #$27
	sta ppu_addr
	lda #$C0
	sta ppu_addr
	lda #$FF
	ldy #64
:	sta ppu_data
	dey
	bne :-
	
	jsr ow_draw_mtn
	jsr ow_draw_level_name
	jsr ow_draw_icon_fadeout

	lda owldctrl
	ora #os_1stfr
	sta owldctrl
	
	lda #$F1
	sta ow_splity
	
	jsr ow_select_banks
	
	lda #0
	sta ow_timer
	sta miscsplit
	sta fadeupdrt+1
	jsr fade_in

gamemode_overwd_update_FAR:
	lda #0
	sta irqtmp1
	
	; draw features
	inc ow_timer
	
	ldx ow_timer2
	inx
	cpx #4
	bcc :+
	ldx #4
:	stx	ow_timer2
	
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
	jsr ow_update_irq
	jsr ow_update_drawer
	
	lda #(os_leftmov | os_rightmov)
	bit owldctrl
	bne @return         ; don't handle controller input during a transition
	
	lda #(cont_a | cont_start)
	bit temp5
	bne @pressedAOrStart
@return:
	rts
	
@pressedAOrStart:
	; check if we need to open the drawer first
	lda ow_lvlopen
	bne @enterGame
	
	; just begin opening the drawer
	inc ow_lvlopen
	
	rts
	
@enterGame:
	; now enter the game!
	jsr ow_clear_irq
	
	ldx ow_sellvl
	beq @isPrologue
	
	jmp tl_gameswitchpcard

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
	jsr ow_on_update_lvl
	rts

@right_frame4:
	inc ow_slidetmr
	inc ow_sellvl
	lda #$10
	sta ow_iconoff
	jmp ow_on_update_lvl

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
	ldy #2
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
	cpy #4
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
	
	lda #14+16              ; note: ow_draw_level_icon clobbers x_crd_temp.
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
	lda #4+16
	sta y_crd_temp
	
	lda #%00010000
	bit ow_timer
	beq :+
	inc y_crd_temp
	
:	lda #1
	ldy #$1E
	jsr oam_putsprite
	
;	lda #((256-8)/2)
;	sta x_crd_temp
;	lda #24+16
;	sta y_crd_temp
;	
;	lda #%00010000
;	bit ow_timer
;	beq :+
;	dec y_crd_temp
;	
;:	lda #(1 | obj_flipvt)
;	ldy #$1E
;	jsr oam_putsprite
	
	rts

; ** SUBROUTINE: ow_draw_level_name
; desc: Draws the new level name.
; assumes: Inside of NMI
.proc ow_draw_level_name
	lda #$24
	sta ppu_addr
	lda #$49
	sta ppu_addr
	
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
	
	lda #14
	jsr ppu_wrstring
	
	lda #$24
	sta ppu_addr
	lda #$AF
	sta ppu_addr
	
	lda levelnumber
	beq berriesBothZero
	lda ow_berries1
	ora ow_berries2
	beq berriesBothZero
	
	lda #$82
	sta ppu_data
	lda #$00
	sta ppu_data
	
	lda ow_berries2
	beq :+
	clc
	adc #$20 ; I should have done $30 but whatever
:	sta ppu_data
	
	lda ow_berries1
	clc
	adc #$20 ; I should have done $30 but whatever
	sta ppu_data
	
	; check if we need to push the /XX or blank
	ldx ow_sellvl
	lda bitSet, x
	and sf_completed
	bne useLevel
	ldx #0
	beq displayAnyway
useLevel:
	lda ow_sellvl
	asl
	asl
	tax
displayAnyway:
	lda amountData, x
	sta ppu_data
	inx
	lda amountData, x
	sta ppu_data
	inx
	lda amountData, x
	sta ppu_data
	inx
	bne berriesNotAllZero

berriesBothZero:
	lda #0
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data

berriesNotAllZero:
	
	; Update Death Counter
	lda #$25
	sta ppu_addr
	lda #$11
	sta ppu_addr
	ldy #0
	
	lda ow_deathsE
	beq skip10K
	clc
	adc #$20
	sta ppu_data

skip10K:
	lda ow_deathsO
	beq skip1K
	clc
	adc #$20
	sta ppu_data
	iny

skip1K:
	lda ow_deathsH
	beq skip100
	clc
	adc #$20
	sta ppu_data
	iny

skip100:
	lda ow_deathsT
	beq :+
	clc
	adc #$20
:	sta ppu_data
	iny
	
	lda ow_deathsU
	clc
	adc #$20
	sta ppu_data
	iny
	
	lda #0
:	sta ppu_data
	iny
	cpy #6
	bne :-
	
	rts

bitSet:	.byte $00,$01,$02,$04,$08,$10,$20,$40,$80
amountData:
	.byte $00,$00,$00,$00
	.byte $81,$22,$20,$00 ; / 20
	.byte $81,$21,$28,$00 ; / 18
.endproc

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
	sta temp5
	
	lda #0
	sta ow_slidetmr
	
	lda ow_lvlopen
	bne @isLevelOpen
	
	lda #cont_left
	bit temp5
	beq :+
	
	lda owldctrl
	ora #os_leftmov
	and #(os_rightmov ^ $FF)
	sta owldctrl
	
:	lda #cont_right
	bit temp5
	beq :+
	
	lda owldctrl
	ora #os_rightmov
	and #(os_leftmov ^ $FF)
	sta owldctrl
	
:	rts

@isLevelOpen:
	lda #cont_b
	bit temp5
	beq :+
	dec ow_lvlopen
:	rts

.proc ow_on_update_lvl
	lda ow_sellvl
	sta levelnumber
	tax
	lda level_berry_counts, x
	sta temp10
	
	jsr save_file_load_berries
	
	; count the amount of berries
	lda #0
	sta ow_berries1
	sta ow_berries2
	sta temp11
	
	ldy #0
@loop:
	ldx #8
	lda sstrawberries, y
@loop2:
	pha
	
	; check if we've checked enough bits
	lda temp11
	cmp temp10
	bcs @doneAdding
	inc temp11
	
	pla
	
	lsr
	pha
	bcc @dontAdd
	
	lda ow_berries1
	clc
	adc #1
	sta ow_berries1
	
	cmp #10
	bcc @dontAdd
	
	inc ow_berries2
	lda #0
	sta ow_berries1
	
@dontAdd:
	pla
	dex
	bne @loop2
	
	iny
	cpy #4
	bne @loop
	
	pha
@doneAdding:
	pla
	
	; update the deaths count
	lda levelnumber
	asl
	tay
	lda sf_deaths-1, y ; high byte
	tax
	lda sf_deaths-2, y ; low byte
	jsr ow_to_decimal_16bit
	
	lda temp1
	sta ow_deathsU
	lda temp2
	sta ow_deathsT
	lda temp3
	sta ow_deathsH
	lda temp4
	sta ow_deathsO
	lda temp5
	sta ow_deathsE
	
	lda #nc_updlvlnm
	ora nmictrl
	sta nmictrl
	rts
.endproc

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
	sta temp1
	jsr ow_anim_frame
	asl
	asl
	clc
	adc #$02
	sta temp2
	clc
	adc #$02
	sta temp3
	
	ldx ow_sellvl
	lda ow_waypoints_x, x
	ldy ow_waypoints_y, x
	ldx #<temp1
	jsr ow_draw_2xsprite
	
	; draw hair
	lda #1
	sta temp1
	lda #$1A
	sta temp2
	lda #$1C
	sta temp3
	
	ldx ow_sellvl
	lda ow_waypoints_y, x
	sta temp4
	
	jsr ow_anim_frame
	and #1
	beq :+
	inc temp4
	
:	ldy temp4
	lda ow_waypoints_x, x
	ldx #<temp1
	jsr ow_draw_2xsprite
	
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
	jsr ow_put_sprite
	
	rts

; ** SUBROUTINE: ow_draw_mtn
; desc: Draws a mountain to the screen.
ow_draw_mtn:
	lda #$21
	sta temp1
	lda #$23
	sta temp2
	
	lda #<MTN_data
	sta temp3
	lda #>MTN_data
	sta temp4
	
	lda #0
	sta temp5
	
:	lda temp1
	sta ppu_addr
	lda temp2
	sta ppu_addr
	ldx temp3
	ldy temp4
	lda #26
	jsr ppu_wrstring
	
	clc
	lda temp3
	adc #26
	sta temp3
	lda temp4
	adc #0
	sta temp4
	
	clc
	lda temp2
	adc #$20
	sta temp2
	lda temp1
	adc #0
	sta temp1
	
	clc
	lda temp5
	adc #1
	sta temp5
	
	cmp #20
	bne :-
	
	; finally write palette data
	lda #$23
	sta ppu_addr
	lda #$C0
	sta ppu_addr
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
	jmp ow_put_sprite

ow_draw_c1_city:
	lda #111
	sta x_crd_temp
	lda #170+yoff
	sta y_crd_temp
	lda #3
	ldy #$28
	jsr ow_put_sprite
	
	lda #125
	sta x_crd_temp
	lda #173+yoff
	sta y_crd_temp
	lda #1
	ldy #$30
	jsr ow_put_sprite
	
	lda #129
	sta x_crd_temp
	lda #170+yoff
	sta y_crd_temp
	lda #3
	ldy #$28
	jsr ow_put_sprite
	
	lda #122
	sta x_crd_temp
	lda #166+yoff
	sta y_crd_temp
	lda #2
	ldy #$2E
	jsr ow_put_sprite
	
	lda #130
	sta x_crd_temp
	lda #161+yoff
	sta y_crd_temp
	lda #2
	ldy #$28
	jsr ow_put_sprite
	
	lda #114
	sta x_crd_temp
	lda #158+yoff
	sta y_crd_temp
	lda #1
	ldy #$30
	jsr ow_put_sprite
	
	lda #122
	sta x_crd_temp
	lda #155+yoff
	sta y_crd_temp
	lda #1
	ldy #$2A
	jsr ow_put_sprite
	
	lda #130
	sta x_crd_temp
	lda #155+yoff
	sta y_crd_temp
	lda #1
	ldy #$2C
	jsr ow_put_sprite
	
	lda #119
	sta x_crd_temp
	lda #153+yoff
	sta y_crd_temp
	lda #2
	ldy #$2E
	jsr ow_put_sprite
	
	lda #111
	sta x_crd_temp
	lda #151+yoff
	sta y_crd_temp
	lda #2
	ldy #$28
	jmp ow_put_sprite

ow_draw_c2_tower:
	lda #94
	sta x_crd_temp
	lda #132+yoff
	sta y_crd_temp
	
	lda #2
	ldy #$28
	jmp ow_put_sprite

ow_draw_c3_hotel:
	lda #150
	sta x_crd_temp
	lda #106+yoff
	sta y_crd_temp
	
	lda #1          ; use pink color
	ldy #$20
	jsr ow_put_sprite
	
	lda #158
	sta x_crd_temp
	lda #1
	ldy #$22
	jsr ow_put_sprite
	
	lda #166
	sta x_crd_temp
	lda #1
	ldy #$24
	jsr ow_put_sprite
	
	lda #174
	sta x_crd_temp
	lda #1
	ldy #$26
	jmp ow_put_sprite

ow_draw_c4_cliff:
	lda #130
	sta x_crd_temp
	lda #88+yoff
	sta y_crd_temp
	ldy #$34
	lda #(1 | obj_backgd)
	jsr ow_put_sprite
	
	lda #138
	sta x_crd_temp
	lda #92+yoff
	sta y_crd_temp
	ldy #$34
	lda #1
	jsr ow_put_sprite
	
	lda #146
	sta x_crd_temp
	lda #96+yoff
	sta y_crd_temp
	ldy #$36
	lda #1
	jsr ow_put_sprite
	
	lda #154
	sta x_crd_temp
	lda #100+yoff
	sta y_crd_temp
	ldy #$34
	lda #(1 | obj_backgd)
	jmp ow_put_sprite

ow_draw_c5_temple:
	lda #100
	sta x_crd_temp
	lda #74+yoff
	sta y_crd_temp
	ldy #$38
	lda #1
	jmp ow_put_sprite


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
	jmp ow_put_sprite

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

; note: each space is 16 bytes wide, but only 14 are used
ow_level_names:
	.byte $00,$00,$00,$00,$6f,$3d,$7e,$7f,$2a,$8f,$00,$00,$00,$00,$FF,$FF
	.byte $00,$00,$00,$3e,$3f,$48,$49,$4a,$4b,$4c,$4d,$00,$00,$00,$FF,$FF
	.byte $00,$00,$00,$00,$4e,$4f,$5b,$5c,$5d,$8e,$00,$00,$00,$00,$FF,$FF
	; TODO the rest
	;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
	;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
	;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
	;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
	;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
	;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
	
ow_icon_pals:
	; note: bit 0x20 SHOULD be set else the level select effect won't work.
	.byte $21, $23, $21, $21, $22, $21, $22, $23

; ** SUBROUTINE: ow_select_banks
; desc: Selects the banks required to display the title screen.
ow_select_banks:
	ldy #chrb_bgowd
	sty bg0_bknum
	ldy #chrb_bgowd+2
	sty bg1_bknum
	
	ldy #chrb_owsp00
	sty spr0_bknum
	
	ldy #chrb_owsp01
	sty spr1_bknum
	
	ldy #chrb_owsp02
	sty spr2_bknum
	
	ldy #chrb_owsp03
	sty spr3_bknum
	rts

.proc ow_update_drawer
	lda ow_splity
	pha
	
	ldx ow_lvlopen
	bne @isOpen
	
	; close
	lda #$F1
	sec
	sbc ow_splity
	clc
	adc #3
	lsr
	lsr
	clc
	adc ow_splity
	sta ow_splity
	jmp @drawBerrySprite

@isOpen:
	lda ow_splity
	sec
	sbc #$60
	clc
	adc #3
	lsr
	lsr
	sta temp11
	lda ow_splity
	sec
	sbc temp11
	sta ow_splity

@drawBerrySprite:
	pla
	clc
	adc #36
	bcs @dontDraw
	sta y_crd_temp
	
	lda ow_sellvl
	beq @dontDraw
	
	lda ow_berries1
	ora ow_berries2
	beq @dontDraw
	
	lda #100
	sta x_crd_temp
	
	lda ow_timer
	and #%00011000
	lsr
	ora #%10000000
	pha
	tay
	lda #1
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	
	pla
	ora #%00000010
	tay
	lda #1
	jsr oam_putsprite
	
@dontDraw:
	rts
.endproc

.proc ow_clear_irq
	sei
	lda #<irq_idle
	sta irqaddr
	lda #>irq_idle
	sta irqaddr+1
	lda #0
	sta miscsplit
	cli
	rts
.endproc

.proc ow_put_sprite
	pha
	lda y_crd_temp
	cmp ow_splity
	bcs @dont
	pla
	jmp oam_putsprite
@dont:
	pla
	rts
.endproc

.proc ow_update_irq
	; I don't know why I have to delay setting the IRQ address
	; away from irq_idle by at least one frame for this, but fine.
	lda ow_splity
	cmp #$F0
	bne :+
	lda #$F1
:	sta miscsplit
	
	lda ow_timer2
	cmp #4
	bcc :+
	
	sei
	lda #<irq_overworld
	sta irqaddr
	lda #>irq_overworld
	sta irqaddr+1
	cli
	
:	rts
.endproc

; The IRQ for the overworld, reveals the level panel
.proc irq_overworld
	pha
	sta mmc3_irqdi
	lda irqtmp1
	bne secondPhase
	inc irqtmp1
	
	lda levelnumber
	bne @dontReProgram
	lda #31
	sta mmc3_irqla
	sta mmc3_irqrl
	sta mmc3_irqen
	
@dontReProgram:
	; Nametable number << 2 (we want nametable $2400)
	lda #4
	sta ppu_addr
	; New Y is zero.
	lda #0
	sta ppu_scroll
	
	; Wait for h-blank.
	
	; I know using the accumulator to count isn't great. It allowed me
	; to save a clobbered register, until I realized I needed the X reg
	; anyway.
	lda #8
:	sec
	sbc #1
	bne :-
	nop
	
	; New X to $2005
	sta ppu_scroll
	; Low byte of nametable address to $2006
	sta ppu_addr
	
	txa
	pha
	tya
	pha
	
	; turn off rendering of background
	lda #<(def_ppu_msk & ~%00001000)
	sta ppu_mask
	
	; prepare the mask to turn off sprites this time
	lda #<(def_ppu_msk & ~%00010000)
	
	; also update the BG bank
	ldx #mmc3bk_bg0 | def_mmc3_bn
	ldy #chrb_optns
	stx mmc3_bsel
	sty mmc3_bdat
	inx
	iny
	iny
	stx mmc3_bsel
	sty mmc3_bdat
	
	; make sure the PPUMASK write lands in h-blank
	ldy #14
:	dey
	bne :-
	sta ppu_mask
	lda #def_ppu_msk
	
	; wait like 16 scanlines more
	ldy #251
:	dey
	bne :-
	ldy #110
:	dey
	bne :-
	
	sta ppu_mask
	
	pla
	tay
	pla
	tax
	pla
	rti

secondPhase:
	; Nametable number << 2 (we want nametable $2400)
	lda #4
	sta ppu_addr
	; New Y is 80.
	lda #80
	sta ppu_scroll
	
	; Wait for h-blank.
	
	; I know using the accumulator to count isn't great. It allowed me
	; to save a clobbered register, until I realized I needed the X reg
	; anyway.
	lda #10
:	sec
	sbc #1
	bne :-
	
	; New X to $2005
	sta ppu_scroll
	; Low byte of nametable address to $2006
	lda #<(80<<2)
	sta ppu_addr
	
	pla
	rti
.endproc

; ** SUBROUTINE: ow_draw_2xsprite
; desc: Draws a double sprite.
; NOTE: copy of gm_draw_2xsprite
.proc ow_draw_2xsprite
	sta x_crd_temp
	sty y_crd_temp
	lda $00,x       ; get shared attributes into a
	inx
	ldy $00,x       ; get left sprite
	inx
	stx temp7
	jsr ow_put_sprite
	ldx temp7
	ldy $00,x       ; get right sprite
	lda x_crd_temp  ; add 8 to x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	dex
	dex
	lda $00,x       ; get shared attributes again
	jmp ow_put_sprite
.endproc

; ** SUBROUTINE: ow_to_decimal_16bit
; desc: Converts a number from 16-bit binary to 5 decimal digits.
; input:
;     XA - The 16-bit number.
; result:
;     temp5, temp4, temp3, temp2, temp1 -- The digits (temp5 is most significant)
; clobbers:
;     temp6 - Used as temporary storage for the high byte of the number.  Is zero at the end.
.proc ow_to_decimal_16bit
byteHi := temp6
byteLo := temp1
digits := temp1
	
	stx byteHi
	sta byteLo
	
	lda #0
	sta digits+1
	sta digits+2
	sta digits+3
	sta digits+4
	
sb10000Loop:
	; load the high byte
	lda byteHi
	beq stop10000
	cmp #>10000
	; if it's less than 0x27 (10000>>8), then clearly we can't
	bcc stop10000
	; if it's different, then it's more, so totally can
	bne :+
	; the high byte is the same, check the low byte
	lda byteLo
	cmp #<10000
	bcc stop10000
:	; can subtract 10000!
	lda byteLo
	sec
	sbc #<10000
	sta byteLo
	lda byteHi
	sbc #>10000
	sta byteHi
	inc digits+4
	bne sb10000Loop

stop10000:
	; try 1000
sb1000Loop:
	; load the high byte
	lda byteHi
	beq stop1000
	cmp #>1000
	; if it's less than 3 (1000>>8), then clearly we can't
	bcc stop1000
	; if it's different, then it's more, so totally can
	bne :+
	; the high byte is the same, check the low byte
	lda byteLo
	cmp #<1000
	bcc stop1000
:	; can subtract 1000!
	lda byteLo
	sec
	sbc #<1000
	sta byteLo
	lda byteHi
	sbc #>1000
	sta byteHi
	inc digits+3
	bne sb1000Loop

stop1000:
	; try 100
sb100Loop:
	; load the high byte
	lda byteHi
	; if it's >0, then can subtract
	bne :+
	; check the low byte
	lda byteLo
	cmp #100
	bcc stop100
:	; can subtract 100!
	lda byteLo
	sec
	sbc #100
	sta byteLo
	bcs :+
	dec byteHi
:	inc digits+2
	bne sb100Loop

stop100:
	; try 10
sb10Loop:
	; don't need to check the high byte anymore since it's guaranteed to be 0
	lda byteLo
	beq stop10
	cmp #10
	bcc stop10
	; can subtract 10!
	lda byteLo
	sec
	sbc #10
	sta byteLo
	inc digits+1
	bne sb10Loop

stop10:
	; the units digit was actually calculated in temp1 already.
	rts
.endproc
