; Copyright (C) 2025 iProgramInCpp

.segment "PRG_LVL2D"
.include "rooms/3.asm"

level2_mirror_frames_lo: 	.byte <level2_mirror_frame_0, <level2_mirror_frame_1, <level2_mirror_frame_2, <level2_mirror_frame_3, <level2_mirror_frame_4, <level2_mirror_frame_5
level2_mirror_frames_hi:	.byte >level2_mirror_frame_0, >level2_mirror_frame_1, >level2_mirror_frame_2, >level2_mirror_frame_3, >level2_mirror_frame_4, >level2_mirror_frame_5

level2_mirror_frame_0:
	.byte $61,$71,$72,$79
	.byte $62,$72,$73,$7A
	.byte $63,$73,$74,$7B
	.byte $64,$74,$75,$7C
	.byte $65,$75,$6D,$7D
	.byte $66,$76,$6E,$7E
level2_mirror_frame_1:
	.byte $61,$71,$72,$5F
	.byte $62,$72,$73,$7A
	.byte $63,$73,$74,$7B
	.byte $64,$4F,$75,$7C
	.byte $65,$75,$6D,$7D
	.byte $66,$76,$6E,$7E
level2_mirror_frame_2:
	.byte $61,$71,$72,$5F
	.byte $62,$72,$16,$06
	.byte $63,$73,$27,$7B
	.byte $64,$4F,$28,$7C
	.byte $65,$75,$6D,$7D
	.byte $66,$76,$6E,$7E
level2_mirror_frame_3:
	.byte $61,$01,$01,$01
	.byte $69,$01,$01,$01
	.byte $6A,$01,$01,$01
	.byte $6B,$01,$01,$01
	.byte $6C,$01,$01,$01
	.byte $66,$01,$01,$01
level2_mirror_frame_4:
	.byte $61,$01,$01,$26
	.byte $69,$01,$17,$01
	.byte $6A,$02,$18,$01
	.byte $6B,$03,$19,$29
	.byte $6C,$01,$01,$01
	.byte $66,$01,$01,$01
level2_mirror_frame_5:
	.byte $04,$0A,$1A,$2A
	.byte $05,$0B,$1B,$2B
	.byte $63,$0C,$1C,$2C
	.byte $07,$0D,$1D,$2D
	.byte $08,$0E,$1E,$2E
	.byte $09,$0F,$1F,$2F

level2_db_opening_row_1: .byte $41,$42,$41,$42,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$36,$42
level2_db_opening_row_2: .byte $4C,$5B,$4D,$5D,$55,$42,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$47,$5C
level2_db_opening_row_3: .byte $00,$00,$00,$00,$00,$4D,$58,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$42,$43,$56,$00
level2_db_opening_row_4: .byte $00,$00,$00,$00,$00,$5B,$57,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$41,$41,$56,$5C,$5D,$00,$00
level2_db_opening_row_5: .byte $00,$00,$00,$00,$00,$00,$55,$42,$43,$41,$42,$37,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$41,$41,$56,$4C,$5B,$00,$00,$00,$00,$00
level2_db_opening_row_6: .byte $00,$00,$00,$00,$00,$00,$00,$5D,$5C,$4C,$4D,$55,$43,$41,$44,$F8,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$FD,$49,$5C,$4E,$00,$00,$00,$00,$00,$00,$00,$00
level2_db_closing_row_1: .byte $00,$00,$00,$4B,$57,$00,$00,$00,$00,$00,$00,$36,$42,$42,$41,$41,$41,$41,$42,$42,$42,$43,$43,$42,$42,$43,$41,$42,$44,$00,$00,$47,$4C,$00,$00,$00
level2_db_closing_row_2: .byte $00,$00,$00,$4C,$58,$00,$00,$00,$40,$41,$41,$56,$5C,$5D,$5C,$4D,$4C,$5E,$5B,$4D,$4D,$4C,$5C,$4C,$5E,$5D,$4C,$4D,$55,$43,$41,$56,$00,$00,$00,$00
level2_db_closing_row_3: .byte $00,$00,$00,$00,$55,$41,$42,$43,$56,$5D,$4B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4C,$5E,$00,$00,$00,$00,$00
level2_db_closing_row_4: .byte $00,$00,$00,$00,$00,$5E,$5C,$4D,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
level2_db_opening_empty: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

level2_db_opening_rows_lo:
	.byte <level2_db_opening_row_6
	.byte <level2_db_opening_row_5
	.byte <level2_db_opening_row_4
	.byte <level2_db_opening_row_3
	.byte <level2_db_opening_row_2
	.byte <level2_db_opening_row_1
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
level2_db_opening_rows_hi:
	.byte >level2_db_opening_row_6
	.byte >level2_db_opening_row_5
	.byte >level2_db_opening_row_4
	.byte >level2_db_opening_row_3
	.byte >level2_db_opening_row_2
	.byte >level2_db_opening_row_1
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
level2_db_closing_rows_lo:
	.byte <level2_db_closing_row_1
	.byte <level2_db_closing_row_2
	.byte <level2_db_closing_row_3
	.byte <level2_db_closing_row_4
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
level2_db_closing_rows_hi:
	.byte >level2_db_closing_row_1
	.byte >level2_db_closing_row_2
	.byte >level2_db_closing_row_3
	.byte >level2_db_closing_row_4
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
