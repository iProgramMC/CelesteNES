; Copyright (C) 2024 iProgramInCpp

; This code belongs in the MAIN segment and is an
; interface to things in the PRG_XTRA bank.

gm_leaveroomR:
	lda #<gm_leaveroomR_FAR
	sta temp1
	lda #>gm_leaveroomR_FAR
	sta temp1+1
	ldy #prgb_xtra
	jmp far_call

gm_leaveroomU:
	lda #<gm_leaveroomU_FAR
	sta temp1
	lda #>gm_leaveroomU_FAR
	sta temp1+1
	ldy #prgb_xtra
	jmp far_call

gm_gener_tiles_below:
	lda #<gm_gener_tiles_below_FAR
	sta temp1
	lda #>gm_gener_tiles_below_FAR
	sta temp1+1
	ldy #prgb_xtra
	jmp far_call

xt_gener_col_r:
	lda #<h_gener_col_r
	sta temp1
	lda #>h_gener_col_r
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_gener_mts_ents_r:
	lda #<x_gener_mts_ents_r_fixed
	sta temp1
	lda #>x_gener_mts_ents_r_fixed
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_leave_doframe:
	lda #<gm_leave_doframe
	sta temp1
	lda #>gm_leave_doframe
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_gener_row_u:
	lda #<h_gener_row_u
	sta temp1
	lda #>h_gener_row_u
	sta temp1+1
	ldy musicbank
	jmp far_call

xt_set_room:
	tya
	tax                 ; save room # in X
	
	ldy musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
	txa
	tay                 ; restore room # in X
	jsr gm_set_room
	
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back

x_gener_mts_ents_r_fixed:
	jsr h_gener_ents_r
	jmp h_gener_mts_r

; generate palette data for vertical transition
xt_generate_palette_data_V:
	ldy musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
	; pre-generate all palette data
	ldy #0
@palloop:
	sty temp6
	jsr h_palette_data_column
	
	; an inner loop to copy from temppal to loadedpals
	lda temp6
	asl
	asl
	asl
	tax
	ldy #0
	
:	lda temppal, y
	sta loadedpals, x
	inx
	iny
	cpy #8
	bne :-
	
	ldy temp6
	iny
	cpy #8
	bne @palloop
	
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back

; ** SUBROUTINE: xt_read_row
; desc: Loads a row from tile data. Used by gm_gener_tiles_below_FAR
xt_read_row:
	ldy musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
	ldy temp1
	
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
	
	jsr gm_read_tile_na
	cmp #$FF
	bne @notFF
	
	lda gamectrl2
	ora #g2_scrstopD
	sta gamectrl2
	
@notFF:
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back

; ** SUBROUTINE: xt_convert_metatiles
; desc: Generates a list of metatiles to write.
__xt_convert_metatiles:
	ldy musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
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
	
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back

; ** SUBROUTINE: __xt_read_palette_data_below
; desc: Reads palette data to prepare for a vertical scroll.
__xt_read_palette_data_below:

	; vars:
	; (note: these  M U S T  match the ones in gm_gener_tiles_below_FAR::@uploadPaletteDataBelow
@row = temp1
@i   = temp2
@p12 = temp3
@p34 = temp4
@idx = temp5

	ldy musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank   ; change bank
	
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
	and #$3F
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
	and #$3F
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
	and #$3F
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
	and #$3F
	sta @i
	
	; if (i == ntwrhead)
	cmp ntwrhead
	;     break;
	
	bne @loopPal_
	
@return:
	ldy #prgb_xtra
	lda #mmc3bk_prg1
	jmp mmc3_set_bank   ; change bank back

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
