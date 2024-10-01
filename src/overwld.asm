; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: ow_draw_mtn
; desc: Draws a mountain to the screen.
ow_draw_mtn:
	lda #$20
	sta ow_temp1
	lda #$E3
	sta ow_temp2
	
	lda #<MTN_data
	sta ow_temp3
	lda #>MTN_data
	sta ow_temp4
	
	lda #0
	sta ow_temp5
	
:	ldy ow_temp1
	ldx ow_temp2
	jsr ppu_loadaddr
	ldx ow_temp3
	ldy ow_temp4
	lda #26
	jsr ppu_wrstring
	
	clc
	lda ow_temp3
	adc #26
	sta ow_temp3
	lda ow_temp4
	adc #0
	sta ow_temp4
	
	clc
	lda ow_temp2
	adc #$20
	sta ow_temp2
	lda ow_temp1
	adc #0
	sta ow_temp1
	
	clc
	lda ow_temp5
	adc #1
	sta ow_temp5
	
	cmp #20
	bne :-
	
	; finally write palette data
	ldy #$23
	ldx #$C0
	jsr ppu_loadaddr
	ldx #<MTN_attr
	ldy #>MTN_attr
	lda #64
	jsr ppu_wrstring

	rts

; ** GAMEMODE: gamemode_overwd
gamemode_overwd:
	lda #os_1stfr
	bit owldctrl
	bne gamemode_overwd_update
	
	lda #0
	sta camera_x
	sta camera_x_hi
	sta camera_y
	sta ppu_mask     ; disable rendering
	jsr vblank_wait
	ldy #(owld_palette - lastpage)
	jsr load_palette
	lda #$20
	jsr clear_nt
	
	jsr ow_draw_mtn
	jsr tl_init_snow
	jsr ppu_rstaddr
	lda owldctrl
	ora #(os_1stfr | os_turnon)
	sta owldctrl
	lda #bank_owld
	jsr mmc1_selcharbank
	jsr vblank_wait
	
gamemode_overwd_update:
	jsr tl_update_snow
	jsr tl_render_snow
	; TODO
	
	rts