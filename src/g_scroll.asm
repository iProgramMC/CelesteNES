; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_gener_tiles_below
; desc: Generates tiles at the scroll seam.
gm_gener_tiles_below:
	lda #rf_new
	bit roomflags
	bne gm_gener_tiles_below_NEW_
	
	lda #gs_readvd
	bit gamectrl
	bne @dontInitializeVerticalRead
	
	; initialize vertical reading.
	ora gamectrl
	sta gamectrl
	
	; skip the $FF byte, for tiles, palettes, and entities
	jsr gm_adv_tile
	jsr gm_adv_pal
	jsr gm_adv_ent
	
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
	jmp gm_gener_tiles_horiz

gm_gener_tiles_below_NEW_:
	jmp gm_gener_tiles_below_NEW
gm_gener_tiles_above_NEW_:
	jmp gm_gener_tiles_above_NEW

; ** SUBROUTINE: gm_gener_tiles_above
; desc: Generates tiles at the scroll seam.
gm_gener_tiles_above:
	lda #rf_new
	bit roomflags
	bne gm_gener_tiles_above_NEW_
	
	lda #gs_readvd
	bit gamectrl
	bne @dontInitializeVerticalRead
	
	; initialize vertical reading.
	ora gamectrl
	sta gamectrl
	
	; skip the $FF byte, for tiles, palettes, and entities
	jsr gm_adv_tile
	jsr gm_adv_pal
	jsr gm_adv_ent
	
@dontInitializeVerticalRead:
	; get the tile position of camera_y
	lda camera_y
	lsr
	lsr
	lsr
	clc
	adc #1
	cmp #30
	bne :+
	lda #0
:	sta temp1
	jmp gm_gener_tiles_horiz

; ** SUBROUTINE: gm_read_row
; desc: Loads a row from tile data. Used by gm_gener_tiles_below_FAR
gm_read_row:
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
	rts

; ** SUBROUTINE: gm_convert_metatiles_load_entities
; desc: Generates a list of metatiles to write, and loads entities corresponding to the correct row.
;
; parameters:
;    X - Row Number
gm_convert_metatiles_load_entities:
	lda temp1
	pha
	
	ldx #0
@loop1:
	ldy temprowtot, x
	lda metatiles, y
	sta temprow1, x
	inx
	cpx wrcountHR1
	bne @loop1
	
	; store the index in temprowtot to temp4, will be picked up later
	stx temp4
	
	ldx #0
@loop2:
	ldy temp4
	lda temprowtot, y
	
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
	
	; now start loading entities.
	
	; but first, ensure there isn't a delay imposed on us
	lda entdelay
	beq @entityLoadLoop
	
	; yeah there is, decrement and return
	dec entdelay
	jmp @return
	
@entityLoadLoop:
	jsr gm_read_ent_na
	cmp #ec_dataend
	beq @return
	
	cmp #ec_scrnext
	beq @screenNext
	
	; three bits will be masked away. these might be repurposed for flags.
	; this is the Y position of the entity.
	
	; compare it to the current row's position
	lsr
	lsr
	lsr
	cmp temp1
	
	; if they are not equal, then return, this entity don't belong on this column.
	bne @return
	
	; they DO belong on this column! load the entity.
	
	; - When scrolling up, entities will be moved up. Using $F8, it's partly off the
	; top of the screen, but when the screen is scrolled again it goes back to
	; zero.
	; - When scrolling down, $F8 will be the resting position of the entity.
	lda #$F8
	sta temp2
	
	; Load the rest of the data
	; TODO: Use one of the unused 3 bits for the X position
	jsr gm_read_ent               ; Y position + 3 unused bits. Skipping
	jsr gm_read_ent               ; X position
	sta temp1
	jsr gm_read_ent               ; Type of entity
	sta temp3
	
	; Find a spot for this entity.
	ldx #0
@spotFindingLoop:
	lda sprspace + sp_kind, x
	beq @spotFound
	inx
	cpx #sp_max
	bne @spotFindingLoop
	
	; No Space Found
	; Read as many entities as there are on this column
	beq @entityLoadLoop
	
	; "Not Equal" is not possible because we would have jumped back to @spotFindingLoop
@screenNext:
	; OK. Next screen then, eh?
	
	; Delay entity loading for 30 rows (1 full screen)
	lda #30
	sta entdelay
	
	jmp @return
	
@spotFound:
	; initialize the entity
	jsr gm_init_entity
	
	; load its X coordinate.
	lda roombeglo
	clc
	adc temp1
	sta sprspace + sp_x, x
	
	lda temp3
	; rotate the 0x80 bit back into 0x01
	rol
	rol
	and #1
	
	clc
	adc roombeghi
	sta sprspace + sp_x_pg, x
	
	; okay !! try loading another entity
	jmp @entityLoadLoop
	
@return:
	pla
	sta temp1
	
@return2:
	rts

; ** SUBROUTINE: gm_read_palette_data_horiz
; desc: Reads palette data to prepare for a vertical scroll.
gm_read_palette_data_horiz:

	; vars:
	; (note: these  M U S T  match the ones in gm_gener_tiles_below_FAR::@uploadPaletteDataBelow
@row = temp1
@i   = temp2
@p12 = temp3
@p34 = temp4
@idx = temp5
	
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

; ** SUBROUTINE: gm_gener_tiles_horiz_FAR
; desc: Generates tiles at the scroll seam.
;       This is the PRG_XTRA part of the function gm_gener_tiles_below.
gm_gener_tiles_horiz:
	; temp1 has the row to load.
	
	; outlined because we need access to level data bank
	jsr gm_read_row
	
	; ok, now that the tiles are written, render them to the screen
	; we're reusing tempcol for that
	
gm_gener_tiles_horiz_row_read:
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
	
	; ppuaddrHR3 (if needed) is going to be the nametable we're starting with with X=0
	sta ppuaddrHR3
	lda ppuaddrHR1+1
	sta ppuaddrHR3+1
	
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
	bne :+
	lda #%01000000
:	sec
	sbc wrcountHR1
	sta wrcountHR2
	
	cmp #32
	bcc @noMoreThan32
	
	; sigh, seems like it's still more than 32
	sbc #32
	sta wrcountHR3
	; note: writes to temprow2 will slip onto temprow3. wrcountHR2 will be fixed up later
	
@noMoreThan32:
	; outlined because we need access to level data bank
	ldx temp1
	jsr gm_convert_metatiles_load_entities
	
	lda #nc_flushrow
	ora nmictrl
	sta nmictrl
	
	lda wrcountHR2
	cmp #32
	bcc @noFixUpWrCount
	lda #32
	sta wrcountHR2
@noFixUpWrCount:
	
	lda temp1
	and #1
	eor #1
	cmp temp10
	beq @uploadPaletteDataBelow
	rts

@uploadPaletteDataBelow:
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
	
	; outlined because we need access to level data bank
	jsr gm_read_palette_data_horiz
	
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

gm_calculate_vert_offs:
	; calculate vertical offset hack
	lda camera_y
	sec
	sbc camera_y_bs
	lsr
	lsr
	lsr
	sta vertoffshack
	rts

; ** SUBROUTINE: gm_load_level_if_vert
; desc: Loads more of the horizontal level segment, if in vertical mode.
gm_load_level_if_vert:
	lda #(g3_transitA)
	bit gamectrl3
	bne @return          ; if there are transitions going on, then return
	
	lda #(rf_godown | rf_goup)
	bit roomflags
	beq @return          ; if level is horizontal, then return
	
	lda #gs_lvlend
	bit gamectrl
	bne @return          ; if level is over, then return
	
	jmp h_gener_col_r

@return:
	rts
