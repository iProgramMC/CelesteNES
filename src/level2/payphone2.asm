; Copyright (C) 2025 iProgramInCpp

.proc level2_payphone_xform12
	;     Y,  TN, X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	.byte pph_palette, pal_fwhite
	.byte $01,$10,$01
	.byte $01,$12,$09
	
	.byte $F9,$02,$06
	.byte $F9,$04,$0E
	.byte $09,$20,$FE
	.byte $09,$22,$06
	.byte $09,$24,$0E
	.byte $09,$26,$16
	
	.byte $11,$30,$FF
	.byte $11,$32,$07
	
	.byte $19,$08,$FF
	.byte $19,$0A,$07
	.byte $19,$0C,$0F
	.byte $19,$0E,$17
	
	.byte $21,$14,$00
	.byte $21,$16,$08
	.byte $31,$18,$00
	.byte $31,$1A,$08
	
stuff:
	.byte $28,$28,$00
	.byte $28,$2A,$08
	.byte $28,$2C,$10
	.byte $28,$2E,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_xform13
	;     Y,  TN, X
	.byte chrb_papho2
	.byte pph_plrbrace
	
	.byte pph_palette, pal_fwhite
	.byte $02,$10,$00
	.byte $02,$12,$08
	
	.byte $F9,$02,$00
	.byte $F9,$04,$08
	.byte $09,$20,$10
	.byte $09,$22,$08
	.byte $09,$24,$10
	.byte $09,$26,$18
	
	.byte $11,$30,$00
	.byte $11,$32,$08
	
	.byte $19,$08,$00
	.byte $19,$0A,$08
	.byte $19,$0C,$10
	.byte $19,$0E,$18
	
	.byte $20,$14,$00
	.byte $20,$16,$08
	.byte $30,$18,$00
	.byte $30,$1A,$08
	
	.byte pph_jump
	.word level2_payphone_xform12::stuff
.endproc

.proc level2_payphone_monsterI
	;     Y,  TN, X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte pph_palette, pal_fwhite
	.byte $08,$00,$00
	.byte $08,$02,$08
	.byte $08,$04,$10
	.byte $08,$06,$18
	.byte $18,$20,$00
	.byte $18,$22,$08
	.byte $18,$24,$10
	.byte $18,$26,$18
stuff:
	.byte $28,$08,$00
	.byte $28,$0A,$08
	.byte $28,$0C,$10
	.byte $28,$0E,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_monster1
	;     Y,  TN, X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte pph_palette, pal_red
	.byte $08,$00,$00
	.byte $08,$02,$08
	.byte $08,$04,$10
	.byte $08,$06,$18
	.byte $18,$20,$00
	.byte $18,$22,$08
	.byte $18,$24,$10
	.byte $18,$26,$18
	
	.byte pph_jump
	.word level2_payphone_monsterI::stuff
.endproc

.proc level2_payphone_monster2
	;     Y,  TN, X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte pph_palette, pal_red
	.byte $08,$00,$00
	.byte $08,$02,$08
	.byte $08,$04,$10
	.byte $08,$06,$18
	.byte $23,$28,$01
	.byte $23,$2A,$09
	.byte $23,$2C,$11
	.byte $23,$2E,$19
	.byte $18,$20,$00
	.byte $18,$22,$08
	.byte $18,$24,$10
	.byte $18,$26,$18
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere1
	;     Y,  TN, X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte pph_palette, pal_red
	.byte <(-11+$04),$18,<(9+$00)
	.byte <(-11+$04),$1A,<(9+$08)
	.byte <(-11+$04),$1C,<(9+$10)
	.byte <(-11+$04),$1E,<(9+$18)
	.byte <(-11+$24),$28,<(9+$00)
	.byte <(-11+$24),$2A,<(9+$08)
	.byte <(-11+$24),$2C,<(9+$10)
	.byte <(-11+$24),$2E,<(9+$18)
	.byte <(-11+$14),$38,<(9+$00)
	.byte <(-11+$14),$3A,<(9+$08)
	.byte <(-11+$14),$3C,<(9+$10)
	.byte <(-11+$14),$3E,<(9+$18)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere2
	;     Y,  TN, X
	.byte chrb_papho3
	.byte pph_plrbrace
	
	.byte pph_palette, pal_red
	.byte <(+7+$04),$00,<(-3+$00)
	.byte <(+7+$04),$02,<(-3+$08)
	.byte <(+7+$04),$04,<(-3+$10)
	.byte <(+7+$04),$06,<(-3+$18)
	.byte <(+7+$14),$20,<(-3+$00)
	.byte <(+7+$14),$22,<(-3+$08)
	.byte <(+7+$14),$24,<(-3+$10)
	.byte <(+7+$14),$26,<(-3+$18)
	.byte <(+7+$24),$0A,<(-3+$08)
	.byte <(+7+$24),$0C,<(-3+$10)
	.byte <(+7+$24),$0E,<(-3+$18)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere3
	;     Y,  TN, X
	.byte chrb_papho4
	
	.byte pph_palette, pal_red
	.byte $28,$2C,<(-24+$00)
	.byte $28,$2E,<(-24+$08)
	.byte $28,$30,<(-24+$10)
	.byte $28,$32,<(-24+$18)
	.byte $28,$28,<(-24+$20)
	.byte $28,$2A,<(-24+$28)
	.byte $28,$38,<(-24+$30)
	.byte $28,$3A,<(-24+$38)
	
	.byte $18,$10,<(-24+$10)
	.byte $18,$12,<(-24+$18)
	.byte $18,$14,<(-24+$20)
	.byte $18,$16,<(-24+$28)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere4
	;     Y,  TN, X
	.byte chrb_papho5
	
	.byte pph_palette, pal_red
	.byte $28,$20,<(-24+$00)
	.byte $28,$22,<(-24+$08)
	.byte $28,$24,<(-24+$10)
	.byte $28,$26,<(-24+$18)
	.byte $28,$28,<(-24+$20)
	.byte $28,$2A,<(-24+$28)
	.byte $28,$2C,<(-24+$30)
	
	.byte $18,$04,<(-24+$10)
	.byte $18,$06,<(-24+$18)
	.byte $18,$08,<(-24+$20)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere5
	;     Y,  TN, X
	.byte chrb_papho5
	
	.byte pph_palette, pal_red
	.byte $28,$2E,<(-24+$08)
	.byte $28,$30,<(-24+$10)
	.byte $28,$32,<(-24+$18)
	.byte $28,$34,<(-24+$20)
	.byte $28,$36,<(-24+$28)
	.byte $28,$38,<(-24+$30)
	
	.byte $18,$10,<(-24+$10)
	.byte $18,$12,<(-24+$18)
	.byte $18,$14,<(-24+$20)
	.byte $18,$16,<(-24+$28)
	.byte $18,$18,<(-24+$30)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere6
	;     Y,  TN, X
	.byte chrb_papho6
	
	.byte pph_palette, pal_red
	.byte $10,$00,<(-24+$10)
	.byte $10,$02,<(-24+$18)
	.byte $10,$04,<(-24+$20)
	.byte $10,$06,<(-24+$28)
	
	.byte $20,$20,<(-24+$10)
	.byte $20,$22,<(-24+$18)
	.byte $20,$24,<(-24+$20)
	.byte $20,$26,<(-24+$28)
	.byte $20,$28,<(-24+$30)
	
	.byte $30,$16,<(-24+$10)
	;.byte $30,$18,<(-24+$18)
	.byte $30,$1A,<(-24+$20)
	.byte $30,$1C,<(-24+$28)
	.byte $30,$1E,<(-24+$30)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monstere7
	;     Y,  TN, X
	.byte chrb_papho6
	
	.byte pph_palette, pal_red
	.byte $08,$0A,<(-16+$10)
	.byte $08,$0C,<(-16+$18)
	.byte $08,$0E,<(-16+$20)
	.byte $08,$10,<(-16+$28)
	
	.byte $18,$2A,<(-16+$10)
	.byte $18,$2C,<(-16+$18)
	.byte $18,$2E,<(-16+$20)
	.byte $18,$30,<(-16+$28)
	.byte $18,$32,<(-16+$30)
	
	.byte $28,$38,<(-16+$18)
	.byte $28,$3A,<(-16+$20)
	.byte $28,$3C,<(-16+$28)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd1
	;     Y,  TN, X
	.byte chrb_papho7
	
	.byte pph_palette, pal_red
	.byte $28,$08,<(-12+$10)
	.byte $28,$0A,<(-12+$18)
	.byte $28,$0C,<(-12+$20)
	.byte $28,$0E,<(-12+$28)
	
restofthebody:
	.byte $18,$20,<(-12+$10)
	.byte $18,$22,<(-12+$18)
	.byte $18,$24,<(-12+$20)
	.byte $18,$26,<(-12+$28)
	
	.byte $08,$00,<(-12+$10)
	.byte $08,$02,<(-12+$18)
	.byte $08,$04,<(-12+$20)
	.byte $08,$06,<(-12+$28)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd2
	;     Y,  TN, X
	.byte chrb_papho7
	
	.byte pph_palette, pal_red
	
	.byte $28,$08,<(-12+$10)
	.byte $28,$0A,<(-12+$18)
	.byte $28,$0C,<(-12+$20)
	.byte $28,$0E,<(-12+$28)
	
restofthebody:
	.byte $18,$30,<(-12+$10)
	.byte $18,$32,<(-12+$18)

restofthebody2:
	.byte $08,$10,<(-12+$10)
	.byte $08,$12,<(-12+$18)
	.byte $08,$14,<(-12+$20)
	.byte $08,$16,<(-12+$28)
	
	.byte $18,$34,<(-12+$20)
	.byte $18,$36,<(-12+$28)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd3
	;     Y,  TN, X
	.byte chrb_papho7
	
	.byte pph_palette, pal_red
	
	.byte $28,$28,<(-12+$10)
	.byte $28,$2A,<(-12+$18)
	.byte $28,$2C,<(-12+$20)
	.byte $28,$2E,<(-12+$28)
	
restofthebody:
	.byte $08,$18,<(-12+$10)
	.byte $08,$1A,<(-12+$18)
	.byte $08,$1C,<(-12+$20)
	.byte $08,$1E,<(-12+$28)
	
	.byte $18,$38,<(-12+$10)
	.byte $18,$3A,<(-12+$18)
	.byte $18,$3C,<(-12+$20)
	.byte $18,$3E,<(-12+$28)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterbottom
	.byte $28,$18,<(-12+$10)
	.byte $28,$1A,<(-12+$18)
	.byte $28,$1C,<(-12+$20)
	.byte $28,$1E,<(-12+$28)
	.byte pph_return
.endproc

.proc level2_payphone_monsterd4
	;     Y,  TN, X
	.byte chrb_papho8
	
proper:
	.byte pph_palette, pal_red
	
	.byte pph_call
	.word level2_payphone_monsterbottom
	
	.byte pph_jump
	.word level2_payphone_monsterd1::restofthebody
.endproc

.proc level2_payphone_monsterd5
	;     Y,  TN, X
	.byte chrb_papho8
	
proper:
	.byte pph_palette, pal_red
	
	.byte pph_call
	.word level2_payphone_monsterbottom
	
	.byte $08,$08,<(-12+$10)
	.byte $08,$0A,<(-12+$18)
	.byte $08,$0C,<(-12+$20)
	.byte $08,$0E,<(-12+$28)
	
	.byte $18,$28,<(-12+$10)
	.byte $18,$2A,<(-12+$18)
	.byte $18,$2C,<(-12+$20)
	.byte $18,$2E,<(-12+$28)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd6
	;     Y,  TN, X
	.byte chrb_papho8
	
	.byte pph_palette, pal_red
	
	.byte pph_call
	.word level2_payphone_monsterbottom
	
	.byte pph_jump
	.word level2_payphone_monsterd2::restofthebody
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd7
	;     Y,  TN, X
	.byte chrb_papho8
	
	.byte pph_palette, pal_red
	
	.byte pph_call
	.word level2_payphone_monsterbottom
	
	.byte $10,$38,<(-12+$10)
	.byte $10,$3A,<(-12+$18)
	
	.byte pph_jump
	.word level2_payphone_monsterd2::restofthebody
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd8
	;     Y,  TN, X
	.byte chrb_papho8
	
	.byte pph_palette, pal_red
	
	.byte pph_call
	.word level2_payphone_monsterbottom
	
	.byte $10,$3C,<(-12+$10)
	.byte $10,$3E,<(-12+$18)
	
	.byte pph_jump
	.word level2_payphone_monsterd2::restofthebody
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd9
	.byte chrb_papho9
	
	.byte pph_jump
	.word level2_payphone_monsterd4::proper
.endproc

.proc level2_payphone_monsterd10
	.byte chrb_papho9
	
	.byte pph_jump
	.word level2_payphone_monsterd5::proper
.endproc

.proc level2_payphone_monsterd11
	.byte chrb_papho9
	
	.byte pph_palette, pal_red
	.byte pph_call
	.word level2_payphone_monsterbottom
	
	.byte $08,$08,<(-13+$10)
	.byte $08,$0A,<(-13+$18)
	.byte $08,$0C,<(-13+$20)
	.byte $08,$0E,<(-13+$28)
	
	.byte $18,$28,<(-13+$10)
	.byte $18,$2A,<(-13+$18)
	.byte $18,$2C,<(-13+$20)
	.byte $18,$2E,<(-13+$28)
	
	.byte pph_exit
.endproc

.proc level2_payphone_monsterd12
	.byte chrb_papho9
	
	.byte pph_palette, pal_red
	.byte pph_call
	.word level2_payphone_monsterbottom
	
	.byte $08,$08,<(-11+$10)
	.byte $08,$0A,<(-11+$18)
	.byte $08,$0C,<(-11+$20)
	.byte $08,$0E,<(-11+$28)
	
	.byte $18,$28,<(-11+$10)
	.byte $18,$2A,<(-11+$18)
	.byte $18,$2C,<(-11+$20)
	.byte $18,$2E,<(-11+$28)
	
	.byte pph_exit
.endproc
