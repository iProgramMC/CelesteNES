; Copyright (C) 2025 iProgramInCpp

.segment "PRG_LVL2E"
.include "rooms/4.asm"
.include "music/level2.asm"

; level2_start is located here, so also add the memorial
level2_s_memorial:
	.byte $00,$70,$64,$74,$68,$09,$19,$78
	.byte $7E,$71,$65,$75,$69,$0A,$1A,$79
	.byte $7F,$72,$66,$76,$69,$0B,$1B,$79
	.byte $00,$73,$67,$77,$6A,$0C,$1C,$7A

level2_alt_palette:
	.byte $0f,$30,$1c,$0c
	.byte $0f,$37,$16,$06
	.byte $0f,$30,$21,$11
	.byte $0f,$30,$10,$00
	.byte $0f

; level2_end_chase is located here, so also add the info kiosk
level2_s_info_kiosk_offsets:
	.byte 0, 9, 18, 27, 36, 45, 54, 63, 72, 81

level2_s_info_kiosk:
	.byte $00,$00,$00,$14,$39,$50,$49,$49,$3A
	.byte $00,$00,$00,$15,$40,$51,$4A,$5A,$3B
	.byte $10,$20,$30,$16,$41,$52,$00,$5B,$3C
	.byte $11,$21,$31,$17,$42,$52,$00,$5B,$3D
	.byte $12,$22,$32,$18,$43,$53,$00,$5B,$3E
	.byte $13,$23,$33,$26,$44,$54,$4B,$5C,$3C
	.byte $00,$00,$34,$27,$45,$55,$4C,$5D,$3F
	.byte $00,$00,$35,$28,$46,$56,$4D,$5E,$2A
	.byte $00,$24,$36,$38,$47,$57,$4E,$29,$2B ;done
	.byte $00,$25,$00,$00,$48,$58,$59,$59,$4F

; level2_end_chase is located here, so also add the payphone data
chrb_papho0 = $40
chrb_papho1 = $41
chrb_papho2 = $42
chrb_papho3 = $43
chrb_papho4 = $44
chrb_papho5 = $45
chrb_papho6 = $46
chrb_papho7 = $47
chrb_papho8 = $48

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
