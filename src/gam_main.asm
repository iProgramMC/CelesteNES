; Copyright (C) 2024 iProgramInCpp

; Desc: If you put these functions in the game segment, it will overflow.
; These functions are instead implemented in the main segment.
.include "e_physic.asm"

; ** SUBROUTINE: gm_scroll_d_cond
gm_scroll_d_cond:
	lda #gs_camlock
	bit gamectrl
	bne @scrollRet
	
	lda #rf_godown
	bit roomflags
	beq @scrollRet
	
	lda player_y
	sec
	sbc camera_y_sub
	bcc @scrollRet
	
	cmp #vscrolllimit
	bcc @scrollRet
	beq @scrollRet
	
	sec
	sbc #vscrolllimit
	cmp #camspeed
	bcc @noFix
	lda #camspeed
@noFix:
	
	sta temp1          ; store the difference here as we'll need it later
	
	; add it to the camera Y sub coord
	lda camera_y_sub
	clc
	adc temp1
	sta camera_y_sub
	
	; if it's still below, then that's fine. just return
	cmp #8
	bcc @scrollRet
	
	; nope, pull it back in the 0-7 range, increment camera_y by 8,
	; and all our other shenanigans.
	lda camera_y_sub
	sec
	sbc #8
	sta camera_y_sub
	
	lda camera_y
	clc
	adc #8
	cmp #240
	bcc :+
	adc #15       ; carry set, so actually adds 16
:	sta camera_y
	
	; move player up
	lda player_y
	sec
	sbc #8
	sta player_y
	
	; move all entities up
	ldy #0
@entShiftLoop:
	lda sprspace+sp_y, y
	sec
	sbc #8
	bcs :+      ; if it didn't go below zero, don't clear
	lda #0
	sta sprspace+sp_kind, y
:	sta sprspace+sp_y, y
	iny
	cpy #sp_max
	bne @entShiftLoop
	
	; load a new set of tiles
	jsr gm_gener_tiles_below
	
@scrollRet:
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

; ** SUBROUTINE: gm_gener_tiles_below
; desc: Generates tiles below the scroll seam.
gm_gener_tiles_below:
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
	beq :+
	jsr gm_upload_palette_data_below
:	rts

gm_upload_palette_data_below:
	rts

; ** SUBROUTINE: gm_load_level_if_vert
; desc: Loads more of the horizontal level segment, if in vertical mode.
gm_load_level_if_vert:
	lda #(g3_transitA)
	bit gamectrl3
	bne @return      ; if there are transitions going on, then return
	
	lda #(rf_godown | rf_goup)
	bit roomflags
	beq @return      ; if level is horizontal, then return
	
	lda #gs_lvlend
	bit gamectrl
	bne @return      ; if level is over, then return
	
	jmp h_gener_col_r

@return:
	rts

