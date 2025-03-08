; Copyright (C) 2025 iProgramInCpp

; This belongs in the PRG_XTRA bank.  It deals with outputting the
; postcard and level end graphics.

; ** SUBROUTINE: nexxt_rle_decompress_XTRA
; desc: Decompresses the NEXXT RLE format.
; assumes: rendering is disabled
; NOTE: EXACT copy of src/title/rle.asm! Must be synched at all times!
; parameters:
;    X - high byte of data
;    A - low  byte of data
.proc nexxt_rle_decompress_XTRA
_RLE_LOW  = temp1
_RLE_HIGH = temp2
_RLE_TAG  = temp3
_RLE_BYTE = temp4

	; Set up
	tay
	stx <_RLE_HIGH
	lda #0
	sta <_RLE_LOW
	; Read byte that does not appear in data, used to signal a run
	lda (_RLE_LOW),y
	sta <_RLE_TAG
	iny
	bne @tag_nowrap
		inc <_RLE_HIGH
	@tag_nowrap:
@decodeloop:
	; Read a byte from the stream
	lda (_RLE_LOW),y
	iny
	bne @main_nowrap
		inc <_RLE_HIGH
	@main_nowrap:
	; If it doesn't match the run marker, output it
	cmp <_RLE_TAG
	beq @is_rle
	@is_literal:
		sta ppu_data
		sta <_RLE_BYTE
		bne @decodeloop
	@is_rle:
	; We just saw a run marker.	Load the length, stopping if zero
	lda (_RLE_LOW),y
	beq @done
	iny
	bne @len_nowrap
		inc <_RLE_HIGH
	@len_nowrap:
	; The run marker followed by $01 means itself
	cmp #$01
	bcs @is_run
		lda <_RLE_TAG
		bcc @is_literal
	@is_run:
	tax	; X = length of run
	; Output the most recent byte X times
	lda <_RLE_BYTE
	@runloop:
		sta ppu_data
		dex
		bne @runloop
	beq @decodeloop
@done:
	rts
.endproc

