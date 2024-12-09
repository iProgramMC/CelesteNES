; Copyright (C) 2024 iProgramInCpp

;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

.proc level1_zip_mover
	ldx temp1
	lda sprspace+sp_flags, x
	ora #ef_collidable
	sta sprspace+sp_flags, x
	
	lda #16
	sta sprspace+sp_hei, x
	
	lda sprspace+sp_wid, x
	sec
	sbc #8
	sta temp9
	
	lda #pal_gray
	jsr gm_allocate_palette
	sta temp8
	
	lda temp2
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	
	lda #0
loop:
	sta temp10
	
	; draw a sprite
	tay             ; tay to calculate flags, not because we need it in Y
	bne notZero
	
	; it's zero
	lda #$40
	bne draw
	
notZero:
	; check if it's the end
	cmp temp9
	bne notEnd
	
	; it's the end
	lsr
	lsr
	and #2
	beq endWhatever
	lda #$46
	bne draw
endWhatever:
	lda #$48
	bne draw

notEnd:
	; not the end
	lsr
	lsr
	and #2
	clc
	adc #$42
	
draw:
	tay
	lda temp8
	
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc #8
	; TODO: carry here means it overflew!
	sta x_crd_temp
	
	ldx temp1
	lda temp10
	clc
	adc #8
	cmp sprspace+sp_wid, x
	bcc loop
	
	rts
.endproc
