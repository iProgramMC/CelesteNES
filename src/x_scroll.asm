; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_gener_tiles_below_FAR
; desc: Generates tiles below the scroll seam.
gm_gener_tiles_below_FAR:
	lda #gs_readvd
	bit gamectrl
	bne @dontInitializeVerticalRead
	
	; initialize vertical reading.
	ora gamectrl
	sta gamectrl
	
	; skip the $FF byte, for tiles, palettes, and entities
	jsr gm_read_tile
	jsr gm_read_pal
	jsr gm_read_ent
	
@dontInitializeVerticalRead:
	; get the tile position of camera_y
	lda camera_y
	lsr
	lsr
	lsr
	; take the one *above* camera_y
	tay
	dey
	bpl :+
	ldy #29
:	sty temp1
	
	ldx roombeglo2
	jsr h_comp_addr
	
@loop:
	stx temp2
	jsr gm_read_tile
	sta (lvladdr), y
	ldx temp2
	sta tempcol, x
	lda lvladdr
	clc
	adc #32
	sta lvladdr
	bcc :+
	inc lvladdr+1
:	inx
	cpx #64
	bne :+
	ldx #0
:	cpx ntwrhead
	bne @loop
	
	; ok, now that the tiles are written, render them to the screen
	; we're reusing tempcol for that
	
	; calculate the first PPUADDR
	lda #$00
	sta ppuaddrHR1
	lda #$20
	sta ppuaddrHR1+1
	
	; (add ntwrhead / 32) * 0x400
	lda roombeglo2
	and #$20
	beq :+
	lda #$24
	sta ppuaddrHR1+1
:	; add ntwrhead % 32
	lda roombeglo2
	and #$1F
	sta ppuaddrHR1
	
	; add (temp1 % 8) * 0x20 + (temp1 / 8) * 0x100
	lda temp1
	lsr
	lsr
	lsr
	sta temp2
	
	lda temp1
	ror
	ror
	ror
	ror
	and #%11100000
	clc
	adc ppuaddrHR1
	sta ppuaddrHR1
	lda ppuaddrHR1+1
	adc temp2
	sta ppuaddrHR1+1
	
	; done! ppuaddrHR2 is going to be the other nametable with X=0
	lda ppuaddrHR1+1
	eor #$04
	sta ppuaddrHR2+1
	lda ppuaddrHR1
	and #%11100000
	sta ppuaddrHR2
	
	; determine how much we should be writing to the first half
	lda ppuaddrHR1
	and #%00011111
	sta temp3
	
	lda #32
	sec
	sbc temp3
	sta wrcountHR1
	
	; calculate wrcountHR2 now
	lda ntwrhead
	sec
	sbc roombeglo2
	and #%00111111 ; total number to write
	sec
	sbc wrcountHR1
	sta wrcountHR2
	
	ldx #0
@loop1:
	ldy tempcol, x
	lda metatiles, y
	sta temprow1, x
	inx
	cpx wrcountHR1
	bne @loop1
	
	; store the index in tempcol to temp4, will be picked up later
	stx temp4
	
	ldx #0
@loop2:
	ldy temp4
	lda tempcol, y
	
	; increment and store to get rid of it. we'll need Y for a different purpose
	iny
	sty temp4
	
	; load the relevant metatile and store it
	tay
	lda metatiles, y
	sta temprow2, x
	inx
	cpx wrcountHR2
	bne @loop2
	
	lda #nc_flushrow
	ora nmictrl
	sta nmictrl
	
	lda temp1
	and #1
	bne :+
	jsr gm_upload_palette_data_below
:	rts

gm_upload_palette_data_below:
	; vars:
@row = temp1
@i   = temp2
@p12 = temp3
@p34 = temp4
@idx = temp5
	
	; calculate the "row" parameter
	lda temp1
	lsr
	sta @row
	
	; initiate the loop
	lda roombeglo2
	sta @i
@loopPal:
	; rd = palette_data[palette_data_index++];
	jsr gm_read_pal
	
	; p12 = rd & 0b1111
	pha
	and #%00001111
	sta @p12
	pla
	; p34 = (rd >> 4) & 0b1111
	lsr
	lsr
	lsr
	lsr
	sta @p34
	
	jsr @computeIdx
	
	lda #1
	bit @row
	bne @oddRow
	
	; even row (top)
	; attribute_table[idx] = (attribute_table[idx] & 0b11110000) | p12;
	ldx @idx
	lda ntattrdata, x
	and #%11110000
	ora @p12
	sta ntattrdata, x
	
	; i += 4
	lda @i
	clc
	adc #4
	sta @i
	
	; if (i == ntwrhead)
	cmp ntwrhead
	;     break;
	beq @return
	
	; idx = incidx(idx);
	jsr @incrementIdx
	
	; attribute_table[idx] = (attribute_table[idx] & 0b11110000) | p34;
	ldx @idx
	lda ntattrdata, x
	and #%11110000
	ora @p34
	sta ntattrdata, x
	
	lda @i
	clc
	adc #4
	sta @i
	
	; if (i == ntwrhead)
	cmp ntwrhead
	;     break;
	beq @return
	
@loopPal_:
	bne @loopPal
	
@oddRow:
	; bottom
	; p12 <<= 4
	asl @p12
	asl @p12
	asl @p12
	asl @p12
	
	; p34 <<= 4
	asl @p34
	asl @p34
	asl @p34
	asl @p34
	
	; attribute_table[idx] = (attribute_table[idx] & 0b00001111) | p12;
	ldx @idx
	lda ntattrdata, x
	and #%00001111
	ora @p12
	sta ntattrdata, x
	
	; i += 4
	lda @i
	clc
	adc #4
	sta @i
	
	; if (i == ntwrhead)
	cmp ntwrhead
	;     break;
	beq @return
	
	; idx = incidx(idx);
	jsr @incrementIdx
	
	; attribute_table[idx] = (attribute_table[idx] & 0b00001111) | p34;
	ldx @idx
	lda ntattrdata, x
	and #%00001111
	ora @p34
	sta ntattrdata, x
	
	lda @i
	clc
	adc #4
	sta @i
	
	; if (i == ntwrhead)
	cmp ntwrhead
	;     break;
	
	bne @loopPal_
	
@return:
	; now enqueue the upload
	lda #8
	sta wrcountHP1
	sta wrcountHP2
	
	; only the row to be calculated
	lda #0
	sta @i
	jsr @computeIdx
	
	ldx @idx
	ldy #0
@loopUpload1:
	lda ntattrdata, x
	sta temppalH1, y
	inx
	iny
	cpy #8
	bne @loopUpload1
	
	lda #$20
	sta @i
	jsr @computeIdx
	
	ldx @idx
	ldy #0
@loopUpload2:
	lda ntattrdata, x
	sta temppalH2, y
	inx
	iny
	cpy #8
	bne @loopUpload2
	
	; compute the address
	lda #0
	sta @i
	jsr @computeIdx
	
	lda @idx
	and #%00111111
	ora #%11000000
	sta ppuaddrHP1
	sta ppuaddrHP2
	
	lda #$23
	sta ppuaddrHP1+1
	lda #$27
	sta ppuaddrHP2+1
	
	lda #nc_flushpal
	ora nmictrl
	sta nmictrl
	
	rts

@computeIdx:
	; idx = (i & 0x20) ? 64 : 0 ...
	lda @i
	and #$20
	asl
	sta @idx
	
	; ... + ((row >> 1) << 3) ...
	lda @row
	and #%11111110
	asl
	asl
	clc
	adc @idx
	sta @idx
	
	; ... + ((i & 0x1F) >> 2);
	lda @i
	and #$1F
	lsr
	lsr
	clc
	adc @idx
	sta @idx
	rts

@incrementIdx:
	; byte oldidx = idx;
	lda @idx
	; idx++;
	tax
	inx
	stx @idx
	; A = oldidx ^ idx
	eor @idx
	; A = A & 0b11111000
	and #%11111000
	; if (A)
	beq @returnFromIncrement
	; idx -= 8
	lda @idx
	sec
	sbc #8
	; idx ^= 64
	eor #$64
	sta @idx
@returnFromIncrement:
	; return idx;
	rts
