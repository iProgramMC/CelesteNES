level1:
	.word level1_music	; music table
	.word level1_banks	; list of banks for each room
	.byte $01	; environment type
	.byte $10	; room count
	.word level1_r1
	.word level1_r2
	.word level1_r3
	.word level1_r4
	.word level1_r5
	.word level1_r6
	.word level1_r7
	.word level1_r8
	.word level1_r9
	.word level1_r10
	.word level1_r11
	.word level1_r12
	.word level1_r13
	.word level1_r14
	.word level1_r15
	.word level1_r16
level1_banks:
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a
	.byte prgb_lvl1a