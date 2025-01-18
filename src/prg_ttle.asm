; Copyright (C) 2024 iProgramInCpp

.segment "PRG_TTLE"

	.include "title/rle.asm"
	.include "title/title.asm"
	.include "title/overwld.asm"
	.include "title/prologue.asm"
	.include "title/titlescr.asm"
	.include "title/mountain.asm"
	.include "title/letter.asm"
	.include "title/levelend.asm"

title_palette:
	.incbin "title/title.pal"
	; sprite palettes
	.byte $0f,$37,$14,$21
	.byte $0f,$36,$16,$06
	.byte $0f,$20,$21,$11
	.byte $0f,$30,$29,$09

logo_pressstart:	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78
logo_iprogram:		.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E
logo_exok:			.byte $60,$61,$79,$7A,$00,$7B,$7C,$7D,$7E
