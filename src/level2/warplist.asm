level2_w_init:
	.byte 8			; room left offset
	.byte 160, 160	; player spawn X/Y
	.word level2_start
level2_w_start_to_0:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_0
level2_w_start_to_s0:
	.byte 0			; room left offset
	.byte 224, 224	; player spawn X/Y
	.word level2_s0
level2_w_0_to_start:
	.byte 8			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_start
level2_w_0_to_r3x:
	.byte 0			; room left offset
	.byte 72, 184	; player spawn X/Y
	.word level2_r3x
level2_w_0_to_r1:
	.byte 0			; room left offset
	.byte 0, 152	; player spawn X/Y
	.word level2_r1
level2_w_0_to_d1:
	.byte 8			; room left offset
	.byte 240, 72	; player spawn X/Y
	.word level2_d1
level2_w_s0_to_start:
	.byte 8			; room left offset
	.byte 160, 160	; player spawn X/Y
	.word level2_start
level2_w_s0_to_s1:
	.byte 0			; room left offset
	.byte 224, 200	; player spawn X/Y
	.word level2_s1
level2_w_r3x_to_r3:
	.byte 0			; room left offset
	.byte 104, 176	; player spawn X/Y
	.word level2_r3
level2_w_r1_to_0:
	.byte 16			; room left offset
	.byte 240, 152	; player spawn X/Y
	.word level2_0
level2_w_r1_to_r1b:
	.byte 0			; room left offset
	.byte 48, 144	; player spawn X/Y
	.word level2_r1b
level2_w_r1_to_r2_fake:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level2_r2_fake
level2_w_r1_to_d0:
	.byte 0			; room left offset
	.byte 144, 48	; player spawn X/Y
	.word level2_d0
level2_w_d1_to_0:
	.byte 16			; room left offset
	.byte 240, 152	; player spawn X/Y
	.word level2_0
level2_w_d1_to_d0:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level2_d0
level2_w_d1_to_d0a:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level2_d0a
level2_w_d1_to_d6:
	.byte 0			; room left offset
	.byte 32, 64	; player spawn X/Y
	.word level2_d6
level2_w_s1_to_s0:
	.byte 0			; room left offset
	.byte 224, 0	; player spawn X/Y
	.word level2_s0
level2_w_s1_to_s2:
	.byte 0			; room left offset
	.byte 88, 176	; player spawn X/Y
	.word level2_s2
level2_w_r3_to_r4:
	.byte 12			; room left offset
	.byte 208, 184	; player spawn X/Y
	.word level2_r4
level2_w_r1b_to_r1:
	.byte 0			; room left offset
	.byte 0, 32	; player spawn X/Y
	.word level2_r1
level2_w_r2_fake_to_r1:
	.byte 8			; room left offset
	.byte 240, 168	; player spawn X/Y
	.word level2_r1
level2_w_d0_to_r1:
	.byte 4			; room left offset
	.byte 120, 176	; player spawn X/Y
	.word level2_r1
level2_w_d0_to_d1:
	.byte 8			; room left offset
	.byte 240, 72	; player spawn X/Y
	.word level2_d1
level2_w_d0_to_d0a:
	.byte 0			; room left offset
	.byte 80, 16	; player spawn X/Y
	.word level2_d0a
level2_w_d0_to_d4:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level2_d4
level2_w_d0a_to_d0:
	.byte 0			; room left offset
	.byte 112, 184	; player spawn X/Y
	.word level2_d0
level2_w_d0a_to_d2:
	.byte 0			; room left offset
	.byte 0, 144	; player spawn X/Y
	.word level2_d2
level2_w_d0a_to_d0b:
	.byte 8			; room left offset
	.byte 208, 80	; player spawn X/Y
	.word level2_d0b
level2_w_d0a_to_d7:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_d7
level2_w_d6_to_d0a:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level2_d0a
level2_w_d6_to_d0b:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level2_d0b
level2_w_s2_to_s1:
	.byte 0			; room left offset
	.byte 88, 56	; player spawn X/Y
	.word level2_s1
level2_w_r4_to_r5:
	.byte 0			; room left offset
	.byte 48, 184	; player spawn X/Y
	.word level2_r5
level2_w_d4_to_d0:
	.byte 8			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level2_d0
level2_w_d4_to_d2b:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level2_d2b
level2_w_d4_to_d5:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level2_d5
level2_w_d2_to_d0a:
	.byte 8			; room left offset
	.byte 240, 80	; player spawn X/Y
	.word level2_d0a
level2_w_d2_to_d2b:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level2_d2b
level2_w_d2_to_d5:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level2_d5
level2_w_d0b_to_d0a:
	.byte 8			; room left offset
	.byte 208, 152	; player spawn X/Y
	.word level2_d0a
level2_w_d0b_to_d6:
	.byte 8			; room left offset
	.byte 240, 184	; player spawn X/Y
	.word level2_d6
level2_w_d0b_to_d7:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_d7
level2_w_d7_to_d0a:
	.byte 8			; room left offset
	.byte 208, 152	; player spawn X/Y
	.word level2_d0a
level2_w_d7_to_d0b:
	.byte 8			; room left offset
	.byte 208, 80	; player spawn X/Y
	.word level2_d0b
level2_w_d7_to_d8:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_d8
level2_w_r5_to_r6:
	.byte 12			; room left offset
	.byte 208, 184	; player spawn X/Y
	.word level2_r6
level2_w_d2b_to_d4:
	.byte 8			; room left offset
	.byte 240, 144	; player spawn X/Y
	.word level2_d4
level2_w_d2b_to_d2:
	.byte 8			; room left offset
	.byte 240, 176	; player spawn X/Y
	.word level2_d2
level2_w_d2b_to_d3u:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_d3u
level2_w_d5_to_d4:
	.byte 8			; room left offset
	.byte 240, 144	; player spawn X/Y
	.word level2_d4
level2_w_d5_to_d2:
	.byte 8			; room left offset
	.byte 240, 176	; player spawn X/Y
	.word level2_d2
level2_w_d5_to_d3u:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_d3u
level2_w_d8_to_d7:
	.byte 8			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_d7
level2_w_d8_to_d3m:
	.byte 0			; room left offset
	.byte 0, 112	; player spawn X/Y
	.word level2_d3m
level2_w_d8_to_d3b:
	.byte 0			; room left offset
	.byte 0, 56	; player spawn X/Y
	.word level2_d3b
level2_w_r6_to_r7:
	.byte 0			; room left offset
	.byte 56, 184	; player spawn X/Y
	.word level2_r7
level2_w_d3u_to_d2b:
	.byte 8			; room left offset
	.byte 240, 96	; player spawn X/Y
	.word level2_d2b
level2_w_d3u_to_d5:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level2_d5
level2_w_d3u_to_d3m:
	.byte 4			; room left offset
	.byte 120, 144	; player spawn X/Y
	.word level2_d3m
level2_w_d3m_to_d8:
	.byte 8			; room left offset
	.byte 240, 48	; player spawn X/Y
	.word level2_d8
level2_w_d3m_to_d3u:
	.byte 4			; room left offset
	.byte 120, 200	; player spawn X/Y
	.word level2_d3u
level2_w_d3b_to_d8:
	.byte 8			; room left offset
	.byte 240, 168	; player spawn X/Y
	.word level2_d8
level2_w_d3b_to_d3m:
	.byte 0			; room left offset
	.byte 0, 112	; player spawn X/Y
	.word level2_d3m
level2_w_r7_to_r8:
	.byte 16			; room left offset
	.byte 216, 184	; player spawn X/Y
	.word level2_r8
level2_w_r8_to_r9:
	.byte 0			; room left offset
	.byte 0, 24	; player spawn X/Y
	.word level2_r9
level2_w_r9_to_r9b:
	.byte 12			; room left offset
	.byte 160, 192	; player spawn X/Y
	.word level2_r9b
level2_w_r9_to_r9z:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level2_r9z
level2_w_r9b_to_r9:
	.byte 0			; room left offset
	.byte 40, 0	; player spawn X/Y
	.word level2_r9
level2_w_r9z_to_r9:
	.byte 0			; room left offset
	.byte 40, 0	; player spawn X/Y
	.word level2_r9
level2_w_r9z_to_r10:
	.byte 8			; room left offset
	.byte 176, 32	; player spawn X/Y
	.word level2_r10
level2_w_r10_to_r10_:
	.byte 8			; room left offset
	.byte 232, 8	; player spawn X/Y
	.word level2_r10_
level2_w_r10__to_r2_:
	.byte 0			; room left offset
	.byte 24, 0	; player spawn X/Y
	.word level2_r2_
level2_w_r2__to_r10_:
	.byte 8			; room left offset
	.byte 232, 8	; player spawn X/Y
	.word level2_r10_
level2_w_r2__to_r2:
	.byte 0			; room left offset
	.byte 24, 56	; player spawn X/Y
	.word level2_r2
level2_w_r2_to_r2_:
	.byte 0			; room left offset
	.byte 24, 0	; player spawn X/Y
	.word level2_r2_
level2_w_r2_to_r11:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_r11
level2_w_r11_to_r2:
	.byte 12			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_r2
level2_w_r11_to_r12bp:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_r12bp
level2_w_r12bp_to_r11:
	.byte 20			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_r11
level2_w_r12bp_to_r12b:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level2_r12b
level2_w_r12b_to_r12bp:
	.byte 0			; room left offset
	.byte 240, 168	; player spawn X/Y
	.word level2_r12bp
level2_w_r12b_to_r12d:
	.byte 0			; room left offset
	.byte 40, 128	; player spawn X/Y
	.word level2_r12d
level2_w_r12b_to_r12c:
	.byte 0			; room left offset
	.byte 128, 184	; player spawn X/Y
	.word level2_r12c
level2_w_r12b_to_r12:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_r12
level2_w_r12d_to_r12b:
	.byte 8			; room left offset
	.byte 120, 176	; player spawn X/Y
	.word level2_r12b
level2_w_r12d_to_r12:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_r12
level2_w_r12c_to_r12b:
	.byte 8			; room left offset
	.byte 128, 72	; player spawn X/Y
	.word level2_r12b
level2_w_r12_to_r12b:
	.byte 16			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_r12b
level2_w_r12_to_end_chase:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_end_chase
level2_w_end_chase_to_r12:
	.byte 28			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_r12
