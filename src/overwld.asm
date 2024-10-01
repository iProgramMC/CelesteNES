; Copyright (C) 2024 iProgramInCpp

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
	ldy init_palette - lastpage
	jsr load_palette
	lda #$20
	jsr clear_nt
	
	jsr print_logo   ; print the logo and the "PRESS BUTTON" text
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