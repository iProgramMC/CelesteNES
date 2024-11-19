; Copyright (C) 2024 iProgramInCpp

; increments 16-bit "thing" by 1
.macro increment_16 thing
.scope
	inc thing
	bne noCarry
	inc thing+1
noCarry:
.endscope
.endmacro

; adds an 8-bit value (constant or from memory) to 16-bit "thing"
.macro add_16 thing, value
.scope
	lda thing
	clc
	adc value
	sta thing
	bcc noCarry
	inc thing+1
noCarry:
.endscope
.endmacro

; adds a 16-bit value (constant) to 16-bit "thing"
.macro add_16_16 thing, constant
	lda #<(constant)
	clc
	adc thing
	sta thing
	lda #>(constant)
	adc thing+1
	sta thing+1
.endmacro

; adds the content of A to 16-bit "thing"
.macro add_16_a thing
.scope
	clc
	adc thing
	sta thing
	bcc noCarry
	inc thing+1
noCarry:
.endscope
.endmacro

; ** FORMAT DESCRIPTION
;
; The NEW level format is formatted like this
;
;	.byte WIDTH, HEIGHT
;
;   ; First row of screens
;	.byte $XX, $XX, ..., $XX  -- Column (may be compressed)
;   ...
;   .byte $XX, $XX, ..., $XX  -- Column (there are WIDTH columns)
;
;   ; Second row of screens
;   .byte $XX, $XX, ..., $XX  -- Column (may be terminated by $FF which says "End Early")
;   ...
;   
;

.proc gm_de_load_screen
	; OK, now start writing.  This is the FIRST row of screens.
	ldx #0
loopX:
	; load a column
	ldy #0
loopY:
	lda (arrdheadlo), y
	cmp #$FF                 ; End Early
	beq endedLoopYEarly
	sta (lvladdr), y
	iny
	cpy #30
	bne loopY
	
	; move on to the next column
endedLoopYEarly:
	tya
	add_16_a arrdheadlo
	add_16   lvladdr, #30
	
	inx
	cpx roomwidth
	bne loopX
	rts
.endproc

; ** SUBROUTINE: gm_de_convert_palette_data
; parameters:
;    [temp2, temp1] - address of screen_1
;    [temp4, temp3] - address of screen_2
; clobbers:
;    temp5, temp6
.proc gm_de_convert_palette_data
_index = temp5
	ldx #0   ; _index
	
loopI:
	stx _index
	
	ldx #0    ; used in the loops as a zero register, always
	ldy #0
loopJ_s1lo:
	; read palette data
	lda (palrdheadlo, x)
	sta temp6
	
	add_16 palrdheadlo, #1
	
	; screen_1[i+j+0]
	lda temp6
	and #%00001111
	ora (temp1), y
	sta (temp1), y
	
	; screen_1[i+j+1]
	lda temp6
	lsr
	lsr
	lsr
	lsr
	iny
	ora (temp1), y
	sta (temp1), y
	
	iny
	cpy #8
	bne loopJ_s1lo
	
	add_16 temp1, #8
	
	ldy #0
loopJ_s2lo:
	lda (palrdheadlo, x)
	sta temp6
	
	add_16 palrdheadlo, #1
	
	; screen_2[i+j+0]
	lda temp6
	and #%00001111
	ora (temp3), y
	sta (temp3), y
	
	; screen_2[i+j+1]
	lda temp6
	lsr
	lsr
	lsr
	lsr
	iny
	ora (temp1), y
	sta (temp1), y
	
	iny
	cpy #8
	bne loopJ_s2lo
	
	add_16 temp3, #8
	
	; check if I is 56
	lda _index
	cmp #56
	beq dontProcess
	
	; i is not 56, also process the high part
loopJ_s1hi:
	lda (palrdheadlo, x)
	sta temp6
	
	add_16 palrdheadlo, #1
	
	; screen_1[i+j+0]
	lda temp6
	asl
	asl
	asl
	asl
	ora (temp1), y
	sta (temp1), y
	
	; screen_1[i+j+1]
	lda temp6
	and #%11110000
	iny
	ora (temp1), y
	sta (temp1), y
	
	iny
	cpy #8
	bne loopJ_s1hi
	
	add_16 temp1, #8
	
	ldy #0
loopJ_s2hi:
	lda (palrdheadlo, x)
	sta temp6
	
	add_16 palrdheadlo, #1
	
	; screen_2[i+j+0]
	lda temp6
	asl
	asl
	asl
	asl
	ora (temp3), y
	sta (temp3), y
	
	; screen_1[i+j+1]
	lda temp6
	and #%11110000
	iny
	ora (temp3), y
	sta (temp3), y
	
	iny
	cpy #8
	bne loopJ_s2hi
	
	add_16 temp3, #8
	
	; sigh, finally done
	lda _index
dontProcess:
	clc
	adc #8
	tax
	cpx #64
	beq :+
	jmp loopI
:	rts
.endproc

.proc gm_de_read_palette_data
	; TODO: Read all 256 bytes for now
	; note: perhaps there may be less, but reads would spill only into tile data so they'd be fine
	ldy #0
loop:
	jsr gm_read_pal
	sta areapal8X2, y
	lda #0
	sta areapal4X4, y
	iny
	bne loop
	
	; convert palette data from 8X2 to 4X4
	
	; first nametable row
	
	; prepare addresses
	lda #<(areapal4X4+0)
	sta temp1
	lda #>(areapal4X4+0)
	sta temp2
	
	lda #<(areapal4X4+64)
	sta temp3
	lda #>(areapal4X4+64)
	sta temp4
	
	;jsr gm_de_convert_palette_data
	
	; prepare addresses
	lda #<(areapal4X4+128)
	sta temp1
	lda #>(areapal4X4+128)
	sta temp2
	
	lda #<(areapal4X4+192)
	sta temp3
	lda #>(areapal4X4+192)
	sta temp4
	
	;jmp gm_de_convert_palette_data
	rts
.endproc

; ** SUBROUTINE: gm_decompress_level
; desc: Completely decompresses a level.
.proc gm_decompress_level
	
	; Read room width and height.
	jsr gm_read_tile
	sta roomwidth
	jsr gm_read_tile
	sta roomheight
	
	; Start loading the first screen
	lda #<areaextra
	sta lvladdr
	lda #>areaextra
	sta lvladdr+1
	
	jsr gm_de_load_screen
	
	lda #<(areaextra+960*2)
	sta lvladdr
	lda #>(areaextra+960*2)
	sta lvladdr+1
	
	jsr gm_de_load_screen
	
	jsr gm_de_read_palette_data
	
	; TODO: palette data, etc.
	
	lda #0
	sta roomcurrcol
	sta roomreadidx
	sta roomreadidx+1
	sta camera_y_hi   ; might want to set it to 1 if the room grows *up*
	
	rts
.endproc

; ** SUBROUTINE: h_gener_mts_NEW_r
; desc: Generates a column of metatiles from areaextra.  Called by h_gener_mts_r.
.proc h_gener_mts_NEW_r
	lda roomcurrcol
	cmp roomwidth
	bcs dataEnd
	
	; Generate metatiles from areaextra.
	; Currently, this is ONLY the first row of nametables.
	
	; called by h_gener_mts_r who called us
	;ldx arwrhead
	;jsr h_comp_addr       ; compute the address in (lvladdr)
	
	lda #<areaextra
	sta temp1
	lda #>areaextra
	sta temp1+1
	
	lda temp1
	clc
	adc roomreadidx
	sta temp1
	lda temp1+1
	adc roomreadidx+1
	sta temp1+1
	
	ldy #0
loop:
	lda (temp1), y
	sta (lvladdr), y
	iny
	cpy #30
	bne loop

finally:
	add_16 roomreadidx, #30
	inc roomcurrcol
	
	lda #0
	sta (lvladdr), y
	iny
	sta (lvladdr), y
	
	jmp h_genertiles_inc_arwrhead

dataEnd:
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
	lda #(gs_scrstopR | gs_lvlend)
	ora gamectrl
	sta gamectrl
	lda arwrhead
	sta trarwrhead
	jmp finally
.endproc

; desc: Generates a row of tiles below the scroll seam.
.proc gm_gener_tiles_below_NEW
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
	ldx #1
	jmp gm_gener_tiles_horiz_NEW
.endproc

; desc: Generates a row of tiles above the scroll seam.
.proc gm_gener_tiles_above_NEW
	lda camera_y
	lsr
	lsr
	lsr
	; take the one *below* camera_y
	clc
	adc #1
	cmp #30
	bne :+
	lda #0
:	sta temp1
	ldx #0
	; jmp gm_gener_tiles_horiz
.endproc

; desc: Generates a row of tiles on the scroll seam.
.proc gm_gener_tiles_horiz_NEW
	; read a row
	lda #<areaextra
	sta temp2
	lda #>areaextra
	sta temp2+1
	
	; X is either 0 or 1. 0 if scrolling up, 1 if scrolling down.
	; This pretty much always tells us which nametable we need.
	txa
	beq dontUseSecondRow
	add_16_16 temp2, (960*2)
	
dontUseSecondRow:
	ldx roombeglo2
	jsr h_comp_addr
	
	ldy temp1
	ldx #0
loop:
	lda (temp2),    y
	sta (lvladdr),  y
	sta temprowtot, x
	
	; increment the column index
	add_16 temp2,   #30
	add_16 lvladdr, #32
	
	; of course, we need to mask out any potential increases beyond areaspace
	; lvladdr is formed of the following bits: 0100 0xxx xxxy yyyy
	lda lvladdr+1
	and #%11110111
	sta lvladdr+1
	
	inx
	cpx roomwidth
	bne loop
	
	jmp gm_gener_tiles_horiz_row_read
.endproc
