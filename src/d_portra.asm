; Copyright (C) 2024 iProgramInCpp

;  This code belongs in the PRG_DIAL segment

speaker_banks:
	.byte chrb_dmade ; SPK_madeline
	.byte chrb_dgran ; SPK_granny
	.byte chrb_dtheo ; SPK_theo
	.byte chrb_dbade ; SPK_badeline

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

speaker_portrait_tables_hi:
	.byte >portraits_madeline
	.byte >portraits_granny
	.byte >portraits_madeline
	.byte >portraits_badeline

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

portraits_granny:
	.word portrait_00
	.word portrait_10
	.word portrait_01
	.word portrait_11

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

; ** SUBROUTINE: dlg_set_speaker
; desc: Sets the current speaker's portrait bank.
; arguments:
;     X - current speaker
dlg_set_speaker:
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
	lda dlg_port_pal
	jsr gm_allocate_palette
	sta dlg_port_pala
	
	ldx #0
	jsr homeX
	lda #(dialog_border_upp-8)
	sta y_crd_temp
loop:
	txa
	tay
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
	beq grannyExtra
	cmp #chrb_dmade
	beq madelineExtra_
	cmp #chrb_dbade
	beq badelineExtra_
return:
	rts

madelineExtra_:
	jmp madelineExtra

badelineExtra_:
	jmp badelineExtra

grannyExtra:
	lda dlg_portrait+11
	cmp #$4C
	bne return
	
	; draw Granny's tongue in red. I was careful not to overstep the 8sp/sl limit
	lda dlg_portraitx
	clc
	adc #9
	sta x_crd_temp
	lda #$1A
	sta y_crd_temp
	lda #1           ; TODO: hardcoded to the first palette, the hair palette
	ldy #$14
	jsr oam_putsprite
	
	jsr incrementX
	lda #1
	ldy #$16
	jsr oam_putsprite
	jsr incrementX
	lda #1
	ldy #$18
	jmp oam_putsprite

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

badelineExtra:
	jsr badelineRedEyes	

	lda dlg_portrait+11
	cmp #$42
	beq @goToNormalSpeak
	cmp #$4C
	beq @goToNormalSpeak
	rts

@goToNormalSpeak:
	jmp madeline_normalSpeak

badelineRedEyes:
	jsr homeX
	jsr incrementX
	lda #(dialog_border_upp-8+16)
	sta y_crd_temp
	
	lda #pal_red
	jsr gm_allocate_palette
	sta temp11
	
	ldy dlg_portraitid
	lda @leftEyeOffsets, y
	sta temp9
	lda @eyeSpriteNumbers, y
	sta temp10
	
	cpy #BAD_scoff
	bne :+
	inc x_crd_temp
:	cpy #BAD_worried
	bne :+
	lda y_crd_temp
	clc
	adc #4
	sta y_crd_temp
:	lda temp10
	tay
	sty temp10
	lda temp11
	jsr oam_putsprite
	
	jsr incrementX
	
	lda temp11
	ldy temp10
	iny
	iny
	sty temp10
	
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc temp9
	sta x_crd_temp
	
	lda temp11
	ldy temp10
	iny
	iny
	jsr oam_putsprite
	
	rts

; note: anatomically left - it's actually on the right!
@leftEyeOffsets:	.byte 12, 10, 8,  8
@eyeSpriteNumbers:	.byte $C0,$C6,$E0,$CC

madelineExtra:
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
	lda #$44
	sta dlg_portrait+12
	lda #$46
	sta dlg_portrait+13
	rts

@mouthFrames:
	.byte $44, $6A, $72, $6E
	.byte $4E, $8A, $92, $8E

transformYBasedOnExpression:
	lda dlg_portrait+11
	cmp #$4C
	beq @sad
	rts
@sad:
	iny
	iny
	iny
	iny
	rts

.endproc
