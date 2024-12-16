
level0:
	.word level0_music	; music table
	.word level0_banks	; list of banks for each room
	.byte $00	; environment type
	.byte $04	; room count
	.word level0_r1
	.word level0_r2
	.word level0_r3
	.word level0_r4

level0_banks:
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
