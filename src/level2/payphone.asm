; Copyright (C) 2025 iProgramInCpp

; ######### ANIMATION TABLES #########
.proc level2_payphone_idle
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
main:
	.byte $00,$00,pal_gray,$00
	.byte $00,$02,pal_gray,$08
	.byte $00,$04,pal_red, $10
pole:
	.byte $10,$22,pal_gray,$08
	.byte $10,$24,pal_red, $10
	.byte $20,$08,pal_gray,$08
	.byte $20,$0A,pal_red, $10
	.byte $30,$28,pal_gray,$08
	.byte $30,$2A,pal_red, $10
	.byte $30,$0C,pal_red, $18
	.byte $FF
.endproc

.proc level2_payphone_mad1
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$C4,$80,    $FB
	.byte $28,$C6,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad2
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$10,$80,    $FB
	.byte $28,$12,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad3
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$14,$80,    $FB
	.byte $28,$16,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad4
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$18,$80,    $FB
	.byte $28,$1A,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad5
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$06,$80,    $FB
	.byte $28,$26,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad6
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$18,$80,    $FB
	.byte $28,$0E,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc

.proc level2_payphone_mad7
	;     Y,  TN, PAL,     X
	.byte chrb_papho0
	.byte $28,$1C,$80,    $FB
	.byte $28,$1E,$80,    $03
	.byte $28,$F2,pal_red,$FB
	.byte $28,$F0,pal_red,$03
	.byte $FE
	.word level2_payphone_idle::main
.endproc
