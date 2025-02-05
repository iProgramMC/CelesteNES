; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: gm_load_hair_palette
; desc: Loads Madeline's hair's palette
gm_load_hair_palette:
	lda plh_forcepal
	bne :+
	lda #maxdashes
	sec
	sbc dashcount
:	jsr gm_allocate_palette
	sta plh_attrs
	rts

; ** SUBROUTINE: gm_draw_2xsprite
; arguments: x - offset into zero page with sprite structure
;            a - x position, y - y position
; structure:  [shared attributes] [left sprite] [right sprite]
gm_draw_2xsprite:
	sta x_crd_temp
	sty y_crd_temp
	lda $00,x       ; get shared attributes into a
	inx
	ldy $00,x       ; get left sprite
	inx
	stx temp7
	jsr oam_putsprite
	ldx temp7
	ldy $00,x       ; get right sprite
	lda x_crd_temp  ; add 8 to x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	dex
	dex
	lda $00,x       ; get shared attributes again
	jmp oam_putsprite

; ** SUBROUTINE: gm_draw_respawn
.proc gm_draw_respawn
	lda playerctrl
	and #pl_dead
	bne return
	
	lda respawntmr
	beq return
	
	jmp gm_do_respawn
	
return:
	rts
.endproc

; ** SUBROUTINE: gm_dead_sub2
; desc: Does some math to reduce the result of sine/cosine.
; It's like (temp1 >> 3) + (temp1 >> 4) basically
.proc gm_dead_sub2
	; divide each component by 8
	lda temp1
	jsr rotate3x
	sta temp1
	cmp #128
	ror
	clc
	adc temp1
	sta temp1
	
	lda temp2
	jsr rotate3x
	sta temp2
	cmp #128
	ror
	clc
	adc temp2
	sta temp2
	rts

rotate3x:
	cmp #128
	ror
	cmp #128
	ror
	cmp #128
	ror
	rts
.endproc

; ** SUBROUTINE: gm_dead_sub3
; desc: Does some more math to interpolate towards temp1, temp2
.proc gm_dead_sub3
	lda deathtimer
	cmp plattemp1
	bcs return
	
	lda #0
	sta temp5
	sta temp6
	
	ldy temp11
loop:
	lda temp1
	cmp #128
	ror
	sta temp1
	ror temp5
	
	lda temp2
	cmp #128
	ror
	sta temp2
	ror temp6
	
	dey
	bne loop
	
	ldy deathtimer
	beq return
	lda #0
	sta temp7
	sta temp8
	sta temp9
	sta temp10
loop2:
	lda temp9
	clc
	adc temp5
	sta temp9
	
	lda temp7
	adc temp1
	sta temp7
	
	lda temp10
	clc
	adc temp6
	sta temp10
	
	lda temp8
	adc temp2
	sta temp8
	
	dey
	bne loop2
	
	lda temp7
	sta temp1
	lda temp8
	sta temp2

return:
	rts
.endproc

; ** SUBROUTINE: gm_dead_shake
.proc gm_dead_shake
	lda #%00001111
	sta quakeflags
	sta quaketimer
	rts
.endproc

; ** SUBROUTINE: gm_draw_dead
.proc gm_draw_dead
	lda #pl_dead
	bit playerctrl
	bne notDead
return:
	rts

notDead:
	lda #8
	sta plattemp1
	lda #3
	sta temp11
	
	lda deathtimer
	bne :+
	jsr gm_dead_shake
:	cmp #32
	bcs return

respawnOverride:
	lda deathangle
	sta temp4
	inc deathangle
	inc deathangle
	
	; load the dead-player-bank. the player isn't being drawn anymore so just reuse its slots
	lda #chrb_dpldi
	sta spr0_bknum
	
	ldy #0
deadLoop:
	lda temp4
	jsr sine
	sta temp1
	
	lda temp4
	jsr cosine
	sta temp2
	
	lda temp4
	clc
	adc #32
	sta temp4
	
	sty temp3
	jsr gm_dead_sub2
	jsr gm_dead_sub3
	ldy temp3
	
	lda player_dx
	clc
	adc temp1
	sta x_crd_temp
	ldx #0
	lda temp1
	bpl :+
	dex
:	txa
	adc #0
	bne doneLoop
	
	lda x_crd_temp
	clc
	adc #4
	sta x_crd_temp
	bcs doneLoop
	
	lda player_dy
	clc
	adc temp2
	sta y_crd_temp
	
	ldx #0
	lda temp2
	bpl :+
	dex
:	txa
	adc #0
	bne doneLoop
	
	lda y_crd_temp
	cmp #240
	bcs doneLoop
	clc
	adc #4
	sta y_crd_temp
	
	lda plh_attrs
	sty temp3

	lda deathtimer
	cmp #24
	bcc :+
	lda #24
:	lsr
	lsr
	tay
	lda tableT, y
	tay
	lda #1
	
	jsr oam_putsprite
	ldy temp3
	
doneLoop:
	iny
	cpy #8
	bne deadLoop
	
	; increment death timer
done:
	ldx respawntmr
	bne return2
	
	ldx deathtimer
	inx
	cpx #24
	bne dontRespawn
	jmp gm_respawn
dontRespawn:
	stx deathtimer
return2:
	rts

;tableT:	.byte $10,$10,$06,$06,$00,$00,$00,$00,$06,$06,$08,$08,$12,$12
tableT:	.byte $10,$06,$00,$00,$06,$08,$12
.endproc

; ** SUBROUTINE: gm_check_level_banks
; desc: Checks the loaded background banks for levels.
.proc gm_check_level_banks
	lda levelnumber
	cmp #1
	beq @level1
	cmp #2
	beq @level2
	
@return:
	rts

@level2:
	lda cassrhythm
	bmi @return
	lda miscsplit
	bne @return
	
	ldx #chrb_lvl2+2
	ldy #chrb_splv2n
	lda dbenable
	bne :+
	ldx #chrb_lvl2e
:	cmp #3
	bne :+
	ldy #chrb_gensp1
:	stx bg1_bknum
	sty spr2_bknum
	rts

@level1:
	; check if we are in the "r11z" room.
	lda #>level1_r11z
	cmp roomptrhi
	bne @nope
	lda #<level1_r11z
	cmp roomptrlo
	bne @nope
	
	; we are.
	; load the tape
	lda #chrb_cass1
	sta spr1_bknum
	
	sei
	lda #<irq_cass_elevator
	sta irqaddr
	lda #>irq_cass_elevator
	sta irqaddr+1
	cli
	
	lda #64
	sta miscsplit
	
@nope:
	rts
.endproc

.proc irq_cass_elevator
	sta mmc3_irqdi
	pha
	lda #def_mmc3_bn | mmc3bk_spr1
	sta mmc3_bsel
	lda #chrb_splvl1
	sta mmc3_bdat
	lda mmc3_shadow
	sta mmc3_bsel
	pla
	rti
.endproc
