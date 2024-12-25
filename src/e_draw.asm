; Copyright (C) 2024 iProgramInCpp

; ** Entity Draw/Update routines
; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

;     reg X - direction (0-UL, 1-UR, 2-DL, 3-DR)
gm_draw_particle:
	lda temp2
	cmp #$F8
	bcc @dontCheckOffScreen
	
	lda temp4
	bmi @returnEarly
	lda temp2

@dontCheckOffScreen:
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	ldy sprspace+sp_part_chrti, x
	lda sprspace+sp_part_chrat, x
	jsr oam_putsprite

@returnEarly:
	jsr gm_update_particle
	rts

gm_draw_berry:
	lda temp1
	pha
	
	jsr gm_update_berry
	bne @shrinking
	
	; normal rendering
	lda #pal_red
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	
	pla
	sta temp1
	tax
	
	lda #$F8
	sta temp6
	lda #$FA
	sta temp7
	jmp gm_draw_common

@shrinking:
	; shrinking
	lda #pal_red
	jsr gm_allocate_palette
	sta temp8
	ora #obj_fliphz
	sta temp5
	
	pla
	sta temp1
	tax
	lda sprspace+sp_strawb_timer, x
	and #$FC
	lsr
	clc
	adc #$CC
	sta temp6
	sta temp7
	jmp gm_draw_common

gm_draw_refillhold:
	lda #pal_green
	jsr gm_allocate_palette
	sta temp5
	ora #$40
	sta temp8
	lda #$9A
	sta temp6
	sta temp7
	jsr gm_draw_common
	jmp gm_update_refillhold

gm_draw_refill:
	lda #pal_green
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	lda #$FC
	sta temp6
	lda #$FE
	sta temp7
	jsr gm_draw_common
	jmp gm_update_refill
	
gm_draw_spring:
	jsr gm_update_spring
	lda #pal_red
	jsr gm_allocate_palette
	sta temp5
	ora #obj_fliphz
	sta temp8
	ldy temp1
	ldx sprspace+sp_spring_frame, y
	lda @frames, x
	sta temp6
	sta temp7
	dec temp3 ; correction because sprites are drawn with a 1 px down offset
	jmp gm_draw_common

@frames: .byte $C0, $C2, $C4, $CA, $C4, $CA, $C4, $C2, $C6, $C8
	
gm_draw_key:
	lda #pal_gold
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	lda #$DC
	sta temp6
	lda #$DE
	sta temp7
	jmp gm_draw_common

gm_draw_box:
	jsr gm_update_box
	lda #pal_gray
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	lda #$D4
	sta temp6
	lda #$D6
	sta temp7
	jmp gm_draw_common
	
gm_draw_points:
	lda #pal_blue
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	
	ldx temp1
	
	sec
	lda sprspace+sp_y_lo, x
	sbc #$60
	sta sprspace+sp_y_lo, x
	
	lda sprspace+sp_y, x
	sbc #0
	beq @clearKind
	sta sprspace+sp_y, x
	
	lda sprspace+sp_points_timer, x
	sec
	sbc #1
	bne @skipClearKind
@clearKind:
	sta sprspace+sp_kind, x
@skipClearKind:
	sta sprspace+sp_points_timer, x
	
	lda sprspace+sp_points_count, x
	pha
	cmp #6
	bne @no1UpMode
	
	; 1 up mode
	lda #$8E
	sta temp7
	bne @done
	
@no1UpMode:
	; normal points mode
	lda #$80
	sta temp7
	
@done:
	pla
	asl
	clc
	adc #$80
	sta temp6
	
	jmp gm_draw_common
	
; draws a common 2X sprite.
gm_draw_common:
	lda temp3
	sta y_crd_temp
	
	; draw the left sprite
	lda temp2
	cmp #$F8
	bcc :+
	; sprite X is bigger than $F8, because either the sprite is to the
	; left of the screen (so fraudulently got there via overflow), or
	; legitimately to the right
	lda temp4
	bmi @skipLeftSprite      ; X high coord < $00, don't draw that part
	lda temp2
	
:	sta x_crd_temp
	
	lda temp5
	ldy temp6
	jsr oam_putsprite
	
@skipLeftSprite:
	; draw the right sprite
	lda temp4
	bmi @temp4neg
	lda temp2
	clc
	adc #8
	bcs :+                   ; if it overflew while computing the coord,
@temp4negd:
	sta x_crd_temp           ; then it need not render
	
	lda temp8
	ldy temp7
	jsr oam_putsprite
	
:	rts

@temp4neg:
	lda temp2
	clc
	adc #8
	bcs @temp4negd
	bcc @temp4negd

; ** SUBROUTINE: gm_draw_ent_call
; desc: Calls the relevant entity draw function.
; arguments:
;     A - entity type
;     temp1 - entity index
; note: temp1 is occupied by gm_draw_entities and represents the index within the sprspace array.
gm_draw_ent_call:
	pha
	jsr gm_check_ent_onscreen
	bne @notOffScreen
	
	pla
	cmp #e_particle
	bne @notParticle
	
	; particle went off screen HAHA, destroy it
	lda #0
	sta sprspace+sp_kind, x
	
@notParticle:
	rts
	
@notOffScreen:
	; note: gm_check_ent_onscreen already calculated the x coordinate for us
	
	lda #e_strawb
	cmp sprspace+sp_kind, x
	bne @forceAddingCamY
	
	lda sprspace+sp_y, x
	sec
	sbc camera_y_sub
	sec
	sbc temp10
	sta temp3
	
	lda sprspace+sp_strawb_flags, x
	and #esb_picked    ; picked sprites do not need cameraY added to them
	bne @doNotAddCamY
	
@forceAddingCamY:
	lda lvlyoff
	asl
	asl
	asl
	sta temp3
	lda sprspace+sp_y, x
	clc
	adc temp3
	sta temp3
	sec
	sbc camera_y_bs
	sec
	sbc camera_y_sub
	sec
	sbc temp10
	sta temp3
	
@doNotAddCamY:
	pla
	tax
	lda gm_entjtable_lo, x
	sta lvladdr
	lda gm_entjtable_hi, x
	sta lvladdrhi
	
	ldx temp1
	
	jmp (lvladdr)

.define entity_jump_table   \
	$0000,                  \
	gm_draw_berry,          \
	gm_draw_refill,         \
	gm_draw_spring,         \
	gm_draw_key,            \
	gm_draw_particle,       \
	gm_draw_refillhold,     \
	gm_draw_points,         \
	level0_intro_crusher,   \
	gm_draw_box,            \
	level0_bridge_manager,  \
	level0_granny,          \
	level0_bird_climb,      \
	level0_bird_dash,       \
	level1_zip_mover,       \
	level1_zip_mover

gm_entjtable_lo: .lobytes entity_jump_table
gm_entjtable_hi: .hibytes entity_jump_table

; ** SUBROUTINE: gm_check_ent_onscreen
; desc:     Checks if an entity is off of the screen.
; parms:    Y - entity index
; returns:  ZF - entity is off-screen
; clobbers: A, X, temp3, temp4, temp10. not Y
gm_check_ent_onscreen:
	lda #0
	sta temp10
	
	lda sprspace+sp_flags, x
	and #ef_limbo
	bne @returnZero             ; if entity is in limbo
	
	lda sprspace+sp_x, x
	sec
	sbc camera_x
	sta temp2
	
	lda sprspace+sp_x_pg, x
	sbc camera_x_pg
	sta temp4
	
	; result < 0: sprite went off the left side.
	; result = 0: sprite is in view.
	; result > 0: sprite is to the right.
	bmi @checkLeft
	beq @moreChecking
	
	; result is 0.
@returnZero:
	lda #0
	rts
	
@checkLeft:
	; result is different from 0. we should check if the low byte is > $F8
	lda temp2
	cmp #$F8
	bcc @returnZero

@moreChecking:
	; ok, totally in bounds, now see if we're in an up room transition
	lda #g3_transitU
	bit gamectrl3
	beq @returnOne
	
	; if the room numbers are different
	lda sprspace+sp_flags, x
	; ef_oddroom == $02
	lsr
	eor roomnumber
	and #1
	asl
	asl
	asl
	asl
	sta temp10
	
	lda sprspace+sp_y, x
	sec
	sbc camera_y
	
	; carry SET -- return zero for OLD ROOM
	lda #0
	rol
	; ef_oddroom == $02
	asl
	eor sprspace+sp_flags, x
	lsr
	eor roomnumber
	and #1
	
	; carry ^ (entityRoomNumberParity ^ activeRoomNumberParity)
	beq @returnZero
	
@returnOne:
	lda #1
	rts

; ** SUBROUTINE: gm_unload_ents_room
; desc: Unloads all entities with a specific room number.
; arguments: A - the room number to unload entities from.
; note: Can only be used to unload entities from the previous room.
gm_unload_ents_room:
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
	lda #0
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
	bne @skipThisObject

; ** SUBROUTINE: gm_unload_os_ents
; desc: Unloads entities that went off the left side of the screen.
gm_unload_os_ents:
	lda #g3_transitA
	bit gamectrl3
	bne @forceUnLoad  ; as long as a room transition is going on, unload any off-screen entities.
	
	lda roomsize
	bne @earlyReturn  ; if the level may scroll back left, don't unload any off-screen entities.
	
@forceUnLoad:
	ldx #0
:	lda sprspace+sp_kind, x
	beq :+
	
	lda sprspace+sp_x, x
	clc
	adc #$10
	sta temp2
	lda sprspace+sp_x_pg, x
	adc #0
	sta temp3
	
	sec
	lda temp2
	sbc camera_x
	;sta temp2
	lda temp3
	sbc camera_x_pg
	
	; result < 0: sprite went off the right side.
	bpl :+
	
	lda #0
	sta sprspace+sp_kind, x
:	inx
	cpx #sp_max
	bne :--

@earlyReturn:
	rts

; ** SUBROUTINE: gm_draw_entities
; desc: Draws visible entities to the screen.
gm_draw_entities:
	lda #1
	bit framectr
	
	beq @evenFrame
	
	; odd frame
	ldx #(sp_max - 1)
@loopOdd:
	lda sprspace+sp_kind, x
	beq :+             ; this is an empty entity slot. waste no time
	stx temp1
	jsr gm_draw_ent_call
	ldx temp1
:	dex
	cpx #$FF
	bne @loopOdd
	rts
	
@evenFrame:
	ldx #0
@loopEven:
	lda sprspace+sp_kind, x
	beq :+             ; this is an empty entity slot. waste no time
	stx temp1
	jsr gm_draw_ent_call
	ldx temp1
:	inx
	cpx #sp_max
	bne @loopEven
	rts
