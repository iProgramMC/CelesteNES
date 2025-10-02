; Copyright (C) 2024-2025 iProgramInCpp

; ** SUBROUTINE: h_comp_addr
; desc:    Computes the address of the 64 byte row of tiles into lvladdr.
; arguments:
;     x - X coordinate
; clobbers: a
h_comp_addr:
	; the address goes as follows:
	; 0110 0xxx xxxy yyyy
	lda #<areaspace
	sta lvladdr
	lda #>areaspace
	sta lvladdrhi
	txa
	lsr
	lsr
	lsr             ; chop off the first 3 bits
	and #%00000111
	clc
	adc lvladdrhi
	sta lvladdrhi
	txa
	ror
	ror
	ror
	ror
	and #%11100000  ; put the 3 LSBs of X in the lvladdr
	sta lvladdr     ; note: need to ror 4x because rotation also involves the carry bit
	rts

; ** SUBROUTINE: h_get_tile
; desc:    Gets the value of a tile in loaded areaspace for the horizontal layout
;          (equivalent of the C code "areaspace[x * 32 + y]")
; arguments:
;     x - X coordinate
;     y - Y coordinate
; returns:  a - Tile value
; clobbers: a
h_get_tile:
	cpy #$FF
	beq @noTile
	lda vertoffshack
	beq @noOffset
	
	sty plattemp1
	tya
	clc
	adc vertoffshack
	cmp #30
	bcc :+
	sbc #30
:	tay
	jsr h_comp_addr
	lda (lvladdr), y; A = (&areaspace[x * 32])[y]
	ldy plattemp1
	rts
@noTile:
	lda #0
	rts

@noOffset:
	jsr h_comp_addr
	lda (lvladdr), y; A = (&areaspace[x * 32])[y]
	rts

; ** SUBROUTINE: h_set_tile
; desc:    Sets the value of a tile in loaded areaspace for the horizontal layout
;          (equivalent of the C code "areaspace[x * 32 + y]")
; arguments:
;     x - X coordinate
;     y - Y coordinate
;     a - Tile value
; clobbers: a
;h_set_tile:
;	pha
;	jsr h_comp_addr
;	pla
;	sta (lvladdr), y
;	rts

; ** SUBROUTINE: h_ntwr_to_ppuaddr
; desc: Converts the nametable write head (ntwraddr) to a PPU address.
h_ntwr_to_ppuaddr:
	; the PPU address we want to start writing to is
	; 0x2000 + (ntwrhead / 32) * 0x400 + (ntwrhead % 32)
	lda ntwrhead
	ldy #$20
	and #$20
	beq :+
	iny
	iny
	iny
	iny
:	lda ntwrhead
	and #$1F
	sty ppu_addr
	sta ppu_addr
	rts

; ** SUBROUTINE: h_flush_pal_r_cond
; desc:    Flushes a generated palette column in temppal to the screen if nc_flshpalv is set.
;          Used during init.
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts), increment to 1
h_flush_pal_r_cond:
	lda #nc_flshpalv
	bit nmictrl
	bne :+
	rts
:	eor nmictrl
	sta nmictrl

; ** SUBROUTINE: h_flush_pal_r
; desc:    Flushes a generated palette column in temppal to the screen
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts), increment to 1
h_flush_pal_r:
	clc
	lda ntwrhead
	sbc #2
	and #$20
	lsr
	lsr
	lsr
	clc
	adc #$23
	tax
	stx y_crd_temp      ; store the high byte of the nametable address there. we'll need it.
	ldx #$C0
	stx x_crd_temp
	lda ntwrhead
	lsr
	clc
	sbc #1
	lsr
	and #7
	clc
	adc x_crd_temp
	sta x_crd_temp
	; need to write 8 bytes.
	ldy #0
@loop:
	ldx y_crd_temp
	stx ppu_addr
	ldx x_crd_temp
	stx ppu_addr
	lda temppal, y
	sta ppu_data
	lda #8
	adc x_crd_temp
	sta x_crd_temp
	iny
	cpy #8
	bne @loop
	rts

; ** SUBROUTINE: h_flush_pal_u
; desc:    Flushes a generated palette row in temppalH to the screen.
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts), increment to 1
h_flush_pal_u:
	ldy wrcountHP1
	beq @dontflushHP1
	
	lda ppuaddrHP1+1
	sta ppu_addr
	lda ppuaddrHP1
	sta ppu_addr
	ldy #0
	
:	lda temppalH1, y
	sta ppu_data
	iny
	cpy wrcountHP1
	bne :-
	
@dontflushHP1:
	ldy wrcountHP2
	beq @dontflushHP2
	
	lda ppuaddrHP2+1
	sta ppu_addr
	lda ppuaddrHP2
	sta ppu_addr
	ldy #0
	
:	lda temppalH2, y
	sta ppu_data
	iny
	cpy wrcountHP2
	bne :-
	
@dontflushHP2:
	rts

; ** SUBROUTINE: h_flush_row
; desc:    Flushes a generated row in temprow to the screen.
; assumes: we're in vblank or rendering is disabled
h_flush_row:
	ldy wrcountHR1
	beq @dontflushHR1
	
	lda ppuaddrHR1+1
	sta ppu_addr
	lda ppuaddrHR1
	sta ppu_addr
	ldy #0
	
:	lda temprow1, y
	sta ppu_data
	iny
	cpy wrcountHR1
	bne :-
	
@dontflushHR1:
	ldy wrcountHR2
	beq @dontflushHR2
	
	lda ppuaddrHR2+1
	sta ppu_addr
	lda ppuaddrHR2
	sta ppu_addr
	ldy #0
	
:	lda temprow2, y
	sta ppu_data
	iny
	cpy wrcountHR2
	bne :-
	
@dontflushHR2:
	ldy wrcountHR3
	beq @dontflushHR3
	
	lda ppuaddrHR3+1
	sta ppu_addr
	lda ppuaddrHR3
	sta ppu_addr
	ldy #0
	
:	lda temprow3, y
	sta ppu_data
	iny
	cpy wrcountHR3
	bne :-
	
@dontflushHR3:
	; Determine how to advance ntrowhead, depending on which transition type we're in
	lda gamectrl3
	and #g3_transitD
	bne @downTransition
	
	; advance the row head but keep it within 30
	ldx ntrowhead
	bne :+
	ldx #30
:	dex
	stx ntrowhead
	rts

@downTransition:
	; advance the row head but keep it within 30
	ldx ntrowhead
	cpx #29
	bne :+
	ldx #$FF
:	inx
	stx ntrowhead
	rts

; ** SUBROUTINE: h_request_transfer
; desc: Requests a transfer to the PPU nametables.  This transfer is a rectangle
;       of clearsizex * clearsizey tiles, at the X/Y coordinates specified in the
;       X/Y registers.
;       The data source is "setdataaddr", set to $0100 to clear, as long as the
;       stack never reaches $100+clearsizex*clearsizey bytes.
; clobbers: A register
.proc h_request_transfer
	jsr h_calcppuaddr
	
	lda nmictrl
	ora #nc_clearenq
	sta nmictrl
	
	rts
.endproc

; ** SUBROUTINE: h_clear_tiles
; desc: Clears tiles in a region of the loaded world.
;       Does not enqueue a visual clear.
; parameters:
;    clearsizex - the width of the cleared region
;    clearsizey - the height of the cleared region
;    X register - the X position of the upper left corner
;    Y register - the Y position of the upper left corner
;    A register - the tile to place
; clobbers: clearsizex, clearsizey, temp2, temp3
.proc h_clear_tiles
	sty temp3
	
loopColumn:
	pha
	jsr h_comp_addr
	pla
	
	; do one column
	ldy clearsizey
	sty temp2
	
	ldy temp3
loopRow:
	sta (lvladdr), y
	iny
	cpy #30
	bcc :+
	ldy #0
:	dec temp2
	bne loopRow
	
	; increment the column
	inx
	cpx #64
	bcc :+
	ldx #0
:	dec clearsizex
	bne loopColumn
	rts
.endproc

; ** SUBROUTINE: h_enqueued_transfer
; desc: Transfers data to the PPU based on the X/Y position and address specified.
;       Uses "setdataaddr" as its data source. Set it to $0100 to clear - should be
;       zero as long as the stack isn't over 256-clearsizex*clearsizey bytes
; assumes: running inside an NMI or rendering is disabled.
.proc h_enqueued_clear
clearcurrH := temp1
cleardestY := temp3
	
	; set the increment to 32 in the PPUCTRL
	lda ctl_flags
	ora #pctl_adv32
	sta ppu_ctrl
	
	; calculate the dest Y
	lda #0
	tay
	sta cleardestY
	
	lda clearpalo
	; rotate the upper 3 bits into cleardestY's low 3 bits
	rol
	rol cleardestY
	rol
	rol cleardestY
	rol
	rol cleardestY
	
	lda clearpahi
	and #%00000011
	asl
	asl
	asl
	ora cleardestY
	sta cleardestY
	
@loopWidth:
	dec clearsizex
	bmi @doneLoopWidth
	
	lda clearpahi
	sta ppu_addr
	lda clearpalo
	sta ppu_addr
	
	ldx cleardestY
	
	lda clearsizey
	sta clearcurrH
	
@loopHeight:
	dec clearcurrH
	bmi @doneLoopHeight
	
	lda (setdataaddr), y
	sta ppu_data
	iny
	
	inx
	cpx #30
	bcc @loopHeight
	
	lda clearpahi
	and #%11111100
	sta ppu_addr
	
	lda clearpalo
	and #%00011111
	sta ppu_addr
	ldx #0
	beq @loopHeight

@doneLoopHeight:
	lda clearpalo
	and #%00011111
	cmp #%00011111
	beq :+
	inc clearpalo
	bne @loopWidth
	
:	lda clearpalo
	and #%11100000
	sta clearpalo
	lda clearpahi
	eor #%00000100
	sta clearpahi
	jmp @loopWidth
	
@doneLoopWidth:
	; restore the old PPUCTRL
	lda ctl_flags
	sta ppu_ctrl
	
	rts
.endproc

; ** SUBROUTINE: h_calcppuaddr
; desc: Calculates the PPU address for the tile position in the X and Y registers.
;       Returns the results in clearpalo, clearpahi.  These are then used by
;       the NMI handler.
;
; parameters:
;    X - X position
;    Y - Y position
; returns:
;    [clearpahi, clearpalo] - PPUADDR for that X/Y position
.proc h_calcppuaddr
	tya
	clc
	adc lvlyoff
	cmp #30
	bcc :+
	sbc #30
:	pha
	
	lda #$20
	cpx #$20
	bcc :+
	lda #$24
:	sta clearpahi
	lda #$00
	sta clearpalo
	
	; the address is made up of the following:
	; 0100 0XYY YYYX XXXX
	
	pla
	; put the 3 lower bits of Y into clearpalo, also places the high 2 bits
	; in the right place for clearpahi
	lsr
	ror clearpalo
	lsr
	ror clearpalo
	lsr
	ror clearpalo
	
	ora clearpahi
	sta clearpahi
	
	txa
	and #$1F
	ora clearpalo
	sta clearpalo
	rts
.endproc

; ** SUBROUTINE: h_clear_2cols
; desc:    Clears two columns with blank.
; assumes: we're in vblank, or rendering is disabled
h_clear_2cols:
	; set the increment to 32 in PPUCTRL
	lda ctl_flags
	ora #pctl_adv32
	sta ppu_ctrl
	
	jsr h_ntwr_to_ppuaddr
	jsr @write30Xblank
	jsr h_advance_wr_head
	jsr h_ntwr_to_ppuaddr
	jsr @write30Xblank
	jsr h_advance_wr_head

	; restore the old PPUCTRL
	lda ctl_flags
	sta ppu_ctrl
	rts

@write30Xblank:
	lda #0
	tay
:	sta ppu_data
	iny
	cpy #$1E
	bne :-
	rts

; ** SUBROUTINE: h_advance_wr_head
; desc:    Advances the name table write head (ntwrhead).
h_advance_wr_head:
	; advance the write head but keep it within 64
	ldx ntwrhead
	inx
	txa
	and #$3F
	sta ntwrhead
	rts

; ** SUBROUTINE: h_flush_col_r_cond
; desc: Flushes a generated column in tempcol to the screen if the
;       relevant flag is set in nmictrl.  Used during init
h_flush_col_r_cond:
	lda #nc_flushcol
	bit nmictrl
	bne :+
	rts
:	eor nmictrl
	sta nmictrl

; ** SUBROUTINE: h_flush_col_r
; desc:    Flushes a generated column in tempcol to the screen
; assumes: we're in vblank or rendering is disabled
h_flush_col_r:
	; set the increment to 32 in PPUCTRL
	lda ctl_flags
	ora #pctl_adv32
	sta ppu_ctrl
	
	jsr h_ntwr_to_ppuaddr
	
	; start writing tiles.
	; each iteration will write 2 character tiles for one metatile.
	ldy #0
h_fls_wrloop:
	lda tempcol, y
	sta ppu_data
	iny
	cpy #$1E
	bne h_fls_wrloop
	
	jsr h_advance_wr_head
	
	; restore the old PPUCTRL
	lda ctl_flags
	sta ppu_ctrl
	rts

; ** SUBROUTINE: h_gener_row_u
; desc:    Generates a horizontal row of characters corresponding to the respective
;          metatiles in area space, upwards.
.proc h_gener_row_u
	ldy #0
	sty wrcountHR1
	sty wrcountHR2
	sty wrcountHR3
	sty wrcountHP1
	sty wrcountHP2
	
	lda roomsize
	pha
	lda roomloffs
	pha
	lda ntwrhead
	pha
	
	lda #wf_nicevert
	bit warpflags
	beq :+
	
	lda #$40
	sta roomsize
	lsr
	sta roomloffs
	
:	sty temp1
	
	; multiply by 32.  this is in range 0-29, so we
	; don't care about the upper 3 bits
	lda ntrowhead
	asl
	asl
	asl
	asl
	rol temp1
	asl
	rol temp1
	
	sta ppuaddrHR1
	sta ppuaddrHR2
	lda #$20
	clc
	adc temp1
	sta ppuaddrHR1+1
	clc
	adc #4
	sta ppuaddrHR2+1
	
	; we're going to treat temprow1 and temprow2 as a continuous array.
	; clear
	tya ; load zero
	
:	sta temprow1, y
	iny
	cpy #$40
	bne :-
	
	; cleared, now let's actually fill in the tiles we care about
	lda #$20
	sta wrcountHR1
	sta wrcountHR2
	
	lda ntwrhead
	sta temp1
	lda #32
	clc
	adc roomloffs
	sta temp2 ; load count
	
	ldy #0
@mainLoadLoop:
	sty temp3
	ldx temp1
	jsr h_comp_addr
	
	ldy ntrowhead2
	lda (lvladdr), y
	bmi @detour
	tax
@nodetour:
	lda metatiles, x
@detoured:
	ldx temp1
	sta temprow1, x
	
	lda temp1
	clc
	adc #1
	and #$3F
	sta temp1

	ldy temp3
	iny
	cpy temp2
	bne @mainLoadLoop
	beq @avoidDetour
	
@detour:
	tax
	cmp #$F2
	bcs @nodetour
	cmp #$EF
	bcc @nodetour
	lda lvlbasebank
	cmp #chrb_lvl2
	beq @level2
	bne @nodetour

@level2:
	jsr level2_struct_detour2
	jmp @detoured
	
@avoidDetour:
	; now that the row has been computed, it's time to set the nmictrl flag
	lda #nc_flushrow
	ora nmictrl
	sta nmictrl
	
	; check if (ntrowhead % 4) == 0
	lda ntrowhead
	and #$03
	bne @dontgeneratepal
	
	; get the Y index
	lda ntrowhead
	and #%00011100
	asl
	pha
	; $23C0 + y * 8 + x
	clc
	adc #$C0
	sta ppuaddrHP1
	sta ppuaddrHP2
	lda #$23
	sta ppuaddrHP1+1
	lda #$27
	sta ppuaddrHP2+1
	
	; start reading palette data.
	; palette data is loaded in "ntattrdata". Indexing: ntattrdata[xhigh * 64 + y * 8 + x].
	pla
	tax
	
	; got the Y coordinate
	ldy #0
@palette_loop:
	lda ntattrdata, x
	sta temppalH1, y
	lda ntattrdata+64, x
	sta temppalH2, y
	inx
	iny
	cpy #8
	bne @palette_loop
	
	sty wrcountHP1
	sty wrcountHP2
	
	lda #nc_flushpal
	ora nmictrl
	sta nmictrl
	
@dontgeneratepal:
	pla
	sta ntwrhead
	pla
	sta roomloffs
	pla
	sta roomsize
	rts
.endproc

; ** SUBROUTINE: h_gener_col_r
; desc:    Generates a vertical column of characters corresponding to the respective
;          metatiles in area space, on the right side of the scroll seam.  Also
;          generates the next column of tiles and the palette if necessary.
h_gener_col_r:
	lda #gs_scrstopR
	bit gamectrl
	beq @continue
@return:
	rts
@continue:
	lda #nc_flushcol
	bit nmictrl
	bne @return               ; if a column was already enqueued, return
	
	ldx ntwrhead              ; compute the areaspace address
	jsr h_comp_addr
	ldy lvlyoff               ; start writing tiles.
	sty temp6
	ldy #0                    ; start writing tiles.
	sty temp7
@loop:                        ; each iteration will write 1 character tile for one metatile.
	lda (lvladdr), y
	bmi @detour
	tax
@nodetour:
	lda metatiles, x
@detoured:
	sty temp7                 ; store the current y into temp7
	ldy temp6                 ; load the offsetted version into temp6
	sta tempcol, y
	iny
	cpy #$1E
	bne :+
	ldy #0
:	sty temp6
	ldy temp7                 ; restore the current y into temp7
	iny
	cpy #$1E
	bne @loop

	lda #nc_flushcol          ; set the nmictrl nc_flushcol flag
	ora nmictrl
	sta nmictrl
	
	lda #gs_dontgen
	bit gamectrl
	bne :+
	
	jsr h_gener_ents_r
	jsr h_gener_mts_r         ; generate a new column of meta-tiles and entities
	
:	lda ntwrhead              ; check if we're writing the 3rd odd column
	and #$03
	cmp #$03
	beq h_palette_data_column
	rts

@detour:
	tax
	cmp #$F2
	bcs @nodetour
	cmp #$EF
	bcc @nodetour
	lda lvlbasebank
	cmp #chrb_lvl2
	beq @level2
	bne @nodetour

@level2:
	jsr level2_struct_detour
	jmp @detoured

; ** SUBROUTINE: h_calc_ntattrdata_addr
; desc: Calculates the ntattrdata address into temp1 for a column.
; arguments:
;     A - The column index.
h_calc_ntattrdata_addr:
	sta temp2
	
	; in temp1, we store the index into ntattrdata.
	lda #%00100000
	bit temp2
	bne :+
	lda #0
:	asl
	sta temp1
	
	; determined the Page Index
	; now determine the sub page index
	
	lda temp2
	and #$1F
	lsr
	lsr
	clc
	adc temp1
	sta temp1
	rts

; ** SUBROUTINE: h_palette_data_column
; desc: Reads a single column of palette data.
; NOTE: sets nc_flshpalv in nmictrl!
.proc h_palette_data_column
	lda #gs_dontpal
	bit gamectrl
	bne returnAndSetFlag
	
	lda #rf_new
	bit roomflags
	beq :+
	jmp gm_gen_pal_col_NEW
:	ldy #0                    ; start reading palette data.
	
ploop:
	jsr gm_read_pal
	cmp #$FD
	beq phaveFD
	cmp #$FE
	beq phaveFE               ; break out of this loop
	cmp #$FF
	bne pnoFF
	
	lda palrdheadlo
	bne :+
	dec palrdheadhi
:	dec palrdheadlo
	
	lda #0
pnoFF:
	sta temppal,y
	iny
	cpy #8
	bne ploop
phaveFE:
	
doneloadingpalettes:
	lda temp1
	pha
	
	; copy all that stuff into "ntattrdata"
	lda ntwrhead
	jsr h_calc_ntattrdata_addr
	
	ldy #0
loopCopy:
	; load the palette from the array
	lda temppal, y
	
	; load the index, and store it there
	ldx temp1
	sta ntattrdata, x
	
	; increment it by eight
	txa
	clc
	adc #8
	sta temp1
	
	; then advance the loop
	iny
	cpy #8
	bne loopCopy
	
	pla
	sta temp1

returnAndSetFlag:
	lda #nc_flshpalv
	ora nmictrl
	sta nmictrl
	
	rts

phaveFD:
	jsr gm_read_pal
	jmp pnoFF
.endproc

h_palette_finish := h_palette_data_column::doneloadingpalettes

; significance of palette combinations:
; $FE - Re-use the same palette data as the previous column
; $FF - End of palette data

; ** FEATURE: h_genertiles_dup
; desc:    Generates a column of metatiles from 2 bytes.
; args:    A - the dup data, Y - the Y position to start placing at
;
; The format in bytes for the first byte (currently loaded in A) as follows: 001CCCCC TTTTTTTT
h_genertiles_dup:
	and #%00011111
	sta temp1
	tya                   ; transfer the Y coordinate over to add it to temp1
	clc
	adc temp1
	sta temp1             ; store it in temp1
	jsr gm_read_tile      ; read another byte - will be used as our 'brush'
	ldx arwrhead
:   sta (lvladdr), y
	sta lastcolumn, y
	iny
	cpy temp1             ; check it against the limit
	bne :-
	jmp h_genertiles_cont

; ** FEATURE: h_genertiles_copy
; desc:    Copies an amount of metatiles from the last column.
h_genertiles_copy:
	and #%00011111
	sta temp1
	tya                   ; transfer the Y coordinate over to add it to temp1
	clc
	adc temp1
	sta temp1             ; store it in temp1
	
:	lda lastcolumn, y
	sta (lvladdr), y
	; no need to store to lastcolumn as that's where we got it from in the first place!
	iny
	cpy temp1
	bne :-
	
	jmp h_genertiles_cont

; ** FEATURE: h_genertiles_high
; desc:    Copies data verbatim after this byte.
h_genertiles_high:
	and #%00011111
	sta temp1
	tya
	clc
	adc temp1
	sta temp1

:	jsr gm_read_tile
	sta (lvladdr), y
	sta lastcolumn, y
	iny
	cpy temp1
	bne :-
	
	jmp h_genertiles_cont

; ** FEATURE: h_genertiles_dupair
; desc:    Like h_genertiles_dup but only generates air.
h_genertiles_dupair:
	and #%00011111
	sta temp1
	tya
	clc
	adc temp1
	sta temp1
	ldx arwrhead
	lda #0
:	sta (lvladdr), y
	sta lastcolumn, y
	iny
	cpy temp1
	bne :-
	jmp h_genertiles_cont

h_genertiles_lvlend:
	lda arrdheadlo
	bne :+
	dec arrdheadhi
:	dec arrdheadlo
	
	jsr h_genertiles_calc_camlimit
	
	lda #0                ; just store 0 as the tile
	sta (lvladdr), y
	sta lastcolumn, y
	iny
	jmp h_genertiles_cont

; ** SUBROUTINE: h_gener_mts_r
; desc:    Generates a column of metatiles ahead of the visual column render head.
h_gener_mts_r:
	lda #gs_lvlend
	bit gamectrl
	beq :+
	rts
	
:	inc colsloaded
	ldx arwrhead
	jsr h_comp_addr       ; compute the address in (lvladdr)
	
	lda #rf_new
	bit roomflags
	beq :+
	jmp h_gener_mts_NEW_r
	
:	ldy #0
h_genertiles_loop:
	jsr gm_read_tile
	cmp #0
	bpl @positive
	cmp #$FF              ; if data == 0xFF, then decrement the pointer
	beq h_genertiles_lvlend
	
	cmp #$A1              ; if data >= 0xA1 && data < 0xC0, then this is a "duplicate" tile.
	bcc :+
	cmp #$BF
	bcs :+
	jmp h_genertiles_dup
	
:	cmp #$C1
	bcc :+
	cmp #$DF
	bcs :+
	jmp h_genertiles_dupair
	
:	cmp #$81
	bcc :+
	cmp #$9F
	bcs :+
	jmp h_genertiles_copy
	
:	cmp #$E1
	bcc :+
	cmp #$FF
	bcs :+
	jmp h_genertiles_high

:
@positive:
	sta (lvladdr), y
	sta lastcolumn, y
	iny
h_genertiles_cont:
	cpy #30
	bcc h_genertiles_loop
	
	; no need to store these in lastcolumn as the bytes are never used.
	lda #0
	sta (lvladdr), y
	iny
	sta (lvladdr), y
	iny
	
h_genertiles_inc_arwrhead:
	clc                   ; loop done, increment arwrhead, ensuring it rolls over after 63
	lda #1
	adc arwrhead
	and #$3F
	sta arwrhead
	rts

; ** SUBROUTINE: h_genertiles_calc_camlimit
; desc: Calculates the rightward camera scrolling limit when hitting an end marker.
.proc h_genertiles_calc_camlimit
	; TODO: This doesn't work always.  In cases where room width is
	; already specified, just use that to calculate the camera limit.
	lda roomsize
	bne roomWidthNotZero
	
	lda #rf_new
	bit roomflags
	beq :+
	lda roomwidth
	bne roomWidthNotZero
	
:	lda #0
	sta camlimithi
	
	lda colsloaded
	and #%11111100
	
	; multiply by 8 for the pixel amount
	asl
	rol camlimithi
	asl
	rol camlimithi
	asl
	rol camlimithi
	
	clc
	adc roombeglo
	sta camlimit
	
	lda camlimithi
	adc roombeghi
	sec
	sbc #1
	sta camlimithi
	jmp done

roomWidthNotZero:
	sta camlimit
	lda #0
	asl camlimit
	rol
	asl camlimit
	rol
	asl camlimit
	rol
	sta camlimithi
	
	lda camlimit
	clc
	adc roombeglo
	sta camlimit
	
	lda camlimithi
	adc roombeghi
	sta camlimithi
	dec camlimithi

done:
	lda #(gs_scrstopR | gs_lvlend)
	ora gamectrl
	sta gamectrl
	lda arwrhead
	sta trarwrhead
	rts
.endproc

h_generents_scrnext:
	jsr gm_adv_ent        ; advance the entity stream
	clc
	lda #1                ; NOTE: assumes arwrhead is between 0-63! change if/when expanding.
	adc tr_scrnpos
	sta tr_scrnpos
	rts

; ** SUBROUTINE: h_gener_ents_r
; desc:    Generates a column of entities ahead of the visual column render head.
h_gener_ents_r:
	jsr gm_read_ent_na    ; read the byte at the beginning of the stream without advancing
	cmp #ec_dataend       ; if it's a level terminator, simply return.
	bne :+
	rts
:	cmp #ec_scrnext       ; if it's a next screen command, handle it separately and return.
	beq h_generents_scrnext
	sta temp1
	; this is the X coordinate of an entity.
	
	lda arwrhead          ; ok. check if we're on the correct screen
	sec
	sbc roombeglo2
	lsr
	lsr
	lsr
	lsr
	lsr                   ; divide by 32 to get the screen number
	and #1                ; NOTE: assumes arwrhead is between 0-63! change if/when expanding.
	sta temp2
	lda tr_scrnpos
	and #1
	cmp temp2
	beq :+
	rts                   ; if the screen numbers are not equal, then return
:	lda arwrhead
	and #$1F              ; cap it between 0-31, this will be an in-screen coordinate.
	asl
	asl
	asl                   ; now check if the X coordinate is bigger than the area write head.
	sec
	sbc roombeglo
	cmp temp1
	bcs :+                ; if A [(arwrhead & 0x1F) >> 3] >= M [the X coord of the tile]
	rts                   ; then return.
:	jsr gm_adv_ent        ; advance the stream. we will process this entity's data.
	
	; load the rest of the data
	jsr gm_read_ent
	sta temp2             ; store the Y position in temp2
	jsr gm_read_ent
	sta temp3             ; store the entity kind in temp3
	
	; find a free spot in sprite space.
	ldx #0
:	lda sprspace+sp_kind, x
	beq h_generents_spotfound
	inx
	cpx #sp_max
	bne :-
	; no more space found for this entity! :(
	rts
h_generents_spotfound:
	; a sprite slot was found. its slot number is located in the x register.
	
	; load the X coordinate, and add the room beginning pixel and the current screen pos
	clc
	lda temp1
	adc roombeglo
	sta sprspace+sp_x, x
	
	lda tr_scrnpos
	adc roombeghi
	sta sprspace+sp_x_pg, x
	
	; TODO-- Is it fine to init the entity after calculating its X?
	; If not, then make sure that Dust Bunnies' homxh value is calculated
	; properly.
	
	;jmp gm_init_entity

; ** SUBROUTINE: gm_init_entity
; desc: Initializes an entity's fields when loaded.
;       Handles all the special entity ID cases (e.g. e_rerefill)
;
; note: You can also use `gm_read_ent` here to read extra properties about
;       this entity (though you MUST make LevelEditor export them as well)
;
; note: Do NOT clobber X!
;
; note: The X coordinate is up to the loader. It won't be modified.
;
; parameters:
;     temp2 - Y coordinate
;     temp3 - Entity Type
;     X Reg - Entity index
gm_init_entity:
	lda #0
	sta sprspace+sp_entspec1, x
	sta sprspace+sp_entspec2, x
	sta sprspace+sp_entspec3, x
	sta sprspace+sp_entspec4, x
	sta sprspace+sp_entspec5, x
	sta sprspace+sp_entspec6, x
	sta sprspace+sp_entspec7, x
	sta sprspace+sp_x_lo, x
	sta sprspace+sp_y_lo, x
	sta sprspace+sp_wid, x
	sta sprspace+sp_hei, x
	sta sprspace+sp_vel_x, x
	sta sprspace+sp_vel_y, x
	sta sprspace+sp_vel_x_lo, x
	sta sprspace+sp_vel_y_lo, x
	sta sprspace+sp_flags, x
	
	lda roomnumber
	and #1
	asl
	sta sprspace+sp_flags, x
	
	lda temp2
	sta sprspace+sp_y, x
	
	lda temp3
	asl                       ; shift the limbo bit in Carry
	
	lda #0
	rol                       ; rotate the carry bit in
	asl
	asl                       ; ef_limbo is $04
	ora sprspace+sp_flags, x
	sta sprspace+sp_flags, x
	
	lda temp3
	and #%01111111
	sta sprspace+sp_kind, x
	
	; TODO: Seriously we should consider using a jump table here.
	cmp #e_l0bridgea
	bne @notL0BridgeA
	
	lda #e_l0bridge           ; turn it into a normal bridge manager entity
	sta sprspace+sp_kind, x   ; with the auto collapse flag set.
	lda #1
	sta sprspace+sp_l0bm_acoll, x
	rts
@notL0BridgeA:
	cmp #e_rerefill
	bne @notReRefill
	
	lda #e_refill             ; this is a refill with regeneration. turn it into a
	sta sprspace+sp_kind, x   ; normal refill entity with the erf_regen flag set.
	lda #erf_regen
	sta sprspace+sp_refill_flags, x
	rts
@notReRefill:
	cmp #e_strawb
	beq @isStrawberry
	cmp #e_strawbw
	bne @isNotStrawberry
	
@isStrawberry:
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_strawb_ident, y
	
	lda sprspace+sp_kind, y
	cmp #e_strawbw
	bne @tyxReturn
	
	lda #e_strawb
	sta sprspace+sp_kind, y
	lda sprspace+sp_strawb_flags, y
	ora #esb_winged
	sta sprspace+sp_strawb_flags, y
	
@tyxReturn:
	tya
	tax
	rts

@isNotStrawberry:
	cmp #e_crumble
	bne @isNotCrumbleBlock
	
	; is crumble block
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_crumbl_width, y
	jmp @tyxReturn
	
@isNotCrumbleBlock:
	cmp #e_l1zipmovr
	beq @isZipMover
	cmp #e_l1zipmovt
	bne @notZipMover
	
@isZipMover:
	txa
	tay
	lda #0
	sta sprspace+sp_l1zm_flags, y
	
	jsr gm_read_ent
	sta sprspace+sp_wid, y
	cmp #0
	
	bpl @notSpiky
	and #$7F
	sta sprspace+sp_wid, y
	lda #sp_l1zmf_spikyUP
	sta sprspace+sp_l1zm_flags, y

@notSpiky:
	jsr gm_read_ent
	sta sprspace+sp_l1zm_destx, y
	jsr gm_read_ent
	sta sprspace+sp_l1zm_desty, y
	lda #0
	sta sprspace+sp_l1zm_timer, y
	
	tya
	tax
	rts
	
@notZipMover:
	cmp #e_breakblck
	bne @notBreakable
	
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_wid, y
	jsr gm_read_ent
	sta sprspace+sp_hei, y
	jmp @tyxReturn
	
@notBreakable:
	cmp #e_l2chaser
	bne @notChaser
	
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_l2dc_state, y
	jmp @tyxReturn
	
@notChaser:
	cmp #e_fallblock
	bne @notFalling
	
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_fall_dindx, y
	jmp @tyxReturn
	
@notFalling:
	cmp #e_swgate
	bne @notSwitchGate
	
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_wid, y
	jsr gm_read_ent
	sta sprspace+sp_sgat_trajx, y
	jsr gm_read_ent
	sta sprspace+sp_sgat_trajy, y
	lda #24
	sta sprspace+sp_hei, y
	jmp @tyxReturn
	
@notSwitchGate:
	cmp #e_l2payphon
	bne @notPayPhone
	
	lda #$80
	sta sprspace+sp_l2ph_state, x
	rts
	
@notPayPhone:
	cmp #e_l3sinkpla
	bne @notSinkPla
	
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_wid, y
	lda sprspace+sp_x, y
	sta sprspace+sp_l3sp_homex, y
	lda sprspace+sp_y, y
	sta sprspace+sp_l3sp_homey, y
	jmp @tyxReturn
	
@notSinkPla:
	cmp #e_l3dustbun
	bne @notDustCreature
	
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_l3db_tratp, y
	jsr gm_read_ent
	sta sprspace+sp_l3db_trara, y
	jsr gm_read_ent
	sta sprspace+sp_l3db_timer, y
	
	lda sprspace+sp_x, y
	sta sprspace+sp_l3db_homex, y
	lda sprspace+sp_y, y
	sta sprspace+sp_l3db_homey, y
	lda sprspace+sp_x_pg, y
	sta sprspace+sp_l3db_homxh, y
	jmp @tyxReturn
	
@notDustCreature:
	cmp #e_invisbar
	bne @notInvisBarr
	
	txa
	tay
	jsr gm_read_ent
	sta sprspace+sp_wid, y
	jsr gm_read_ent
	sta sprspace+sp_hei, y
	jmp @tyxReturn
	
@notInvisBarr:
	; todo: more cases ...
	rts

; ** SUBROUTINE: gm_read_tile_na
; ** SUBROUTINE: gm_read_ent_na
; ** SUBROUTINE: gm_read_tile
; ** SUBROUTINE: gm_read_ent
; desc: Reads a byte from the tile or entity streams. The _na versions don't
; advance the pointer.
; returns: a - the byte of data read in
; clobbers: x
gm_read_tile_na:
	ldx #0
	lda (arrdheadlo,x)
	rts

gm_read_ent_na:
	ldx #0
	lda (entrdheadlo,x)
	rts

;gm_read_pal_na:
;	ldx #0
;	lda (palrdheadlo,x)
;	rts

gm_read_tile:
	ldx #0
	lda (arrdheadlo,x)
gm_adv_tile:
	inc arrdheadlo
	bne :+
	inc arrdheadhi
:	rts

gm_read_ent:
	ldx #0
	lda (entrdheadlo,x)
gm_adv_ent:
	inc entrdheadlo
	bne :+
	inc entrdheadhi
:	rts

gm_read_pal:
	ldx #0
	lda (palrdheadlo,x)
gm_adv_pal:
	inc palrdheadlo
	bne :+
	inc palrdheadhi
:	rts

; ** SUBROUTINE: gm_fetch_room
; args: y - offset into lvl array
; clobbers: a, x, y
; desc: loads a room, initializes the tile and entity streams
gm_fetch_room:
	; load room pointer from lvl pointer
	
	; push the level index, then multiply by 2, and index into the level table
	; note: the level table MUST reside in bank 1! bank 0 is not automatically loaded anymore
	tya
	pha
	asl
	tay
	iny ; skip the two bytes (environment type and room count)
	iny
	
	lda (lvlptrlo),y
	sta temp1
	iny
	lda (lvlptrlo),y
	sta temp1+1
	
	; pull the level index and then load its corresponding bank
	pla
	tay
	lda (lvlbktbl),y
	tay
	sty lvldatabank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank
	
	; ok, so currently we want to look at the *warp*, we need to load some details
	; and load roomptrlo as well
	ldy #0
	lda (temp1), y
	sta roomloffs
	and #%11000000 ; max offset of 64
	sta warpflags
	lda roomloffs
	and #%00111111
	sta roomloffs
	iny
	lda (temp1), y
	sta startpx
	iny
	lda (temp1), y
	sta startpy
	iny
	lda (temp1), y
	sta roomptrlo
	iny
	lda (temp1), y
	sta roomptrhi
	
	; now load the actual room pointer
	ldy #0

@fetchRoomLoop:
	lda (roomptrlo),y
	sta roomhdrfirst,y
	iny
	cpy #<(roomhdrlast-roomhdrfirst)
	bne @fetchRoomLoop
	
	; split out the 2nd room flags
	lda rm_paloffs
	sta roomflags2
	and #%00000111
	sta rm_paloffs
	
	; ok, now zero out the altwarps. in case we don't load them,
	; they'll be zero, so inactivated
	lda #0
	sta warp_ualt_x
	sta warp_dalt_x
	sta warp_lalt_y
	sta warp_ralt_y
	
	; ok. now, load the alternative warps, if any
	lda (roomptrlo), y
	iny
	cmp #$FF
	beq @skipLoadingAltWarps
	
	sta warp_ualt_x
@fetchRoomLoop2:
	lda (roomptrlo),y
	sta roomhdrfirst,y
	iny
	cpy #<(roomaltwarpslast-roomhdrfirst)
	bne @fetchRoomLoop2
	
@skipLoadingAltWarps:
	; load tile pointer from room pointer
	lda (roomptrlo),y
	sta arrdheadlo
	iny
	lda (roomptrlo),y
	sta arrdheadhi
	iny
	
	; load palette pointer from room pointer
	lda (roomptrlo),y
	sta palrdheadlo
	iny
	lda (roomptrlo),y
	sta palrdheadhi
	iny

	; load entity pointer from room pointer
	lda (roomptrlo),y
	sta entrdheadlo
	iny
	lda (roomptrlo),y
	sta entrdheadhi
	iny
	
	; reset the columns loaded value
	lda #0
	sta colsloaded
	
	; check if we are allowed to respawn here
	lda roomflags
	and #rf_norespawn
	bne @dontChangeRespawn
	
	lda currroom
	sta respawnroom
	
@dontChangeRespawn:
	; check if we need to update the loaded background bank
	
	; if transitioning, then bank 0 has a lower
	; priority than the rest
	lda gamectrl3
	and #g3_transitA
	beq @skipTransitionCheck
	
	; transitioning, so check if the current bank
	; would be zero. if it would be, then skip this check
	lda roomflags2
	and #%00011000
	beq @dontChangeBank
	
@skipTransitionCheck:
	jsr gm_update_bg_bank
	
	; check if this is a new level
@dontChangeBank:
	lda #rf_new
	bit roomflags
	beq :+
	jmp gm_decompress_level
:	rts

; ** SUBROUTINE: gm_update_bg_bank
; desc: Updates the first background bank when transitioning between rooms.
.proc gm_update_bg_bank
	lda cassrhythm
	bmi @return
	
	lda roomflags2
	and #%00011000
	beq :+
	lsr
	lsr
	clc
	adc #2
:	clc
	adc lvlbasebank
	sta bg0_bknum
	
	; If this is level 2, and the current bank number is LVL2B, then
	; load alternate palettes.
	cmp #chrb_lvl3
	bne @notLevel3
	
	; is level 3, so check the outside flag
	lda roomflags2
	and #r2_outside
	beq :+
	lda #chrb_lvl3al
	sta bg0_bknum
:	rts
	
@notLevel3:
	cmp #chrb_lvl2b
	beq @level2B
	bne @normalPalette
	
@return:
	rts

@level2B:
	lda #<level2_alt_palette
	sta paladdr
	lda #>level2_alt_palette
	sta paladdr+1
	
	lda #g4_altpal
	bit gamectrl4
	bne @return
	
	ora gamectrl4
	sta gamectrl4
	
	bne @schedulePaletteUpload
	
@normalPalette:
	; try and revert to the normal palette
	lda #g4_altpal
	bit gamectrl4
	beq @return
	
	eor gamectrl4
	sta gamectrl4
	
	lda levelnumber
	asl
	tax
	lda level_palettes, x
	sta paladdr
	inx
	lda level_palettes, x
	sta paladdr+1
	
@schedulePaletteUpload:
	lda paladdr
	sta vmcsrc
	lda paladdr+1
	sta vmcsrc+1
	
	lda #$3F
	sta vmcaddr+1
	lda #$00
	sta vmcaddr
	
	lda #$10
	sta vmccount
	
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
	rts
.endproc

; ** SUBROUTINE: gm_on_level_init
; desc: Called on level initialization.
gm_on_level_init:
	; load the player's X coordinate to the pixel coordinates provided,
	; if this is the first level
	lda startpx
	sta player_x
	lda startpy
	sta player_y
	
	; select the music bank
	lda #mmc3bk_prg1
	ldy musicbank
	jsr mmc3_set_bank
	
	lda musicdiff
	beq @dontReloadMusic
	
	ldy #0
	lda (musictable), y
	tax
	iny
	
	lda (musictable), y
	tay
	
	lda #1 ; NTSC
	jsr famistudio_init
	
	ldy #2
	lda (musictable), y
	jsr famistudio_music_play
	
@dontReloadMusic:
	; then set it back to level data
	lda #mmc3bk_prg1
	ldy lvldatabank
	jmp mmc3_set_bank

; ** SUBROUTINE: gm_set_level
; args: X - level number
; assumes: vblank is off and you're loading a new level
gm_set_level:
	stx levelnumber
	
	jsr save_file_load_berries
	
	ldx levelnumber
	lda lvldatabank
	pha
	
	ldy level_banks_mus, x
	sty musicbank
	
	ldy level_banks2, x
	sty lvldatabank2
	lda #mmc3bk_prg0
	jsr mmc3_set_bank
	
	ldy level_banks_spr, x
	sty defsprbank
	sty spr1_bknum
	
	txa
	asl
	tax
	
	lda level_table, x
	sta lvlptrlo
	lda level_palettes, x
	sta paladdr
	inx
	lda level_table, x
	sta lvlptrhi
	lda level_palettes, x
	sta paladdr+1
	
	; load the music table
	lda musictable
	pha
	lda musictable+1
	pha
	
	ldy #0
	lda (lvlptrlo), y
	sta musictable
	iny
	
	lda (lvlptrlo), y
	sta musictable+1
	iny
	
	lda (lvlptrlo), y
	sta lvlbktbl
	iny
	
	lda (lvlptrlo), y
	sta lvlbktbl+1
	iny
	
	lda lvlptrlo
	clc
	adc #4
	sta lvlptrlo
	bcc :+
	inc lvlptrhi
	
	; check if any details changed
:	lda #0
	tay
	sta musicdiff
	
	pla
	cmp musictable+1
	beq :+
	inc musicdiff
:	pla
	cmp musictable
	beq :+
	inc musicdiff
:	pla
	cmp lvldatabank
	beq :+
	inc musicdiff

:	; load room 0
	
	; load the "environment type" field. This specifies the default bank
	lda (lvlptrlo), y
	tay
	lda level_bg_banks_1, y
	sta bg0_bknum
	sta lvlbasebank
	lda level_bg_banks_2, y
	sta bg1_bknum
	
	ldy #0
	jsr gm_set_room
	
	jsr gm_load_generics
	jmp gm_on_level_init

; ** SUBROUTINE: gm_set_room
; args: Y - room number
; assumes: you're loading a new level
gm_set_room:
	sty currroom
	jmp gm_fetch_room

; ** SUBROUTINE: gm_load_generics
; desc: Loads the generic sprite sheet banks.  The game may animate them later.
gm_load_generics:
	lda #chrb_plrsp0
	sta spr0_bknum
	
	; spr1_bknum is controlled by the level itself.
	
	lda #chrb_gensp1
	sta spr2_bknum
	
	lda #chrb_anisp0
	sta spr3_bknum
	rts

; ** SUBROUTINE: gm_respawn
; desc: Respawns the player.
gm_respawn:
	lda camera_x_pg
	lsr
	lda camera_x
	ror
	lsr
	lsr
	sta ntwrhead
	
	lda #32
	sta respawntmr
	
	lda #g3_transitX
	ora gamectrl3
	sta gamectrl3
	
	jsr gm_init_death_wipe
	
	jsr gm_respawn_leave_doframe2
	
	; perform the slide wipe
	ldy #32
@loop:
	sty transtimer
	
	cpy #23
	bcs @dontClearCol
	
	lda #nc2_clrcol
	ora nmictrl2
	sta nmictrl2
	
@dontClearCol:
	inc deathtimer
	
	lda #16
	sta miscsplit
	
	jsr gm_respawn_leave_doframe
	
	ldy transtimer
	dey
	bne @loop
	
	lda #0
	ldy #0
:	sta sprspace+sp_kind, y
	iny
	cpy #sp_max
	bne :-
	
	; initiate the transition sequence now.
	lda #g2_noclrall
	sta gamectrl2
	
	lda #0
	sta gamectrl
	; disable rendering
	sta ppu_mask
	sta miscsplit
	jsr vblank_wait
	
	lda nmictrl
	and #<~(nc_flshpalv | nc_flushcol | nc_flushpal | nc_flushrow)
	sta nmictrl
	lda gamectrl
	and #<~(gs_lvlend | gs_scrstopR | gs_scrstodR)
	sta gamectrl
	
	jsr com_clear_oam
	
	ldy respawnroom
	jsr gm_set_room
	
	lda #0
	sta musicdiff   ; no difference in music
	
	jmp gm_on_level_init
