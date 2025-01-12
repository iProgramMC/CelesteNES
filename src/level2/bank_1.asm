; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL2B"
.include "metatile.asm"

music_data_ch2_dmc:
.incbin "music/level2.dmc"

level2_music:
	.word music_data_ch2 ; song list
	.byte $00            ; default song

.include "rooms/1.asm"
.include "roomlist.asm"
.include "warplist.asm"
.include "palette.asm"
.include "structs.asm"
.include "dialog.asm"
.include "entity.asm"

level2_alt_palette:
	.byte $0f,$30,$1c,$0c
	.byte $0f,$37,$16,$06
	.byte $0f,$30,$21,$11
	.byte $0f,$30,$10,$00
	.byte $0f
