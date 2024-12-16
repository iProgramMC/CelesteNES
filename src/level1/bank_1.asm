; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL1B"
.include "metatile.asm"

music_data_ch1_dmc:
.incbin "level1.dmc"

level1_music:
	.word music_data_ch1 ; song list
	.byte $00            ; default song

.include "entity.asm"
.include "roomlist.asm"
