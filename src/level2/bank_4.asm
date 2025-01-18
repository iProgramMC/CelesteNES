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
