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
	
	lda pauseoption
	bpl dontPreparePalette
	
	ldy #0
	sty pauseoption
palettePrepLoop:
	lda (paladdr), y
	jsr fade_twice_if_high
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
	
	; "PAUSED" text
	.byte  40, $01, $01, $60
	.byte  40, $03, $01, $68
	.byte  40, $05, $01, $70
	.byte  40, $07, $01, $78
	.byte  40, $09, $01, $80
	.byte  40, $0B, $01, $88
	.byte  40, $0D, $01, $90
	.byte  40, $0F, $01, $98
	
	; resume button
	.byte  80, $21, $02, $6C
	.byte  80, $23, $02, $74
	.byte  80, $25, $02, $7C
	.byte  80, $27, $02, $84
	.byte  80, $29, $02, $8C
	
	; retry button
	.byte  96, $19, $02, $70
	.byte  96, $1B, $02, $78
	.byte  96, $1D, $02, $80
	.byte  96, $1F, $02, $88
	
	; save and quit button
	.byte 112, $2B, $02, $60
	.byte 112, $2D, $02, $68
	.byte 112, $2F, $02, $70
	.byte 112, $31, $02, $78
	.byte 112, $33, $02, $80
	.byte 112, $35, $02, $88
	.byte 112, $37, $02, $90
	.byte 112, $39, $02, $98
	
	; options button
	.byte 128, $51, $02, $70
	.byte 128, $53, $02, $78
	.byte 128, $55, $02, $80
	.byte 128, $57, $02, $88
	
	; restart chapter
	.byte 160, $41, $02, $60
	.byte 160, $43, $02, $68
	.byte 160, $45, $02, $70
	.byte 160, $47, $02, $78
	.byte 160, $49, $02, $80
	.byte 160, $4B, $02, $88
	.byte 160, $4D, $02, $90
	.byte 160, $4F, $02, $98
	
	; return to map
	.byte 176, $61, $02, $60
	.byte 176, $63, $02, $68
	.byte 176, $65, $02, $70
	.byte 176, $67, $02, $78
	.byte 176, $69, $02, $80
	.byte 176, $6B, $02, $88
	.byte 176, $6D, $02, $90
	.byte 176, $6F, $02, $98


pause_data_end:

pause_copy_max = pause_data_end - pause_data
