level3:
	.word level3_music	; music table
	.word level3_banks	; list of banks for each room
	.byte $03	; environment type
	.byte $0B	; warp count
	.word level3_w_init
	.word level3_w_s0_to_s1
	.word level3_w_s1_to_s0
	.word level3_w_s1_to_s1u
	.word level3_w_s1_to_s2
	.word level3_w_s1u_to_s1
	.word level3_w_s1u_to_s2u
	.word level3_w_s2_to_s1
	.word level3_w_s2_to_s2u
	.word level3_w_s2u_to_s1u
	.word level3_w_s2u_to_s2
level3_banks:
	.byte prgb_lvl3a	; level3_w_init
	.byte prgb_lvl3a	; level3_w_s0_to_s1
	.byte prgb_lvl3a	; level3_w_s1_to_s0
	.byte prgb_lvl3a	; level3_w_s1_to_s1u
	.byte prgb_lvl3a	; level3_w_s1_to_s2
	.byte prgb_lvl3a	; level3_w_s1u_to_s1
	.byte prgb_lvl3a	; level3_w_s1u_to_s2u
	.byte prgb_lvl3a	; level3_w_s2_to_s1
	.byte prgb_lvl3a	; level3_w_s2_to_s2u
	.byte prgb_lvl3a	; level3_w_s2u_to_s1u
	.byte prgb_lvl3a	; level3_w_s2u_to_s2
