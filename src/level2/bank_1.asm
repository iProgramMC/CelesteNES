; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL2B"
.include "metatile.asm"

level2_music:
	.word music_data_ch2 ; song list
	.byte $00            ; default song

.include "rooms_1.asm"
.include "roomlist.asm"
.include "warplist.asm"
.include "palette.asm"
.include "structs.asm"
.include "entity.asm"
.include "dialog.asm"
