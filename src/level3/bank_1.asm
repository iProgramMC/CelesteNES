; Copyright (C) 2025 iProgramInCpp

.segment "PRG_LVL3B"
.include "metatile.asm"
.include "roomlist.asm"
.include "warplist.asm"
.include "palette.asm"
.include "backgd.asm"
.include "rooms/1.asm"

level3_music:
	.word music_data_blank
	.byte $00
