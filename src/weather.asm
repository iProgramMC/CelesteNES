
; ** SUBROUTINE: tl_adjust_y
; arguments: a - the Y coordinate to adjust
; returns:   a - the adjusted Y coordinate
; clobbers:  x
; desc:      adjusts a Y coordinate to fit in a [0, 224] range
tl_adjust_y:
	tax
	cpx #$E0
	bcc tl_adjusret
	sbc #$E0
	asl
	asl
	asl
	asl
	and #%11011111
tl_adjusret:
	rts

; ** SUBROUTINE: tl_init_snow
tl_init_snow:
	ldy #$00           ; initialize Y coordinates
tl_initloop1:
	jsr rand
	sta tl_snow_y, y
	iny
	cpy #$10
	bne tl_initloop1
	
	ldy #$00           ; initialize X coordinates
tl_initloop2:
	jsr rand
	sta tl_snow_x, y
	iny
	cpy #$10
	bne tl_initloop2

	rts

osciltable:
	.byte $FF,$FF,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$FF,$FF

; ** SUBROUTINE: tl_update_snow
tl_update_snow:
	inc tl_timer
	ldy #$00
	
	; update Y coordinate to oscillate
tl_updaupdloop:
	tya
	adc tl_timer
	and #$07
	bne tl_updadontosci
	tya
	adc tl_timer
	lsr
	lsr
	lsr
	and #$0F
	tax
	lda tl_snow_y, y
	clc
	adc osciltable, x
	sta tl_snow_y, y
tl_updadontosci:
	
	; update X coordinate to go left
	ldx tl_snow_x, y
	dex
	beq tl_updatrespawn
	tya
	and #$01
	bne tl_updadontdecr
	dex
	beq tl_updatrespawn
tl_updadontdecr:
	stx tl_snow_x, y
tl_updacontinue:
	
	; move on to the next particle
	iny
	cpy #$10
	bne tl_updaupdloop
	rts
tl_updatrespawn:         ; respawn this particle
	lda #$FF
	sta tl_snow_x, y
	jsr rand
	jsr tl_adjust_y
	sta tl_snow_y, y
	jmp tl_updacontinue

snow_sprites: .byte $16, $18

; ** SUBROUTINE: tl_render_snow
tl_render_snow:
	ldy #$00
tl_render_loop:
	lda tl_snow_y, y
	sta y_crd_temp
	lda tl_snow_x, y
	sta x_crd_temp
	tya
	pha
	and #$01
	tay
	lda snow_sprites, y
	tay
	lda #3
	jsr oam_putsprite
	pla
	tay
	iny
	cpy #$10
	bne tl_render_loop
	rts
