; Copyright (C) 2025 iProgramInCpp

; This is the second part to g_decomp.asm.

; ** SUBROUTINE: gm_gen_pal_col_NEW
; desc: Generates a column of palettes, stores it in temppal, then
;       returns back to a label inside of h_palette_data_column.
;
; note: this is NOT called using jsr!
.proc gm_gen_pal_col_NEW
	lda #$FF
	sta nitrantmp
	lda ntwrhead
	and #%11111100
	sec
	sbc roombeglo2
	pha               ; OK SO we need to actually push here
	and #%00011111    ; we'll want to reuse this amount to determine
	lsr               ; which nametable this is actually a part of (important)
	lsr
	clc
	adc #<areapal4X4
	sta temp1
	lda #>areapal4X4
	adc #0
	sta temp1+1
	
	lda #rf_inverted
	bit roomflags
	beq dontAdd128
	
	; new + inverted. are we transitioning down? that is a special case.
	lda gamectrl3
	and #g3_transitD
	beq justAdd128
	
	; we'll add 128 later. for now, calculate the threshold at which we need to
	lda #60
	sec
	sbc roomheight
	; since this in tiles we need to turn it into palette clusters
	lsr
	lsr
	sta nitrantmp
	
justAdd128:
	add_16 temp1, #128
	
dontAdd128:
	pla
	and #%00100000
	beq dontAdd64
	
	; add 64
	add_16 temp1, #64
	
dontAdd64:
	ldx #0
	ldy #0
loop:
	lda (temp1),  y
	sta temppal,  x
	add_16 temp1, #8
	inx
	cpx nitrantmp
	bne skipAdding128
	sub_16 temp1, #128
skipAdding128:
	cpx #8
	bne loop
	
	jmp h_palette_finish
.endproc

; ** SUBROUTINE: get_player_y_for_warp
; desc: Gets the player's Y position used for warp checking.
.proc get_player_y_for_warp
	lda roomflags
	and #rf_new
	beq @justReturnTheY
	
	lda roomflags
	and #rf_inverted
	beq @notInverted
	
	; we are inverted, so if the camera Y high is 1, then treat player_y as is
	lda camera_y_hi
	bne @justReturnTheY
	beq @calculateFromCameraY
	
@notInverted:
	; we aren't inverted, so if the camera Y high is zero, then treat player_y as is
	lda camera_y_hi
	beq @justReturnTheY
	
@calculateFromCameraY:
	lda camera_y
	clc
	adc player_y
	; if it DID NOT overflow or go above 240, then we're above the trigger line
	bcc @returnZero
	cmp #240
	bcc @returnZero
	
	; return this Y but add 16 because we went past a screen boundary
	adc #15 ; +1 because carry set
	rts

@justReturnTheY:
	lda player_y
	rts

@returnZero:
	lda #0
	rts

@return255:
	lda #255
	rts
.endproc
