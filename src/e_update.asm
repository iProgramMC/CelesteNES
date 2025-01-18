; Copyright (C) 2024 iProgramInCpp

; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

; ** SUBROUTINE: gm_check_player_bb
; desc: Checks if the player is located within this entity's bounding box.
gm_check_player_bb:
	lda #0
	sta temp7
	sta temp8
	lda #16
	sta temp9
	sta temp10
	txa
	tay
	jmp gm_check_collision_ent

; ** SUBROUTINE: gm_ent_oscillate
; desc: Oscillates this entity using the first entity specific field as a timer.
gm_ent_oscillate:
	ldx temp1
	lda sprspace+sp_oscill_timer, x
	clc
	adc #1
	sta sprspace+sp_oscill_timer, x
	
	sta temp5
	and #7
	bne @return
	
	lda temp5
	lsr
	lsr
	lsr
	and #15
	tax
	lda osciltable, x
	sta temp5
	ldx temp1
	
	lda temp5
	bmi @temp5Negative
	
	clc
	adc sprspace+sp_y, x
	sta sprspace+sp_y, x
	bcs @overflow
@return:
	rts

@temp5Negative:
	clc
	adc sprspace+sp_y, x
	sta sprspace+sp_y, x
	bcc @overflow
	rts

@overflow:
	lda #g3_transitA
	bit gamectrl3
	bne @continue           ; in transition, so can't be in limbo
	
	lda #rf_new
	bit roomflags
	beq @continue           ; can't go in limbo in a normal room
	
	lda sprspace+sp_flags,x
	eor #ef_limbo
	sta sprspace+sp_flags,x
	
@continue:
	rts

; ** SUBROUTINE: gm_collect_berry
; desc: Collects a strawberry.
; parameters: X - The entity ID of the strawberry.
; clobbers: A, X, Y
.proc gm_collect_berry
	lda sprspace+sp_strawb_ident, x
	tay             ; keep the ID into Y
	lsr             ; byte number into X
	lsr
	lsr
	tax
	tya             ; restore the Index
	and #7          ; get the bit number
	tay
	lda bitmask, y  ; 1 single bit set based on Y
	ora strawberries, x
	sta strawberries, x
	lda #0
	rts
bitmask:	.byte $01, $02, $04, $08, $10, $20, $40, $80
.endproc

; ** SUBROUTINE: gm_remove_follower
; desc: Removes a follower from the player's followers.
; parameters: X - The index of the entity to remove as follower.
; clobbers: all regs
.proc gm_remove_follower
	; load the following ID, to compare with the rest of the entities
	lda sprspace+sp_strawb_colid, x
	
	ldx #0
loop:
	ldy sprspace+sp_kind, x
	cpy #e_strawb
	bne continue
	
	; compare following IDs
	cmp sprspace+sp_strawb_colid, x
	bcs continue
	
	lda sprspace+sp_strawb_colid, x
	sec
	sbc #8
	sta sprspace+sp_strawb_colid, x
	
continue:
	inx
	cpx #sp_max
	bne loop
	
	lda #$F0
	sta groundtimer
	
	dec plrstrawbs
	rts
.endproc

; ** SUBROUTINE: gm_pick_up_berry_entity
; desc: Picks up a berry entity.
; parameters: X - The index of the entity to pick up.
.proc gm_pick_up_berry_entity
	lda temp11
	pha
	stx temp11
	;lda sprspace+sp_strawb_flags, x
	;ora #esb_shrink
	;and #<~esb_picked
	;sta sprspace+sp_strawb_flags, x
	
	; since esb_picked == 1 and esb_shrink == 2
	inc sprspace+sp_strawb_flags, x
	
	lda #0
	sta sprspace+sp_strawb_timer, x
	
	jsr gm_remove_follower
	jsr gm_strawb_sfx
	
	ldx temp11
	jsr gm_collect_berry
	
	ldx temp11
	pla
	sta temp11
	rts
.endproc
