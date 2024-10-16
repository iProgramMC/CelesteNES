; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_spawn_particle
; desc: Spawns a particle.
; parameters:
;     temp1 - old entity index
;     temp4 - character tile
;     temp5 - attributes of that tile (when palette alloc added, the old entity type)
;     reg X - direction (0-UL, 1-UR, 2-DL, 3-DR)
; note: the value of X is preserved.
; note: the value of temp6 is clobbered
gm_spawn_particle:
	stx temp6
	ldy #0
:	lda sprspace+sp_kind, y
	beq :+
	iny
	cpy #sp_max
	bne :-
	
	; no more space :(
	rts

:	; slot found!
	lda #e_particle
	sta sprspace+sp_kind, y
	
	ldx temp1
	lda sprspace+sp_kind, x
	sta sprspace+sp_part_entty, y
	
	clc
	lda sprspace+sp_x, x
	adc #4
	sta sprspace+sp_x, y
	
	lda sprspace+sp_x_pg, x
	adc #0
	sta sprspace+sp_x_pg, y
	
	clc
	lda sprspace+sp_y, x
	adc #4
	sta sprspace+sp_y, y
	
	ldx temp6
	lda partdirx, x
	sta sprspace+sp_part_vel_x, y
	lda partdiry, x
	sta sprspace+sp_part_vel_y, y
	
	lda #8
	sta sprspace+sp_part_timer, y
	lda temp4
	sta sprspace+sp_part_chrti, y
	lda temp5
	sta sprspace+sp_part_chrat, y
	
	rts

partdirx: .byte $FC,$04,$FC,$04
partdiry: .byte $FC,$FC,$04,$04

; ** SUBROUTINE: gm_give_points
; desc: Gives points to a player. Note: these aren't actually tracked anywhere >:)
;
;       Handles the bonus streak mechanic.
gm_give_points:
	inc ptscount
	ldx ptscount
	cpx #7           ; values between 1 and 6 are valid.
	bne :+
	ldx #6
	stx ptscount
:	lda #120
	sta ptstimer
	
	; fallthrough

; ** SUBROUTINE: gm_spawn_points
; desc: Spawns a floating points sprite at the player's position.
; arguments:
;   reg X: amount of points  ((X+1)*1000, or 1UP)
gm_spawn_points:
	ldy #0
:	lda sprspace+sp_kind, y
	beq :+
	iny
	cpy #sp_max
	bne :-
	
	; no more space :(
	rts

:	; slot found!
	lda #e_points
	sta sprspace+sp_kind, y
	
	clc
	lda player_x
	adc camera_x
	sta sprspace+sp_x, y
	
	lda camera_x_pg
	adc #0
	sta sprspace+sp_x_pg, y
	
	lda player_y
	sta sprspace+sp_y, y
	
	lda #60
	sta sprspace+sp_points_timer, y
	
	txa
	cmp #6
	bcc :+
	lda #6
:	sta sprspace+sp_points_count, y

	rts
