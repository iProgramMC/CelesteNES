level2_start_p:
	.byte $CC,$CC,$CC,$0C,$00,$A0,$08,$00
	.byte $FD,$FF,$FD,$FF,$FD,$FF,$0F,$00
	.byte $60,$22,$02,$FD,$FF,$FD,$FF,$FD
	.byte $FF,$0F,$00,$90,$AA,$0A,$FD,$FF
	.byte $FD,$FF,$FD,$FF,$0F,$00,$A0,$0A
	.byte $00,$FD,$FF,$FD,$FF,$FD,$FF,$FD
	.byte $FF,$FD,$FF,$2A,$00,$00,$FD,$FF
	.byte $FD,$FF,$FD,$FF,$FD,$FF,$FD,$FF
	.byte $0A,$00,$00,$FD,$FF,$FD,$FF,$FD
	.byte $FF,$0F,$00,$8A,$00,$00,$FD,$FF
	.byte $FD,$FF,$FD,$FF,$0F,$00,$54,$00
	.byte $00,$FD,$FF,$FD,$FF,$FD,$FF,$0F
	.byte $00,$51,$00,$00,$33,$33,$33,$03
	.byte $00,$A0,$00,$00,$FF
level2_start_e:
	.byte $90,$58,$18
	.byte $F8,$9C,$13
	.byte $FF
level2_start_t:
	.byte $D6,$21,$2F,$A6,$EE,$96,$1E,$36
	.byte $86,$96,$00,$22,$33,$85,$97,$23
	.byte $2B,$85,$97,$21,$2C,$2C,$33,$30
	.byte $2F,$2B,$97,$1E,$29,$A5,$2A,$97
	.byte $3D,$A6,$EE,$97,$3C,$86,$97,$3E
	.byte $86,$97,$01,$28,$27,$27,$27,$28
	.byte $27,$97,$22,$2D,$33,$33,$30,$32
	.byte $2D,$97,$23,$30,$A5,$EE,$97,$21
	.byte $2D,$85,$97,$22,$2C,$85,$97,$21
	.byte $32,$85,$96,$1D,$37,$A6,$EE,$95
	.byte $1D,$37,$A7,$EE,$92,$6E,$1D,$28
	.byte $37,$A8,$EE,$8B,$A8,$EF,$21,$30
	.byte $A9,$EE,$93,$23,$2D,$89,$93,$21
	.byte $33,$89,$94,$30,$89,$8B,$C7,$6F
	.byte $1E,$36,$2D,$88,$92,$00,$00,$23
	.byte $89,$95,$2E,$88,$94,$1E,$36,$88
	.byte $94,$00,$21,$31,$87,$95,$1E,$36
	.byte $87,$95,$00,$05,$87,$96,$07,$13
	.byte $86,$95,$70,$07,$14,$86,$95,$71
	.byte $05,$17,$86,$95,$72,$05,$1A,$86
	.byte $95,$73,$07,$13,$86,$95,$00,$06
	.byte $19,$86,$97,$A7,$EE,$96,$22,$87
	.byte $97,$2E,$86,$52,$46,$94,$23,$2B
	.byte $86,$00,$50,$94,$22,$32,$86,$FF
level2_start:
	.byte 40, 0
	.byte 2, 255, 255, 1
	.byte 8, 0, 0, 0
	.byte 40
	.byte 64, 0, 0, 0
	.byte 255, 0, 0, 0
	.byte 0, 0, 0, 0
	.word level2_start_t
	.word level2_start_p
	.word level2_start_e
level2_s1_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FF
level2_s1_e:
	.byte $FF
level2_s1_t:
	.byte $DE,$9E,$9E,$9E,$8B,$48,$53,$52
	.byte $53,$53,$52,$52,$52,$4A,$8A,$8B
	.byte $E9,$4E,$5C,$58,$EE,$5C,$5D,$57
	.byte $57,$50,$8A,$8B,$4C,$5A,$A5,$EE
	.byte $5C,$4F,$8A,$8B,$4D,$58,$84,$5C
	.byte $60,$4B,$8A,$89,$48,$53,$63,$A5
	.byte $EE,$5B,$51,$CB,$89,$4C,$57,$A6
	.byte $EE,$59,$50,$8B,$52,$52,$53,$52
	.byte $52,$52,$53,$52,$52,$63,$A7,$EE
	.byte $58,$8C,$E9,$5C,$59,$EE,$5B,$5C
	.byte $5A,$EE,$57,$59,$A9,$EE,$8C,$B2
	.byte $EE,$51,$8B,$91,$58,$4F,$8B,$91
	.byte $59,$51,$8B,$91,$E1,$EE,$8C,$92
	.byte $4F,$8B,$91,$58,$51,$8B,$91,$57
	.byte $8C,$91,$E2,$EE,$4F,$8B,$91,$58
	.byte $51,$8B,$91,$57,$8C,$91,$5C,$4F
	.byte $8B,$91,$5A,$51,$8B,$91,$5D,$4F
	.byte $8B,$92,$51,$8B,$91,$E2,$EE,$50
	.byte $8B,$91,$5B,$4F,$8B,$91,$E3,$EE
	.byte $61,$4A,$8A,$92,$5C,$4F,$8A,$92
	.byte $EC,$EE,$61,$52,$53,$53,$53,$52
	.byte $53,$53,$52,$53,$52,$93,$EB,$5C
	.byte $56,$57,$57,$EE,$57,$5D,$5B,$5C
	.byte $5B,$5D,$FF
level2_s1:
	.byte 32, 128
	.byte 19, 18, 255, 255
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level2_s1_t
	.word level2_s1_p
	.word level2_s1_e
level2_r2_fake_p:
	.byte $00,$80,$08,$00,$00,$00,$00,$00
	.byte $00,$00,$02,$00,$00,$40,$00,$00
	.byte $00,$00,$00,$00,$00,$10,$00,$00
	.byte $FE,$00,$00,$00,$80,$88,$A8,$00
	.byte $00,$00,$00,$00,$20,$AA,$AA,$08
	.byte $00,$00,$00,$00,$00,$A0,$AA,$0A
	.byte $00,$00,$00,$00,$00,$20,$0A,$00
	.byte $00,$FF
level2_r2_fake_e:
	.byte $FF
level2_r2_fake_t:
	.byte $E6,$5C,$5D,$EE,$57,$5A,$58,$A9
	.byte $EE,$60,$55,$4B,$C5,$4E,$56,$A5
	.byte $EE,$E9,$54,$55,$54,$55,$54,$55
	.byte $62,$EE,$5B,$85,$5D,$50,$C7,$4E
	.byte $58,$85,$C6,$1E,$2A,$2A,$36,$84
	.byte $57,$89,$A6,$EE,$86,$00,$00,$00
	.byte $21,$5B,$83,$E2,$EE,$4F,$87,$4D
	.byte $59,$85,$89,$23,$57,$84,$51,$88
	.byte $56,$85,$89,$1E,$62,$84,$4F,$87
	.byte $45,$55,$62,$84,$89,$00,$4C,$83
	.byte $56,$51,$87,$3D,$00,$4D,$57,$83
	.byte $8B,$57,$83,$50,$87,$3C,$00,$4E
	.byte $A4,$EE,$8B,$5D,$82,$E2,$EE,$4F
	.byte $89,$4C,$5C,$83,$8A,$4E,$A3,$EE
	.byte $5D,$88,$3E,$00,$4E,$56,$83,$8E
	.byte $58,$50,$87,$44,$52,$63,$A4,$EE
	.byte $8A,$4C,$83,$57,$4F,$87,$49,$54
	.byte $62,$84,$8A,$4E,$57,$82,$E2,$EE
	.byte $51,$87,$3D,$00,$4E,$5D,$83,$8B
	.byte $58,$82,$5D,$4F,$87,$3E,$00,$4D
	.byte $58,$83,$8B,$57,$82,$E1,$EE,$88
	.byte $44,$53,$63,$A4,$EE,$8A,$4C,$A4
	.byte $EE,$88,$49,$54,$62,$84,$8A,$4E
	.byte $5C,$82,$59,$51,$86,$40,$00,$00
	.byte $4D,$58,$83,$8B,$57,$82,$E2,$EE
	.byte $4F,$86,$E1,$E6,$82,$4E,$5B,$83
	.byte $8A,$4D,$5C,$83,$35,$27,$1F,$83
	.byte $1D,$26,$83,$58,$83,$8A,$4E,$5A
	.byte $59,$82,$E8,$EE,$2D,$35,$28,$27
	.byte $28,$29,$24,$83,$A4,$EE,$8A,$49
	.byte $55,$54,$55,$36,$2D,$A2,$EE,$34
	.byte $29,$26,$00,$23,$28,$53,$63,$84
	.byte $8A,$C4,$1E,$2A,$36,$2B,$26,$00
	.byte $21,$27,$29,$36,$56,$A5,$EE,$8E
	.byte $00,$00,$1E,$36,$35,$28,$37,$25
	.byte $00,$21,$2D,$85,$90,$00,$1E,$2A
	.byte $36,$31,$35,$28,$37,$A6,$EE,$91
	.byte $00,$00,$1E,$2A,$36,$34,$29,$36
	.byte $85,$93,$00,$00,$23,$26,$00,$21
	.byte $2D,$84,$96,$35,$28,$37,$A5,$EE
	.byte $93,$E5,$1D,$27,$37,$EE,$2E,$A6
	.byte $EE,$93,$1E,$36,$A9,$EE,$93,$00
	.byte $22,$2C,$88,$94,$23,$2F,$88,$94
	.byte $21,$32,$88,$FF
level2_r2_fake:
	.byte 32, 0
	.byte 255, 255, 24, 255
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level2_r2_fake_t
	.word level2_r2_fake_p
	.word level2_r2_fake_e
level2_s2_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FF
level2_s2_e:
	.byte $FF
level2_s2_t:
	.byte $DE,$9E,$53,$53,$53,$52,$53,$52
	.byte $52,$52,$53,$46,$94,$56,$A2,$EE
	.byte $56,$57,$5A,$A2,$EE,$60,$54,$66
	.byte $5E,$92,$A7,$EE,$60,$4B,$D5,$87
	.byte $50,$D6,$86,$60,$47,$96,$85,$59
	.byte $51,$D7,$85,$E2,$EE,$50,$97,$85
	.byte $60,$47,$97,$85,$50,$D2,$48,$52
	.byte $A4,$53,$84,$5B,$4F,$92,$E6,$4E
	.byte $5D,$EE,$5A,$5C,$5B,$84,$E1,$EE
	.byte $93,$4D,$5B,$A4,$EE,$85,$50,$92
	.byte $4C,$A5,$EE,$85,$51,$90,$48,$52
	.byte $63,$85,$84,$59,$4F,$90,$4E,$5B
	.byte $A6,$EE,$84,$E4,$EE,$61,$52,$46
	.byte $8E,$4C,$A7,$EE,$85,$A2,$EE,$4F
	.byte $8F,$5B,$86,$85,$60,$54,$4B,$8E
	.byte $4E,$A7,$EE,$84,$5C,$51,$D0,$4C
	.byte $5B,$86,$84,$56,$4F,$90,$4D,$59
	.byte $86,$85,$50,$8F,$48,$63,$A7,$EE
	.byte $84,$5D,$4F,$8F,$4C,$5A,$87,$84
	.byte $56,$51,$8F,$4D,$5C,$87,$84,$57
	.byte $4F,$8F,$45,$62,$87,$84,$E2,$EE
	.byte $50,$8F,$00,$4C,$87,$84,$5B,$4F
	.byte $91,$5B,$86,$84,$56,$50,$90,$4E
	.byte $56,$86,$84,$E5,$EE,$61,$53,$53
	.byte $4A,$8D,$4C,$5D,$86,$85,$A3,$EE
	.byte $61,$53,$53,$53,$4A,$89,$4D,$5B
	.byte $86,$88,$EA,$EE,$5B,$58,$EE,$61
	.byte $53,$53,$52,$52,$52,$A4,$53,$63
	.byte $A7,$EE,$89,$A5,$EE,$E8,$5B,$EE
	.byte $5C,$58,$5C,$5B,$57,$5A,$A8,$EE
	.byte $FF
level2_s2:
	.byte 32, 128
	.byte 255, 33, 255, 255
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level2_s2_t
	.word level2_s2_p
	.word level2_s2_e
level2_d3b_p:
	.byte $00,$00,$0F,$FD,$FF,$C0,$CC,$00
	.byte $00,$00,$00,$0F,$33,$33,$F3,$0F
	.byte $00,$00,$00,$CF,$CC,$CC,$FC,$0F
	.byte $00,$00,$00,$00,$00,$30,$33,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FE,$FE,$FE,$FF
level2_d3b_e:
	.byte $38,$80,$01,$00
	.byte $FF
level2_d3b_t:
	.byte $C4,$E7,$E3,$BD,$00,$00,$00,$B8
	.byte $DC,$D3,$84,$E1,$DE,$85,$E1,$DD
	.byte $93,$84,$E1,$DD,$84,$E2,$BA,$DE
	.byte $93,$84,$E2,$E3,$BB,$84,$E1,$DC
	.byte $84,$E4,$E3,$DC,$DE,$DF,$8B,$84
	.byte $E2,$DC,$BD,$84,$E6,$E3,$E2,$DF
	.byte $E1,$C6,$C5,$A2,$C4,$E2,$C5,$C8
	.byte $8A,$84,$E2,$E0,$BB,$83,$E6,$B2
	.byte $C3,$C2,$C5,$C4,$B7,$C4,$E2,$B9
	.byte $E2,$89,$84,$E2,$E1,$BD,$83,$CA
	.byte $E2,$BA,$E0,$89,$84,$E2,$DC,$BB
	.byte $8E,$DF,$89,$84,$E1,$E1,$8E,$E2
	.byte $B9,$DC,$89,$84,$E1,$E3,$8F,$E1
	.byte $E3,$89,$84,$E3,$00,$C7,$BE,$A2
	.byte $C1,$BF,$A3,$C1,$E2,$BF,$B5,$84
	.byte $E2,$BA,$DE,$89,$85,$EF,$00,$DE
	.byte $E1,$E3,$DC,$DF,$E3,$DD,$E3,$C7
	.byte $C1,$C0,$BF,$C0,$C9,$CA,$86,$C9
	.byte $E4,$E3,$DC,$E3,$E0,$CB,$8F,$CF
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$FF
level2_d3b:
	.byte 32, 0
	.byte 255, 255, 60, 61
	.byte 0, 0, 242, 234
	.byte 1
	.byte 255
	.word level2_d3b_t
	.word level2_d3b_p
	.word level2_d3b_e
level2_r2__p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FF
level2_r2__e:
	.byte $10,$00,$15,$00
	.byte $FF
level2_r2__t:
	.byte $FE,$5C,$56,$EE,$5D,$5C,$5D,$EE
	.byte $5D,$EE,$5D,$56,$EE,$59,$59,$59
	.byte $EE,$5D,$5D,$5A,$EE,$57,$5B,$57
	.byte $5B,$5A,$58,$59,$58,$EE,$5B,$54
	.byte $55,$54,$55,$54,$55,$55,$54,$54
	.byte $55,$54,$54,$54,$55,$54,$54,$55
	.byte $55,$55,$54,$54,$55,$54,$55,$54
	.byte $54,$55,$55,$55,$54,$DE,$9E,$9E
	.byte $9E,$53,$53,$52,$52,$53,$A4,$52
	.byte $53,$52,$53,$52,$53,$52,$A4,$53
	.byte $52,$53,$52,$52,$53,$52,$52,$46
	.byte $83,$E2,$EE,$5D,$A2,$EE,$60,$55
	.byte $54,$62,$5A,$5D,$A2,$EE,$EF,$5B
	.byte $EE,$58,$60,$55,$54,$62,$58,$5D
	.byte $58,$58,$5D,$60,$54,$4B,$83,$A3
	.byte $EE,$58,$51,$00,$00,$49,$55,$62
	.byte $82,$A3,$EE,$51,$A2,$EE,$4D,$57
	.byte $A3,$EE,$5D,$51,$C5,$83,$5B,$4F
	.byte $82,$00,$00,$4E,$58,$84,$50,$83
	.byte $A4,$EE,$56,$50,$85,$84,$50,$84
	.byte $4C,$A5,$EE,$61,$52,$52,$63,$84
	.byte $5A,$86,$83,$E3,$EE,$61,$4A,$83
	.byte $4E,$5B,$84,$E3,$EE,$5C,$5A,$A6
	.byte $EE,$61,$53,$46,$83,$84,$58,$51
	.byte $83,$45,$54,$54,$54,$62,$82,$A3
	.byte $EE,$E4,$56,$EE,$5D,$5A,$A2,$EE
	.byte $58,$61,$46,$82,$84,$56,$84,$C4
	.byte $4E,$5C,$58,$82,$60,$54,$55,$54
	.byte $55,$55,$55,$54,$55,$4B,$82,$84
	.byte $E2,$EE,$50,$87,$E6,$45,$55,$62
	.byte $EE,$60,$47,$CB,$8D,$00,$00,$4C
	.byte $5D,$50,$CC,$84,$59,$83,$E9,$48
	.byte $53,$52,$53,$52,$52,$53,$63,$EE
	.byte $8D,$84,$EB,$EE,$61,$52,$52,$63
	.byte $5B,$57,$5C,$EE,$58,$57,$A2,$EE
	.byte $61,$53,$52,$52,$4A,$88,$85,$E2
	.byte $EE,$5D,$AB,$EE,$5A,$5A,$57,$61
	.byte $53,$53,$53,$4A,$84,$86,$B0,$EE
	.byte $E5,$5C,$EE,$59,$61,$4A,$83,$96
	.byte $A3,$EE,$5B,$51,$83,$99,$58,$50
	.byte $83,$99,$60,$55,$5E,$82,$98,$60
	.byte $4B,$C4,$97,$58,$4F,$C5,$97,$5B
	.byte $51,$85,$97,$E1,$EE,$86,$98,$61
	.byte $46,$84,$98,$60,$47,$84,$98,$51
	.byte $C5,$98,$4F,$85,$97,$57,$61,$52
	.byte $4A,$83,$FF
level2_r2_:
	.byte 32, 0
	.byte 255, 72, 255, 255
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level2_r2__t
	.word level2_r2__p
	.word level2_r2__e
level2_r12bp_p:
	.byte $00,$00,$00,$00,$00,$A0,$00,$00
	.byte $00,$00,$00,$00,$00,$A0,$0A,$00
	.byte $00,$00,$39,$FC,$15,$69,$0A,$00
	.byte $00,$00,$22,$03,$23,$A2,$0A,$00
	.byte $00,$00,$00,$00,$00,$A0,$02,$00
	.byte $00,$00,$AB,$BF,$A6,$24,$0A,$00
	.byte $00,$00,$01,$23,$22,$A0,$02,$00
	.byte $00,$00,$00,$00,$00,$A0,$0A,$00
	.byte $FF
level2_r12bp_e:
	.byte $18,$A0,$03
	.byte $FF
level2_r12bp_t:
	.byte $D6,$23,$33,$A6,$EE,$96,$22,$30
	.byte $86,$96,$21,$31,$86,$96,$22,$30
	.byte $86,$96,$1E,$36,$86,$96,$00,$21
	.byte $2F,$85,$98,$33,$85,$98,$32,$85
	.byte $97,$1E,$36,$85,$89,$F1,$A8,$8A
	.byte $8B,$8C,$8D,$8E,$8F,$88,$89,$8A
	.byte $8B,$8C,$8D,$8E,$AC,$22,$31,$84
	.byte $89,$F1,$9A,$82,$86,$7A,$7E,$82
	.byte $86,$7A,$7E,$82,$86,$7A,$7E,$82
	.byte $A2,$22,$32,$84,$89,$F1,$9B,$83
	.byte $87,$7B,$7F,$83,$87,$7B,$7F,$83
	.byte $87,$7B,$7F,$83,$A3,$23,$30,$84
	.byte $89,$F1,$AB,$92,$93,$94,$95,$96
	.byte $97,$90,$91,$92,$93,$94,$95,$96
	.byte $AF,$21,$31,$84,$89,$CE,$1D,$37
	.byte $A5,$EE,$97,$22,$2E,$85,$98,$33
	.byte $85,$97,$21,$32,$85,$98,$30,$85
	.byte $96,$1D,$37,$A6,$EE,$96,$22,$30
	.byte $86,$96,$1E,$2A,$36,$85,$88,$F2
	.byte $A9,$89,$8A,$8B,$8C,$8D,$8E,$8F
	.byte $88,$89,$8A,$8B,$8C,$8D,$8E,$AC
	.byte $22,$2B,$84,$88,$F2,$9E,$7E,$82
	.byte $86,$7A,$7E,$82,$86,$7A,$7E,$82
	.byte $86,$7A,$7E,$82,$A6,$21,$32,$84
	.byte $88,$F2,$9F,$7F,$83,$87,$7B,$7F
	.byte $83,$87,$7B,$7F,$83,$87,$7B,$7F
	.byte $83,$A7,$21,$2C,$84,$88,$F2,$AA
	.byte $91,$92,$93,$94,$95,$96,$97,$90
	.byte $91,$92,$93,$94,$95,$96,$AF,$21
	.byte $2E,$84,$88,$CE,$1D,$28,$37,$A5
	.byte $EE,$53,$4A,$94,$21,$2B,$A6,$EE
	.byte $5B,$61,$53,$4A,$92,$23,$31,$86
	.byte $A2,$EE,$57,$50,$88,$44,$53,$52
	.byte $4A,$86,$1E,$36,$86,$82,$E3,$EE
	.byte $61,$4A,$87,$45,$54,$55,$47,$86
	.byte $00,$22,$2B,$85,$83,$58,$51,$87
	.byte $CB,$22,$2D,$85,$83,$59,$93,$23
	.byte $2F,$85,$FF
level2_r12bp:
	.byte 32, 0
	.byte 255, 255, 76, 77
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level2_r12bp_t
	.word level2_r12bp_p
	.word level2_r12bp_e
level2_r12c_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$90,$03,$00,$00,$00
	.byte $00,$0F,$00,$00,$00,$70,$05,$00
	.byte $00,$00,$00,$09,$00,$00,$00,$90
	.byte $0E,$00,$00,$00,$C0,$0A,$00,$00
	.byte $00,$B0,$0A,$00,$00,$00,$F0,$03
	.byte $00,$00,$00,$A0,$01,$00,$00,$00
	.byte $A0,$00,$00,$00,$00,$10,$01,$00
	.byte $00,$00,$C0,$0A,$00,$00,$00,$20
	.byte $05,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$01,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$FF
level2_r12c_e:
	.byte $48,$B0,$81,$0F
	.byte $FF
level2_r12c_t:
	.byte $28,$30,$AC,$D2,$EE,$FE,$FE,$F1
	.byte $5B,$59,$E1,$57,$59,$E1,$57,$5C
	.byte $5C,$E4,$F0,$60,$55,$55,$54,$54
	.byte $55,$54,$55,$54,$55,$62,$E3,$EE
	.byte $60,$55,$4B,$A8,$3F,$4C,$59,$E1
	.byte $5C,$ED,$60,$4B,$AA,$E2,$C1,$EE
	.byte $60,$54,$EC,$56,$4F,$AB,$E1,$49
	.byte $62,$4B,$00,$EC,$59,$51,$EB,$00
	.byte $3F,$67,$A2,$EC,$5C,$EE,$C1,$E5
	.byte $E2,$FB,$67,$E2,$EC,$C1,$EE,$4F
	.byte $F0,$FB,$65,$E2,$EC,$56,$50,$E5
	.byte $3F,$C1,$A9,$8F,$88,$89,$8A,$8B
	.byte $8C,$8D,$8E,$8F,$EC,$5D,$4F,$E6
	.byte $9C,$84,$78,$7C,$80,$84,$78,$7C
	.byte $80,$84,$EC,$56,$E7,$9D,$85,$79
	.byte $7D,$81,$85,$79,$7D,$81,$85,$EC
	.byte $5A,$51,$E6,$9E,$86,$7A,$7E,$82
	.byte $86,$7A,$7E,$82,$86,$EC,$58,$E7
	.byte $9F,$87,$7B,$7F,$83,$87,$7B,$7F
	.byte $83,$87,$EC,$56,$50,$E6,$C1,$AA
	.byte $97,$90,$91,$92,$93,$94,$95,$96
	.byte $97,$EC,$C1,$EE,$61,$46,$E5,$64
	.byte $A9,$ED,$C1,$EE,$61,$53,$46,$E3
	.byte $67,$E9,$EE,$C1,$EE,$59,$61,$53
	.byte $52,$53,$50,$E9,$EF,$C1,$EE,$C1
	.byte $EE,$5D,$59,$C1,$EE,$4F,$E9,$F1
	.byte $C1,$EE,$C1,$EE,$59,$51,$E9,$F3
	.byte $C1,$EE,$50,$E9,$F4,$61,$46,$E8
	.byte $F4,$C1,$EE,$61,$52,$46,$E6,$F5
	.byte $C1,$EE,$C1,$EE,$61,$53,$52,$52
	.byte $53,$53,$52,$F7,$C1,$EE,$5C,$57
	.byte $57,$5C,$C1,$EE,$5C,$F8,$C6,$EE
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE
	.byte $FE,$FE,$DE,$EE,$FE,$FE,$FE,$E2
	.byte $5A,$5A,$56,$57,$57,$E1,$58,$E2
	.byte $5C,$58,$E1,$57,$5B,$59,$5C,$5B
	.byte $EB,$60,$C3,$54,$55,$C9,$54,$55
	.byte $C3,$54,$55,$62,$EA,$4B,$B1,$3F
	.byte $4D,$5C,$E9,$B2,$E1,$4E,$EA,$F4
	.byte $59,$E9,$F1,$3F,$44,$63,$CA,$EE
	.byte $F2,$4C,$56,$EA,$F2,$4D,$58,$EA
	.byte $F2,$4E,$C1,$EE,$5D,$5A,$5C,$59
	.byte $E2,$5C,$5B,$5D,$E1,$88,$89,$8A
	.byte $8B,$8C,$8D,$8E,$8F,$88,$89,$8A
	.byte $8B,$8C,$8D,$8E,$C1,$AC,$C1,$E4
	.byte $66,$55,$55,$54,$54,$55,$55,$54
	.byte $55,$54,$55,$55,$54,$78,$7C,$80
	.byte $84,$78,$7C,$80,$84,$78,$7C,$80
	.byte $84,$78,$7C,$80,$C1,$A4,$AE,$79
	.byte $7D,$81,$85,$79,$7D,$81,$85,$79
	.byte $7D,$81,$85,$79,$7D,$81,$C1,$A5
	.byte $EE,$7A,$7E,$82,$86,$7A,$7E,$82
	.byte $86,$7A,$7E,$82,$86,$7A,$7E,$82
	.byte $C1,$A6,$E9,$3C,$E4,$7B,$7F,$83
	.byte $87,$7B,$7F,$83,$87,$7B,$7F,$83
	.byte $87,$7B,$7F,$83,$C1,$A7,$E9,$3E
	.byte $E4,$90,$91,$92,$93,$94,$95,$96
	.byte $97,$90,$91,$92,$93,$94,$95,$96
	.byte $C1,$AF,$E9,$48,$53,$52,$53,$53
	.byte $A4,$3F,$48,$52,$53,$53,$52,$46
	.byte $AE,$4C,$C1,$EE,$59,$C1,$EE,$C1
	.byte $EE,$E5,$4C,$5C,$56,$5B,$C1,$EE
	.byte $4F,$EE,$4E,$5C,$C3,$EE,$E5,$4E
	.byte $E1,$C3,$EE,$51,$EE,$4C,$C4,$EE
	.byte $E5,$4C,$56,$E2,$56,$4F,$EF,$58
	.byte $E3,$E5,$4D,$59,$E2,$5C,$51,$EE
	.byte $4D,$56,$E3,$E3,$3F,$44,$63,$C3
	.byte $EE,$5B,$50,$EE,$4C,$59,$E3,$E4
	.byte $4C,$5C,$E3,$5A,$51,$EE,$4D,$57
	.byte $E3,$E5,$56,$E3,$57,$50,$EE,$4C
	.byte $E4,$C3,$53,$52,$63,$C4,$EE,$5A
	.byte $4F,$ED,$48,$63,$C4,$EE,$C1,$EE
	.byte $58,$C1,$EE,$56,$C6,$EE,$EE,$4C
	.byte $C5,$EE,$E1,$C9,$EE,$61,$46,$EC
	.byte $4E,$E5,$EA,$C1,$EE,$61,$52,$46
	.byte $F0,$EB,$C1,$EE,$59,$61,$52,$53
	.byte $C3,$52,$53,$52,$53,$52,$52,$63
	.byte $E5,$EC,$C1,$EE,$C1,$EE,$56,$5B
	.byte $57,$59,$5B,$59,$57,$5B,$C1,$EE
	.byte $5A,$C6,$EE,$EE,$D0,$EE,$FE,$FE
	.byte $FE,$FE,$FE,$FE,$FF
level2_r12c:
	.byte 40, 15
	.byte 255, 86, 255, 255
	.byte 0, 252, 0, 0
	.byte 32
	.byte 255
	.word level2_r12c_t
	.word level2_r12c_p
	.word level2_r12c_e
level2_end_chase_p:
	.byte $00,$00,$00,$00,$00,$A0,$00,$00
	.byte $00,$00,$00,$00,$00,$A0,$08,$00
	.byte $00,$00,$00,$00,$00,$00,$02,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$80,$00,$00
	.byte $00,$00,$00,$AA,$AA,$AA,$00,$00
	.byte $FE,$00,$00,$00,$22,$22,$A2,$00
	.byte $00,$00,$00,$00,$00,$00,$A0,$00
	.byte $00,$FE,$FF
level2_end_chase_e:
	.byte $FE
	.byte $10,$78,$10
	.byte $FF
level2_end_chase_t:
	.byte $D6,$22,$33,$A6,$EE,$97,$32,$86
	.byte $96,$23,$2E,$86,$96,$22,$87,$96
	.byte $23,$2B,$86,$96,$1E,$36,$86,$96
	.byte $00,$22,$30,$85,$97,$23,$2F,$85
	.byte $97,$4E,$86,$97,$4C,$2B,$85,$95
	.byte $44,$52,$63,$A6,$EE,$95,$4D,$5C
	.byte $A7,$EE,$93,$48,$52,$63,$A8,$EE
	.byte $93,$4C,$5D,$A9,$EE,$93,$45,$62
	.byte $5B,$88,$93,$00,$45,$54,$62,$87
	.byte $94,$00,$00,$4D,$59,$86,$97,$5C
	.byte $86,$96,$21,$2B,$86,$96,$22,$2E
	.byte $86,$8D,$A9,$F0,$23,$2F,$86,$96
	.byte $21,$2E,$86,$96,$23,$32,$86,$97
	.byte $2D,$86,$96,$21,$32,$86,$9E,$96
	.byte $23,$2F,$86,$96,$22,$2B,$86,$97
	.byte $33,$86,$97,$2D,$86,$8D,$C9,$21
	.byte $2C,$86,$96,$22,$33,$86,$96,$21
	.byte $2E,$86,$97,$32,$86,$97,$30,$86
	.byte $97,$33,$86,$97,$31,$86,$96,$22
	.byte $2D,$86,$96,$21,$32,$86,$97,$33
	.byte $86,$FF
level2_end_chase:
	.byte 40, 0
	.byte 255, 255, 87, 255
	.byte 0, 0, 0, 0
	.byte 8
	.byte 255
	.word level2_end_chase_t
	.word level2_end_chase_p
	.word level2_end_chase_e
level2_d9_p:
	.byte $FD,$FF,$FD,$FF,$FD,$FF,$FC,$FD
	.byte $FF,$CF,$00,$00,$FD,$FF,$0F,$F0
	.byte $0F,$00,$F3,$00,$00,$00,$0F,$F0
	.byte $CF,$4C,$F8,$CC,$0C,$00,$0F,$30
	.byte $33,$3F,$3C,$33,$03,$00,$0F,$00
	.byte $08,$3F,$03,$00,$00,$00,$0F,$00
	.byte $0E,$0F,$00,$0F,$00,$00,$0F,$00
	.byte $03,$0F,$00,$03,$00,$00,$FD,$FF
	.byte $15,$FD,$FF,$2F,$22,$0A,$00,$00
	.byte $FD,$FF,$99,$FD,$FF,$0F,$00,$02
	.byte $00,$00,$FD,$FF,$CE,$FD,$FF,$CF
	.byte $CC,$0C,$00,$00,$2F,$22,$EE,$00
	.byte $00,$0F,$00,$00,$0F,$00,$FD,$FF
	.byte $00,$00,$03,$00,$00,$CF,$00,$33
	.byte $00,$88,$00,$00,$00,$30,$33,$33
	.byte $33,$33,$33,$03,$FF
level2_d9_e:
	.byte $FF
level2_d9_t:
	.byte $DE,$A2,$DC,$E4,$DD,$DC,$E2,$E1
	.byte $A2,$E3,$E3,$DF,$DE,$E0,$83,$E7
	.byte $E2,$DD,$DF,$DE,$DF,$E2,$DE,$89
	.byte $E4,$C3,$C2,$C4,$C3,$A2,$C4,$E1
	.byte $C5,$A4,$C2,$E3,$C8,$DC,$C6,$A2
	.byte $C4,$A2,$C5,$E4,$C3,$C4,$C3,$C8
	.byte $88,$CB,$E3,$BA,$C6,$B7,$C7,$E2
	.byte $B8,$E0,$87,$8B,$E2,$B9,$BB,$C8
	.byte $E2,$B3,$C8,$87,$C0,$A4,$BF,$E1
	.byte $B5,$85,$E1,$BA,$89,$E3,$00,$B9
	.byte $E2,$86,$A2,$DD,$E4,$DC,$E3,$DE
	.byte $BC,$86,$E1,$BC,$8A,$E1,$DD,$86
	.byte $C4,$E2,$DD,$BD,$85,$E2,$B8,$BD
	.byte $8A,$DF,$86,$84,$E1,$DC,$87,$E1
	.byte $BC,$89,$E2,$B8,$E0,$86,$84,$E2
	.byte $E3,$BC,$85,$E1,$B9,$8A,$E2,$BA
	.byte $DF,$86,$85,$E1,$BB,$85,$E3,$BA
	.byte $C7,$B4,$88,$E2,$B8,$E3,$86,$84
	.byte $E2,$DC,$BD,$85,$F1,$B8,$E1,$C7
	.byte $BF,$BE,$BF,$B4,$A9,$8B,$8C,$AC
	.byte $B9,$E2,$E3,$DD,$DE,$E3,$A2,$DC
	.byte $84,$E2,$C6,$B7,$86,$E2,$E2,$C6
	.byte $A2,$C5,$EB,$C8,$BB,$9C,$84,$78
	.byte $A4,$B8,$E3,$C6,$C4,$C3,$A3,$C4
	.byte $84,$E1,$BD,$C6,$EE,$B2,$C2,$B6
	.byte $00,$00,$B9,$BD,$9D,$85,$79,$A5
	.byte $B3,$C4,$B7,$C5,$84,$E1,$BB,$86
	.byte $C5,$E6,$B8,$BC,$9E,$86,$7A,$A6
	.byte $C8,$84,$E1,$BC,$8B,$E6,$B9,$BB
	.byte $9F,$87,$7B,$A7,$88,$84,$E1,$BD
	.byte $8B,$E6,$B8,$BB,$98,$84,$78,$A0
	.byte $88,$84,$E1,$BC,$8B,$E6,$BA,$BB
	.byte $AB,$93,$94,$AE,$88,$8C,$E2,$F9
	.byte $FB,$82,$E2,$B9,$BB,$CC,$84,$E1
	.byte $BB,$87,$E2,$FD,$FE,$82,$E2,$BA
	.byte $BC,$8C,$84,$E1,$BD,$8B,$E2,$B8
	.byte $BD,$8C,$84,$E1,$BB,$87,$E2,$FA
	.byte $FC,$82,$E2,$B9,$BC,$86,$E2,$F3
	.byte $F5,$84,$84,$E1,$BC,$87,$E2,$F3
	.byte $F5,$82,$E2,$B8,$BB,$86,$E2,$F7
	.byte $F8,$84,$84,$E1,$BD,$87,$E2,$F7
	.byte $F8,$82,$E1,$B9,$8D,$90,$E2,$BA
	.byte $BD,$86,$E2,$F4,$F6,$84,$84,$E1
	.byte $BB,$87,$E2,$F4,$F6,$8A,$C6,$8C
	.byte $C4,$E2,$B9,$BC,$8C,$84,$E2,$C7
	.byte $B5,$8B,$E1,$BD,$8C,$84,$E2,$DF
	.byte $BD,$8A,$EA,$B8,$BB,$F9,$FB,$F9
	.byte $FB,$F9,$FB,$F9,$FB,$84,$84,$F6
	.byte $00,$C7,$B5,$A8,$88,$89,$8A,$8B
	.byte $AD,$B1,$BE,$BF,$C9,$BB,$FA,$FC
	.byte $FA,$FC,$FA,$FC,$FD,$FE,$84,$85
	.byte $ED,$E3,$BD,$9E,$7A,$7E,$82,$86
	.byte $A6,$B9,$DD,$DE,$DD,$BD,$C6,$86
	.byte $85,$ED,$E2,$BC,$9F,$7B,$7F,$83
	.byte $87,$A7,$B8,$E3,$00,$E1,$BB,$8C
	.byte $85,$EC,$DD,$BB,$98,$78,$7C,$80
	.byte $84,$A0,$B9,$DC,$00,$E0,$8D,$85
	.byte $EC,$E2,$BD,$99,$79,$7D,$81,$85
	.byte $A1,$B8,$DF,$00,$DD,$87,$E2,$FA
	.byte $FC,$84,$85,$E9,$E1,$BB,$9A,$7A
	.byte $7E,$82,$86,$A2,$B9,$82,$E2,$E0
	.byte $BD,$86,$C6,$85,$ED,$DD,$BB,$9B
	.byte $7B,$7F,$83,$87,$A3,$B9,$E3,$00
	.byte $E3,$BB,$8C,$9E,$85,$EC,$E0,$BD
	.byte $9C,$78,$7C,$80,$84,$A4,$BA,$E2
	.byte $00,$E0,$8D,$85,$F5,$DF,$BC,$9D
	.byte $79,$7D,$81,$85,$A5,$BA,$DC,$E2
	.byte $E1,$BB,$F3,$F5,$F3,$F5,$F3,$F5
	.byte $F3,$F5,$84,$85,$F5,$E0,$BC,$AB
	.byte $90,$91,$92,$93,$AE,$B3,$C2,$C5
	.byte $C3,$B7,$F4,$F6,$F4,$F6,$F4,$F6
	.byte $F7,$F8,$84,$85,$EA,$E3,$BB,$F9
	.byte $FB,$F9,$FB,$F9,$FB,$F9,$FB,$C9
	.byte $86,$85,$EA,$C6,$B7,$FA,$FC,$FA
	.byte $FC,$FA,$FC,$FA,$FC,$8F,$84,$E2
	.byte $E3,$BB,$C7,$E2,$F3,$F5,$8F,$84
	.byte $E2,$DC,$BD,$87,$E2,$F7,$F8,$8F
	.byte $84,$E2,$E0,$BC,$98,$84,$E1,$DC
	.byte $93,$E2,$F4,$F6,$84,$84,$E2,$E0
	.byte $BB,$92,$C6,$84,$E2,$E2,$BC,$98
	.byte $84,$E1,$DC,$99,$85,$E1,$BD,$87
	.byte $E2,$F4,$F6,$8F,$84,$E4,$00,$C7
	.byte $C0,$B5,$85,$C8,$E2,$F9,$FB,$87
	.byte $85,$E3,$00,$E3,$BC,$8D,$E2,$FA
	.byte $FC,$87,$86,$F2,$00,$C7,$C0,$BF
	.byte $BE,$C1,$C0,$BF,$BF,$C0,$C1,$C0
	.byte $C0,$BF,$C1,$BE,$C0,$BE,$A2,$C1
	.byte $A3,$BE,$BF,$87,$00,$A2,$DC,$E3
	.byte $E1,$E3,$E2,$A2,$DD,$E3,$E2,$E0
	.byte $E2,$A3,$DE,$E9,$E2,$DD,$E3,$DD
	.byte $E2,$E3,$E1,$E0,$DD,$88,$D6,$9E
	.byte $FF
level2_d9:
	.byte 56, 0
	.byte 88, 255, 255, 255
	.byte 240, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_d9_t
	.word level2_d9_p
	.word level2_d9_e
