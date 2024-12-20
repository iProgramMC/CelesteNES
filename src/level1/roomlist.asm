level1:
	.word level1_music	; music table
	.word level1_banks	; list of banks for each room
	.byte $01	; environment type
	.byte $1A	; room count
	.word level1_r1
	.word level1_r2
	.word level1_r3
	.word level1_r4
	.word level1_r3b
	.word level1_r5
	.word level1_r6
	.word level1_r6a
	.word level1_r6b
	.word level1_r6c
	.word level1_r7
	.word level1_r8
	.word level1_r8b
	.word level1_r9
	.word level1_r9b
	.word level1_r10a
	.word level1_r11
	.word level1_r12
	.word level1_r12a
	.word level1_rend
	.word level1_r7a
	.word level1_r8_from_r7a
	.word level1_r9z
	.word level1_r9z_from_r8
	.word level1_r8_from_r9z
	.word level1_rtest
level1_banks:
	.byte prgb_lvl1c	; level1_r1
	.byte prgb_lvl1c	; level1_r2
	.byte prgb_lvl1c	; level1_r3
	.byte prgb_lvl1c	; level1_r4
	.byte prgb_lvl1c	; level1_r3b
	.byte prgb_lvl1a	; level1_r5
	.byte prgb_lvl1a	; level1_r6
	.byte prgb_lvl1c	; level1_r6a
	.byte prgb_lvl1a	; level1_r6b
	.byte prgb_lvl1a	; level1_r6c
	.byte prgb_lvl1a	; level1_r7
	.byte prgb_lvl1a	; level1_r8
	.byte prgb_lvl1a	; level1_r8b
	.byte prgb_lvl1a	; level1_r9
	.byte prgb_lvl1a	; level1_r9b
	.byte prgb_lvl1a	; level1_r10a
	.byte prgb_lvl1a	; level1_r11
	.byte prgb_lvl1a	; level1_r12
	.byte prgb_lvl1a	; level1_r12a
	.byte prgb_lvl1a	; level1_rend
	.byte prgb_lvl1a	; level1_r7a
	.byte prgb_lvl1a	; level1_r8_from_r7a
	.byte prgb_lvl1a	; level1_r9z
	.byte prgb_lvl1a	; level1_r9z_from_r8
	.byte prgb_lvl1a	; level1_r8_from_r9z
	.byte prgb_lvl1a	; level1_rtest
