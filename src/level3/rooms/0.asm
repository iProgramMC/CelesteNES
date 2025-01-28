level3_s0_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$00,$08,$00,$00,$00,$00
	.byte $00,$00,$00,$0A,$00,$00,$00,$00
	.byte $00,$00,$FE,$FE,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$FE,$FE,$FF
level3_s0_e:
	.byte $FF
level3_s0_t:
	.byte $DE,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$84,$01
	.byte $01,$98,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$84,$DA
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$FF
level3_s0:
	.byte 40, 0
	.byte 255, 255, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.byte 255
	.word level3_s0_t
	.word level3_s0_p
	.word level3_s0_e
