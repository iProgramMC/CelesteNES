; Copyright (C) 2025 iProgramInCpp

; This just gets more insane. Now, title code inside of PRG_PAUS? Gimme a break.

.proc s_update_title_aux
	lda tl_cschctrl
	bne :+
	
	inc tl_cschctrl
	jsr s_update_control_scheme
	
:	lda p1_cont
	and #cont_select
	beq doNotSwitch
	
	lda p1_conto
	and #cont_select
	bne doNotSwitch
	
	inc ctrlscheme
	lda ctrlscheme
	cmp #(cns_max+1)
	bne doneSwitch
	
	lda #cns_min
	sta ctrlscheme
	
doneSwitch:
	jsr s_update_control_scheme
	
doNotSwitch:
	rts
.endproc

.proc s_update_control_scheme
	ldy #0
:	lda text_control_scheme_main, y
	sta temprow1, y
	iny
	cpy #32
	bne :-
	
	; depending on the current control scheme
	lda ctrlscheme
	asl
	asl
	tay
	
	ldx #0
:	lda text_ctrl_schemes, y
	sta temprow1+25, x
	inx
	iny
	cpx #4
	bne :-
	
	lda #$20
	sta vmcaddr+1
	lda #$A0
	sta vmcaddr
	lda #$20
	sta vmccount
	
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
	
	rts
.endproc

text_control_scheme_main:
	.byte $00,$00,$00,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$00,$00,$00

text_ctrl_schemes:
	.byte $FF,$FF,$FF,$FF ; [indeterminate]
	.byte $2B,$2C,$2D,$2E ; cns_console
	.byte $2B,$2C,$2D,$2F ; cns_emulat
	.byte $27,$28,$29,$2A ; cns_snes
