; Copyright (C) 2024 iProgramInCpp

;  This code belongs in the PRG_DIAL segment

speaker_banks:
	.byte chrb_dmade ; SPK_madeline
	.byte chrb_dgran ; SPK_granny
	.byte chrb_dtheo ; SPK_theo
	.byte chrb_dbade ; SPK_badeline
	.byte chrb_dmome ; SPK_momex

speaker_palettes:
	.byte pal_red
	.byte pal_granny
	.byte pal_green
	.byte pal_chaser

speaker_portrait_tables_lo:
	.byte <portraits_madeline
	.byte <portraits_granny
	.byte <portraits_madeline
	.byte <portraits_badeline
	.byte <portraits_momex

speaker_portrait_tables_hi:
	.byte >portraits_madeline
	.byte >portraits_granny
	.byte >portraits_madeline
	.byte >portraits_badeline
	.byte >portraits_momex

portraits_madeline:
	.word portrait_00
	.word portrait_10
	.word portrait_20
	.word portrait_01
	.word portrait_X1

portraits_badeline:
	.word portrait_00
	.word portrait_10
	.word portrait_20
	.word portrait_01
	.word portrait_X2

portraits_granny:
	.word portrait_00
	.word portrait_10
	.word portrait_01
	.word portrait_11

portraits_momex:
	.word portrait_00
	.word portrait_10
	.word portrait_ex

portrait_00:
	.byte $00,$02,$04,$06,$08
	.byte $20,$22,$24,$26,$28
	.byte $40,$42,$44,$46,$48
portrait_10:
	.byte $0A,$0C,$0E,$10,$12
	.byte $2A,$2C,$2E,$30,$32
	.byte $4A,$4C,$4E,$50,$52
portrait_20:
	.byte $14,$16,$18,$1A,$1C
	.byte $34,$36,$38,$3A,$3C
	.byte $54,$56,$58,$5A,$5C
portrait_01:
	.byte $60,$62,$64,$66,$68
	.byte $80,$82,$84,$86,$88
	.byte $A0,$A2,$A4,$A6,$A8
portrait_11:
	.byte $6A,$6C,$6E,$70,$72
	.byte $8A,$8C,$8E,$90,$92
	.byte $AA,$AC,$AE,$B0,$B2
portrait_X1:
	.byte $AA,$AC,$AE,$B0,$B2
	.byte $CA,$CC,$CE,$D0,$D2
	.byte $EA,$EC,$EE,$F0,$F2
portrait_X2:
	.byte $76,$78,$7A,$7C,$7E
	.byte $96,$98,$9A,$9C,$9E
	.byte $B6,$B8,$BA,$BC,$BE
	
portrait_ex:
	; NOTE: non standard format
	; Y, TN, PAL, X
	.byte $00, $15, pal_green, $00
	.byte $00, $17, pal_green, $08
	.byte $00, $19, pal_green, $10
	.byte $00, $1B, pal_green, $18
	.byte $08, $1D, pal_green, $20
	.byte $10, $35, pal_green, $00
	.byte $10, $37, pal_green, $08
	.byte $10, $39, pal_green, $10
	.byte $10, $3B, pal_green, $18
	.byte $10, $57, pal_gray,  $08
	.byte $10, $59, pal_gray,  $10
	.byte $10, $5B, pal_gray,  $18
	.byte $10, $55, pal_gray,  $00
	.byte $20, $75, pal_gray,  $00
	.byte $20, $77, pal_gray,  $08
	.byte $20, $79, pal_gray,  $10
	.byte $20, $7B, pal_gray,  $18
	.byte $20, $E1, $80,       $00
	.byte $20, $E3, $80,       $0A
	.byte $20, $E5, $80,       $12

; ** SUBROUTINE: dlg_set_speaker
; desc: Sets the current speaker's portrait bank.
; arguments:
;     X - current speaker
dlg_set_speaker:
	stx dlg_speaker
	
	; set the bank
	lda speaker_banks, x
	tay
	sty spr0_bkspl
	iny
	sty spr1_bkspl
	iny
	sty spr2_bkspl
	iny
	sty spr3_bkspl
	
	; set the palette
	lda speaker_palettes, x
	sta dlg_port_pal
	
	; set the portrait table
	lda speaker_portrait_tables_lo, x
	sta dlg_porttbl
	lda speaker_portrait_tables_hi, x
	sta dlg_porttbl+1
	
	rts

; ** SUBROUTINE: dlg_set_expression
; desc: Sets the current speaker's expression.
; arguments:
;     A - current expression
dlg_set_expression:
	sta dlg_portraitid
	asl
	tay
	lda (dlg_porttbl), y
	sta temp1
	iny
	lda (dlg_porttbl), y
	sta temp1+1
	
	; copy 25 bytes to dlg_portrait
	ldy #0
@loop:
	lda (temp1),      y
	sta dlg_portrait, y
	iny
	cpy #25
	bne @loop
	rts

; ** SUBROUTINE: dlg_draw_portrait
; desc: Draws the active portrait.
.proc dlg_draw_portrait
	lda dlg_speaker
	cmp #SPK_momex
	bne @notMomEx
	
	lda dlg_portraitid
	cmp #MOM_exph
	bne @notMomEx
	jmp drawEx
	
@notMomEx:
	lda dlg_port_pal
	jsr gm_allocate_palette
	ldx dlg_facing
	beq :+
	ora #obj_fliphz
:	sta dlg_port_pala
	
	ldx #0
	jsr homeX
	lda #(dialog_border_upp-8)
	sta y_crd_temp
loop:
	lda dlg_facing
	bne facingDetour
	txa
	tay
facingDetoured:
	lda dlg_portrait, y
	tay
	lda dlg_port_pala
	jsr oam_putsprite
	jsr incrementX
	inx
	; if it's 15, return
	cpx #15
	beq break
	; if it's 5 or 10, move on to the next row
	cpx #5
	beq detour
	cpx #10
	beq detour
	bne loop
break:
	; ok, now draw extra features depending on the portrait
	; this compares the active bank
	lda spr0_bkspl
	cmp #chrb_dgran
	beq grannyExtra_
	cmp #chrb_dmade
	beq madelineExtra_
	cmp #chrb_dbade
	beq badelineExtra_
return:
	rts
facingDetour:
	ldy reversedIndices, x
	jmp facingDetoured

reversedIndices:
	.byte 4,3,2,1,0
	.byte 9,8,7,6,5
	.byte 14,13,12,11,10
	.byte 19,18,17,16,15
	.byte 24,23,22,21,20

madelineExtra_:
	jmp madelineExtra

badelineExtra_:
	jmp badelineExtra

grannyExtra_:
	jmp grannyExtra

; small interface
detour:
	jsr homeX
	jsr incrementY
	jmp loop

incrementX:
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	rts
incrementX2:
	lda dlg_facing
	beq incrementX
	lda x_crd_temp
	sec
	sbc #8
	sta x_crd_temp
	rts
incrementX1:
	lda dlg_facing
	bne :+
	inc x_crd_temp
	rts
:	dec x_crd_temp
	rts
incrementY:
	lda y_crd_temp
	clc
	adc #16
	sta y_crd_temp
	rts
homeX:
	lda dlg_portraitx
	sta x_crd_temp
	rts
homeX2:
	lda dlg_portraitx
	sta x_crd_temp
	lda dlg_facing
	beq :+
	lda x_crd_temp
	clc
	adc #32
	sta x_crd_temp
:	rts

grannyExtra:
	lda dlg_portrait+10
	cmp #$40
	beq @normal
	cmp #$4A
	bne :+
	jmp @laughing
:	rts

@normal:
	lda #$1C+16
	sta y_crd_temp
	
	; normal, so select mouth frame
	lda dlg_speaktimer
	cmp #$FF
	beq @setNormal_
	
	cmp #32
	bcc :+
	lda #0
	sta dlg_speaktimer
:	lsr
	lsr
	lsr
	tay
	lda @mouthFrames, y
	sta dlg_portrait+11
	clc
	adc #2
	sta dlg_portrait+12
	clc
	adc #2
	sta dlg_portrait+13
	clc
	adc #2
	sta dlg_portrait+14
	
	; also draw the mouth sprite
	lda dlg_speaktimer
	sec
	sbc #1
	and #%00011111
	lsr
	lsr
	lsr
	tay
	sty temp11
	
	; Add the mouth offset
	jsr @calculateInitialMouthOffset
	
	; Draw the first sprite
	lda @mouthSprites, y
	tay
	lda dlg_facing
	beq :+
	lda #obj_fliphz
:	ora #1           ; TODO: hardcoded to the first palette, the hair palette
	pha
	jsr oam_putsprite
	
	; Check if it was that 1 sprite version
	ldx temp11
	cpx #3
	beq @returnPull
	
	; No, so this is a 3x sprite
	jsr incrementX2
	lda @mouthSprites, x
	clc
	adc #2
	tay
	pla
	sta temp11
	jsr oam_putsprite
	
	; No, so this is a 3x sprite
	jsr incrementX2
	lda @mouthSprites, x
	clc
	adc #4
	tay
	lda temp11       ; TODO: hardcoded to the first palette, the hair palette
	jmp oam_putsprite

@setNormal_:
	beq @setNormal

@returnPull:
	pla
	rts

@laughing:
	; draw Granny's tongue in red. I was careful not to overstep the 8sp/sl limit
	lda dlg_portraitx
	clc
	adc #9
	sta x_crd_temp
	lda #$1A+16
	sta y_crd_temp
	lda #1            ; TODO: hardcoded to the first palette, the hair palette
	ldy #$F6
	jsr oam_putsprite
	
	jsr incrementX2
	lda #1
	ldy #$F8
	jsr oam_putsprite
	jsr incrementX
	lda #1
	ldy #$FA
	jmp oam_putsprite

@setNormal:
	lda #$42
	sta dlg_portrait+11
	lda #$44
	sta dlg_portrait+12
	lda #$46
	sta dlg_portrait+13
	lda #$48
	sta dlg_portrait+14
	rts

@mouthFrames:
	.byte $C0, $C8, $D0, $D8
@mouthSprites:
	.byte $E0, $E6, $EC, $F2
@mouthOffsets:
	.byte 2, 3, 4, 20

@calculateInitialMouthOffset:
	lda dlg_facing
	beq @facingRight
	
	lda dlg_portraitx
	clc
	adc #24
	sec
	sbc @mouthOffsets, y
	sta x_crd_temp
	rts
	
@facingRight:
	lda dlg_portraitx
	clc
	adc @mouthOffsets, y
	;because why would it overflow right
	adc #8
	sta x_crd_temp
	rts
	
@done:
badelineExtra:
	jsr badelineRedEyes	

	lda dlg_portrait+11
	cmp #$B8
	beq @goToNormalSpeak
	cmp #$A2
	beq @goToNormalSpeak
	cmp #$42
	beq @goToNormalSpeak
	cmp #$4C
	beq @goToNormalSpeak
	rts

@goToNormalSpeak:
	jmp badeline_normalSpeak

badelineRedEyes:
	jsr homeX2
	jsr incrementX2
	lda #(dialog_border_upp-8+16)
	sta y_crd_temp
	
	lda #pal_red
	jsr gm_allocate_palette
	ldx dlg_facing
	beq :+
	ora #obj_fliphz
:	sta temp11
	
	ldy dlg_portraitid
	lda @leftEyeOffsets, y
	sta temp9
	lda @eyeSpriteNumbers, y
	sta temp10
	
	cpy #BAD_scoff
	bne :+
	jsr incrementX1
:	cpy #BAD_worried
	bne :+
	lda y_crd_temp
	clc
	adc #4
	sta y_crd_temp
:	cpy #BAD_upset
	bne :+
	lda y_crd_temp
	clc
	adc #8
	sta y_crd_temp
	lda x_crd_temp
	clc
	adc #4
	sta x_crd_temp
:	lda temp10
	tay
	sty temp10
	lda temp11
	jsr oam_putsprite
	
	jsr incrementX2
	
	lda temp11
	ldy temp10
	iny
	iny
	sty temp10
	
	jsr oam_putsprite
	
	lda dlg_facing
	bne @faceLeft
	
	lda x_crd_temp
	clc
	adc temp9
	sta x_crd_temp
	bne @done
	
@faceLeft:
	lda x_crd_temp
	sec
	sbc temp9
	sta x_crd_temp
@done:
	lda temp11
	ldy temp10
	iny
	iny
	jsr oam_putsprite
	
	rts

; note: anatomically left - it's actually on the right!
@leftEyeOffsets:	.byte 12, 10, 8,  8,  8
@eyeSpriteNumbers:	.byte $C0,$C6,$E0,$CC,$E6

badeline_normalSpeak:
	; normal, so select mouth frame
	lda dlg_speaktimer
	cmp #$FF
	beq @setNormal
	
	cmp #32
	bcc :+
	lda #0
	sta dlg_speaktimer
:	lsr
	lsr
	lsr
	tay
	jsr badTransformYBasedOnExpression
	lda @mouthFrames, y
	sta dlg_portrait+12
	clc
	adc #2
	sta dlg_portrait+13
	rts

@setNormal:
	lda dlg_portrait+10
	cmp #$4A
	beq @setSadNormal
	cmp #$A0
	beq @setAngryNormal
	cmp #$B6
	beq @setUpsetNormal
	lda #$44
	sta dlg_portrait+12
	lda #$46
	sta dlg_portrait+13
	rts
@setSadNormal:
	lda #$4E
	sta dlg_portrait+12
	lda #$50
	sta dlg_portrait+13
	rts
@setAngryNormal:
	lda #$A4
	sta dlg_portrait+12
	lda #$A6
	sta dlg_portrait+13
	rts
@setUpsetNormal:
	lda #$BA
	sta dlg_portrait+12
	lda #$BC
	sta dlg_portrait+13
	rts

@mouthFrames:
	.byte $44, $6A, $72, $6E
	.byte $4E, $8A, $92, $8E
	.byte $BA, $AA, $B2, $AE
	.byte $A4, $D4, $DC, $D8

badTransformYBasedOnExpression:
	lda dlg_portrait+10
	cmp #$4A
	beq @sad
	cmp #$B6
	beq @upset
	cmp #$A0
	beq @angry
	rts
@angry:
	iny
	iny
	iny
	iny
@upset:
	iny
	iny
	iny
	iny
@sad:
	iny
	iny
	iny
	iny
	rts

madelineExtra:
	jsr madelineWhiteEyes
	
	lda dlg_portrait+11
	cmp #$42
	beq madeline_normalSpeak
	cmp #$4C
	beq madeline_normalSpeak
	rts

madeline_normalSpeak:
	; normal, so select mouth frame
	lda dlg_speaktimer
	cmp #$FF
	beq @setNormal
	
	cmp #32
	bcc :+
	lda #0
	sta dlg_speaktimer
:	lsr
	lsr
	lsr
	tay
	jsr transformYBasedOnExpression
	lda @mouthFrames, y
	sta dlg_portrait+12
	clc
	adc #2
	sta dlg_portrait+13
	rts

@setNormal:
	lda dlg_portrait+10
	cmp #$4A
	beq @setSadNormal
	lda #$44
	sta dlg_portrait+12
	lda #$46
	sta dlg_portrait+13
	rts
@setSadNormal:
	lda #$4E
	sta dlg_portrait+12
	lda #$50
	sta dlg_portrait+13
	rts

@mouthFrames:
	.byte $44, $6A, $72, $6E
	.byte $4E, $8A, $92, $8E

madelineWhiteEyes:
	jsr homeX2
	jsr incrementX2
	lda #(dialog_border_upp-8+16)
	sta y_crd_temp
	
	lda #pal_gray
	jsr gm_allocate_palette
	ldx dlg_facing
	beq :+
	ora #obj_fliphz
:	sta temp11
	
	ldy dlg_portraitid
	lda @leftEyeOffsets, y
	sta temp9
	lda @eyeSpriteNumbers, y
	sta temp10
	
	cpy #MAD_distract
	bne @notDistract
	
	lda dlg_facing
	bne @distractLeft
	
	lda x_crd_temp
	sec
	sbc #8
	sta x_crd_temp
	bne @distractIncrement

@distractLeft:
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	
@distractIncrement:
	inc y_crd_temp
	inc y_crd_temp
	
@notDistract:
	lda temp10
	tay
	sty temp10
	lda temp11
	jsr oam_putsprite
	
	jsr incrementX2
	
	lda temp11
	ldy temp10
	iny
	iny
	sty temp10
	
	jsr oam_putsprite
	
	lda dlg_facing
	bne @faceLeft
	
	lda x_crd_temp
	clc
	adc temp9
	sta x_crd_temp
	bne @done
	
@faceLeft:
	lda x_crd_temp
	sec
	sbc temp9
	sta x_crd_temp
@done:
	lda temp11
	ldy temp10
	iny
	iny
	jsr oam_putsprite
	
	rts

@leftEyeOffsets:	.byte 8,  8,  12, 12, 16
@eyeSpriteNumbers:	.byte $76,$96,$B6,$D6,$F6

transformYBasedOnExpression:
	lda dlg_portrait+10
	cmp #$4A
	beq @sad
	rts
@sad:
	iny
	iny
	iny
	iny
	rts

drawEx:
	ldy #0
	ldx oam_wrhead
@loop:
	; Y coord
	lda portrait_ex, y
	clc
	adc #$0C
	sta oam_buf, x
	inx
	iny
	
	; Tile Number
	lda portrait_ex, y
	sta oam_buf, x
	inx
	iny
	
	; Attributes
	lda portrait_ex, y
	bmi :+
	stx oam_wrhead
	sty temp11
	jsr gm_allocate_palette
	ldy temp11
	ldx oam_wrhead
:	and #$7F
	sta oam_buf, x
	inx
	iny
	
	; X Coordinate
	lda portrait_ex, y
	clc
	adc dlg_portraitx
	sta oam_buf, x
	inx
	iny
	stx oam_wrhead
	
	cpy #80
	bne @loop
	rts

.endproc
