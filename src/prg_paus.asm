; Copyright (C) 2024 iProgramInCpp

; This bank handles the game pause functionality.
.segment "PRG_PAUS"

.proc pause_update
	; Note: For speed, we will **not** use oam_putsprite.  Instead,
	; we will push the data pre-made into OAM RAM, and then modify
	; that.
	lda nmictrl
	and #nc_flushrow
	bne dontPreparePalette
	
	ldy #0
palettePrepLoop:
	lda (paladdr), y
	jsr fade_once_color
	sta temprow1,  y
	iny
	cpy #16
	bne palettePrepLoop
	
	; set that bit
	lda #$3F
	sta ppuaddrHR1+1
	lda #$00
	sta ppuaddrHR1
	lda #$10
	sta wrcountHR1
	lda #$00
	sta wrcountHR2
	sta wrcountHR3
	
	lda nmictrl
	ora #nc_flushrow
	sta nmictrl
	
dontPreparePalette:
	ldy #0
copyLoop:
	lda pause_data, y
	sta oam_buf,    y
	
	iny
	cpy #pause_copy_max
	bne copyLoop
	
	; manipulate that data here
	
	rts
.endproc

pause_data:
	; Y, tileNumber, attribute, X
	.byte 40, $01, $01, $60
	.byte 40, $03, $01, $68
	.byte 40, $05, $01, $70
	.byte 40, $07, $01, $78
	.byte 40, $09, $01, $80
	.byte 40, $0B, $01, $88
	.byte 40, $0D, $01, $90
	.byte 40, $0F, $01, $98




pause_data_end:

pause_copy_max = pause_data_end - pause_data
