; Copyright (C) 2024 iProgramInCpp

; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

; ** SUBROUTINE: gm_check_player_bb
; desc: Checks if the player is located within this entity's bounding box.
gm_check_player_bb:
	lda temp3
	clc
	adc #16
	sta temp5
	
	clc
	lda player_y
	adc #8
	cmp temp3
	bcc gm_cpbb_nocoll    ; player_y+8 < temp3 (top of object)
	cmp temp5
	bcs gm_cpbb_nocoll    ; player_y+8 > temp5 (bottom of object)
	
	lda temp2
	clc
	adc #16
	sta temp5
	
	clc
	lda player_x
	adc #8
	cmp temp2
	bcc gm_cpbb_nocoll    ; player_x+8 < temp2 (left of object)
	cmp temp5
	bcs gm_cpbb_nocoll    ; player_x+8 > temp5 (right of object)
	
	lda #1
	rts

gm_cpbb_nocoll:
	lda #0
	rts

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
	lda sprspace+sp_flags,x
	eor #ef_limbo
	sta sprspace+sp_flags,x
	rts

gm_update_spring:
	ldy temp1
	ldx temp1
	lda sprspace+sp_spring_frame, y
	beq @idleTime
	
	dec sprspace+sp_spring_timer, x
	bne @idleTime
	
	ldx sprspace+sp_spring_frame, y
	inx
	cpx #10
	bne :+
	ldx #0
:	txa
	sta sprspace+sp_spring_frame, y
	lda @frametimes, x
	sta sprspace+sp_spring_timer, y

@idleTime:
	lda player_vl_y
	bmi @return
	
	; is the player colliding?
	lda #14
	sta temp8
	lda #0
	sta temp7
	lda #16
	sta temp9
	sta temp10
	jsr gm_check_collision_ent
	beq @return
	
	lda #1
	sta sprspace+sp_spring_frame, y
	lda #5
	sta sprspace+sp_spring_timer, y
	
	jsr gm_spring_sfx
	
	; propel the player!
	lda temp10
	jmp gm_superbounce
	
@return:
	rts

@frametimes:	.byte 5, 3, 6, 8, 7, 8, 9, 5, 4, 4
; note: frame 2 is constantly oscillating

gm_update_berry:
	jsr gm_ent_oscillate
	
	ldx temp1
	lda sprspace+sp_strawb_flags, x
	and #esb_picked
	beq @floatingMode
	
	; trailing behind player mode
	lda sprspace+sp_strawb_colid, x
	asl
	asl
	eor #$FF
	clc
	adc plrtrahd
	
	and #$3F
	tay
	
	clc
	lda temp2
	cmp #$F8
	bcc :+
	lda #0
:	adc plr_trace_x, y
	ror                 ; average between temp2 and plr_trace_x
	sta temp2
	
	clc
	lda temp3
	adc plr_trace_y, y
	ror
	sta temp3
	
	clc
	lda temp2
	adc camera_x
	sta sprspace+sp_x, x
	
	lda camera_x_pg
	adc #0
	sta sprspace+sp_x_pg, x
	
	lda temp3
	sta sprspace+sp_y, x
	
	rts

@floatingMode:	
	; floating mode
	jsr gm_check_player_bb
	bne :+
	rts
	
:	; collided, set to picked up mode
	lda sprspace+sp_strawb_flags, x
	ora #esb_picked
	sta sprspace+sp_strawb_flags, x
	
	inc plrstrawbs
	lda plrstrawbs
	sta sprspace+sp_strawb_colid, x
	
	jmp gm_give_points

gm_update_refill:
	jsr gm_ent_oscillate
	
	jsr gm_check_player_bb
	beq @return
	
	; collided!
	; check if the dash count is non zero.
	lda dashcount
	bne @break
	
	; dash count is zero (never dashed), so check stamina
	lda stamina+1
	bne @return
	
	lda stamina
	cmp #stamlowthre
	bcs @return
	
@break:
	; player has dashed which means 
	; break into 4 pieces, destroy, and give the player their dashes back
	
	lda #$98
	sta temp4   ; character tile
	lda #3
	sta temp5   ; tile attributes
	
	lda #8
	sta temp9   ; lifetime
	lda #0
	sta temp8   ; gravity
	
	ldx #0
	jsr gm_spawn_particle_at_ent
	inx
	jsr gm_spawn_particle_at_ent
	inx
	jsr gm_spawn_particle_at_ent
	inx
	jsr gm_spawn_particle_at_ent
	
	ldx temp1
	lda sprspace+sp_refill_flags, x
	and #erf_regen
	beq @setKind
	
	lda sprspace+sp_oscill_timer, x
	sta sprspace+sp_refill_oldos, x
	
	lda #$F0
	sta sprspace+sp_oscill_timer, x
	lda #e_refillhd
	
@setKind:
	sta sprspace+sp_kind, x
	
	lda #0
	sta dashcount
	lda #<staminamax
	sta stamina
	lda #>staminamax
	sta stamina+1
	
@return:
	rts

gm_update_refillhold:
	ldx temp1
	dec sprspace+sp_oscill_timer, x
	bne :+
	; time to replace with a normal one
	lda sprspace+sp_refill_oldos, x
	sta sprspace+sp_oscill_timer, x
	lda #e_refill
	sta sprspace+sp_kind, x
	
:	rts

gm_update_particle:
	ldx temp1
	lda #0
	sta temp7
	
	lda sprspace+sp_part_vel_x, x
	sta temp5
	bpl :+
	lda #$FF
	sta temp7
	
:	clc
	lda sprspace+sp_x, x
	adc temp5
	sta sprspace+sp_x, x
	lda sprspace+sp_x_pg, x
	adc temp7
	sta sprspace+sp_x_pg, x
	
	lda sprspace+sp_vel_y_lo, x
	clc
	adc sprspace+sp_y_lo, x
	sta sprspace+sp_y_lo, x
	
	lda sprspace+sp_part_vel_y, x
	bmi @velMinus
	
	; velocity is positive. that means that a SET carry determines overflow
	adc sprspace+sp_y, x
	bcc @setY
	
	lda #0
	sta sprspace+sp_kind, x  ; particle went off screen, actually!
	lda #$F0
	bne @setY
	
@velMinus:
	; velocity is negative. means that a CLEAR carry determines overflow
	adc sprspace+sp_y, x
	bcs @setY
	lda #$00
@setY:
	sta sprspace+sp_y, x
	
	; gravity
	lda sprspace+sp_vel_y_lo, x
	clc
	adc sprspace+sp_part_gravi, x
	sta sprspace+sp_vel_y_lo, x
	
	bcc @done
	inc sprspace+sp_vel_y, x
@done:
	dec sprspace+sp_part_timer, x
	bne :+
	lda #0
	sta sprspace+sp_kind, x
:	rts

gm_update_box:
	ldx temp1
	
	; set the collidable flag
	lda #ef_collidable
	ora sprspace+sp_flags, x
	sta sprspace+sp_flags, x
	
	; and now the width / height
	lda #16
	sta sprspace+sp_wid, x
	sta sprspace+sp_hei, x
	
	rts
