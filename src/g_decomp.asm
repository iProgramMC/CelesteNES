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

; adds a value (constant or from memory) to 16-bit "thing"
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
	
	jsr load_screen
	
	lda #<(areaextra+960*2)
	sta lvladdr
	lda #>(areaextra+960*2)
	sta lvladdr+1
	
	jsr load_screen
	
	; TODO: palette data, etc.
	
	lda #0
	sta roomcurrcol
	sta roomreadidx
	sta roomreadidx+1
	
	rts

load_screen:
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
	; jmp gm_gener_tiles_horiz
.endproc

; desc: Generates a row of tiles on the scroll seam.
.proc gm_gener_tiles_horiz_NEW
	
	
	rts
.endproc
