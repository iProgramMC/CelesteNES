level3:
	.word level3_music	; music table
	.word level3_banks	; list of banks for each room
	.byte $03	; environment type
	.byte $01	; warp count
	.word level3_w_init
level3_banks:
	.byte prgb_lvl3a	; level3_w_init
