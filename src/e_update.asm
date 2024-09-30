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
	bne :+
	
	lda temp5
	lsr
	lsr
	lsr
	and #15
	tax
	lda osciltable, x
	sta temp5
	ldx temp1
	lda sprspace+sp_y, x
	clc
	adc temp5
	sta sprspace+sp_y, x
	
:	rts

gm_update_berry:
	jsr gm_ent_oscillate
	
	ldx temp1
	lda sprspace+sp_strawb_flags, x
	and #esb_picked
	beq :++
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
	and #1
	sta sprspace+sp_x_hi, x
	
	lda temp3
	sta sprspace+sp_y, x
	
	jmp :++
:	
	; floating mode
	jsr gm_check_player_bb
	beq :+
	
	; collided, set to picked up mode
	lda sprspace+sp_strawb_flags, x
	ora #esb_picked
	sta sprspace+sp_strawb_flags, x
	
	inc plrstrawbs
	lda plrstrawbs
	sta sprspace+sp_strawb_colid, x
	
:	rts

gm_update_refill:
	jsr gm_ent_oscillate
	
	jsr gm_check_player_bb
	beq :++
	
	; collided!
	; check if the dash count is non zero.
	lda dashcount
	beq :++
	; todo: check stamina too
	
	; player has dashed which means 
	; break into 4 pieces, destroy, and give the player their dashes back
	
	lda #$74
	sta temp4
	lda #1
	sta temp5
	
	ldx #0
	jsr gm_spawn_particle
	inx
	jsr gm_spawn_particle
	inx
	jsr gm_spawn_particle
	inx
	jsr gm_spawn_particle
	
	ldx temp1
	lda sprspace+sp_refill_flags, x
	and #erf_regen
	beq :+
	
	lda sprspace+sp_oscill_timer, x
	sta sprspace+sp_refill_oldos, x
	
	lda #$F0
	sta sprspace+sp_oscill_timer, x
	lda #e_refillhd
:	sta sprspace+sp_kind, x
	
	lda #0
	sta dashcount
	
:	rts

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
:	lda sprspace+sp_part_vel_y, x
	sta temp6
	
	clc
	lda sprspace+sp_x, x
	adc temp5
	sta sprspace+sp_x, x
	lda sprspace+sp_x_pg, x
	adc temp7
	sta sprspace+sp_x_pg, x
	and #1
	sta sprspace+sp_x_hi, x
	
	clc
	lda sprspace+sp_y, x
	adc temp6
	sta sprspace+sp_y, x
	
	dec sprspace+sp_part_timer, x
	bne :+
	lda #0
	sta sprspace+sp_kind, x
:	rts
