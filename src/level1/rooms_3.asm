level1_r7a_p:
	.byte $55,$55,$55,$55,$55,$55,$55,$05
	.byte $11,$11,$55,$55,$11,$55,$11,$01
	.byte $00,$00,$55,$11,$00,$55,$00,$00
	.byte $00,$00,$55,$55,$00,$55,$00,$00
	.byte $00,$00,$55,$05,$00,$11,$00,$00
	.byte $00,$00,$55,$05,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$55,$55,$55,$55,$55
	.byte $55,$55,$05,$FF
level1_r7a_e:
	.byte $FF
level1_r7a_t:
	.byte $BE,$01,$9E,$9E,$9E,$9E,$C8,$83
	.byte $CF,$84,$A4,$01,$9A,$9E,$9E,$9E
	.byte $C8,$96,$9E,$A4,$01,$9A,$9E,$9E
	.byte $82,$C6,$96,$9E,$9E,$88,$D2,$84
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$82,$BC,$01,$9E,$9E,$9E,$FF
level1_r7a:
	.byte 40, 0
	.byte 30, 255, 29, 255
	.byte 232, 0, 0, 0
	.byte 3
	.word level1_r7a_t
	.word level1_r7a_p
	.word level1_r7a_e
level1_r9z_p:
	.byte $55,$55,$55,$55,$55,$55,$55,$05
	.byte $00,$00,$55,$55,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$00,$40,$55,$55,$00
	.byte $00,$00,$00,$00,$50,$55,$55,$00
	.byte $00,$00,$00,$00,$00,$55,$55,$00
	.byte $00,$00,$00,$FE,$55,$55,$55,$55
	.byte $55,$55,$55,$05,$FF
level1_r9z_e:
	.byte $FF
level1_r9z_t:
	.byte $BE,$02,$9E,$9E,$83,$D7,$84,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$98,$A6,$02,$9E,$98,$C6,$98
	.byte $A6,$02,$9E,$98,$00,$00,$00,$83
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$83,$BB,$02,$9E,$9E,$FF
level1_r9z:
	.byte 40, 0
	.byte 255, 34, 255, 35
	.byte 0, 252, 0, 26
	.byte 3
	.word level1_r9z_t
	.word level1_r9z_p
	.word level1_r9z_e
