; Copyright (C) 2024 iProgramInCpp
; Level 0 specific entities.

; ** Entity Draw/Update routines
; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

; ** ENTITY: level0_intro_crusher
; desc: The intro crusher from the Prologue.
;       Draws itself in two halves which alternate their order every frame.
;       This way, at least some of the crusher is visible even if the
;       player is horizontally adjacent.
l0ic_dormant  = $00
l0ic_shaking  = $01
l0ic_falling  = $02
l0ic_fallen   = $03

l0ic_maxy        = 120
l0ic_defshaketmr = (256 - 20)
l0ic_palette     = $2

level0_intro_crusher:
	lda #0
	sta temp7
	ldx temp1
	lda sprspace+sp_l0ic_state, x
	; cmp #1
	; bne @returnEarly
	sta temp6 ; TEMP
	
	cmp #l0ic_dormant
	bne @notDormant
	
	; Is dormant
	lda player_x
	sec
	sbc #30
	bcc @notDormant
	cmp temp2
	bcc @returnEarly
	
	; trigger a fall.
	inc sprspace+sp_l0ic_state, x
	lda #l0ic_defshaketmr
	sta sprspace+sp_l0ic_timer, x
	
	lda temp2
	pha
	lda temp3
	pha
	jsr @clearTilesForIC
	pla
	sta temp3
	pla
	sta temp2
	
	jmp @drawSprite
	
@returnEarly:
	rts
	
@notDormant:
	cmp #l0ic_shaking
	bne @notShaking
	
	lda sprspace+sp_l0ic_timer, x
	bne @doShake
	
	; sprite timer hit 0! time to fall!!
	inc sprspace+sp_l0ic_state, x
	lda #0
	sta sprspace+sp_y_lo, x
	sta sprspace+sp_l0ic_vel_y, x
	sta sprspace+sp_l0ic_vsu_y, x
	
	bne @drawSprite

@doShake:
	lda sprspace+sp_l0ic_timer, x
	and #3
	tay
	lda l0ic_shake_table, y
	clc
	adc temp2
	sta temp2
	jmp @drawSprite

@notShaking:
	cmp #l0ic_falling
	bne @notFalling
	
	; is falling
	; accelerate
	clc
	lda sprspace+sp_l0ic_vsu_y, x
	adc #$20
	sta sprspace+sp_l0ic_vsu_y, x
	bcc :+
	inc sprspace+sp_l0ic_vel_y, x

	; pull
:	clc
	lda sprspace+sp_y_lo, x
	adc sprspace+sp_l0ic_vsu_y, x
	sta sprspace+sp_y_lo, x
	lda sprspace+sp_y, x
	adc sprspace+sp_l0ic_vel_y, x
	sta sprspace+sp_y, x
	
	cmp #l0ic_maxy
	bcc @drawSprite
	
	; has fallen
	lda #l0ic_maxy
	sta sprspace+sp_y, x
	inc sprspace+sp_l0ic_state, x
	
	lda #$7
	sta quakeflags
	sta quaketimer
	
	jsr @setTilesForIC
	
@notFalling:
	; Is fallen
	rts
	
@drawSprite:
	inc sprspace+sp_l0ic_timer, x
	lda sprspace+sp_l0ic_timer, x
	and #1
	bne @drawFirstHalfFirst
	; draw second half first.
	jsr @secondHalf
	jsr @firstHalf
	rts
@drawFirstHalfFirst:
	; draw first half first.
	jsr @firstHalf
	jsr @secondHalf
	rts
	
; Draws the first half.
@firstHalf:
	jsr @firstHalfUp
	jsr @firstHalfDown
	rts

@secondHalf:
	jsr @secondHalfUp
	jsr @secondHalfDown
	rts

@firstHalfUp:
	lda temp2
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	
	ldy #0
:	sty temp5
	lda l0ic_dataFHU, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_fhu
	
	ldy temp5
	iny
	cpy #4
	bne :-
	
@return_fhu:
	rts

@firstHalfDown:
	lda temp2
	sta x_crd_temp
	lda temp3
	clc
	adc #16
	sta y_crd_temp
	bcs @return_fhd
	
	ldy #0
:	sty temp5
	lda l0ic_dataFHD, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_fhd
	
	ldy temp5
	iny
	cpy #4
	bne :-
	
@return_fhd:
	rts

@secondHalfUp:
	lda temp2
	clc
	adc #32
	sta x_crd_temp
	bcs @return_shu
	lda temp3
	sta y_crd_temp
	
	ldy #0
:	sty temp5
	lda l0ic_dataSHU, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_shu
	
	ldy temp5
	iny
	cpy #3
	bne :-
	
@return_shu:
	rts

@secondHalfDown:
	lda temp2
	clc
	adc #32
	sta x_crd_temp
	bcs @return_shd
	lda temp3
	clc
	adc #16
	sta y_crd_temp
	bcs @return_shd
	
	ldy #0
:	sty temp5
	lda l0ic_dataSHD, y
	tay
	lda #l0ic_palette
	jsr oam_putsprite
	
	jsr @incrementX
	bcs @return_shd
	
	ldy temp5
	iny
	cpy #3
	bne :-
	
@return_shd:
	rts

@incrementX:
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	rts

@clearTilesForIC:
	; Set the flags that will clear the crusher's nametable visually.
	stx l0crshidx
	
	lda #g2_clrcru
	ora gamectrl2
	sta gamectrl2
	
	; Initiate the clearing process.
	jsr level0_ic_calcpos         ; calculate tile pos in (temp2, temp3)
	jsr level0_ic_calcppuaddr     ; use said tile pos to prepare for the g2_clrcru NMI.
	
	ldx #0
@loop:
	stx temp4
	
	ldy temp3
	ldx temp2
	jsr h_comp_addr
	inx
	stx temp2
	
	ldx #4
	lda #0
:	sta (lvladdr), y
	iny
	dex
	bne :-
	
	ldx temp4
	inx
	cpx #7
	bne @loop
	
	rts

@setTilesForIC:
	; Set the flags that will clear the crusher's nametable visually.
	stx l0crshidx
	
	lda #g2_setcru
	ora gamectrl2
	sta gamectrl2
	
	; Initiate the setting process.
	jsr level0_ic_calcpos         ; calculate tile pos in (temp2, temp3)
	jsr level0_ic_calcppuaddr     ; use said tile pos to prepare for the g2_setcru NMI.
	
	ldx #0
	stx temp6
@loop1:
	stx temp4
	
	ldy temp3
	ldx temp2
	jsr h_comp_addr
	inx
	stx temp2
	
	lda #1
	ldx #4
:	sta (lvladdr), y
	iny
	dex
	bne :-
	
	ldx temp4
	inx
	cpx #7
	bne @loop1
	
	rts

; ** SUBROUTINE: level0_nmi_clear_icr
; desc: Clears the places in a nametable that the IntroCrusher occupies.
; assumes: running inside an NMI or rendering is disabled.
level0_nmi_clear_icr:
	lda l0crshpahi
	sta ppu_addr
	lda l0crshpalo
	sta ppu_addr
	
	ldx #0
@loop:
	stx temp2
	
	ldx #0
	lda #0
:	sta ppu_data
	inx
	cpx #7
	bne :-
	
	lda l0crshpalo
	clc
	adc #$20
	sta l0crshpalo
	bcc :+
	inc l0crshpahi
:	lda l0crshpahi
	sta ppu_addr
	lda l0crshpalo
	sta ppu_addr
	
	ldx temp2
	inx
	cpx #4
	bne @loop
	rts
	
level0_nmi_set_icr:
	lda l0crshpahi
	sta ppu_addr
	lda l0crshpalo
	sta ppu_addr
	
	ldx #0
	ldy #0
@loop:
	stx temp2
	
	ldx #0
:	lda l0ic_chardata, y
	sta ppu_data
	iny
	inx
	cpx #7
	bne :-
	
	lda l0crshpalo
	clc
	adc #$20
	sta l0crshpalo
	bcc :+
	inc l0crshpahi
	
:	lda l0crshpahi
	sta ppu_addr
	lda l0crshpalo
	sta ppu_addr
	
	ldx temp2
	inx
	cpx #4
	bne @loop
	rts

; ** SUBROUTINE: level0_ic_calcpos
; desc: Calculates the tile position of the IntroCrusher into [temp2, temp3].
level0_ic_calcpos:
	; Initiate the setting process.
	lda sprspace + sp_y, x
	lsr
	lsr
	lsr
	sta temp3
	tay
	
	lda sprspace + sp_x_pg, x
	ror
	ror
	ror
	ror
	and #%00100000
	sta temp2
	
	lda sprspace + sp_x, x
	lsr
	lsr
	lsr
	ora temp2
	sta temp2
	
	rts

; desc: Calculates the PPU address of the current IntroCrusher position, stored
;       at [temp2 (x), temp3 (y)].
;       Returns the results in l0crshpalo, l0crshpahi.  These are then used by
;       the NMI handler.
level0_ic_calcppuaddr:
	; add the level Y offset.
	lda temp3
	pha
	
	clc
	adc lvlyoff
	cmp #$1E
	bcc :+
	sbc #$1E
:	sta temp3
	
	; the nametable the IC is a part of.
	;
	; note: the IC may not wrap across nametables! Tiles will be written to the
	; wrong place if it does!
	lda #%00100000
	bit temp2
	bne @do24
	lda #$20
	bne @done
@do24:
	lda #$24
@done:
	sta l0crshpalo
	
	; then, part of the Y coordinate.
	; between $2000 and $2100 there are 8 tile rows.
	lda temp3
	lsr
	lsr
	lsr
	clc
	adc l0crshpalo
	tay         ; high address in Y
	
	; 0010 0XYY YYYX XXXX
	
	lda temp3
	ror
	ror
	ror
	ror
	and #%11100000
	sta l0crshpalo
	
	lda temp2
	and #%00011111
	ora l0crshpalo
	
	; temp5 - high byte, temp4 - low byte
	sta l0crshpalo
	sty l0crshpahi
	
	pla
	sta temp3
	rts

l0ic_dataFHU:	.byte $81, $89, $8B, $8D
l0ic_dataFHD:	.byte $83, $8F, $91, $93
l0ic_dataSHU:	.byte $8D, $89, $85
l0ic_dataSHD:	.byte $8F, $93, $87
l0ic_shake_table:	.byte $01, $00, $FF, $00

l0ic_chardata:
	.byte $80,$88,$8A,$8C,$8C,$88,$84
	.byte $81,$89,$8B,$8D,$8D,$89,$85
	.byte $82,$8E,$90,$92,$99,$92,$86
	.byte $83,$8F,$91,$93,$8F,$93,$87
