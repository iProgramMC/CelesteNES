; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_gener_tiles_horiz_FAR
; desc: Generates tiles at the scroll seam.
;       This is the PRG_XTRA part of the function gm_gener_tiles_below.
gm_gener_tiles_horiz_FAR:
	; temp1 has the row to load.
	
	; outlined because we need access to level data bank
	jsr xt_read_row
	
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
	
	; outlined because we need access to level data bank
	jsr __xt_convert_metatiles
	
	lda #nc_flushrow
	ora nmictrl
	sta nmictrl
	
	lda roomflags
	and #rf_goup
	bne @goingUp
	
	lda temp1
	and #1
	beq @uploadPaletteDataBelow
	rts

@goingUp:
	lda temp1
	and #1
	bne @uploadPaletteDataBelow
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
	jsr __xt_read_palette_data_below
	
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
