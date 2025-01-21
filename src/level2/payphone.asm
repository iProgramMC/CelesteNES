; Copyright (C) 2025 iProgramInCpp

; When madeline walks to the payphone: WALKTO $CD, $A0

pph_exit		= $80 ; terminate drawing
pph_call		= $81 ; call into routine
pph_return		= $82 ; return from routine
pph_jump		= $83 ; jump to routine
pph_plrbrace	= $84 ; brace for impact

; ######### ANIMATION TABLES #########
.proc level2_payphone_idle
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
main:
	.byte $20,$08,pal_gray,$08
main2:
	.byte $20,$0A,pal_red, $10
	.byte $00,$00,pal_gray,$00
	.byte $00,$02,pal_gray,$08
	.byte $00,$04,pal_red, $10
pole:
	.byte $10,$22,pal_gray,$08
	.byte $10,$24,pal_red, $10
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_mad1
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$06,$80,    $FD
	.byte $28,$26,$80,    $05
	.byte $28,$F2,pal_red,$FD
	.byte $28,$F0,pal_red,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad2
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$10,$80,    $FD
	.byte $28,$12,$80,    $05
	.byte $29,$F2,pal_red,$FD
	.byte $29,$F0,pal_red,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad3
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$14,$80,    $FD
	.byte $28,$16,$80,    $05
	.byte $29,$F2,pal_red,$FD
	.byte $29,$F0,pal_red,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad4
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$18,$80,    $FD
	.byte $28,$1A,$80,    $05
	.byte $29,$F2,pal_red,$FD
	.byte $29,$F0,pal_red,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad5
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$1C,$80,    $FD
	.byte $28,$1E,$80,    $05
	.byte $28,$F2,pal_red,$FD
	.byte $28,$F0,pal_red,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad6
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$30,$80,    $FD
	.byte $28,$32,$80,    $05
	.byte $27,$F2,pal_red,$FD
	.byte $27,$F0,pal_red,$05
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad7
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$34,$80,    $FD
	.byte $28,$36,$80,    $05
	.byte $28,$F2,pal_red,$FE
	.byte $28,$F0,pal_red,$06
	.byte pph_jump
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad8
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$38,$80,    $FD
	.byte $28,$3A,$80,    $05
	.byte $28,$F2,pal_red,$FE
	.byte $28,$F0,pal_red,$06
	.byte $20,$2C,pal_gray,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_mad9
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$3C,$80,    $FD
	.byte $28,$3E,$80,    $05
	.byte $28,$F2,pal_red,$FC
	.byte $28,$F0,pal_red,$04
	.byte $20,$2C,pal_gray,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump1 ; brace
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte $28,$10,$80,    $FD
	.byte $28,$12,$80,    $05
	.byte $29,$F2,pal_red,$FC
	.byte $29,$F0,pal_red,$04
	.byte $20,$2C,pal_gray,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump2 ; startle
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte $28,$14,$80,    $F9
	.byte $28,$16,$80,    $01
	.byte $27,$F2,pal_red,$F8
	.byte $27,$F0,pal_red,$00
	.byte $20,$2C,pal_gray,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump3 ; land 1
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte $28,$18,$80,    $F1
	.byte $28,$1A,$80,    $F9
	.byte $29,$F2,pal_red,$F2
	.byte $29,$F0,pal_red,$FA
	.byte $20,$2C,pal_gray,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_madjump4 ; land 2
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	.byte $20,$2C,pal_gray,$08
	.byte pph_jump
	.word level2_payphone_idle::main2
.endproc

.proc level2_payphone_xform1 ; transform 1
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$00,pal_gray,$01
	.byte $00,$02,pal_gray,$09
	.byte $00,$04,pal_red, $11
	.byte $10,$22,pal_gray,$09
	.byte $10,$24,pal_red, $11
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform2 ; transform 2
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$00,pal_gray,$FF
	.byte $00,$02,pal_gray,$07
	.byte $00,$04,pal_red, $0F
	.byte $10,$22,pal_gray,$07
	.byte $10,$24,pal_red, $0F
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform3 ; transform 3
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$00,pal_gray,$FF
	.byte $00,$02,pal_gray,$07
	.byte $00,$04,pal_red, $0F
	.byte $10,$22,pal_gray,$08
	.byte $10,$24,pal_red, $10
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform4 ; transform 4
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$00,pal_gray,$00
	.byte $00,$02,pal_gray,$08
	.byte $00,$04,pal_red, $10
	.byte $10,$22,pal_gray,$08
	.byte $10,$24,pal_red, $10
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform5 ; transform 5
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$38,pal_gray,$00
	.byte $00,$3A,pal_gray,$08
	.byte $00,$04,pal_red, $10
	.byte $10,$22,pal_gray,$08
	.byte $10,$24,pal_red, $10
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform6 ; transform 6
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$00,pal_gray,$00
	.byte $00,$02,pal_gray,$08
	.byte $00,$1C,pal_red, $10
	.byte $10,$22,pal_gray,$08
	.byte $10,$1E,pal_red, $10
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform7 ; transform 7
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$30,pal_gray,$00
	.byte $00,$32,pal_gray,$08
	.byte $00,$3C,pal_red, $10
	.byte $10,$22,pal_gray,$08
	.byte $10,$3E,pal_red, $10
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform8 ; transform 8
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$30,pal_gray,$FE
	.byte $00,$32,pal_gray,$06
	.byte $00,$3C,pal_red, $0E
	.byte $10,$22,pal_gray,$07
	.byte $10,$3E,pal_red, $0F
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform9 ; transform 9
	;     Y,  TN, PAL,     X
	.byte chrb_papho1
	.byte pph_plrbrace
	
	.byte $20,$2C,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	
	.byte $00,$30,pal_gray,$02
	.byte $00,$32,pal_gray,$0A
	.byte $00,$3C,pal_red, $12
	.byte $10,$22,pal_gray,$09
	.byte $10,$3E,pal_red, $11
	
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte pph_exit
.endproc

.proc level2_payphone_xform10 ; transform 10
	;     Y,  TN, PAL,     X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	;.byte $00,$30,pal_gray,$00
	.byte $00,$10,pal_gray,$00
	.byte $00,$12,pal_gray,$08
	
	.byte $F8,$02,pal_red, $08
	.byte $F8,$04,pal_red, $10
	.byte $08,$20,pal_red, $00
	.byte $08,$22,pal_red, $08
	.byte $08,$24,pal_red, $10
	.byte $08,$26,pal_red, $18
	
	.byte $10,$30,pal_gray,$00
	.byte $10,$32,pal_gray,$08
	
	.byte $18,$08,pal_red, $00
	.byte $18,$0A,pal_red, $08
	.byte $18,$0C,pal_red, $10
	.byte $18,$0E,pal_red, $18
	
	.byte $20,$14,pal_gray,$00
	.byte $20,$16,pal_gray,$08
	.byte $30,$18,pal_gray,$00
	.byte $30,$1A,pal_gray,$08
	
	.byte $28,$28,pal_red, $00
	.byte $28,$2A,pal_red, $08
	.byte $28,$2C,pal_red, $10
	.byte $28,$2E,pal_red, $18
	
	.byte pph_exit
.endproc

.proc level2_payphone_xform11
	;     Y,  TN, PAL,     X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	;.byte $00,$30,pal_gray,$00
	.byte $00,$10,pal_gray,$00
	.byte $00,$12,pal_gray,$08
	
	.byte $F9,$02,pal_red, $07
	.byte $F9,$04,pal_red, $0F
	.byte $09,$20,pal_red, $FF
	.byte $09,$22,pal_red, $07
	.byte $09,$24,pal_red, $0F
	.byte $09,$26,pal_red, $17
	
	.byte $11,$30,pal_gray,$FF
	.byte $11,$32,pal_gray,$07
	
	.byte $19,$08,pal_red, $FF
	.byte $19,$0A,pal_red, $07
	.byte $19,$0C,pal_red, $0F
	.byte $19,$0E,pal_red, $17
	
	.byte $21,$14,pal_gray,$00
	.byte $21,$16,pal_gray,$08
	.byte $31,$18,pal_gray,$00
	.byte $31,$1A,pal_gray,$08
	
	.byte $28,$28,pal_red, $00
	.byte $28,$2A,pal_red, $08
	.byte $28,$2C,pal_red, $10
	.byte $28,$2E,pal_red, $18
	
	.byte pph_exit
.endproc

.proc level2_payphone_xform12
	;     Y,  TN, PAL,     X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	.byte $01,$10,pal_fwhite,$01
	.byte $01,$12,pal_fwhite,$09
	
	.byte $F9,$02,pal_fwhite,$06
	.byte $F9,$04,pal_fwhite,$0E
	.byte $09,$20,pal_fwhite,$FE
	.byte $09,$22,pal_fwhite,$06
	.byte $09,$24,pal_fwhite,$0E
	.byte $09,$26,pal_fwhite,$16
	
	.byte $11,$30,pal_fwhite,$FF
	.byte $11,$32,pal_fwhite,$07
	
	.byte $19,$08,pal_fwhite,$FF
	.byte $19,$0A,pal_fwhite,$07
	.byte $19,$0C,pal_fwhite,$0F
	.byte $19,$0E,pal_fwhite,$17
	
	.byte $21,$14,pal_fwhite,$00
	.byte $21,$16,pal_fwhite,$08
	.byte $31,$18,pal_fwhite,$00
	.byte $31,$1A,pal_fwhite,$08
	
	.byte $28,$28,pal_fwhite,$00
	.byte $28,$2A,pal_fwhite,$08
	.byte $28,$2C,pal_fwhite,$10
	.byte $28,$2E,pal_fwhite,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_xform13
	;     Y,  TN, PAL,     X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	.byte $02,$10,pal_fwhite,$00
	.byte $02,$12,pal_fwhite,$08
	
	.byte $F9,$02,pal_fwhite,$00
	.byte $F9,$04,pal_fwhite,$08
	.byte $09,$20,pal_fwhite,$10
	.byte $09,$22,pal_fwhite,$08
	.byte $09,$24,pal_fwhite,$10
	.byte $09,$26,pal_fwhite,$18
	
	.byte $11,$30,pal_fwhite,$00
	.byte $11,$32,pal_fwhite,$08
	
	.byte $19,$08,pal_fwhite,$00
	.byte $19,$0A,pal_fwhite,$08
	.byte $19,$0C,pal_fwhite,$10
	.byte $19,$0E,pal_fwhite,$18
	
	.byte $20,$14,pal_fwhite,$00
	.byte $20,$16,pal_fwhite,$08
	.byte $30,$18,pal_fwhite,$00
	.byte $30,$1A,pal_fwhite,$08
	
	.byte $28,$28,pal_fwhite,$00
	.byte $28,$2A,pal_fwhite,$08
	.byte $28,$2C,pal_fwhite,$10
	.byte $28,$2E,pal_fwhite,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterI
	;     Y,  TN, PAL,     X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte $08,$00,pal_fwhite,$00
	.byte $08,$02,pal_fwhite,$08
	.byte $08,$04,pal_fwhite,$10
	.byte $08,$06,pal_fwhite,$18
	.byte $18,$20,pal_fwhite,$00
	.byte $18,$22,pal_fwhite,$08
	.byte $18,$24,pal_fwhite,$10
	.byte $18,$26,pal_fwhite,$18
	.byte $28,$08,pal_fwhite,$00
	.byte $28,$0A,pal_fwhite,$08
	.byte $28,$0C,pal_fwhite,$10
	.byte $28,$0E,pal_fwhite,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_monster1
	;     Y,  TN, PAL,     X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte $08,$00,pal_red,$00
	.byte $08,$02,pal_red,$08
	.byte $08,$04,pal_red,$10
	.byte $08,$06,pal_red,$18
	.byte $18,$20,pal_red,$00
	.byte $18,$22,pal_red,$08
	.byte $18,$24,pal_red,$10
	.byte $18,$26,pal_red,$18
	.byte $28,$08,pal_red,$00
	.byte $28,$0A,pal_red,$08
	.byte $28,$0C,pal_red,$10
	.byte $28,$0E,pal_red,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_monster2
	;     Y,  TN, PAL,     X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte $08,$00,pal_red,$00
	.byte $08,$02,pal_red,$08
	.byte $08,$04,pal_red,$10
	.byte $08,$06,pal_red,$18
	.byte $23,$28,pal_red,$01
	.byte $23,$2A,pal_red,$09
	.byte $23,$2C,pal_red,$11
	.byte $23,$2E,pal_red,$19
	.byte $18,$20,pal_red,$00
	.byte $18,$22,pal_red,$08
	.byte $18,$24,pal_red,$10
	.byte $18,$26,pal_red,$18
	
	.byte pph_exit
.endproc

.if 0

.proc level2_payphone_monstere1
	;     Y,  TN, PAL,     X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte $04,$18,pal_red,$00+2
	.byte $04,$1A,pal_red,$08+2
	.byte $04,$1C,pal_red,$10+2
	.byte $04,$1E,pal_red,$18+2
	
	.byte $24,$28,pal_red,$00+2
	.byte $24,$2A,pal_red,$08+2
	.byte $24,$2C,pal_red,$10+2
	.byte $24,$2E,pal_red,$18+2
	
	.byte $14,$38,pal_red,$00+2
	.byte $14,$3A,pal_red,$08+2
	.byte $14,$3C,pal_red,$10+2
	.byte $14,$3E,pal_red,$18+2
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere2
	;     Y,  TN, PAL,     X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte $04,$00,pal_red,$00
	.byte $04,$02,pal_red,$08
	.byte $04,$04,pal_red,$10
	.byte $04,$06,pal_red,$18
	.byte $14,$20,pal_red,$00
	.byte $14,$22,pal_red,$08
	.byte $14,$24,pal_red,$10
	.byte $14,$26,pal_red,$18
	;.byte $04,$08,pal_red,$00
	.byte $04,$0A,pal_red,$08
	.byte $04,$0C,pal_red,$10
	.byte $04,$0E,pal_red,$18
	
	.byte pph_exit
.endproc

.endif
