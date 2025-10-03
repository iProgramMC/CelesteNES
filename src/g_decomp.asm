; Copyright (C) 2024 iProgramInCpp

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
	stx temp8
	; load a column
	ldy #0
loopY:
	; Now that the index into arrdheadlo doesn't necessarily match
	; the actual Y row coord, we have to do this crap.
	jsr readByte
	
	bpl normalTile           ; special bytes start at 0xA0, so anything below 0x80 must be normal
	
	cmp #$FF                 ; End Early
	beq endedLoopYEarly
	
	cmp #$81
	bcc notVerbatimRepeat
	cmp #$9F
	bcc verbatimRepeat
	
notVerbatimRepeat:
	cmp #$A1
	bcc notAirRepeat
	cmp #$BF
	bcc airRepeat            ; A0-BE

notAirRepeat:
	cmp #$C1
	bcc notTileRepeat
	cmp #$DF
	bcc tileRepeat           ; C0-DE

notTileRepeat:
	cmp #$E1
	bcc normalTile
	cmp #$FF
	bcc columnRepeat         ; E0-FE
	
normalTile:
	jsr h_tile_tform
	sta (lvladdr),  y
	sta lastcolumn, y
	iny
doneWithThisByte:
	cpy #30
	bcc loopY
	
	; move on to the next column
endedLoopYEarly:
	add_16 lvladdr, #30
	
	ldx temp8
	inx
	cpx roomwidth
	bne loopX
	rts

airRepeat:
	sec
	sbc #$A0
	tax
	lda #0
airRepeatLoop:
	sta (lvladdr),  y
	sta lastcolumn, y
	iny
	dex
	bne airRepeatLoop
	beq doneWithThisByte

verbatimRepeat:
	sec
	sbc #$80
	sta temp10
verbatimRepeatLoop:
	jsr h_read_tile_tform
	sta (lvladdr),  y
	sta lastcolumn, y
	iny
	dec temp10
	bne verbatimRepeatLoop
	beq doneWithThisByte

tileRepeat:
	sec
	sbc #$C0
	sta temp10   ; store the count in temp10
	jsr h_read_tile_tform ; read byte (clobbers X)
	ldx temp10   ; unclobber X
	jmp airRepeatLoop ; it just places the tile index in A, so fine

columnRepeat:
	sec
	sbc #$E0
	tax
	lda #0
columnRepeatLoop:
	lda lastcolumn, y
	sta (lvladdr),  y
	iny
	dex
	bne columnRepeatLoop
	beq doneWithThisByte

readByte:
	ldx #0
	lda (arrdheadlo, x)
	tax
	increment_16 arrdheadlo
	txa
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
	
	increment_16 palrdheadlo
	
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
	
	increment_16 palrdheadlo
	
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
	ora (temp3), y
	sta (temp3), y
	
	iny
	cpy #8
	bne loopJ_s2lo
	
	add_16 temp3, #8
	
	; check if I is 56
	lda _index
	cmp #56
	bne alsoProcessHighHalf
	
	; sigh, finally done
doneProcessing:
	lda _index
	clc
	adc #8
	tax
	cpx #64
	beq :+
	jmp loopI
:	rts

alsoProcessHighHalf:
	; i is not 56, also process the high part
	; subtract 8 from temp1 and temp3, they'll be back here after
	sub_16 temp1, #8
	sub_16 temp3, #8
	
	ldy #0
loopJ_s1hi:
	lda (palrdheadlo, x)
	sta temp6
	
	increment_16 palrdheadlo
	
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
	
	increment_16 palrdheadlo
	
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
	jmp doneProcessing 
.endproc

.proc gm_de_read_palette_data
	; calculate the roomwidth>>3, into temp1
	; it'll be compared later
	lda roomwidth
	lsr
	lsr
	lsr
	sta temp1
	
	ldy #0
	lda #0
loop3:
	sta areapal4X4, y
	sta areapal8X2, y
	iny
	bne loop3
	
loop2:
	dey
	ldx #0
loop:
	iny
	stx temp2
	jsr gm_read_pal
	sta areapal8X2, y
	ldx temp2
	inx
	cpx temp1
	bne loop
	
	; reached the end of a loop, increment Y until a multiple of 8
loopsub:
	iny
	tya
	and #%00000111
	bne loopsub    ; not a multiple of 8
	tya
	bne loop2      ; reached a non-zero multiple of 16 (256 would be overflow)
	
	; convert palette data from 8X2 to 4X4
	
	; reload palrdhead
	lda #<areapal8X2
	sta palrdheadlo
	lda #>areapal8X2
	sta palrdheadhi
	
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
	
	jsr gm_de_convert_palette_data
	
	; prepare addresses
	lda #<(areapal4X4+128)
	sta temp1
	lda #>(areapal4X4+128)
	sta temp2
	
	lda #<(areapal4X4+192)
	sta temp3
	lda #>(areapal4X4+192)
	sta temp4
	
	jmp gm_de_convert_palette_data
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
	
	lda roomflags
	and #rf_inverted
	; rf_inverted == 8
	lsr
	lsr
	lsr
	sta camera_y_hi   ; might want to set it to 1 if the room grows *up*
	
	; calculate cameraYmin and cameraYmax
	lda roomflags
	and #rf_inverted
	beq notInverted
	
	lda #128
	sta camera_y_max
	lda #60
	sec
	sbc roomheight
	sta camera_y_min
	rts
	
notInverted:
	sta camera_y_min
	lda roomheight
	sec
	sbc #30
	cmp #30
	bcc :+
	lda #32
:	asl
	asl
	sta camera_y_max
	rts
.endproc

; ** SUBROUTINE: h_gener_mts_NEW_r
; desc: Generates a column of metatiles from areaextra.  Called by h_gener_mts_r.
.proc h_gener_mts_NEW_r
	lda #$FF
	sta nitrantmp
	lda roomcurrcol
	cmp roomwidth
	bcs dataEnd
	
	; Generate metatiles from areaextra.
	lda #rf_inverted
	bit roomflags
	bne isInverted
	
	lda #<areaextra
	sta temp1
	lda #>areaextra
	sta temp1+1
	
doneInverted:
	lda temp1
	clc
	adc roomreadidx
	sta temp1
	lda temp1+1
	adc roomreadidx+1
	sta temp1+1
	
	ldy #0
loop:
	; if y < nitrantmp, then dataset from temp1, else dataset from temp3.
	; note that this functionality is used only in the special case where
	; we are transitioning downwards into a new + inverted room (one whose
	; primary room is down). in all other cases nitrantmp is #255 so bcs
	; won't ever be triggered
	cpy nitrantmp
	bcc loadFromTemp1
	lda (temp3), y
	bcs loadedAlready
	
loadFromTemp1:
	lda (temp1), y
loadedAlready:
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
	jsr h_genertiles_calc_camlimit
	jmp finally

otherHalfDetour:

isInverted:
	; is inverted, but check if we're transitioning from downward
	lda gamectrl3
	and #g3_transitD
	beq notTransitioningDown

	; transitioning down, so prepare the other data set pointer
	; and threshold to switch to it
	lda #<areaextra
	clc
	adc roomreadidx
	sta temp3
	lda #>areaextra
	adc roomreadidx+1
	sta temp3+1
	
	lda #60
	sec
	sbc roomheight
	sta nitrantmp

notTransitioningDown:
	lda #<(areaextra+960*2)
	sta temp1
	lda #>(areaextra+960*2)
	sta temp1+1
	bne doneInverted ; MUST succeed
	brk $00
.endproc

; desc: Generates a row of tiles below the scroll seam.
.proc gm_gener_tiles_below_NEW
	ldx #1
	jmp gm_gener_tiles_horiz_NEW
.endproc

; desc: Generates a row of tiles above the scroll seam.
.proc gm_gener_tiles_above_NEW
	lda camera_y
	ldx #0
	; jmp gm_gener_tiles_horiz
.endproc

; desc: Generates a row of tiles on the scroll seam.
.proc gm_gener_tiles_horiz_NEW
	stx temp10
	
	; read a row
	lda #<areaextra
	sta temp2
	lda #>areaextra
	sta temp2+1
	
	lda #0
	sta palrdheadhi
	
	ldx #0
	lda plattemp3
	cmp #30
	bcc :+
	sbc #30
	ldx #1
:	sta temp1
	
	; X is either 0 or 1. 0 if scrolling up, 1 if scrolling down.
	; This pretty much always tells us which nametable we need.
	txa
	beq :+
	lda #30
:	clc
	adc temp1
	and #%00111110   ; divide by 2 (temp1 is tile row) and multiply by 2
	asl
	rol palrdheadhi
	asl
	rol palrdheadhi
	
	sta palrdheadlo
	
	lda #<areapal8X2
	clc
	adc palrdheadlo
	sta palrdheadlo
	lda #>areapal8X2
	adc palrdheadhi
	sta palrdheadhi
	
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
