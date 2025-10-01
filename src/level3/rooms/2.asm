level3_09_d_p:
	.byte $00,$45,$00,$00,$00,$00,$00,$00
	.byte $FE,$00,$05,$00,$00,$00,$00,$00
	.byte $00,$FE,$FE,$FE,$FE,$FE,$FF
level3_09_d_e:
	.byte $FF
level3_09_d_t:
	.byte $DB,$E3,$AD,$00,$00,$9E,$9B,$E3
	.byte $A9,$B5,$B4,$9B,$6F,$00,$00,$9B
	.byte $6E,$82,$9B,$70,$82,$9B,$E1,$A8
	.byte $A2,$B3,$9B,$E3,$AC,$00,$00,$9E
	.byte $9E,$9B,$E1,$AD,$82,$9B,$E1,$AC
	.byte $82,$9B,$E1,$AD,$82,$9E,$9B,$E1
	.byte $AC,$82,$9E,$9B,$E1,$AD,$82,$9E
	.byte $9E,$9E,$9B,$E1,$AC,$82,$9E,$9E
	.byte $9E,$9E,$9E,$9B,$E1,$AD,$82,$9E
	.byte $9E,$9E,$9B,$E1,$AC,$82,$9E,$FF
level3_09_d:
	.byte 32, 0
	.byte 255, 255, 255, 255
	.byte 0, 0, 0, 0
	.byte 2
	.byte 255
	.word level3_09_d_t
	.word level3_09_d_p
	.word level3_09_d_e
level3_10_c_p:
	.byte $11,$11,$11,$11,$11,$11,$11,$01
	.byte $15,$11,$51,$55,$55,$55,$55,$05
	.byte $05,$00,$50,$40,$44,$04,$00,$01
	.byte $45,$00,$D5,$5C,$05,$00,$44,$05
	.byte $55,$00,$75,$53,$45,$00,$00,$00
	.byte $50,$51,$50,$50,$55,$55,$05,$00
	.byte $55,$50,$50,$F0,$F5,$FD,$FF,$00
	.byte $04,$15,$50,$50,$50,$F5,$FD,$FF
	.byte $00,$01,$45,$54,$50,$50,$51,$77
	.byte $47,$04,$00,$00,$50,$50,$00,$00
	.byte $00,$00,$FF
level3_10_c_e:
	.byte $FF
level3_10_c_t:
	.byte $DE,$E3,$B5,$B4,$B5,$A2,$B4,$E1
	.byte $B5,$A2,$B4,$A7,$B5,$A2,$B4,$E1
	.byte $B5,$A2,$B4,$A2,$B5,$E1,$B4,$A3
	.byte $B5,$E1,$B4,$A2,$B5,$E1,$B4,$DE
	.byte $9E,$9E,$A2,$B2,$E4,$B3,$B2,$B3
	.byte $B2,$A4,$B3,$E1,$B2,$A4,$B3,$A3
	.byte $B2,$A2,$B3,$A5,$B2,$E1,$B3,$A4
	.byte $B2,$E5,$00,$00,$00,$BE,$B5,$A5
	.byte $B4,$A2,$B5,$A3,$B4,$E1,$B5,$A4
	.byte $B4,$A3,$B5,$C0,$C6,$83,$E1,$B0
	.byte $D0,$E4,$EA,$ED,$F0,$AC,$86,$94
	.byte $E3,$EC,$EF,$F2,$87,$83,$E1,$AF
	.byte $90,$E1,$F5,$A2,$F4,$87,$94,$E3
	.byte $00,$00,$98,$87,$83,$E1,$B0,$83
	.byte $E4,$A8,$B2,$B3,$BB,$A2,$BA,$E1
	.byte $B1,$88,$E1,$92,$87,$83,$E1,$AF
	.byte $83,$E3,$AC,$00,$AF,$CC,$E2,$99
	.byte $AD,$86,$E4,$00,$BE,$B4,$AB,$85
	.byte $E1,$B0,$8B,$E2,$84,$A7,$87,$E5
	.byte $00,$AF,$D2,$C8,$CA,$83,$E2,$BE
	.byte $AB,$87,$E4,$A8,$B3,$B2,$B3,$A2
	.byte $B2,$E1,$C1,$86,$E5,$00,$B0,$D3
	.byte $C9,$CB,$82,$E2,$AD,$AF,$C8,$E2
	.byte $A9,$B4,$A2,$B5,$A2,$B4,$E2,$B5
	.byte $C0,$85,$82,$E3,$C4,$C6,$D2,$8C
	.byte $C6,$E2,$98,$AC,$85,$82,$E3,$C5
	.byte $C7,$D3,$82,$E2,$AC,$B0,$8E,$E1
	.byte $92,$86,$E9,$00,$BF,$B3,$AA,$00
	.byte $00,$00,$AC,$AF,$8E,$E2,$99,$AD
	.byte $85,$E4,$00,$00,$00,$B0,$84,$E3
	.byte $B0,$9C,$8D,$8C,$E1,$9A,$86,$88
	.byte $E3,$BF,$B2,$B3,$A2,$B2,$E5,$B3
	.byte $B2,$B3,$B2,$AA,$85,$E2,$D6,$AC
	.byte $85,$88,$C9,$E1,$AF,$85,$E4,$D7
	.byte $AD,$BE,$B5,$A2,$B4,$E1,$B5,$87
	.byte $E1,$AD,$8F,$E7,$D6,$AD,$AF,$00
	.byte $00,$6F,$00,$83,$E1,$AF,$83,$E6
	.byte $A9,$C0,$BE,$B5,$B4,$B5,$A2,$B4
	.byte $A2,$B5,$E1,$AB,$86,$E1,$AC,$83
	.byte $6E,$00,$83,$E1,$B0,$82,$E9,$C8
	.byte $CA,$AD,$B0,$C4,$C6,$D0,$CC,$CE
	.byte $C8,$E2,$85,$AD,$85,$86,$E9,$C9
	.byte $CB,$AC,$AF,$C5,$C7,$D1,$CD,$CF
	.byte $88,$E1,$92,$84,$70,$00,$83,$E1
	.byte $AF,$82,$A2,$D2,$E7,$AD,$AF,$C8
	.byte $CA,$D0,$D1,$D3,$88,$E1,$9A,$84
	.byte $E2,$A8,$B3,$83,$E1,$B0,$82,$A2
	.byte $D3,$E7,$AD,$B0,$C9,$CB,$D1,$C8
	.byte $CA,$86,$E3,$84,$87,$A7,$84,$E2
	.byte $AD,$00,$86,$E9,$00,$A8,$C1,$B0
	.byte $CC,$CE,$D0,$C9,$CB,$85,$E2,$A8
	.byte $B2,$A2,$B3,$E2,$C1,$B0,$82,$E2
	.byte $AC,$00,$83,$E1,$AF,$83,$E8,$AC
	.byte $00,$B0,$CD,$CF,$C8,$CA,$D2,$85
	.byte $E1,$A9,$A2,$B4,$A2,$B5,$E1,$AB
	.byte $84,$87,$E8,$AD,$00,$AF,$D0,$D2
	.byte $C9,$CB,$D3,$85,$00,$00,$6F,$C5
	.byte $E2,$AD,$00,$8A,$E3,$D1,$D3,$D0
	.byte $A2,$D1,$87,$6E,$85,$E2,$AC,$00
	.byte $89,$E9,$BF,$B3,$AA,$D1,$C4,$C6
	.byte $D2,$C8,$CA,$8C,$83,$E1,$B0,$85
	.byte $E9,$00,$00,$B0,$D0,$C5,$C7,$D3
	.byte $C9,$CB,$84,$70,$87,$8B,$BF,$A4
	.byte $B3,$E1,$B2,$A5,$B3,$A2,$B2,$A2
	.byte $B3,$E4,$B2,$B3,$C1,$00,$8B,$D3
	.byte $9E,$83,$E1,$AF,$9A,$9E,$87,$E1
	.byte $AC,$96,$FF
level3_10_c:
	.byte 40, 0
	.byte 255, 40, 255, 255
	.byte 0, 224, 0, 0
	.byte 2
	.byte 255
	.word level3_10_c_t
	.word level3_10_c_p
	.word level3_10_c_e
