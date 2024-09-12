
; ** SUBROUTINE: h_get_tile
; desc:    Gets the value of a tile in loaded areaspace for the horizontal layout
;          (equivalent of the C code "areaspace[y * 32 + x]")
; arguments:
;     x - X coordinate
;     y - Y coordinate
; returns:  a - Tile value
; clobbers: a,x
h_get_tile:
	tya
	asl                 ; shift left by 5.  The last shift will put the bit in carry
	asl
	asl
	asl
	asl
	bcc h_load_4
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	sta x_crd_temp
	ldx x_crd_temp
	lda areaspace+$100, x
	rts
h_load_4:
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	sta x_crd_temp
	ldx x_crd_temp
	lda areaspace, x
	rts

; ** SUBROUTINE: h_set_tile
; desc:    Sets the value of a tile in loaded areaspace for the horizontal layout
;          (equivalent of the C code "areaspace[y * 32 + x]")
; arguments:
;     x - X coordinate
;     y - Y coordinate
;     a - Tile value
; clobbers: a,x
h_set_tile:
	pha
	tya
	asl                 ; shift left by 5.  The last shift will put the bit in carry
	asl
	asl
	asl
	asl
	bcc h_store_4
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	sta x_crd_temp
	ldx x_crd_temp
	pla
	sta areaspace+$100, x
	rts
h_store_4:
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	sta x_crd_temp
	ldx x_crd_temp
	pla
	sta areaspace, x
	rts

; ** SUBROUTINE: h_generate_metatiles
; desc:    Generates a column of metatiles ahead of the visual column render logic.
h_generate_metatiles:
	ldy #$00
h_genmtloop:
	jsr rand
	ldx arwrhead
	jsr h_set_tile
	iny
	cpy #$0F
	bne h_genmtloop
	ldx arwrhead
	inx
	txa
	and #$1F
	sta arwrhead
	rts

; ** SUBROUTINE: h_generate_column
; desc:    Generates a vertical column of characters corresponding to the respective
;          metatiles in area space.
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts)
h_generate_column:
	lda #ctl_irq_i32
	sta ppu_ctrl
	
	; the PPU address we want to start writing to is
	; 0x2000 + (ntwrhead / 32) * 0x400 + (ntwrhead % 32)
	lda ntwrhead
	ldy #$20
	and #$20
	beq h_dontadd4
	iny
	iny
	iny
	iny
h_dontadd4:
	lda ntwrhead
	and #$1F
	tax
	jsr ppu_loadaddr
	
	; start writing tiles.
	; each iteration will write 2 character tiles for one metatile.
	ldy #0
h_gen_wrloop:
	lda ntwrhead
	lsr                 ; get the tile coordinate
	tax
	jsr h_get_tile
	
	; TODO
	; simply write it down twice
	sta ppu_data
	sta ppu_data

	iny
	cpy #15
	bne h_gen_wrloop

	; advance the write head but keep it within 64
	ldx ntwrhead
	inx
	txa
	and #$3F
	sta ntwrhead
	
	; set the PPUCTRL increment back to 1
	lda #ctl_irq_off
	sta ppu_ctrl
	
	; check if we were writing the odd column
	; generate a column of metatiles if so
	lda ntwrhead
	and #$01
	bne h_gen_dont
	lda gamectrl
	ora #gs_gentiles
	sta gamectrl
h_gen_dont:
	rts

; ** SUBROUTINE: gamemode_init
gm_game_init:
	lda #$00
	sta gamectrl      ; clear some game fields
	sta ntwrhead
	sta arwrhead
	sta ppu_mask      ; disable rendering
	lda #$20
	jsr clear_nt      ; clear the two nametables the game uses
	lda #$24
	jsr clear_nt
	
	; fill 512 bytes of areaspace with garbage
;	ldy #$00
;loop1:
;	jsr rand
;	sta areaspace, y
;	sta areaspace+$100, y
;	iny
;	cpy #$00
;	bne loop1
	jsr h_generate_metatiles
	
	jsr print_logo
	
	; generate 48 columns
;	ldy #$00
;	sty ntwrhead
;loop2:
;	tya
;	pha
;	jsr h_generate_column
;	pla
;	tay
;	iny
;	cpy #$30
;	bne loop2
	
	jsr ppu_rstaddr   ; reset PPUADDR
	lda #def_ppu_msk  ; turn rendering back on
	sta ppu_mask
	jsr vblank_wait
	
	lda gamectrl
	ora #gs_1stfr
	sta gamectrl
	jmp gm_game_update

; ** GAMEMODE: gamemode_game
gamemode_game:
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	;;jsr tl_update_snow
	;;jsr tl_render_snow
	lda #gs_gentiles
	bit gamectrl
	bne gm_dontgen
	jsr h_generate_metatiles
gm_dontgen:
	jmp game_update_return
