; Copyright (C) 2024 iProgramInCpp

.include "testmusic.asm"

level0_music:
	.word music_data_ch0 ; song list
	.byte $00            ; default song
