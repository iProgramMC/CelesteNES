; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_spawn_particle
; desc: Spawns a particle.
; parameters:
;     temp1 - X position
;     temp2 - Y position
;     temp3 - X high position in pages
;     temp4 - character tile
;     temp5 - attributes (when palette alloc added, type of an associated entity`)
;     temp6 - old entity type (redundant ?)
;     temp7 - direction (0-UL, 1-UR, 2-DL, 3-DR, 4-None)
;     temp8 - gravity
;     temp9 - time alive
.proc gm_spawn_particle
	ldy #0
:	lda sprspace+sp_kind, y
	beq slotFound
	iny
	cpy #sp_max
	bne :-
	rts          ; no more space :(

slotFound:
	; from here until startConvergence, gm_spawn_particle does its own thing
	lda temp1
	sta sprspace+sp_x, y
	lda temp2
	sta sprspace+sp_y, y
	lda temp3
	sta sprspace+sp_x_pg, y
	
startConvergence:
	lda #e_particle
	sta sprspace+sp_kind, y
	
	lda roomnumber
	and #1
	asl
	sta sprspace+sp_flags, y
	
	lda #0
	sta sprspace+sp_wid, y
	sta sprspace+sp_hei, y
	sta sprspace+sp_vel_x_lo, y
	sta sprspace+sp_vel_y_lo, y
	sta sprspace+sp_x_lo, y
	sta sprspace+sp_y_lo, y
	
	ldx temp6
	lda partdirx, x
	sta sprspace+sp_part_vel_x, y
	lda partdiry, x
	sta sprspace+sp_part_vel_y, y
	
	lda temp9
	sta sprspace+sp_part_timer, y
	lda temp8
	sta sprspace+sp_part_gravi, y
	lda temp4
	sta sprspace+sp_part_chrti, y
	lda temp5
	sta sprspace+sp_part_chrat, y
	rts
.endproc

; ** SUBROUTINE: gm_spawn_particle_at_ent
; desc: Spawns a particle at an entity's position.
; parameters:
;     temp1 - old entity index
;     temp4 - character tile
;     temp5 - attributes of that tile (when palette alloc added, the old entity type)
;     temp8 - gravity
;     temp9 - time alive
;     reg X - direction (0-UL, 1-UR, 2-DL, 3-DR, 4-None)
; note: the value of X is preserved.
; note: the value of temp6 is clobbered
.proc gm_spawn_particle_at_ent
	stx temp6
	ldy #0
:	lda sprspace+sp_kind, y
	beq @slotFound
	iny
	cpy #sp_max
	bne :-
	
	; no more space :(
	rts

@slotFound:
	
	ldx temp1
	lda sprspace+sp_kind, x
	sta sprspace+sp_part_entty, y
	
	lda sprspace+sp_x, x
	clc
	adc #4
	sta sprspace+sp_x, y
	
	lda sprspace+sp_x_pg, x
	adc #0
	sta sprspace+sp_x_pg, y
	
	lda sprspace+sp_y, x
	clc
	adc #4
	sta sprspace+sp_y, y
	
	jmp gm_spawn_particle::startConvergence
.endproc

partdirx: .byte $FF,$01,$FF,$01,$00
partdiry: .byte $FF,$FF,$01,$01,$00

; ** SUBROUTINE: gm_give_points_ent
; desc: Gives points to a player, setting the points' coordinates to an entity's.
; parameters: X - the ID of the entity
gm_give_points_ent:
	lda sprspace+sp_x, x
	sta temp1
	lda sprspace+sp_x_pg, x
	sta temp2
	lda sprspace+sp_y, x
	sta temp3
	
	jmp gm_give_points2

; ** SUBROUTINE: gm_give_points
; desc: Gives points to a player. Note: these aren't actually tracked anywhere >:)
;
;       Handles the bonus streak mechanic.
gm_give_points:
	lda player_x
	clc
	adc camera_x
	sta temp1
	lda camera_x_pg
	adc #0
	sta temp2
	lda player_y
	sta temp3
	
gm_give_points2:
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
	
	lda roomnumber
	and #1
	asl
	sta sprspace+sp_flags, y
	
	lda temp1
	sta sprspace+sp_x, y
	
	lda temp2
	sta sprspace+sp_x_pg, y
	
	lda temp3
	sta sprspace+sp_y, y
	
	lda #60
	sta sprspace+sp_points_timer, y
	
	txa
	cmp #6
	bcc :+
	lda #6
:	sta sprspace+sp_points_count, y

	rts
