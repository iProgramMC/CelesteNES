; Copyright (C) 2024 iProgramInCpp

; NOTE NOTE NOTE
; These functions are declared in the MAIN segment. Not the GAME segment.

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
;
; NOTE for h_get_tile1: the Y coordinate must be in A when you call!
h_get_tile:
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
; desc:    Flushes a generated palette column in temppal to the screen if nc_flshpalv is set
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts), increment to 1
h_flush_pal_r_cond:
	lda #nc_flshpalv
	bit nmictrl
	bne h_flush_pal_r
	rts

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

; ** SUBROUTINE: h_flush_row_u
; desc:    Flushes a generated row in temprow to the screen.
; assumes: we're in vblank or rendering is disabled
h_flush_row_u:
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
	
	; advance the row head but keep it within 30
	ldx ntrowhead
	bne :+
	ldx #30
:	dex
	stx ntrowhead
	
	rts

; ** SUBROUTINE: h_enqueued_clear
; desc: Clears the places in a nametable that the IntroCrusher occupies.
; assumes: running inside an NMI or rendering is disabled.
h_enqueued_clear:
	; set the increment to 32 in the PPUCTRL
	lda ctl_flags
	ora #pctl_adv32
	sta ppu_ctrl
	
	ldy #0
@loop:
	sty temp2
	
	; load the ppu address to start writing the column
	lda clearpahi
	sta ppu_addr
	lda clearpalo
	sta ppu_addr
	
	; flush one column
	lda #0
	ldx #0
:	; TODO: somehow ensure that the PPUDATA is reloaded properly from the top
    ; when vertically overflowing a nametable?? or something??
	sta ppu_data
	inx
	cpx clearsizey
	bne :-
	
	; keep part of the old row number in a temporary so we can check it later
	lda clearpalo
	and #%11100000
	sta temp3
	
	; increment the PPU address, for the next column
	inc clearpalo
	beq @haveOverFlow  ; in case of this type of overflow, the row was definitely overflown
	
	; check for regular cases of overflow
	lda clearpalo
	and #%11100000
	cmp temp3
	beq @noOverFlow    ; if the row number stayed the same, then no overflow
	
@haveOverFlow:
	; we have overflow! reset the row number to default and increase the name table number
	lda clearpalo
	and #%00011111
	ora temp3
	sta clearpalo
	
	lda clearpahi
	eor #$04
	sta clearpahi

@noOverFlow:
	ldy temp2
	iny
	cpy clearsizex
	bne @loop
	
	; restore the old PPUCTRL
	lda ctl_flags
	sta ppu_ctrl
	
	rts
	
level0_nmi_set_icr:
	lda clearpahi
	sta ppu_addr
	lda clearpalo
	sta ppu_addr
	
	ldx #0
	ldy #0
@loop:
	stx temp2
	
	ldx #0
:	lda l0ic_chardata, y
	sta ppu_data
	iny
	inx
	cpx #7
	bne :-
	
	lda clearpalo
	clc
	adc #$20
	sta clearpalo
	bcc :+
	inc clearpahi
	
:	lda clearpahi
	sta ppu_addr
	lda clearpalo
	sta ppu_addr
	
	ldx temp2
	inx
	cpx #4
	bne @loop
	rts

; ** SUBROUTINE: h_calcppuaddr
; desc: Calculates the PPU address for the tile position stored at [temp2 (x), temp3 (y)].
;       Returns the results in clearpalo, clearpahi.  These are then used by
;       the NMI handler.
h_calcppuaddr:
	; add the level Y offset.
	lda temp3
	pha
	
	clc
	adc lvlyoff
	cmp #$1E
	bcc :+
	sbc #$1E
:	sta temp3
	
	; the nametable the IC is a part of.
	;
	; note: the IC may not wrap across nametables! Tiles will be written to the
	; wrong place if it does!
	lda #%00100000
	bit temp2
	bne @do24
	lda #$20
	bne @done
@do24:
	lda #$24
@done:
	sta clearpalo
	
	; then, part of the Y coordinate.
	; between $2000 and $2100 there are 8 tile rows.
	lda temp3
	lsr
	lsr
	lsr
	clc
	adc clearpalo
	tay         ; high address in Y
	
	; 0010 0XYY YYYX XXXX
	
	lda temp3
	ror
	ror
	ror
	ror
	and #%11100000
	sta clearpalo
	
	lda temp2
	and #%00011111
	ora clearpalo
	
	; temp5 - high byte, temp4 - low byte
	sta clearpalo
	sty clearpahi
	
	pla
	sta temp3
	rts

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
	ldy #0
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
h_gener_row_u:
	ldy #0
	sty wrcountHR1
	sty wrcountHR2
	sty wrcountHP1
	sty wrcountHP2
	
	; determine which nametable is the first written to
	; the PPU address we want to start writing to is
	; 0x2000 + (ntwrhead / 32) * 0x400 + (ntwrhead % 32) + ntrowhead * 0x20
	lda #$00
	sta ppuaddrHR1
	lda #$20
	sta ppuaddrHR1+1
	
	; (add ntwrhead / 32) * 0x400
	lda ntwrhead
	and #$20
	beq :+
	lda #$24
	sta ppuaddrHR1+1
:	; add ntwrhead % 32
	lda ntwrhead
	and #$1F
	clc
	adc ppuaddrHR1
	sta ppuaddrHR1
	; add (ntrowhead % 8) * 0x20 + (ntrowhead / 8) * 0x100
	lda ntrowhead
	lsr
	lsr
	lsr
	sta temp6
	
	lda ntrowhead
	ror
	ror
	ror
	ror
	and #%11100000
	clc
	adc ppuaddrHR1
	sta ppuaddrHR1
	lda ppuaddrHR1+1
	adc temp6
	sta ppuaddrHR1+1
	
	; done! ppuaddrHR2 is going to be the other nametable, with X=0
	lda ppuaddrHR1+1
	eor #$04
	sta ppuaddrHR2+1
	lda ppuaddrHR1
	and #%11100000
	sta ppuaddrHR2
	
	; determine which half we should be writing to
	lda ntwrhead
	and #$1F
	sta temp2
	lda #32
	sec
	sbc temp2
	sta temp2
	
	; sike! don't use an offset for HR1 either.
	lda ppuaddrHR1
	and #%00011111
	tay
	eor ppuaddrHR1
	sta ppuaddrHR1
	
	; write a bunch of fillers.
	lda #0
	iny
	dey
	beq @loop       ; don't actually write anything
	
:	ldx wrcountHR1
	sta temprow1, x
	inx
	stx wrcountHR1
	dey
	bne :-
	
@loop:
	sty temp1
	lda ntwrhead
	clc
	adc temp1
	and #$3F
	tax                      ; the X coordinate
	jsr h_comp_addr
	
	ldy ntrowhead2           ; the Y coordinate
	lda (lvladdr), y
	tax
	lda metatiles, x
	
	ldy temp1
	cpy temp2
	bcc :+
	ldx wrcountHR2           ; second half
	sta temprow2, x
	inx
	stx wrcountHR2
	bne @writedone
:	ldx wrcountHR1           ; first half
	sta temprow1, x
	inx
	stx wrcountHR1
@writedone:
	
	; pad out hr2 with filler.
	lda #0
	ldy wrcountHR2
	cpy #$20
	bne @dont
:	sta temprow2, y
	iny
	cpy #$20
	bne :-
	sty wrcountHR2
	
@dont:
	ldy temp1
	iny
	cpy #$20
	bne @loop
	
	; now that the row has been flushed, it's time to set the nmictrl flag
	lda #nc_flushrow
	ora nmictrl
	sta nmictrl
	
	; check if (ntrowhead % 4) == 0
	lda ntrowhead
	and #$03
	bne @dontgeneratepal
	
	; prepare addresses for palH1 and palH2.
	lda ntwrhead
	and #$20
	lsr
	lsr
	lsr
	clc
	adc #$23
	sta ppuaddrHP1+1
	
	; add the Y coordinate
	lda ntrowhead  ; 000yyyyy [0 - 29]
	asl            ; 00yyyyy0
	and #%00111000 ; 00yyy000
	ora #%11000000 ; $C0
	sta ppuaddrHP1
	
	; add the X coordinate
	lda ntwrhead   ; 00sxxxxx
	lsr            ; 000sxxxx
	lsr            ; 0000sxxx
	and #%00000111 ; 00000xxx
	clc
	adc ppuaddrHP1
	sta ppuaddrHP1
	
	; palH2 will be on the same nametable but the X coordinate will be zero
	lda ppuaddrHP1+1
	eor #$04
	sta ppuaddrHP2+1
	
	lda ppuaddrHP1
	and #%11111000
	sta ppuaddrHP2
	
	; calculate the Y threshold at which we need to switch to the other name table.
	lda ntwrhead
	and #$1F
	lsr
	lsr
	sta temp2
	lda #8
	sec
	sbc temp2
	sta temp2
	
	; start reading palette data.
	; palette data is loaded in "loadedpals". Indexing: loadedpals[x * 8 + y].
	; therefore we'll need to add 8 every load
	ldy #0
	lda ntrowhead
	lsr                  ; divide by 4. ntrowhead is a tile coordinate. convert to a
	lsr                  ; palette grid coordinate.
@ploop:
	pha                  ; push A to restore it later
	tax                  ; use it as an index into loadedpals.
	lda loadedpals, x
	
	cpy temp2
	bcc :+
	ldx wrcountHP2
	sta temppalH2, x
	inx
	stx wrcountHP2
	bne @writedone1
:	ldx wrcountHP1
	sta temppalH1, x
	inx
	stx wrcountHP1
	
@writedone1:
	pla                  ; restore A
	clc
	adc #8               ; and add 8 to it.
	iny
	cpy #8
	bne @ploop
	
	lda #nc_flushpal
	ora nmictrl
	sta nmictrl
	
@dontgeneratepal:
	rts
	

; ** SUBROUTINE: h_gener_col_r
; desc:    Generates a vertical column of characters corresponding to the respective
;          metatiles in area space, on the right side of the scroll seam.  Also
;          generates the next column of tiles and the palette if necessary.
h_gener_col_r:
	lda #gs_scrstopR
	bit gamectrl
	beq :+
	rts
:	ldx ntwrhead              ; compute the areaspace address
	jsr h_comp_addr
	ldy lvlyoff               ; start writing tiles.
	sty temp6
	ldy #0                    ; start writing tiles.
	sty temp7
@loop:                        ; each iteration will write 1 character tile for one metatile.
	lda (lvladdr), y
	tax
	lda metatiles, x
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

; ** SUBROUTINE: h_palette_data_column
; desc: Reads a single column of palette data.
; NOTE: sets nc_flshpalv in nmictrl!
h_palette_data_column:
	ldy #0                    ; start reading palette data.
@ploop:
	jsr gm_read_pal
	cmp #$FE
	beq @phaveFE              ; break out of this loop
	cmp #$FF
	bne @pnoFF
	
	lda palrdheadlo
	bne :+
	dec palrdheadhi
:	dec palrdheadlo
	
	lda #0
@pnoFF:
	sta temppal,y
	iny
	cpy #8
	bne @ploop
@phaveFE:
	lda #nc_flshpalv
	ora nmictrl
	sta nmictrl
	rts
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
	
	lda arwrhead          ; arwrhead: 0-63
	rol
	rol
	rol
	rol                   ; rotate that ANDed bit back to bit 0
	and #1
	eor #1                ; subtract 256 from it
	sta camlimithi
	lda arwrhead
	asl
	asl
	asl
	sta camlimit
	lda #gs_scrstopR
	ora gamectrl
	sta gamectrl
	lda arwrhead
	sta trarwrhead
	lda #0                ; just store 0 as the tile
	sta (lvladdr), y
	sta lastcolumn, y
	iny
	jmp h_genertiles_cont

; ** SUBROUTINE: h_gener_mts_r
; desc:    Generates a column of metatiles ahead of the visual column render head.
h_gener_mts_r:
	lda #gs_scrstopR
	bit gamectrl
	beq :+
	rts
	
:	ldx arwrhead
	jsr h_comp_addr       ; compute the address in (lvladdr)
	
	ldy #0
h_genertiles_loop:
	jsr gm_read_tile
	cmp #$FF              ; if data == 0xFF, then decrement the pointer
	beq h_genertiles_lvlend
	
	cmp #$A1              ; if data >= 0xA1 && data < 0xC0, then this is a "duplicate" tile.
	bcc :+
	cmp #$C0
	bcs :+
	jmp h_genertiles_dup
	
:	cmp #$C1
	bcc :+
	cmp #$E0
	bcs :+
	jmp h_genertiles_dupair
	
:	cmp #$81
	bcc :+
	cmp #$9F
	bcs :+
	jmp h_genertiles_copy
	
:	sta (lvladdr), y
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
	
	clc                   ; loop done, increment arwrhead, ensuring it rolls over after 63
	lda #1
	adc arwrhead
	and #$3F
	sta arwrhead
	rts

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
	lda #0
	sta sprspace+sp_entspec1, x
	sta sprspace+sp_entspec2, x
	sta sprspace+sp_entspec3, x
	sta sprspace+sp_x_lo, x
	sta sprspace+sp_y_lo, x
	sta sprspace+sp_wid, x
	sta sprspace+sp_hei, x
	sta sprspace+sp_vel_x, x
	sta sprspace+sp_vel_y, x
	sta sprspace+sp_vel_x_lo, x
	sta sprspace+sp_vel_y_lo, x
	sta sprspace+sp_flags, x
	
	lda temp3
	cmp #e_rerefill
	bne :+
	lda #e_refill             ; this is a refill with regeneration. turn it into a
	sta sprspace+sp_kind, x   ; normal refill entity with the erf_regen flag set.
	lda #erf_regen
	sta sprspace+sp_refill_flags, x
	jmp h_generents_cont
:
	; some more exceptional entity IDs here...
	sta sprspace+sp_kind, x
h_generents_cont:
	lda roomnumber
	and #1
	asl
	sta sprspace+sp_flags, x
	
	lda temp2
	sta sprspace+sp_y, x
	
	; load the X coordinate, and add the room beginning pixel and the current screen pos
	clc
	lda temp1
	adc roombeglo
	sta sprspace+sp_x, x
	
	lda tr_scrnpos
	adc roombeghi
	sta sprspace+sp_x_pg, x
	
	rts

; ** SUBROUTINE: gm_set_level_ptr
; ** SUBROUTINE: gm_set_room_ptr
; args:
;     x - low byte
;     y - high byte
gm_set_level_ptr:
	stx lvlptrlo
	sty lvlptrhi
	rts
gm_set_room_ptr:
	stx roomptrlo
	sty roomptrhi
	rts
; ** SUBROUTINE: gm_set_tile_head
; ** SUBROUTINE: gm_set_pal_head
; ** SUBROUTINE: gm_set_ent_head
; args:
;     x - low byte
;     a - high byte
gm_set_tile_head:
	stx arrdheadlo
	sta arrdheadhi
	rts
gm_set_pal_head:
	stx palrdheadlo
	sta palrdheadhi
	rts
gm_set_ent_head:
	stx entrdheadlo
	sta entrdheadhi
	rts

; ** SUBROUTINE: gm_read_tile_na
; ** SUBROUTINE: gm_read_ent_na
; ** SUBROUTINE: gm_read_tile
; ** SUBROUTINE: gm_read_ent
; desc: Reads a byte from the tile or entity streams. The _na versions don't
; advance the pointer.
; returns: a - the byte of data read in
; clobbers: x
;gm_read_tile_na:
;	ldx #0
;	lda (arrdheadlo,x)
;	rts

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
	lda (lvlptrlo),y
	tax
	iny
	lda (lvlptrlo),y
	tay
	jsr gm_set_room_ptr
	
	ldy #0

gm_fetch_room_loop:
	lda (roomptrlo),y
	sta roomhdrfirst,y
	iny
	cpy #<(roomhdrlast-roomhdrfirst)
	bne gm_fetch_room_loop
	
	; load tile pointer from room pointer, Y=10
	lda (roomptrlo),y
	tax
	iny
	lda (roomptrlo),y
	iny
	jsr gm_set_tile_head

	; load palette pointer from room pointer
	lda (roomptrlo),y
	tax
	iny
	lda (roomptrlo),y
	iny
	jsr gm_set_pal_head

	; load entity pointer from room pointer
	lda (roomptrlo),y
	tax
	iny
	lda (roomptrlo),y
	iny
	jsr gm_set_ent_head
	rts

; ** SUBROUTINE: gm_on_level_init
; desc: Called on level initialization.
gm_on_level_init:
	; load the player's X coordinate to the pixel coordinates provided,
	; if this is the first level
	lda startpx
	sta player_x
	lda startpy
	sta player_y
	
	lda musicdiff
	beq @dontReloadMusic
	
	ldy #0
	lda (musictable), y
	tax
	iny
	
	lda (musictable), y
	tay
	
	lda #1
	jsr famistudio_init
	
	ldy #2
	lda (musictable), y
	jsr famistudio_music_play
	
@dontReloadMusic:
	rts

; ** SUBROUTINE: gm_set_level
; args: X - level number
; assumes: vblank is off and you're loading a new level
gm_set_level:
	lda musicbank
	pha
	
	ldy level_banks, x
	sty musicbank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank
	
	ldy level_banks2, x
	sty musicbank2
	lda #mmc3bk_prg0
	jsr mmc3_set_bank
	
	txa
	asl
	tax
	
	lda level_table, x
	inx
	ldy level_table, x
	tax
	jsr gm_set_level_ptr
	
	; load the music table
	lda musictable
	pha
	lda musictable+1
	pha
	
	ldy #0
	lda (lvlptrlo), y
	sta musictable
	inc lvlptrlo
	
	lda (lvlptrlo), y
	sta musictable+1
	inc lvlptrlo
	
	; check if any details changed
	lda #0
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
	cmp musicbank
	beq :+
	inc musicdiff

:	; load room 0
	jsr gm_set_room
	
	; load the "environment type" field. This specifies the default bank
	ldy #0
	lda (lvlptrlo), y
	asl
	asl
	clc
	adc #chrb_lvl0           ; The first level's BG bank is #chrb_lvl0.
	sta bg0_bknum
	
	tay
	iny
	iny
	sty bg1_bknum
	
	jsr gm_load_generics
	jmp gm_on_level_init

; ** SUBROUTINE: gm_set_room
; args: Y - room number
; assumes: you're loading a new level
gm_set_room:
	sty currroom
	iny
	iny
	jsr gm_fetch_room
	rts

; ** SUBROUTINE: gm_load_generics
; desc: Loads the generic sprite sheet banks.  The game may animate them later.
gm_load_generics:
	lda #chrb_plrsp0
	sta spr0_bknum
	
	lda #chrb_gensp2
	sta spr1_bknum
	
	lda #chrb_gensp1
	sta spr2_bknum
	
	lda #chrb_anisp0
	sta spr3_bknum
	rts

; ** SUBROUTINE: gm_respawn
; desc: Respawns the player.
gm_respawn:
	lda camera_x_hi
	lsr
	lda camera_x
	ror
	lsr
	lsr
	sta ntwrhead
	
	; perform the slide wipe
	ldy #18
@loop:
	sty transtimer
	
	lda #nc2_clrcol
	ora nmictrl2
	sta nmictrl2
	
	jsr gm_leave_doframe
	
	ldy transtimer
	dey
	bne @loop
	
	; initiate the transition sequence now.
	lda #0
	sta gamectrl
	
	lda #g2_noclrall
	sta gamectrl2
	
	; disable rendering
	lda #0
	sta ppu_mask
	jsr vblank_wait
	
	jsr com_clear_oam
	
	ldy currroom
	jsr gm_set_room
	
	lda #0
	sta musicdiff   ; no difference in music
	
	jmp gm_on_level_init
