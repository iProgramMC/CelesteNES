level1:
	.word level1_music	; music table
	.word level1_banks	; list of banks for each room
	.byte $01	; environment type
	.byte $14	; room count
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
	.word level1_r17
	.word level1_r18
	.word level1_r19
	.word level1_rEnd
level1_banks:
	.byte prgb_lvl1c	; level1_r1
	.byte prgb_lvl1c	; level1_r2
	.byte prgb_lvl1c	; level1_r3
	.byte prgb_lvl1c	; level1_r4
	.byte prgb_lvl1c	; level1_r5
	.byte prgb_lvl1a	; level1_r6
	.byte prgb_lvl1a	; level1_r7
	.byte prgb_lvl1c	; level1_r8
	.byte prgb_lvl1a	; level1_r9
	.byte prgb_lvl1a	; level1_r10
	.byte prgb_lvl1a	; level1_r11
	.byte prgb_lvl1a	; level1_r12
	.byte prgb_lvl1a	; level1_r13
	.byte prgb_lvl1a	; level1_r14
	.byte prgb_lvl1a	; level1_r15
	.byte prgb_lvl1a	; level1_r16
	.byte prgb_lvl1a	; level1_r17
	.byte prgb_lvl1a	; level1_r18
	.byte prgb_lvl1a	; level1_r19
	.byte prgb_lvl1a	; level1_rEnd
