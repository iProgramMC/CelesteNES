level2:
	.word level2_music	; music table
	.word level2_banks	; list of banks for each room
	.byte $02	; environment type
	.byte $21	; warp count
	.word level2_w_init
	.word level2_w_start_to_0
	.word level2_w_start_to_s0
	.word level2_w_0_to_start
	.word level2_w_0_to_r3x
	.word level2_w_0_to_r1
	.word level2_w_s0_to_start
	.word level2_w_s0_to_s1
	.word level2_w_r3x_to_r3
	.word level2_w_r1_to_0
	.word level2_w_r1_to_r1b
	.word level2_w_r1_to_r2_fake
	.word level2_w_s1_to_s0
	.word level2_w_s1_to_s2
	.word level2_w_r3_to_r4
	.word level2_w_r1b_to_r1
	.word level2_w_r2_fake_to_r1
	.word level2_w_s2_to_s1
	.word level2_w_r4_to_r5
	.word level2_w_r5_to_r6
	.word level2_w_r6_to_r7
	.word level2_w_r7_to_r8
	.word level2_w_r8_to_r9
	.word level2_w_r9_to_r9b
	.word level2_w_r9_to_r9z
	.word level2_w_r9b_to_r9
	.word level2_w_r9z_to_r9
	.word level2_w_r9z_to_r10
	.word level2_w_r10_to_r10_
	.word level2_w_r10__to_r2_
	.word level2_w_r2__to_r10_
	.word level2_w_r2__to_r2
	.word level2_w_r2_to_r2_
level2_banks:
	.byte prgb_lvl2a	; level2_w_init
	.byte prgb_lvl2a	; level2_w_start_to_0
	.byte prgb_lvl2a	; level2_w_start_to_s0
	.byte prgb_lvl2a	; level2_w_0_to_start
	.byte prgb_lvl2a	; level2_w_0_to_r3x
	.byte prgb_lvl2c	; level2_w_0_to_r1
	.byte prgb_lvl2a	; level2_w_s0_to_start
	.byte prgb_lvl2a	; level2_w_s0_to_s1
	.byte prgb_lvl2a	; level2_w_r3x_to_r3
	.byte prgb_lvl2a	; level2_w_r1_to_0
	.byte prgb_lvl2c	; level2_w_r1_to_r1b
	.byte prgb_lvl2c	; level2_w_r1_to_r2_fake
	.byte prgb_lvl2a	; level2_w_s1_to_s0
	.byte prgb_lvl2a	; level2_w_s1_to_s2
	.byte prgb_lvl2a	; level2_w_r3_to_r4
	.byte prgb_lvl2c	; level2_w_r1b_to_r1
	.byte prgb_lvl2c	; level2_w_r2_fake_to_r1
	.byte prgb_lvl2a	; level2_w_s2_to_s1
	.byte prgb_lvl2a	; level2_w_r4_to_r5
	.byte prgb_lvl2a	; level2_w_r5_to_r6
	.byte prgb_lvl2a	; level2_w_r6_to_r7
	.byte prgb_lvl2c	; level2_w_r7_to_r8
	.byte prgb_lvl2c	; level2_w_r8_to_r9
	.byte prgb_lvl2c	; level2_w_r9_to_r9b
	.byte prgb_lvl2a	; level2_w_r9_to_r9z
	.byte prgb_lvl2c	; level2_w_r9b_to_r9
	.byte prgb_lvl2c	; level2_w_r9z_to_r9
	.byte prgb_lvl2c	; level2_w_r9z_to_r10
	.byte prgb_lvl2c	; level2_w_r10_to_r10_
	.byte prgb_lvl2c	; level2_w_r10__to_r2_
	.byte prgb_lvl2c	; level2_w_r2__to_r10_
	.byte prgb_lvl2c	; level2_w_r2__to_r2
	.byte prgb_lvl2c	; level2_w_r2_to_r2_
