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
	lda nmictrl
	ora #nc_prolclr
	sta nmictrl
	
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
	ldy #chrb_gensp1
	sty spr2_bknum
	
	ldy #chrb_dmain
	sty bg0_bknum
	rts

gamemode_prologue_init_FAR:
	lda #0
	sta p_textnum
	sta p_textlen
	sta p_texttimer
	sta pl_ppuaddr
	sta pl_state
	sta ppu_mask     ; disable rendering
	sta scroll_x
	sta scroll_y
	sta scroll_flags
	sta camera_x
	sta camera_y
	sta camera_x_pg
	sta camera_y_hi
	jsr vblank_wait
	
	lda prolctrl
	and #ps_candoit
	beq :+
	
	lda #3
	sta p_textnum
	
:	ldy #<init_palette
	sty paladdr
	ldy #>init_palette
	sty paladdr+1
	jsr load_palette
	
	lda #$20
	jsr clear_nt
	jsr pl_select_banks
	jsr tl_init_snow
	
	lda prolctrl
	ora #ps_1stfr
	sta prolctrl
	
	lda nmictrl
	ora #nc_turnon
	sta nmictrl
	
	jsr vblank_wait

gamemode_prologue_update_FAR:
	; just a regular update
	jsr tl_update_snow
	jsr tl_render_snow
	
	lda #defcameray
	sta camera_y
	
	lda p1_conto
	eor #$FF
	and p1_cont
	and #cont_start
	bne @gameswitch_ ; allow skipping by pressing START
	
	lda pl_state
	cmp #pls_wrtext
	beq @writeText
	cmp #pls_wait
	beq @wait
	cmp #pls_fade
	beq @fade

	; default state: load text
	ldx #3
	lda prolctrl
	and #ps_candoit
	beq :+
	ldx #4
:	stx temp11
	
	ldx p_textnum
	cpx temp11
	beq @gameswitch
	
	jsr pl_load_text
	
	inc p_textnum
	
	inc pl_state
	rts

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

@gameswitch_:
	jmp @gameswitch

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
	rts
	
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
	rts

@gameswitch:
	lda prolctrl
	and #ps_candoit
	bne @exitToOverworld
	
	ldx #0              ; select level zero
	jmp tl_gameswitch

@exitToOverworld:
	jmp tl_owldswitch

p_text0:	.byte "      This is it, Made{ne.      "
p_text1:	.byte "          Just breathe.         "
p_text2:	.byte "     Why are you so nervous?    "
p_text3:	.byte "        You can do this.        "
p_texttable:
	.word p_text0
	.word p_text1
	.word p_text2
	.word p_text3
