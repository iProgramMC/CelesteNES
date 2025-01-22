; Copyright (C) 2025 iProgramInCpp

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
