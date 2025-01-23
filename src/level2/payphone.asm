; Copyright (C) 2025 iProgramInCpp

; When madeline walks to the payphone: WALKTO $CD, $A0

pph_exit		= $80 ; terminate drawing
pph_call		= $81 ; call into routine
pph_return		= $82 ; return from routine
pph_jump		= $83 ; jump to routine
pph_plrbrace	= $84 ; brace for impact
pph_palette 	= $85 ; set palette

; ######### ANIMATION TABLES #########
.proc level2_payphone_idle
	;     Y,  TN, X
	.byte chrb_papho0
main:
	.byte pph_palette, pal_gray
	.byte $20,$08,$08
main2:
	.byte pph_palette, pal_gray
	.byte $00,$00,$00
	.byte $00,$02,$08
	
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$04,$10
pole:
	.byte pph_palette, pal_gray
	.byte $10,$22,$08
	.byte $30,$28,$08
	
	.byte pph_palette, pal_red
	.byte $10,$24,$10
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_mad1
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$06,$FD
	.byte $28,$26,$05
	.byte pph_palette, pal_red
	.byte $28,$F2,$FD
	.byte $28,$F0,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad2
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$10,$FD
	.byte $28,$12,$05
	.byte pph_palette, pal_red
	.byte $29,$F2,$FD
	.byte $29,$F0,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad3
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$14,$FD
	.byte $28,$16,$05
	.byte pph_palette, pal_red
	.byte $29,$F2,$FD
	.byte $29,$F0,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad4
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$18,$FD
	.byte $28,$1A,$05
	.byte pph_palette, pal_red
	.byte $29,$F2,$FD
	.byte $29,$F0,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad5
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$1C,$FD
	.byte $28,$1E,$05
	.byte pph_palette, pal_red
	.byte $28,$F2,$FD
	.byte $28,$F0,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad6
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$30,$FD
	.byte $28,$32,$05
	.byte pph_palette, pal_red
	.byte $27,$F2,$FD
	.byte $27,$F0,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad7
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$34,$FD
	.byte $28,$36,$05
	.byte pph_palette, pal_red
	.byte $28,$F2,$FE
	.byte $28,$F0,$06
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad8
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$38,$FD
	.byte $28,$3A,$05
	.byte pph_palette, pal_red
	.byte $28,$F2,$FE
	.byte $28,$F0,$06
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_mad9
	;     Y,  TN, X
	.byte chrb_papho0
	.byte pph_palette, $80
	.byte $28,$3C,$FD
	.byte $28,$3E,$05
	.byte pph_palette, pal_red
	.byte $28,$F2,$FC
	.byte $28,$F0,$04
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump1 ; brace
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_palette, $80
	.byte $28,$10,$FD
	.byte $28,$12,$05
	.byte pph_palette, pal_red
	.byte $29,$F2,$FC
	.byte $29,$F0,$04
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump2 ; startle
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_palette, $80
	.byte $28,$14,$F9
	.byte $28,$16,$01
	.byte pph_palette, pal_red
	.byte $27,$F2,$F8
	.byte $27,$F0,$00
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump3 ; land 1
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_palette, $80
	.byte $28,$18,$F1
	.byte $28,$1A,$F9
	.byte pph_palette, pal_red
	.byte $29,$F2,$F2
	.byte $29,$F0,$FA
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump4 ; land 2
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_xform1 ; transform 1
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$00,$01
	.byte $00,$02,$09
	.byte $10,$22,$09
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$04,$11
	.byte $10,$24,$11
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_xform2 ; transform 2
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$00,$FF
	.byte $00,$02,$07
	.byte $10,$22,$07
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$04,$0F
	.byte $10,$24,$0F
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_xform3 ; transform 3
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$00,$FF
	.byte $00,$02,$07
	.byte $10,$22,$08
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$04,$0F
	.byte $10,$24,$10
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_xform4 ; transform 4
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$00,$00
	.byte $00,$02,$08
	.byte $10,$22,$08
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$04,$10
	.byte $10,$24,$10
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_xform5 ; transform 5
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$38,$00
	.byte $00,$3A,$08
	.byte $10,$22,$08
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$04,$10
	.byte $10,$24,$10
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_xform6 ; transform 6
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$00,$00
	.byte $00,$02,$08
	.byte $10,$22,$08
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$1C,$10
	.byte $10,$1E,$10
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_xform7 ; transform 7
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$30,$00
	.byte $00,$32,$08
	.byte $10,$22,$08
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$3C,$10
	.byte $10,$3E,$10
stuff:
	.byte $30,$2A,$10
	.byte $30,$0C,$18
	.byte pph_exit
.endproc

.proc level2_payphone_xform8 ; transform 8
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$30,$FE
	.byte $00,$32,$06
	.byte $10,$22,$07
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$3C,$0E
	.byte $10,$3E,$0F
	.byte pph_jump
	.word level2_payphone_xform7::stuff
.endproc

.proc level2_payphone_xform9 ; transform 9
	;     Y,  TN, X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $20,$2C,$08
	.byte $00,$30,$02
	.byte $00,$32,$0A
	.byte $10,$22,$09
	.byte $30,$28,$08
	.byte pph_palette, pal_red
	.byte $20,$0A,$10
	.byte $00,$3C,$12
	.byte $10,$3E,$11
	.byte pph_jump
	.word level2_payphone_xform7::stuff
.endproc

.proc level2_payphone_xform10 ; transform 10
	;     Y,  TN, X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	;.byte $00,$30,$00
	.byte $00,$10,$00
	.byte $00,$12,$08
	
	.byte pph_palette, pal_red
	.byte $F8,$02,$08
	.byte $F8,$04,$10
	.byte $08,$20,$00
	.byte $08,$22,$08
	.byte $08,$24,$10
	.byte $08,$26,$18
	
	.byte pph_palette, pal_gray
	.byte $10,$30,$00
	.byte $10,$32,$08
	
	.byte pph_palette, pal_red
	.byte $18,$08,$00
	.byte $18,$0A,$08
	.byte $18,$0C,$10
	.byte $18,$0E,$18
	
	.byte pph_palette, pal_gray
	.byte $20,$14,$00
	.byte $20,$16,$08
	.byte $30,$18,$00
	.byte $30,$1A,$08
	
	.byte pph_palette, pal_red
	.byte $28,$28,$00
	.byte $28,$2A,$08
	.byte $28,$2C,$10
	.byte $28,$2E,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_xform11
	;     Y,  TN, X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	.byte pph_palette, pal_gray
	.byte $00,$10,$00
	.byte $00,$12,$08
	
	.byte pph_palette, pal_red
	.byte $F9,$02,$07
	.byte $F9,$04,$0F
	.byte $09,$20,$FF
	.byte $09,$22,$07
	.byte $09,$24,$0F
	.byte $09,$26,$17
	
	.byte pph_palette, pal_gray
	.byte $11,$30,$FF
	.byte $11,$32,$07
	
	.byte pph_palette, pal_red
	.byte $19,$08,$FF
	.byte $19,$0A,$07
	.byte $19,$0C,$0F
	.byte $19,$0E,$17
	
	.byte pph_palette, pal_gray
	.byte $21,$14,$00
	.byte $21,$16,$08
	.byte $31,$18,$00
	.byte $31,$1A,$08
	
	.byte pph_palette, pal_red
	.byte $28,$28,$00
	.byte $28,$2A,$08
	.byte $28,$2C,$10
	.byte $28,$2E,$18
	
	.byte pph_exit
.endproc

; continued in payphone2.asm