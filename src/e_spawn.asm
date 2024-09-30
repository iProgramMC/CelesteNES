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
	and #1
	sta sprspace+sp_x_hi, y
	
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