; Copyright (C) 2024 iProgramInCpp

; This bank handles the game pause functionality.
.segment "PRG_PAUS"

.define MAX_PAUSE_OPTION 6

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
	
	; load the length of the sprite data
	ldx pauseoption
	ldy pause_option_lengths, x
	sty temp1
	
	; then the offset which will be where the OAM data is manipulated
	ldy pause_option_offsets, x
loop:
	lda #$03             ; selected option will use palette 3
	sta oam_buf, y
	iny
	
	; then modify the X coordinate for the shake soon
	ldx pauseanim
	lda oam_buf, y
	clc
	adc pause_anim_table, x
	sta oam_buf, y
	
	; skip the Y and TILE NUMBER of the next sprite
	iny
	iny
	iny
	
	; do we have any more sprites to modify?
	dec temp1
	bne loop
	
	; ok, now check what buttons the player is pressing
	lda p1_cont
	and #cont_a
	bne maybePressedA
	
	lda p1_cont
	and #cont_up
	bne maybePressedUp
	
	lda p1_cont
	and #cont_down
	bne maybePressedDown
	
return:
	ldx pauseanim
	beq :+
	dex
:	stx pauseanim
	rts

maybePressedUp:
	lda p1_conto
	and #cont_up
	bne return
	
	ldx pauseoption
	dex
	bpl :+
	ldx #MAX_PAUSE_OPTION-1
:	stx pauseoption
	ldx #16
	stx pauseanim
	rts

maybePressedDown:
	lda p1_conto
	and #cont_down
	bne return
	
	ldx pauseoption
	inx
	cpx #MAX_PAUSE_OPTION
	bcc :+
	ldx #0
:	stx pauseoption
	ldx #16
	stx pauseanim
	rts

maybePressedA:
	lda p1_conto
	and #cont_a
	bne return
	
	ldx pauseoption
	beq pressedResume
	cpx #1
	beq pressedRetry
	cpx #2
	beq pressedSaveAndQuit
	cpx #3
	beq pressedOptions
	cpx #4
	beq pressedRestartChapter
	cpx #5
	beq pressedReturnToMap
	rts

pressedResume:
	jsr com_clear_oam ; actually undo everything we just did
	jmp gm_unpause

pressedRetry:
	jsr com_clear_oam ; actually undo everything we just did
	jsr gm_unpause
	jmp gm_killplayer

pressedSaveAndQuit:
	jmp gm_whoosh_sfx
pressedOptions:
	jmp gm_spring_sfx
pressedRestartChapter:
	jmp gm_bird_caw_sfx
	
pressedReturnToMap:
	lda #2
	sta exitmaptimer
	lda gamectrl2
	ora #g2_exitlvl
	sta gamectrl2
	jmp pressedResume
.endproc

; offsets for the ATTRIBUTES and X COORDINATE bytes
pause_option_offsets:
	.byte 2+24  ; RESUME
	.byte 2+44  ; RETRY
	.byte 2+60  ; SAVE AND QUIT
	.byte 2+92  ; OPTIONS
	.byte 2+108 ; RESTART CHAPTER
	.byte 2+140 ; RETURN TO MAP

; amount of sprites to modify
pause_option_lengths:
	.byte 5, 4, 8, 4, 8, 8

; animation table (stored in reverse order)
pause_anim_table:
	.byte 0,0,1,1,0,0,255,255,255,254,254,255,0,1,2,3,3

pause_data:
	; Y, tileNumber, attribute, X
	
	; "PAUSED" text
	.byte  40, $01, $01, $60
	.byte  40, $03, $01, $6B
	.byte  40, $05, $01, $76
	.byte  40, $07, $01, $81
	.byte  40, $09, $01, $8C
	.byte  40, $0B, $01, $98
	
	; resume button - 24
	.byte  80, $21, $02, $6C
	.byte  80, $23, $02, $74
	.byte  80, $25, $02, $7C
	.byte  80, $27, $02, $84
	.byte  80, $29, $02, $8C
	
	; retry button - 44
	.byte  96, $19, $02, $70
	.byte  96, $1B, $02, $78
	.byte  96, $1D, $02, $80
	.byte  96, $1F, $02, $88
	
	; save and quit button - 60
	.byte 112, $2B, $02, $60
	.byte 112, $2D, $02, $68
	.byte 112, $2F, $02, $70
	.byte 112, $31, $02, $78
	.byte 112, $33, $02, $80
	.byte 112, $35, $02, $88
	.byte 112, $37, $02, $90
	.byte 112, $39, $02, $98
	
	; options button - 92
	.byte 128, $51, $02, $70
	.byte 128, $53, $02, $78
	.byte 128, $55, $02, $80
	.byte 128, $57, $02, $88
	
	; restart chapter - 108
	.byte 160, $41, $02, $60
	.byte 160, $43, $02, $68
	.byte 160, $45, $02, $70
	.byte 160, $47, $02, $78
	.byte 160, $49, $02, $80
	.byte 160, $4B, $02, $88
	.byte 160, $4D, $02, $90
	.byte 160, $4F, $02, $98
	
	; return to map - 140
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

; I know it sounds absurd, but there's very little actually here, we have basically like 7K free, so why not
.include "s_entity.asm"
.include "s_pldraw.asm"
.include "s_bgfx.asm"

; It sounds even more absurd to include a LEVEL SPECIFIC piece of code here, but I don't want to change to 256K PRG.
; TODO: Move this back to level2 specific banks after the first demo.
.include "level2/chaser.asm"
