level2:
	.word level2_music	; music table
	.word level2_banks	; list of banks for each room
	.byte $02	; environment type
	.byte $59	; warp count
	.word level2_w_init
	.word level2_w_start_to_0
	.word level2_w_start_to_s0
	.word level2_w_0_to_start
	.word level2_w_0_to_r1
	.word level2_w_0_to_d1
	.word level2_w_0_to_r3x
	.word level2_w_s0_to_start
	.word level2_w_s0_to_s1
	.word level2_w_r1_to_0
	.word level2_w_r1_to_d0
	.word level2_w_r1_to_r2_fake
	.word level2_w_r1_to_r1b
	.word level2_w_d1_to_0
	.word level2_w_d1_to_d0
	.word level2_w_d1_to_d0a
	.word level2_w_d1_to_d6
	.word level2_w_r3x_to_r3
	.word level2_w_s1_to_s0
	.word level2_w_s1_to_s2
	.word level2_w_d0_to_r1
	.word level2_w_d0_to_d1
	.word level2_w_d0_to_d0a
	.word level2_w_d0_to_d4
	.word level2_w_r2_fake_to_r1
	.word level2_w_r1b_to_r1
	.word level2_w_d0a_to_d0
	.word level2_w_d0a_to_d7
	.word level2_w_d0a_to_d0b
	.word level2_w_d0a_to_d2
	.word level2_w_d6_to_d0a
	.word level2_w_d6_to_d0b
	.word level2_w_r3_to_r4
	.word level2_w_s2_to_s1
	.word level2_w_d4_to_d0
	.word level2_w_d4_to_d2b
	.word level2_w_d4_to_d5
	.word level2_w_d7_to_d0a
	.word level2_w_d7_to_d0b
	.word level2_w_d7_to_d8
	.word level2_w_d0b_to_d0a
	.word level2_w_d0b_to_d6
	.word level2_w_d0b_to_d7
	.word level2_w_d0b_to_d9
	.word level2_w_d2_to_d0a
	.word level2_w_d2_to_d2b
	.word level2_w_r4_to_r5
	.word level2_w_d2b_to_d4
	.word level2_w_d2b_to_d2
	.word level2_w_d2b_to_d3u
	.word level2_w_d5_to_d4
	.word level2_w_d8_to_d7
	.word level2_w_d8_to_d3m
	.word level2_w_d8_to_d3b
	.word level2_w_r5_to_r6
	.word level2_w_d3u_to_d2b
	.word level2_w_d3u_to_d5
	.word level2_w_d3u_to_d3m
	.word level2_w_d3m_to_d8
	.word level2_w_d3m_to_d3u
	.word level2_w_d3b_to_d8
	.word level2_w_d3b_to_d3m
	.word level2_w_r6_to_r7
	.word level2_w_r7_to_r8
	.word level2_w_r8_to_r9
	.word level2_w_r9_to_r9z
	.word level2_w_r9_to_r9b
	.word level2_w_r9z_to_r9
	.word level2_w_r9z_to_r10
	.word level2_w_r9b_to_r9
	.word level2_w_r10_to_r10_
	.word level2_w_r10__to_r2_
	.word level2_w_r2__to_r2
	.word level2_w_r2_to_r11
	.word level2_w_r11_to_r2
	.word level2_w_r11_to_r12bp
	.word level2_w_r12bp_to_r11
	.word level2_w_r12bp_to_r12b
	.word level2_w_r12b_to_r12bp
	.word level2_w_r12b_to_r12
	.word level2_w_r12b_to_r12d
	.word level2_w_r12b_to_r12c
	.word level2_w_r12_to_r12b
	.word level2_w_r12_to_end_chase
	.word level2_w_r12d_to_r12b
	.word level2_w_r12d_to_r12
	.word level2_w_r12c_to_r12b
	.word level2_w_end_chase_to_r12
	.word level2_w_d9_to_d0b
level2_banks:
	.byte prgb_lvl2e	; level2_w_init
	.byte prgb_lvl2a	; level2_w_start_to_0
	.byte prgb_lvl2c	; level2_w_start_to_s0
	.byte prgb_lvl2e	; level2_w_0_to_start
	.byte prgb_lvl2d	; level2_w_0_to_r1
	.byte prgb_lvl2a	; level2_w_0_to_d1
	.byte prgb_lvl2a	; level2_w_0_to_r3x
	.byte prgb_lvl2e	; level2_w_s0_to_start
	.byte prgb_lvl2e	; level2_w_s0_to_s1
	.byte prgb_lvl2a	; level2_w_r1_to_0
	.byte prgb_lvl2c	; level2_w_r1_to_d0
	.byte prgb_lvl2e	; level2_w_r1_to_r2_fake
	.byte prgb_lvl2d	; level2_w_r1_to_r1b
	.byte prgb_lvl2a	; level2_w_d1_to_0
	.byte prgb_lvl2c	; level2_w_d1_to_d0
	.byte prgb_lvl2d	; level2_w_d1_to_d0a
	.byte prgb_lvl2d	; level2_w_d1_to_d6
	.byte prgb_lvl2d	; level2_w_r3x_to_r3
	.byte prgb_lvl2c	; level2_w_s1_to_s0
	.byte prgb_lvl2e	; level2_w_s1_to_s2
	.byte prgb_lvl2d	; level2_w_d0_to_r1
	.byte prgb_lvl2a	; level2_w_d0_to_d1
	.byte prgb_lvl2d	; level2_w_d0_to_d0a
	.byte prgb_lvl2c	; level2_w_d0_to_d4
	.byte prgb_lvl2d	; level2_w_r2_fake_to_r1
	.byte prgb_lvl2d	; level2_w_r1b_to_r1
	.byte prgb_lvl2c	; level2_w_d0a_to_d0
	.byte prgb_lvl2d	; level2_w_d0a_to_d7
	.byte prgb_lvl2d	; level2_w_d0a_to_d0b
	.byte prgb_lvl2d	; level2_w_d0a_to_d2
	.byte prgb_lvl2d	; level2_w_d6_to_d0a
	.byte prgb_lvl2d	; level2_w_d6_to_d0b
	.byte prgb_lvl2c	; level2_w_r3_to_r4
	.byte prgb_lvl2e	; level2_w_s2_to_s1
	.byte prgb_lvl2c	; level2_w_d4_to_d0
	.byte prgb_lvl2c	; level2_w_d4_to_d2b
	.byte prgb_lvl2c	; level2_w_d4_to_d5
	.byte prgb_lvl2d	; level2_w_d7_to_d0a
	.byte prgb_lvl2d	; level2_w_d7_to_d0b
	.byte prgb_lvl2c	; level2_w_d7_to_d8
	.byte prgb_lvl2d	; level2_w_d0b_to_d0a
	.byte prgb_lvl2d	; level2_w_d0b_to_d6
	.byte prgb_lvl2d	; level2_w_d0b_to_d7
	.byte prgb_lvl2e	; level2_w_d0b_to_d9
	.byte prgb_lvl2d	; level2_w_d2_to_d0a
	.byte prgb_lvl2c	; level2_w_d2_to_d2b
	.byte prgb_lvl2c	; level2_w_r4_to_r5
	.byte prgb_lvl2c	; level2_w_d2b_to_d4
	.byte prgb_lvl2d	; level2_w_d2b_to_d2
	.byte prgb_lvl2d	; level2_w_d2b_to_d3u
	.byte prgb_lvl2c	; level2_w_d5_to_d4
	.byte prgb_lvl2d	; level2_w_d8_to_d7
	.byte prgb_lvl2d	; level2_w_d8_to_d3m
	.byte prgb_lvl2e	; level2_w_d8_to_d3b
	.byte prgb_lvl2c	; level2_w_r5_to_r6
	.byte prgb_lvl2c	; level2_w_d3u_to_d2b
	.byte prgb_lvl2c	; level2_w_d3u_to_d5
	.byte prgb_lvl2d	; level2_w_d3u_to_d3m
	.byte prgb_lvl2c	; level2_w_d3m_to_d8
	.byte prgb_lvl2d	; level2_w_d3m_to_d3u
	.byte prgb_lvl2c	; level2_w_d3b_to_d8
	.byte prgb_lvl2d	; level2_w_d3b_to_d3m
	.byte prgb_lvl2d	; level2_w_r6_to_r7
	.byte prgb_lvl2a	; level2_w_r7_to_r8
	.byte prgb_lvl2c	; level2_w_r8_to_r9
	.byte prgb_lvl2d	; level2_w_r9_to_r9z
	.byte prgb_lvl2a	; level2_w_r9_to_r9b
	.byte prgb_lvl2c	; level2_w_r9z_to_r9
	.byte prgb_lvl2a	; level2_w_r9z_to_r10
	.byte prgb_lvl2c	; level2_w_r9b_to_r9
	.byte prgb_lvl2a	; level2_w_r10_to_r10_
	.byte prgb_lvl2e	; level2_w_r10__to_r2_
	.byte prgb_lvl2d	; level2_w_r2__to_r2
	.byte prgb_lvl2d	; level2_w_r2_to_r11
	.byte prgb_lvl2d	; level2_w_r11_to_r2
	.byte prgb_lvl2e	; level2_w_r11_to_r12bp
	.byte prgb_lvl2d	; level2_w_r12bp_to_r11
	.byte prgb_lvl2c	; level2_w_r12bp_to_r12b
	.byte prgb_lvl2e	; level2_w_r12b_to_r12bp
	.byte prgb_lvl2c	; level2_w_r12b_to_r12
	.byte prgb_lvl2c	; level2_w_r12b_to_r12d
	.byte prgb_lvl2e	; level2_w_r12b_to_r12c
	.byte prgb_lvl2c	; level2_w_r12_to_r12b
	.byte prgb_lvl2e	; level2_w_r12_to_end_chase
	.byte prgb_lvl2c	; level2_w_r12d_to_r12b
	.byte prgb_lvl2c	; level2_w_r12d_to_r12
	.byte prgb_lvl2c	; level2_w_r12c_to_r12b
	.byte prgb_lvl2c	; level2_w_end_chase_to_r12
	.byte prgb_lvl2d	; level2_w_d9_to_d0b
