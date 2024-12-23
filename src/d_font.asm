; Copyright (C) 2024 iProgramInCpp

;  This code belongs in the PRG_DIAL segment

dlg_font_data:
	; note: this is NOT CHR data for the NES PPU.  This is a 1BPP bitmap.
	; this array is 1KB in size.
	;
	; the first character index, $00, maps to ASCII $20
	.incbin "d_font.chr"
	;.incbin "d_fontv2.chr"

.include "d_fontw.asm"
;.include "d_fontw2.asm"

; ** SUBROUTINE: dlg_fetch_strip
; desc: Fetches an 8-bit character strip.
; arguments:
;     A - The ASCII code of the character.
;     Y - The Y of the strip to fetch.
dlg_fetch_strip:
	; turn it into a valid index
	sec
	sbc #$20   ; (for example, $20 + $60 == $80)
	and #$7F   ; cap it to 0-128
	
	pha
	
	lda #<dlg_font_data
	sta temp1
	lda #>dlg_font_data
	sta temp1+1
	
	pla
	pha
	
	; get the value to add to the high byte.
	rol
	rol
	rol
	rol
	and #%00000111
	clc
	adc temp1+1
	sta temp1+1
	
	; get the value to add to the low byte
	pla
	asl
	asl
	asl
	clc
	adc temp1
	sta temp1
	
	bcc :+
	inc temp2
	
:	; ok, now just fetch and return
	lda (temp1), y
	rts

dlg_strip_mask:
	; note: bits are stored in reverse order from how they look on screen.
	; note: to get the high bit, just EOR this with $FF
	; note: these are the bits to *keep*, not to *delete*.
	.byte %00000000
	.byte %00000001
	.byte %00000011
	.byte %00000111
	.byte %00001111
	.byte %00011111
	.byte %00111111
	.byte %01111111

dlg_bitmask:
	.byte 1,2,4

; ** SUBROUTINE: dlg_draw_strip
; desc: Draws a strip of 8 bits at an arbitrary X/Y coordinate.
; arguments:
;      A - the strip to write
;      X - the X coordinate [0,255]
;      Y - the Y coordinate [0,23]
; clobbers: temp1, temp2, temp3, temp4
dlg_draw_strip:
	sta temp4
	tya
	pha
	
	; calculate the position where we need to write this stuff
	lda #<dlg_bitmap
	sta temp1
	lda #>dlg_bitmap
	sta temp1+1
	
	; add the Y coordinate on top
	; 000yyyyy -> 000000yy yyy00000
	tya
	
	; first, the high byte
	lsr
	lsr
	lsr
	;and #%00000011
	clc
	adc temp1+1
	sta temp1+1
	
	; then the low byte
	tya
	ror
	ror
	ror
	ror
	
	and #%11100000
	clc
	adc temp1
	sta temp1
	
	bcc :+
	inc temp1+1
	
:	; now add the X coordinate (xxxxxXXX)
	; where "x" denotes the tile index, and "X" denotes the fine X
	txa
	lsr
	lsr
	lsr
	ora temp1
	sta temp1
	
	; OK!! now, [temp2, temp1] stores the address of the current strip to modify.
	; compute fine X now
	txa
	and #%00000111
	tax
	
	; mask out the 8 bits based on the fine X
	ldy #0
	lda (temp1), y
	and dlg_strip_mask, x
	sta (temp1), y
	
	; TODO: can (((temp1[1] ^ $FF) & dlg_strip_mask[x]) ^ $FF) work??
	iny
	lda dlg_strip_mask, x
	eor #$FF
	sta temp3
	
	lda (temp1), y
	and temp3
	sta (temp1), y
	
	lda #0
	sta temp3
	
	; temp4 holds the strip to write
	; but first, put the fine X (amount to shift) on the Y register
	txa
	tay
	beq @noShift
	
	; ok, now shift it that many times
@shiftLoop:
	asl temp4
	rol temp3
	dey
	bne @shiftLoop

@noShift:
	; now OR it!
	ldy #0
	lda (temp1), y
	ora temp4
	sta (temp1), y
	
	iny
	lda (temp1), y
	ora temp3
	sta (temp1), y
	
	pla ; pull the coarse+fine Y
	lsr
	lsr
	lsr ; get the row #
	tay
	
	lda dlg_bitmask, y
	ora dlg_updates
	sta dlg_updates
	
	; mark this and the next column for update
	; TODO: add them only in dlg_draw_char!!
	lda temp1
	and #%00011111
	pha
	tax
	jsr @addUpdate
	
	pla
	tax
	inx
	jsr @addUpdate
	
	lda #nc2_dlgupd
	ora nmictrl2
	sta nmictrl2
	
	; done!!
	rts

; ** SUBROUTINE: dlg_draw_char::@addUpdate
; desc: Adds a single column to an update array.
; arguments:
;     X - The column to add.
;     Y - The row onto which to add the update.
@addUpdate:
	lda @addUpdateTableLo, y
	sta temp2
	lda @addUpdateTableHi, y
	sta temp2+1
	jmp (temp2)

; gosh why
@addUpdateTableLo:
	.byte <@addUpdateRow0
	.byte <@addUpdateRow1
	.byte <@addUpdateRow2
@addUpdateTableHi:
	.byte >@addUpdateRow0
	.byte >@addUpdateRow1
	.byte >@addUpdateRow2
	
@addUpdateRow0:
	txa
	ldx dlg_updc1
	beq @registerR0
	ldx #0
@loopR0:
	cmp dlg_upds1, x
	beq @returnR     ; if the column is already registered for update, then return
	inx
	cpx dlg_updc1
	bne @loopR0
	
	; not registered, so do it now
@registerR0:
	ldx dlg_updc1
	sta dlg_upds1, x
	inx
	stx dlg_updc1
@returnR:
	rts
	
@addUpdateRow1:
	txa
	ldx dlg_updc2
	beq @registerR1
	ldx #0
@loopR1:
	cmp dlg_upds2, x
	beq @returnR     ; if the column is already registered for update, then return
	inx
	cpx dlg_updc2
	bne @loopR1
	
	; not registered, so do it now
@registerR1:
	ldx dlg_updc2
	sta dlg_upds2, x
	inx
	stx dlg_updc2
	rts
	
@addUpdateRow2:
	txa
	ldx dlg_updc3
	beq @registerR2
	ldx #0
@loopR2:
	cmp dlg_upds3, x
	beq @returnR     ; if the column is already registered for update, then return
	inx
	cpx dlg_updc3
	bne @loopR2
	
	; not registered, so do it now
@registerR2:
	ldx dlg_updc3
	sta dlg_upds3, x
	inx
	stx dlg_updc3
	rts

; ** SUBROUTINE: dlg_draw_char
; desc: Draws a single character to the screen buffer reserved for dialog.
; arguments:
;     A - the character index
;     X - the X of the character
;     Y - the Y of the character (either 0, 8, or 16)
; clobbers: temp1-4 [dlg_draw_char], temp5, temp6, temp7, temp8
dlg_draw_char:
	; temp5 - the character index
	; temp6 - the current fine Y
	; temp7 - the coarse Y
	; temp8 - the X coord
	sta temp5
	sty temp7
	stx temp8
	
	tya
	and #%11111000
	sta temp6
	
	; load fine Y and fetch the character strip
	ldy #0
@loop:
	sty temp6
	lda temp5
	jsr dlg_fetch_strip
	
	pha                ; push the strip
	lda temp7          ; calculate fineY from coarseY and loop's iterator
	clc
	adc temp6
	tay
	pla                ; restore the strip
	ldx temp8
	jsr dlg_draw_strip ; and draw it!
	
	ldy temp6
	iny
	cpy #8
	bne @loop
	
	rts
