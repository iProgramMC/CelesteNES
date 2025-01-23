; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_draw_common
; desc: draws a common 2X sprite.
; parameters:
;    temp5 - attributes for left side
;    temp8 - attributes for right side
;    temp6 - tile # for left side
;    temp7 - tile # for right side
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

; ** SUBROUTINE: gm_unload_ents_room
; desc: Unloads all entities with a specific room number.
; arguments: A - the room number to unload entities from.
; note: Can only be used to unload entities from the previous room.
; note: Also marks for collection ALL strawberries.
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
	
	; forcefully pick it up
	jsr gm_pick_up_berry_entity
	jmp @skipThisObject

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
	
	; If it is a bridge, then don't subject it to such unload. It will unload itself soon.
	cmp #e_l0bridge
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
	ldx #<xt_draw_entities
	ldy #>xt_draw_entities
	lda #prgb_paus
	jmp far_call2

