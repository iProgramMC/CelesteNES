; Copyright (C) 2025 iProgramInCpp

; This just gets more insane. Now, title code inside of PRG_PAUS? Gimme a break.


; This looks bad, but trust me
.proc s_check_select_a
	lda p1_cont
	and #(cont_select | cont_a)
	beq @return
	
	lda p1_conto
	and #(cont_select | cont_a)
	bne @returnZero
	
	lda #1
	rts
	
@returnZero:
	lda #0
@return:
	rts
.endproc

.proc s_check_select_a_b
	lda p1_cont
	and #(cont_select | cont_a | cont_b)
	beq @return
	
	lda p1_conto
	and #(cont_select | cont_a | cont_b)
	bne @returnZero
	
	lda #1
	rts
	
@returnZero:
	lda #0
@return:
	rts
.endproc

.proc s_check_b
	lda p1_cont
	and #cont_b
	beq @return
	
	lda p1_conto
	and #cont_b
	bne @returnZero
	
	lda #1
	rts
	
@returnZero:
	lda #0
@return:
	rts
.endproc

.proc s_update_title_aux
	lda tl_cschctrl
	bne isControlSchemeStuffOpen
	
	; well, it's closed
	jsr s_check_select_a_b
	beq @dontOpen
	jmp s_open_control_scheme
	
@dontOpen:
	rts
	
isControlSchemeStuffOpen:
	; well, it's open
	jsr s_check_b
	beq @dontExit
	jmp s_close_control_scheme
	
@dontExit:
	jsr s_check_select_a
	beq @dontSwitch
	
	inc ctrlscheme
	lda ctrlscheme
	cmp #(cns_max+1)
	bne @doneSwitch
	
	lda #cns_min
	sta ctrlscheme
	
@doneSwitch:
	jsr s_update_control_scheme
	
@dontSwitch:
	rts
.endproc

.proc s_open_control_scheme
	inc tl_cschctrl
	jmp s_update_control_scheme
.endproc

.proc s_close_control_scheme
	dec tl_cschctrl
	
	lda #$20
	sta vmcaddr+1
	lda #$A0
	sta vmcaddr
	lda #$01
	sta vmcsrc
	sta vmcsrc+1
	lda #$20
	sta vmccount
	
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
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
	lda #<temprow1
	sta vmcsrc
	lda #>temprow1
	sta vmcsrc+1
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
