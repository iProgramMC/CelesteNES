level2:
	.word level2_music	; music table
	.word level2_banks	; list of banks for each room
	.byte $02	; environment type
	.byte $0B	; warp count
	.word level2_w_init
	.word level2_w_start_to_0
	.word level2_w_start_to_s0
	.word level2_w_0_to_start
	.word level2_w_0_to_r3x
	.word level2_w_s0_to_start
	.word level2_w_s0_to_s1
	.word level2_w_r3x_to_r3
	.word level2_w_s1_to_s0
	.word level2_w_s1_to_s2
	.word level2_w_s2_to_s1
level2_banks:
	.byte prgb_lvl2a	; level2_w_init
	.byte prgb_lvl2a	; level2_w_start_to_0
	.byte prgb_lvl2a	; level2_w_start_to_s0
	.byte prgb_lvl2a	; level2_w_0_to_start
	.byte prgb_lvl2a	; level2_w_0_to_r3x
	.byte prgb_lvl2a	; level2_w_s0_to_start
	.byte prgb_lvl2a	; level2_w_s0_to_s1
	.byte prgb_lvl2a	; level2_w_r3x_to_r3
	.byte prgb_lvl2a	; level2_w_s1_to_s0
	.byte prgb_lvl2a	; level2_w_s1_to_s2
	.byte prgb_lvl2a	; level2_w_s2_to_s1
