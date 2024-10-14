; Copyright (C) 2024 iProgramInCpp


pl_load_text:
	lda p_textnum
	cmp #3
	bne @dontLoad
	
	asl
	tax
	lda p_texttable, x
	sta p_textaddr
	inx
	lda p_texttable, x
	sta p_textaddr
	
	lda #23
	sta p_textlen
	
	lda #$20
	sta pl_ppuaddr
	lda #$00
	sta pl_ppuaddr+1
	
	inc p_textnum
@dontLoad:
	rts

; ** SUBROUTINE: pl_select_banks
; desc: Selects the correct graphics banks for the prologue intro sequence.
pl_select_banks:
	lda #mmc3bk_spr1
	ldy #chrb_gensp2
	jsr mmc3_set_bank
	
	lda #mmc3bk_spr2
	ldy #chrb_gensp1
	jsr mmc3_set_bank
	
	lda #mmc3bk_bg0
	ldy #chrb_dmade
	jmp mmc3_set_bank

gamemode_prologue:
	lda #ps_1stfr
	bit prolctrl
	bne @noinitsequence
	
	lda #0
	sta p_textnum
	sta p_textlen
	sta p_texttimer
	sta pl_ppuaddr
	sta ppu_mask     ; disable rendering
	sta camera_x
	sta camera_x_hi
	sta camera_y
	jsr vblank_wait
	ldy #(init_palette - palettepage)
	jsr load_palette
	lda #$20
	jsr clear_nt
	jsr pl_select_banks
	jsr tl_init_snow
	
	lda prolctrl
	ora #(ps_1stfr | ps_turnon)
	sta prolctrl
	jsr vblank_wait
	
	jsr pl_load_text
	
@noinitsequence:
	; just a regular update
	jsr tl_update_snow
	jsr tl_render_snow
	
	jmp @gameswitch
	
	lda p_textlen
	beq @fadeoutsequence
	
	; push a character of text
	ldy #0
	lda (p_textaddr), y
	
	inc p_textaddr
	bne :+
	inc p_textaddr + 1
:	dec p_textlen
	
	jmp game_update_return

@fadeoutsequence:
	lda #0
	sta pl_ppuaddr
	
	lda p_textnum
	cmp #3
	bne @gameswitch
	
	jsr pl_load_text
	
	jmp game_update_return

@gameswitch:
	jsr vblank_wait
	lda #0
	sta ppu_mask        ; disable rendering to obscure that gm_set_level sets the bank early
	sta pl_ppuaddr
	sta pl_ppuaddr+1
	
	ldx #0              ; select level zero
	jmp tl_gameswitch


p_text0:	.byte " THIS IS IT, MADELINE. "
p_text1:	.byte "     JUST BREATHE.     "
p_text2:	.byte "WHY ARE YOU SO NERVOUS?"
p_texttable:
	.word p_text0
	.word p_text1
	.word p_text2
