; Copyright (C) 2024 iProgramInCpp

;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

; This draws the memorial.
.proc level2_memorial
	dec temp3
	
	lda #chrb_splv2b
	sta spr1_bknum
	
	lda temp2
	sta x_crd_temp
	lda #0
	sta plattemp1
	
	lda temp2
	cmp #$F8
	bcc noLeft
	
	lda temp4
	bpl noLeft
	
	lda #8
	sta plattemp1
	clc
	adc x_crd_temp
	sta x_crd_temp

noLeft:
	lda #pal_gray
	jsr gm_allocate_palette
	sta temp5
	
	lda #0
	sta plattemp2 ; data index
	
loop:
	
	lda temp3
	sta y_crd_temp

innerloop:
	ldy plattemp2
	lda data, y
	tay
	lda temp5
	jsr oam_putsprite
	
	lda y_crd_temp
	clc
	adc #16
	bcs breakInnerLoop
	sta y_crd_temp
	
	inc plattemp2
	ldy plattemp2
	cpy #4
	beq breakInnerLoop
	cpy #8
	beq breakInnerLoop
	cpy #12
	beq breakInnerLoop
	cpy #16
	bne innerloop
	
	; back in the outer loop
breakInnerLoop:
	lda x_crd_temp
	clc
	adc #8
	bcs breakOuterLoop
	sta x_crd_temp
	
	lda #8
	clc
	adc plattemp1
	sta plattemp1
	
	cmp #32
	bcc loop
	
breakOuterLoop:
	rts

data:
	.byte $40,$60,$48,$68
	.byte $42,$62,$4A,$6A
	.byte $44,$64,$4C,$6C
	.byte $46,$66,$4E,$6E
.endproc