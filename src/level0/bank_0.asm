; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL0A"
.include "metatile.asm"
.include "rooms/0.asm"
.include "music/music.asm"
.include "roomlist.asm"
.include "warplist.asm"
.include "palette.asm"
.include "dialog.asm"
.include "entity.asm"

level0_music:
	.word music_data_ch0 ; song list
	.byte $00            ; default song
