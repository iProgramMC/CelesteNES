; Copyright (C) 2025 iProgramInCpp

;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

chrb_papho0 = $40
chrb_papho1 = $41
chrb_papho2 = $42
chrb_papho3 = $43
chrb_papho4 = $44
chrb_papho5 = $45
chrb_papho6 = $46
chrb_papho7 = $47
chrb_papho8 = $48

; ######### ANIMATION TABLES #########
.proc level2_payphone_idle
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
main:
	.byte $00,$00,pal_gray,$00
	.byte $00,$02,pal_gray,$08
	.byte $00,$04,pal_red, $10
pole:
	.byte $10,$22,pal_gray,$08
	.byte $10,$24,pal_red, $10
	.byte $20,$08,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte $FF
.endproc

.proc level2_payphone_mad1
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$C4,$80,    $FB
	.byte $28,$C6,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad2
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$10,$80,    $FB
	.byte $28,$12,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad3
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$14,$80,    $FB
	.byte $28,$16,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad4
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$18,$80,    $FB
	.byte $28,$1A,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad5
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$06,$80,    $FB
	.byte $28,$26,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad6
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$18,$80,    $FB
	.byte $28,$0E,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad7
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$1C,$80,    $FB
	.byte $28,$1E,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.define level2_payphone_table \
	level2_payphone_idle,     \
	level2_payphone_mad1,     \
	level2_payphone_mad2,     \
	level2_payphone_mad3,     \
	level2_payphone_mad5,     \
	level2_payphone_mad6,     \
	level2_payphone_mad7,     \
	level2_payphone_mad7,     \
	$0000

level2_payphone_table_lo:	.lobytes level2_payphone_table
level2_payphone_table_hi:	.hibytes level2_payphone_table

level2_payphone_max_timer = 8

; ######### ANIMATION CODE #########

; ** ENTITY: level2_payphone
; desc: This draws and animates the payphone entity.
.proc level2_payphone
	ldx temp1
	lda sprspace+sp_l2ph_timer, x
	
	; increment the timer
	pha
	clc
	adc #1
	cmp #level2_payphone_max_timer
	bne :+
	lda #0
:	sta sprspace+sp_l2ph_timer, x
	pla
	
	tax
	lda level2_payphone_table_lo, x
	sta setdataaddr
	lda level2_payphone_table_hi, x
	sta setdataaddr+1
	
	; draw
	ldy #0
	lda (setdataaddr), y
	iny
	sta spr1_bknum
	
	ldx oam_wrhead

@loop:
	; write Y coordinate
	lda (setdataaddr), y
	cmp #$FF
	beq @return
	cmp #$FE
	beq @jump
	clc
	adc temp3
	sta oam_buf, x
	inx
	iny
	
	; write tile number
	lda (setdataaddr), y
	;hack
	clc
	adc #$41
	sta oam_buf, x
	inx
	iny
	
	; write attributes
	stx oam_wrhead
	sty temp11
	lda (setdataaddr), y
	bmi :+
	jsr gm_allocate_palette
:	and #$7F
	ldy temp11
	ldx oam_wrhead
	sta oam_buf, x
	inx
	iny
	
	; write X coordinate
	lda (setdataaddr), y
	clc
	adc temp2
	sta oam_buf, x
	inx
	iny
	stx oam_wrhead
	jmp @loop

@return:
	rts

@jump:
	iny
	lda (setdataaddr), y
	tax
	iny
	lda (setdataaddr), y
	stx setdataaddr
	sta setdataaddr+1
	ldx oam_wrhead
	ldy #0
	beq @loop
.endproc

; ** ENTITY: level2_mirror
; desc: The mirror that unlocks the Dream Blocks!
.proc level2_mirror
	; Set up the IRQ
	lda #<level2_hide_irq
	sta irqaddr
	lda #>level2_hide_irq
	sta irqaddr+1
	
	lda #0
	sta miscsplit
	
	lda camera_y
	sec
	sbc camera_y_bs
	sec
	sbc camera_y_sub
	clc
	adc #$C0
	;bcs :+
	
	; activate the scroll split
	sta miscsplit
	
:	jsr drawBadeline
	
	
	rts

drawBadeline:
	lda spr0_bknum
	clc
	adc #chrb_splv2l
	sta spr1_bknum
	
	; Calculate Middle of Screen
	lda roombeglo
	clc
	adc #$A0
	sta temp5
	lda roombeghi
	adc #0
	sta temp6
	
	lda temp5
	sec
	sbc camera_x
	sta temp5
	lda temp6
	sbc camera_x_pg
	sta temp6
	
	lda temp5
	sec
	sbc #$20
	sta temp11
	
	; amount player is offset from screen
	lda player_x
	sec
	sbc temp5
	sta temp2
	
	lda temp5
	sec
	sbc temp2
	sec
	sbc #$10
	sta temp2
	
	lda player_y
	sta temp3
	
	; draw 4 empty sprites above and below the mirror
	lda #$F0
	sta x_crd_temp
	lda #$74
	sta y_crd_temp
	
	jsr put4Sprites
	
	lda #$A0
	sta y_crd_temp
	jsr put4Sprites
	jsr put4Sprites
	
	lda player_y
	cmp #$75
	bcc @dontDraw
	cmp #$A0
	bcs @dontDraw
	
	; check for the X coordinate
	lda temp5
	sec
	sbc #(24+16)
	cmp temp2
	bcs @dontDraw  ; mirrorLeftEdge >= reflectionX
	
	lda temp5
	clc
	adc #24
	cmp temp2
	;bcc @dontDraw  ; mirrorRightEdge < reflectionX
	bcs @doDraw
@dontDraw:
	rts

@doDraw:
	; draw the overlay
	lda temp2
	pha
	
	lda #pal_mirror
	jsr gm_allocate_palette
	sta temp8
	
	pla
	pha
	
	clc
	adc #$24
	sec
	sbc temp5
	lsr
	lsr
	lsr
	and #7
	pha
	tax
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	; draw the first sprite
	lda spriteRow1, x
	tay
	lda #$87
	sta y_crd_temp
	lda temp8
	jsr oam_putsprite
	
	; then the second
	inx
	cpx #8
	bne :+
	ldx #0
:	txa
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	lda spriteRow1, x
	tay
	lda temp8
	jsr oam_putsprite
	
	; Now for the second row
	pla
	tax
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	; the first sprite
	lda spriteRow2, x
	tay
	lda #$97
	sta y_crd_temp
	lda temp8
	jsr oam_putsprite
	
	; then the second
	inx
	cpx #8
	bne :+
	ldx #0
:	txa
	asl
	asl
	asl
	clc
	adc temp11
	sta x_crd_temp
	
	lda spriteRow2, x
	tay
	lda temp8
	jsr oam_putsprite
	
	; done with the overlay
	pla
	sta temp2
	
	lda #pal_chaser
	jsr gm_allocate_palette
	;ora #obj_backgd
	sta temp5
	sta temp8
	
	; Draw Body
	ldx plr_spr_l
	ldy plr_spr_r
	lda playerctrl
	and #pl_left
	bne :+
	ldx plr_spr_r
	ldy plr_spr_l
	lda temp5
	ora #obj_fliphz
	sta temp5
	sta temp8
:	stx temp6
	sty temp7
	
	; HACK for walking
	lda spryoff
	bpl :+
	clc
	adc temp3
	sta temp3
	
:	lda temp11
	cmp temp2
	bcc :+
	
	; mirrorLeftEdge >= player_x
	lda #$5E
	sta temp6
	
:	lda temp11
	clc
	adc #$30
	cmp temp2
	bcs :+
	
	; mirrorRightEdge <= player_x
	lda #$5E
	sta temp7
	
:	jmp drawSprite
	
put4Sprites:
	ldy #$5E
	jsr oam_putsprite
	ldy #$5E
	jsr oam_putsprite
	ldy #$5E
	jsr oam_putsprite
	ldy #$5E
	jmp oam_putsprite

drawSprite:
	lda temp2
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	
	lda temp6
	cmp #$5E
	beq :+
	
	clc
	adc #$40
	tay
	lda temp5
	jsr oam_putsprite

:	lda temp7
	cmp #$5E
	beq :+
	
	clc
	adc #$40
	tay
	lda temp2
	clc
	adc #8
	sta x_crd_temp
	lda temp8
	jmp oam_putsprite

:	rts

spriteRow1:	.byte $70,$72,$74,$76,$78,$7A,$7C,$7E
spriteRow2:	.byte $40,$76,$78,$7A,$62,$64,$66,$42
.endproc

; ** IRQ HANDLER: level2_hide_irq
; desc: This IRQ handler hides the background layer to avoid revealing the upper
; part of the level that's actually lower. The reason we do it as such is to allow
; for scrolling up during the Dream Block Unlock cutscene.
.proc level2_hide_irq
	pha
	lda #%00010000 ; only sprites
	sta ppu_mask
	sta mmc3_irqdi
	
	; schedule a show IRQ later
	lda #$2D  ; from $C0 to $F0, we have $30 pixels. slightly earlier.
	sta mmc3_irqla
	sta mmc3_irqrl
	sta mmc3_irqen
	lda #<level2_show_irq
	sta irqaddr
	lda #>level2_show_irq
	sta irqaddr+1
	
	pla
	rti
.endproc

; ** IRQ HANDLER: level2_show_irq
; desc: This IRQ handler shows the background layer within the lower fringes of the screen.
;       This is done to prevent lag from entirely blanking the screen.
.proc level2_show_irq
	pha
	lda #def_ppu_msk
	sta ppu_mask
	sta mmc3_irqdi
	pla
	rti
.endproc

; ** IRQ HANDLER: level2_dream_block_reveal_irq
; desc: This IRQ sets the bank number to the bank that contains the activated dream blocks.
; The cutscene opens with the dream blocks glowing, then their colored form below.
.proc level2_dream_block_reveal_irq
	pha
	
	lda #mmc3bk_bg1
	sta mmc3_bsel
	lda #chrb_lvl2+2
	sta mmc3_bdat
	lda mmc3_shadow
	sta mmc3_bsel
	sta mmc3_irqdi
	
	pla
	rti
.endproc
.align $100