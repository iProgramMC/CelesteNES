
; ** ENTITY DRAWING ROUTINES!
; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

gm_draw_berry:
	lda #$01
	sta temp5
	lda #$F8
	sta temp6
	lda #$FA
	sta temp7
	jmp gm_draw_common
	
gm_draw_refill:
	lda #$03
	sta temp5
	lda #$FC
	sta temp6
	lda #$FE
	sta temp7
	jmp gm_draw_common
	
gm_draw_spring:
	lda #$01
	sta temp5
	lda #$C8
	sta temp6
	lda #$CA
	sta temp7
	jmp gm_draw_common
	
gm_draw_key:
	lda #$03
	sta temp5
	lda #$DC
	sta temp6
	lda #$DE
	sta temp7
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
	bmi :++                  ; X high coord < $00, don't draw that part
	lda temp2
:	sta x_crd_temp
	
	lda temp5
	ldy temp6
	jsr oam_putsprite
	
:	; draw the right sprite
	clc
	lda temp2
	adc #8
	bcs :+                   ; if it overflew while computing the coord,
	sta x_crd_temp           ; then it need not render
	
	lda temp5
	ldy temp7
	jsr oam_putsprite
	
:	rts

; ** SUBROUTINE: gm_draw_ent_call
; desc: Calls the relevant entity draw function.
; arguments:
;     A - entity type
;     temp1 - entity index
; note: temp1 is occupied by gm_draw_entities and represents the index within the sprspace array.
gm_draw_ent_call:
	pha
	jsr gm_check_ent_onscreen
	bne :+
	pla
	rts
	
:	; note: gm_check_ent_onscreen already calculated the x coordinate for us
	sta temp4
	
	lda sprspace+sp_y, x
	sta temp3
	
	pla
	tax
	lda gm_entjtable_lo, x
	sta lvladdr
	lda gm_entjtable_hi, x
	sta lvladdrhi
	
	ldx temp1
	
	jmp (lvladdr)

; TODO: figure out how to avoid defining two tables like this
gm_entjtable_lo:
	.byte $00
	.byte <gm_draw_berry
	.byte <gm_draw_refill
	.byte <gm_draw_spring
	.byte <gm_draw_key

gm_entjtable_hi:
	.byte $00
	.byte >gm_draw_berry
	.byte >gm_draw_refill
	.byte >gm_draw_spring
	.byte >gm_draw_key


gm_allocate_palettes:
	; clear the memory related to palette allocation.
	lda #$FF
	ldx #0
	stx palallochd
	
:	sta allocpals,x
	sta palsallocd,x
	inx
	cpx #$10
	bne :-
	
	ldy #0
gm_allocpal_loop:
	lda sprspace+sp_kind,y   ; load the entity's kind
	beq :+                   ; if empty, don't update
	tya
	tax
	jsr gm_check_ent_onscreen
	beq :+                   ; if entity is off screen, jump to 
	tax
	lda ent_palettes,x       ; and now the palettes
	
	; OK. now check if that slot has been allocated
	tax
	lda allocpals,x
	cmp #$FF
	bne :+                   ; palette was already allocated.
	
	; need to allocate this palette.
	lda palallochd
	sta allocpals, x         ; determined the physical palette for this logical palette
	
	stx temp1                ; swap the registers 
	tax                      ; 'palallochd' is now in X, and the logical palette is now in A
	lda temp1 
	inc palallochd
	
	sta palsallocd, x
:
	iny
	cpy #sp_max
	bne gm_allocpal_loop
	rts

	
; ** SUBROUTINE: gm_check_ent_onscreen
; desc:     Checks if an entity is off of the screen.
; parms:    Y - entity index
; returns:  ZF - entity is off-screen
; clobbers: A, X. not Y
gm_check_ent_onscreen:
	sec
	lda sprspace+sp_x, x
	
	sbc camera_x
	sta temp2
	
	lda sprspace+sp_x_hi, x
	sbc camera_x_hi
	sta temp4
	
	; result < 0: sprite went off the left side.
	; result = 0: sprite is in view.
	; result > 0: sprite is to the right.
	bmi gm_ceos_left
	bne gm_ceos_rt0
	
	; result is 0.
gm_ceos_rt1:
	lda #1
	rts
	
gm_ceos_left:
	; result is different from 0. we should check if the low byte is > $F8
	lda temp2
	cmp #$F8
	bcs gm_ceos_rt1
gm_ceos_rt0:
	lda #0
	rts
	

; List of entity palette IDs
ent_palettes:
	.byte $00  ; e_none
	.byte $00  ; e_strawb
	.byte $01  ; e_refill
	.byte $02  ; e_spring
	.byte $03  ; e_key