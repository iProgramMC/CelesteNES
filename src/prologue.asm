; Copyright (C) 2024 iProgramInCpp

defwaittimer = 120
deffadetimer = 8
text_address = $21E0
defcameray   = 4

pl_load_text:
	lda p_textnum
	asl
	tax
	lda p_texttable, x
	sta p_textaddr
	inx
	lda p_texttable, x
	sta p_textaddr+1
	
	lda #32
	sta p_textlen
	
	; start clearing
	lda #ps_clear
	ora prolctrl
	sta prolctrl
	
	lda #0
	sta p_textoffs
	sta pl_ppudata
	lda #<text_address
	sta pl_ppuaddr
	lda #>text_address
	sta pl_ppuaddr + 1
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
	sta pl_state
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
	
@noinitsequence:
	; just a regular update
	jsr tl_update_snow
	jsr tl_render_snow
	
	lda #defcameray
	sta camera_y
	
	lda p1_conto
	eor #$FF
	and p1_cont
	and #cont_start
	bne @gameswitch  ; allow skipping by pressing START
	
	lda pl_state
	cmp #pls_wrtext
	beq @writeText
	cmp #pls_wait
	beq @wait
	cmp #pls_fade
	beq @fade

	; default state: load text
	ldx p_textnum
	cpx #3
	beq @gameswitch
	
	jsr pl_load_text
	
	inc p_textnum
	
	inc pl_state
	jmp game_update_return

@fade:
	lda p_texttimer
	and #1
	bne :+
	lda #ps_dofade
	ora prolctrl
	sta prolctrl
	
:	dec p_texttimer
	bne @updateReturn
	
	lda #0
	sta pl_state
	sta p_texttimer
	beq @updateReturn

@wait:
	dec p_texttimer
	bne @updateReturn
	
	; increment state to fadeout
	lda #deffadetimer
	sta p_texttimer
	inc pl_state
	bne @updateReturn
	
@writeText:
	lda #0
	sta pl_ppuaddr
	sta pl_ppuaddr + 1
	
	lda p_textlen
	bne :+
	
	; set wait timer
	lda #defwaittimer
	sta p_texttimer
	
	; increment state
	inc pl_state
@updateReturn:
	jmp game_update_return
	
:	inc p_texttimer
	lda p_texttimer
	and #1
	beq @updateReturn
	
	; push a character of text
	ldy #0
	lda (p_textaddr), y
	sta pl_ppudata
	
	inc p_textaddr
	bne :+
	inc p_textaddr + 1
	
:	dec p_textlen
	
	clc
	lda #<text_address
	adc p_textoffs
	sta pl_ppuaddr
	
	lda #>text_address
	adc #0
	sta pl_ppuaddr + 1
	
	inc p_textoffs
	
	jmp game_update_return

@gameswitch:
	jsr vblank_wait
	lda #0
	sta ppu_mask        ; disable rendering to obscure that gm_set_level sets the bank early
	sta pl_ppuaddr
	sta pl_ppuaddr+1
	
	ldx #0              ; select level zero
	jmp tl_gameswitch

p_text0:	.byte "      THIS IS IT, MADELINE.     "
p_text1:	.byte "          JUST BREATHE.         "
p_text2:	.byte "     WHY ARE YOU SO NERVOUS?    "
p_texttable:
	.word p_text0
	.word p_text1
	.word p_text2
