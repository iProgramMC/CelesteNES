; Copyright (C) 2024 iProgramInCpp

.segment "PRG_TTLE"

	.include "title/title.asm"

title_palette:
	.incbin "title/title.pal"
	; sprite palettes
	.byte $0f,$37,$14,$21
	.byte $0f,$36,$16,$06
	.byte $0f,$20,$21,$11
	.byte $0f,$30,$29,$09

