level2_start_p:
	.byte $00,$00,$00,$00,$00,$A0,$08,$00
	.byte $00,$00,$00,$00,$00,$60,$22,$02
	.byte $00,$00,$00,$00,$00,$90,$AA,$0A
	.byte $00,$00,$00,$00,$00,$A0,$0A,$00
	.byte $00,$00,$00,$00,$80,$2A,$00,$00
	.byte $00,$00,$00,$00,$20,$0A,$00,$00
	.byte $00,$00,$00,$00,$00,$8A,$00,$00
	.byte $00,$00,$00,$00,$00,$54,$00,$00
	.byte $00,$00,$00,$00,$00,$51,$00,$00
	.byte $00,$00,$00,$00,$00,$A0,$00,$00
	.byte $FF
level2_start_e:
	.byte $90,$58,$10
	.byte $FF
level2_start_t:
	.byte $D6,$21,$2F,$C6,$96,$1E,$36,$86
	.byte $96,$00,$22,$33,$85,$97,$23,$2B
	.byte $85,$97,$21,$2C,$2C,$33,$30,$2F
	.byte $2B,$97,$1E,$29,$A5,$2A,$97,$3D
	.byte $C6,$97,$3C,$86,$97,$3E,$86,$97
	.byte $01,$28,$27,$27,$27,$28,$27,$97
	.byte $22,$2D,$33,$33,$30,$32,$2D,$97
	.byte $23,$30,$C5,$97,$21,$2D,$85,$97
	.byte $22,$2C,$85,$97,$21,$32,$85,$96
	.byte $1D,$37,$C6,$95,$1D,$37,$C7,$92
	.byte $6E,$1D,$28,$37,$C8,$92,$00,$21
	.byte $30,$C9,$93,$23,$2D,$89,$93,$21
	.byte $33,$89,$94,$30,$89,$92,$6F,$1E
	.byte $36,$2D,$88,$92,$00,$00,$23,$89
	.byte $95,$2E,$88,$94,$1E,$36,$88,$94
	.byte $00,$21,$31,$87,$95,$1E,$36,$87
	.byte $95,$00,$05,$87,$96,$07,$13,$86
	.byte $95,$70,$07,$14,$86,$95,$71,$05
	.byte $17,$86,$95,$72,$05,$1A,$86,$95
	.byte $73,$07,$13,$86,$95,$00,$06,$19
	.byte $86,$97,$C7,$96,$22,$87,$97,$2E
	.byte $86,$52,$46,$94,$23,$2B,$86,$00
	.byte $50,$94,$22,$32,$86,$FF
level2_start:
	.byte 40, 0
	.byte 2, 255, 255, 1
	.byte 8, 0, 0, 0
	.byte 0
	.byte 64, 0, 0, 0
	.byte 255, 0, 0, 0
	.byte 0, 0, 0, 0
	.word level2_start_t
	.word level2_start_p
	.word level2_start_e
level2_0_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$21
	.byte $00,$00,$00,$00,$00,$21,$00,$00
	.byte $00,$00,$00,$1A,$00,$00,$00,$00
	.byte $00,$18,$00,$00,$00,$00,$C0,$38
	.byte $00,$00,$00,$00,$C0,$3B,$00,$00
	.byte $00,$00,$40,$1B,$00,$00,$00,$00
	.byte $C0,$31,$00,$00,$00,$00,$00,$0C
	.byte $00,$00,$00,$00,$00,$3D,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$AA,$0A,$00,$80
	.byte $80,$02,$00,$A8,$0A,$80,$0A,$00
	.byte $00,$00,$00,$00,$02,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$FF
level2_0_e:
	.byte $FF
level2_0_t:
	.byte $30,$3C,$BE,$FE,$FE,$FE,$FE,$FE
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE
	.byte $E1,$57,$E2,$5B,$58,$5B,$59,$E1
	.byte $5A,$E1,$5C,$E1,$5D,$57,$E1,$58
	.byte $E1,$59,$E2,$5B,$E2,$58,$E1,$59
	.byte $5B,$E1,$56,$54,$55,$54,$C5,$55
	.byte $C5,$54,$55,$54,$54,$55,$55,$54
	.byte $54,$C3,$55,$54,$55,$54,$54,$55
	.byte $54,$54,$BE,$FE,$FE,$53,$53,$C4
	.byte $52,$53,$C3,$52,$53,$52,$53,$52
	.byte $53,$C3,$52,$53,$52,$52,$53,$52
	.byte $53,$52,$53,$52,$53,$52,$52,$00
	.byte $56,$00,$5A,$00,$5A,$5D,$5B,$00
	.byte $57,$59,$57,$57,$56,$57,$00,$58
	.byte $00,$58,$5C,$56,$59,$60,$55,$55
	.byte $54,$54,$62,$5D,$57,$E1,$B3,$60
	.byte $54,$4B,$A4,$4E,$5B,$E1,$F3,$5A
	.byte $51,$A6,$49,$54,$55,$F3,$56,$50
	.byte $E6,$00,$9F,$87,$F3,$00,$61,$46
	.byte $E6,$98,$84,$F4,$00,$51,$E6,$99
	.byte $85,$F4,$60,$47,$E6,$9A,$86,$F3
	.byte $5C,$51,$A7,$9B,$87,$F3,$5B,$50
	.byte $E7,$9C,$84,$F3,$5C,$E8,$C1,$AB
	.byte $97,$F3,$00,$51,$E7,$A2,$F4,$61
	.byte $46,$E8,$F4,$5C,$4F,$E8,$F4,$60
	.byte $47,$E8,$F3,$57,$50,$A9,$F3,$5B
	.byte $4F,$E9,$F3,$00,$50,$E8,$44,$F3
	.byte $58,$4F,$E8,$45,$F3,$56,$50,$E8
	.byte $00,$F3,$00,$61,$52,$4A,$E7,$F4
	.byte $00,$5D,$61,$52,$4A,$E5,$F5,$A2
	.byte $5B,$51,$E5,$F7,$57,$50,$E5,$F7
	.byte $00,$61,$52,$52,$53,$52,$53,$F8
	.byte $A2,$5C,$56,$56,$58,$FA,$A4,$FE
	.byte $FE,$5D,$51,$B4,$22,$2B,$A6,$00
	.byte $4F,$F5,$32,$E6,$E1,$50,$F5,$31
	.byte $E6,$59,$51,$F4,$21,$E7,$58,$F5
	.byte $23,$2E,$E6,$00,$61,$52,$4A,$F2
	.byte $22,$33,$E6,$E1,$A2,$61,$53,$4A
	.byte $F0,$21,$2F,$E6,$E3,$60,$55,$4B
	.byte $F0,$23,$32,$E6,$E2,$56,$51,$B2
	.byte $E1,$30,$E6,$E2,$5A,$F3,$1E,$36
	.byte $E6,$E2,$59,$61,$4A,$F1,$00,$23
	.byte $2C,$E5,$E2,$60,$55,$47,$F2,$1E
	.byte $36,$E5,$E1,$5B,$51,$B5,$22,$2C
	.byte $E4,$E1,$59,$F6,$21,$30,$E4,$5D
	.byte $00,$61,$52,$53,$4A,$F3,$2F,$E4
	.byte $54,$55,$55,$54,$55,$54,$5E,$F1
	.byte $22,$32,$E4,$B8,$23,$E5,$F9,$31
	.byte $E4,$F8,$22,$2F,$E4,$52,$4A,$ED
	.byte $6A,$6A,$E7,$21,$30,$E4,$5A,$61
	.byte $4A,$EB,$3F,$44,$46,$E7,$4C,$A5
	.byte $E1,$57,$61,$46,$EB,$4E,$4F,$E8
	.byte $5C,$E4,$54,$55,$54,$55,$5E,$EA
	.byte $45,$47,$E8,$A5,$7B,$7F,$83,$87
	.byte $7B,$8D,$8E,$8F,$88,$89,$8A,$8B
	.byte $8C,$8D,$8E,$87,$7B,$C1,$AC,$E4
	.byte $44,$53,$63,$5D,$E4,$78,$7C,$80
	.byte $84,$7D,$7D,$80,$84,$80,$79,$80
	.byte $84,$7D,$7C,$80,$84,$79,$A0,$E4
	.byte $4C,$A7,$79,$7D,$81,$85,$79,$E1
	.byte $81,$85,$79,$7D,$81,$85,$79,$7D
	.byte $81,$85,$E1,$C1,$A1,$E4,$4D,$5B
	.byte $E6,$7A,$7E,$82,$86,$7A,$7E,$82
	.byte $86,$7A,$7E,$82,$86,$7A,$7E,$82
	.byte $86,$7A,$C1,$A2,$E4,$4E,$5A,$E6
	.byte $7B,$7F,$83,$87,$7B,$7F,$83,$87
	.byte $7B,$7F,$83,$87,$7B,$7F,$83,$87
	.byte $7B,$C1,$A3,$E4,$4D,$59,$E6,$83
	.byte $7C,$80,$84,$78,$7C,$80,$84,$84
	.byte $7C,$80,$84,$78,$7C,$80,$84,$E1
	.byte $C1,$A4,$E4,$4C,$57,$E6,$90,$91
	.byte $92,$93,$79,$7D,$81,$85,$79,$7D
	.byte $81,$85,$94,$95,$96,$97,$90,$C1
	.byte $AE,$E4,$49,$62,$E6,$A4,$48,$52
	.byte $52,$53,$52,$53,$52,$4A,$AB,$1E
	.byte $36,$E5,$E4,$4D,$57,$00,$5C,$00
	.byte $60,$54,$55,$5E,$EA,$00,$1E,$36
	.byte $E4,$E4,$4C,$5D,$59,$58,$60,$47
	.byte $AF,$23,$33,$E3,$E4,$45,$62,$58
	.byte $5C,$51,$B0,$21,$E4,$E4,$00,$4D
	.byte $59,$00,$ED,$48,$53,$53,$28,$37
	.byte $A4,$E7,$5C,$4F,$EC,$4D,$A2,$2F
	.byte $A5,$46,$E5,$00,$56,$ED,$45,$62
	.byte $E1,$A6,$4B,$E5,$59,$5A,$51,$EC
	.byte $00,$4D,$5C,$E6,$A5,$45,$62,$00
	.byte $EE,$21,$2D,$E6,$E5,$00,$4D,$5A
	.byte $EE,$23,$2E,$E6,$E6,$4C,$00,$50
	.byte $ED,$22,$2F,$E6,$E6,$4D,$E1,$51
	.byte $EE,$31,$E6,$E7,$57,$EE,$4D,$58
	.byte $E6,$52,$4A,$E5,$00,$50,$EC,$44
	.byte $63,$5C,$E6,$5D,$50,$E4,$4C,$59
	.byte $61,$53,$52,$C5,$53,$4A,$E4,$4E
	.byte $A8,$5A,$51,$E5,$5D,$5A,$57,$58
	.byte $00,$56,$58,$5A,$5B,$50,$E4,$4C
	.byte $58,$E7,$57,$E5,$4D,$E1,$A2,$5B
	.byte $5B,$59,$A3,$51,$E4,$4D,$5B,$E7
	.byte $56,$50,$E4,$4C,$56,$E1,$5A,$56
	.byte $57,$00,$58,$E2,$4F,$ED,$FF
level2_0:
	.byte 48, 15
	.byte 4, 255, 3, 5
	.byte 8, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_0_t
	.word level2_0_p
	.word level2_0_e
level2_s0_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FF
level2_s0_e:
	.byte $FF
level2_s0_t:
	.byte $DE,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$53,$52
	.byte $52,$53,$53,$53,$52,$52,$52,$53
	.byte $52,$52,$52,$53,$53,$53,$A4,$52
	.byte $A4,$53,$52,$53,$53,$53,$52,$52
	.byte $00,$5C,$5B,$57,$00,$56,$00,$5B
	.byte $59,$58,$59,$57,$58,$57,$58,$58
	.byte $00,$5A,$5C,$5D,$5A,$57,$00,$56
	.byte $58,$5C,$00,$59,$56,$00,$FF
level2_s0:
	.byte 32, 0
	.byte 7, 6, 255, 255
	.byte 0, 248, 0, 0
	.byte 0
	.byte 255
	.word level2_s0_t
	.word level2_s0_p
	.word level2_s0_e
level2_r3x_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$00,$00,$00,$00,$00,$00,$05
	.byte $00,$00,$00,$75,$0E,$70,$3D,$00
	.byte $00,$00,$00,$53,$0B,$F0,$84,$00
	.byte $00,$00,$00,$D6,$0D,$A0,$E4,$00
	.byte $00,$00,$00,$73,$0C,$30,$1D,$00
	.byte $00,$00,$00,$1D,$04,$D0,$7E,$00
	.byte $00,$00,$00,$33,$02,$00,$23,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FF
level2_r3x_e:
	.byte $FF
level2_r3x_t:
	.byte $DE,$92,$5B,$56,$83,$59,$86,$90
	.byte $60,$A4,$54,$55,$55,$55,$62,$85
	.byte $87,$5C,$56,$59,$00,$57,$83,$60
	.byte $4B,$C7,$4D,$58,$84,$86,$60,$54
	.byte $54,$55,$54,$54,$62,$00,$5B,$51
	.byte $C8,$4D,$5D,$84,$85,$5A,$4F,$C5
	.byte $4C,$5A,$5B,$4F,$89,$56,$84,$00
	.byte $59,$5C,$5A,$5B,$60,$47,$85,$4D
	.byte $5B,$60,$47,$88,$4E,$5C,$5B,$5B
	.byte $5B,$56,$54,$55,$54,$54,$54,$4B
	.byte $C6,$4D,$56,$51,$C9,$49,$54,$54
	.byte $55,$55,$54,$CC,$82,$50,$89,$00
	.byte $3D,$C4,$8C,$49,$55,$51,$8A,$3C
	.byte $84,$8C,$00,$00,$4E,$8A,$3E,$84
	.byte $52,$53,$53,$52,$52,$4A,$93,$01
	.byte $53,$53,$52,$53,$00,$58,$56,$56
	.byte $58,$51,$82,$A1,$A8,$A1,$89,$A1
	.byte $8A,$A1,$8B,$A1,$8C,$A1,$AD,$4E
	.byte $52,$53,$4A,$A1,$A8,$A1,$8B,$A1
	.byte $8C,$A1,$8D,$A1,$AC,$82,$4D,$00
	.byte $00,$00,$5D,$C5,$61,$52,$46,$A1
	.byte $9D,$7D,$A1,$81,$A1,$85,$79,$A1
	.byte $A5,$4E,$60,$55,$4B,$A1,$9D,$A1
	.byte $85,$79,$7D,$A1,$A5,$83,$5B,$82
	.byte $00,$85,$5B,$5C,$4F,$A1,$9E,$7E
	.byte $A1,$82,$A1,$86,$7A,$A1,$A6,$4D
	.byte $4F,$00,$00,$A1,$9E,$A1,$86,$7A
	.byte $7E,$A1,$A6,$44,$53,$63,$C4,$85
	.byte $00,$57,$51,$A1,$9F,$7F,$A1,$83
	.byte $A1,$87,$7B,$A1,$A7,$4E,$50,$82
	.byte $A1,$9F,$A1,$87,$7B,$7F,$A1,$A7
	.byte $4D,$00,$57,$84,$85,$5B,$00,$4F
	.byte $A1,$98,$7C,$80,$A1,$84,$78,$A0
	.byte $84,$A1,$98,$A1,$84,$78,$7C,$A0
	.byte $4E,$5C,$56,$84,$85,$60,$55,$4B
	.byte $A1,$99,$7D,$A1,$81,$A1,$85,$79
	.byte $A1,$A1,$4D,$83,$A1,$99,$A1,$85
	.byte $79,$7D,$A1,$A1,$45,$54,$62,$84
	.byte $84,$5D,$4F,$00,$00,$A1,$9A,$7E
	.byte $A1,$82,$A1,$86,$7A,$A1,$A2,$4E
	.byte $4F,$82,$A1,$9A,$A1,$86,$7A,$7E
	.byte $A1,$A2,$00,$00,$4E,$5B,$83,$88
	.byte $A1,$9B,$7F,$A1,$83,$A1,$87,$7B
	.byte $A1,$A3,$4C,$83,$A1,$9B,$A1,$87
	.byte $7B,$7F,$A1,$A3,$83,$58,$83,$84
	.byte $5B,$83,$A1,$9C,$7C,$80,$A1,$84
	.byte $78,$A1,$A4,$4E,$61,$53,$46,$A1
	.byte $9C,$A1,$84,$78,$7C,$A1,$A4,$83
	.byte $C4,$84,$56,$83,$A1,$9D,$7D,$A1
	.byte $81,$A1,$85,$79,$A1,$A5,$4E,$59
	.byte $5C,$50,$A1,$9D,$A1,$85,$79,$7D
	.byte $A1,$A5,$83,$5A,$83,$84,$59,$51
	.byte $82,$A1,$9E,$7E,$A1,$82,$A1,$86
	.byte $7A,$A1,$A6,$4D,$55,$54,$4B,$A1
	.byte $9E,$A1,$86,$7A,$7E,$A1,$A6,$83
	.byte $59,$83,$84,$5A,$50,$82,$A1,$9F
	.byte $7F,$A1,$83,$A1,$87,$7B,$A1,$A7
	.byte $4D,$00,$00,$00,$A1,$9F,$A1,$87
	.byte $7B,$7F,$A1,$A7,$83,$C4,$84,$00
	.byte $61,$53,$4A,$A1,$98,$7C,$80,$A1
	.byte $84,$78,$A0,$4E,$83,$A1,$98,$A1
	.byte $84,$78,$7C,$A0,$82,$4D,$84,$85
	.byte $56,$56,$50,$A1,$99,$7D,$A1,$81
	.byte $A1,$85,$79,$A1,$A1,$84,$A1,$99
	.byte $A1,$85,$79,$7D,$A1,$A1,$82,$4C
	.byte $59,$83,$85,$60,$54,$4B,$A1,$9A
	.byte $7E,$A1,$82,$A1,$86,$7A,$A1,$A2
	.byte $4D,$4A,$82,$A1,$9A,$A1,$86,$7A
	.byte $7E,$A1,$A2,$82,$4D,$C4,$84,$59
	.byte $50,$00,$00,$A1,$9B,$7F,$A1,$83
	.byte $A1,$87,$7B,$A1,$A3,$4D,$51,$82
	.byte $A1,$9B,$A1,$87,$7B,$7F,$A1,$A3
	.byte $82,$4C,$5A,$83,$88,$A1,$9C,$7C
	.byte $80,$A1,$84,$78,$A1,$A4,$4D,$61
	.byte $52,$4A,$A1,$9C,$A1,$84,$78,$7C
	.byte $A1,$A4,$82,$4D,$59,$83,$84,$5A
	.byte $4F,$82,$A1,$9D,$7D,$A1,$81,$A1
	.byte $85,$79,$A1,$A5,$45,$55,$54,$4B
	.byte $A1,$9D,$A1,$85,$79,$7D,$A1,$A5
	.byte $82,$4C,$84,$84,$56,$51,$82,$A1
	.byte $9E,$7E,$A1,$82,$A1,$86,$7A,$A1
	.byte $A6,$C4,$A1,$9E,$A1,$86,$7A,$7E
	.byte $A1,$A6,$83,$C4,$84,$00,$4F,$82
	.byte $A1,$9F,$7F,$A1,$83,$A1,$87,$7B
	.byte $A1,$A7,$84,$A1,$9F,$A1,$87,$7B
	.byte $7F,$A1,$A7,$83,$5A,$83,$84,$59
	.byte $51,$82,$A1,$AA,$A1,$91,$A1,$92
	.byte $A1,$93,$A1,$94,$A1,$AF,$48,$53
	.byte $53,$46,$A1,$98,$A1,$84,$78,$7C
	.byte $A0,$83,$57,$83,$84,$00,$61,$53
	.byte $46,$C6,$4D,$5D,$5B,$4F,$A1,$99
	.byte $A1,$85,$79,$7D,$A1,$A1,$82,$4D
	.byte $5B,$83,$85,$00,$56,$4F,$87,$5B
	.byte $5B,$4F,$A1,$AA,$A1,$93,$A1,$94
	.byte $A1,$95,$A1,$AE,$44,$52,$63,$C4
	.byte $86,$00,$61,$53,$53,$52,$52,$53
	.byte $52,$63,$00,$00,$61,$53,$53,$52
	.byte $53,$52,$63,$5B,$C5,$87,$00,$00
	.byte $00,$5A,$57,$5C,$5B,$C4,$5D,$5C
	.byte $00,$5A,$56,$C7,$8A,$D4,$9E,$9E
	.byte $FF
level2_r3x:
	.byte 40, 0
	.byte 8, 255, 255, 255
	.byte 252, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_r3x_t
	.word level2_r3x_p
	.word level2_r3x_e
level2_s1_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FF
level2_s1_e:
	.byte $FF
level2_s1_t:
	.byte $DE,$9E,$9E,$9E,$8B,$48,$53,$52
	.byte $53,$53,$52,$52,$52,$4A,$8A,$8B
	.byte $4E,$5C,$58,$00,$5C,$5D,$57,$57
	.byte $50,$8A,$8B,$4C,$5A,$C5,$5C,$4F
	.byte $8A,$8B,$4D,$58,$84,$5C,$60,$4B
	.byte $8A,$89,$48,$53,$63,$C5,$5B,$51
	.byte $CB,$89,$4C,$57,$C6,$59,$50,$8B
	.byte $52,$52,$53,$52,$52,$52,$53,$52
	.byte $52,$63,$C7,$58,$8C,$5C,$59,$00
	.byte $5B,$5C,$5A,$00,$57,$59,$C9,$8C
	.byte $D2,$51,$8B,$91,$58,$4F,$8B,$91
	.byte $59,$51,$8B,$91,$00,$8C,$92,$4F
	.byte $8B,$91,$58,$51,$8B,$91,$57,$8C
	.byte $91,$00,$4F,$8B,$91,$58,$51,$8B
	.byte $91,$57,$8C,$91,$5C,$4F,$8B,$91
	.byte $5A,$51,$8B,$91,$5D,$4F,$8B,$92
	.byte $51,$8B,$91,$00,$50,$8B,$91,$5B
	.byte $4F,$8B,$91,$00,$61,$4A,$8A,$92
	.byte $5C,$4F,$8A,$92,$00,$61,$52,$53
	.byte $53,$53,$52,$53,$53,$52,$53,$52
	.byte $93,$5C,$56,$57,$57,$00,$57,$5D
	.byte $5B,$5C,$5B,$5D,$FF
level2_s1:
	.byte 32, 0
	.byte 13, 12, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_s1_t
	.word level2_s1_p
	.word level2_s1_e
level2_r3_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$00,$00,$00,$00,$00,$00
	.byte $05,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$FE,$00,$00,$00,$48,$04
	.byte $08,$00,$00,$00,$00,$00,$E3,$80
	.byte $A4,$08,$00,$00,$00,$00,$00,$00
	.byte $A0,$02,$00,$00,$00,$00,$04,$04
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$FF
level2_r3_e:
	.byte $FF
level2_r3_t:
	.byte $DE,$9E,$92,$58,$00,$5B,$00,$5A
	.byte $5B,$86,$90,$58,$60,$54,$55,$54
	.byte $55,$55,$55,$62,$85,$8B,$57,$5D
	.byte $5C,$56,$60,$54,$4B,$C6,$4E,$58
	.byte $84,$87,$58,$00,$5C,$60,$54,$54
	.byte $55,$55,$47,$C8,$4E,$C5,$86,$60
	.byte $55,$55,$55,$4B,$CD,$4D,$5D,$84
	.byte $85,$60,$4B,$D1,$4E,$C5,$85,$4F
	.byte $D2,$86,$84,$59,$50,$92,$4C,$5A
	.byte $84,$84,$5A,$94,$5C,$58,$57,$5A
	.byte $5B,$84,$60,$4B,$92,$45,$54,$55
	.byte $55,$55,$54,$83,$57,$4F,$D3,$3D
	.byte $C5,$83,$5B,$94,$3C,$85,$83,$5D
	.byte $94,$3E,$85,$83,$00,$50,$8A,$44
	.byte $53,$4A,$86,$01,$0E,$53,$53,$53
	.byte $52,$84,$61,$53,$4A,$88,$45,$55
	.byte $55,$66,$5E,$84,$4D,$5C,$00,$5A
	.byte $59,$58,$84,$00,$00,$61,$46,$87
	.byte $C9,$4C,$5D,$C4,$85,$59,$57,$4F
	.byte $90,$4E,$58,$84,$86,$60,$47,$91
	.byte $C5,$85,$5D,$4F,$D1,$4D,$85,$85
	.byte $58,$50,$8C,$48,$53,$53,$52,$52
	.byte $63,$85,$85,$5B,$4F,$8C,$4E,$C4
	.byte $5D,$85,$85,$5A,$50,$8C,$45,$55
	.byte $55,$54,$55,$55,$62,$84,$85,$00
	.byte $61,$52,$53,$53,$52,$46,$87,$C5
	.byte $3F,$4D,$5A,$83,$86,$00,$5D,$5D
	.byte $5B,$5C,$4F,$8D,$4C,$C4,$87,$00
	.byte $00,$60,$54,$4B,$92,$89,$51,$A1
	.byte $A9,$A1,$8B,$A1,$8C,$A1,$8D,$A1
	.byte $8E,$A1,$8F,$A1,$88,$A1,$89,$A1
	.byte $8A,$A1,$8B,$A1,$8C,$A1,$AC,$48
	.byte $52,$52,$63,$84,$88,$5B,$51,$A1
	.byte $9C,$A1,$84,$78,$7C,$80,$A1,$84
	.byte $78,$7C,$80,$A1,$84,$78,$A1,$A4
	.byte $21,$33,$5A,$C5,$88,$5C,$4F,$A1
	.byte $9D,$A1,$85,$79,$7D,$A1,$81,$A1
	.byte $85,$79,$7D,$A1,$81,$A1,$85,$79
	.byte $A1,$A5,$23,$33,$C6,$88,$57,$4F
	.byte $A1,$AA,$A1,$93,$A1,$94,$A1,$95
	.byte $A1,$96,$A1,$97,$A1,$90,$A1,$91
	.byte $A1,$92,$A1,$93,$A1,$94,$A1,$AF
	.byte $1E,$36,$86,$88,$00,$61,$4A,$CB
	.byte $74,$21,$2B,$85,$89,$60,$4B,$8C
	.byte $23,$31,$85,$88,$59,$4F,$CC,$74
	.byte $21,$2E,$85,$88,$60,$47,$8D,$1E
	.byte $62,$85,$00,$5D,$5C,$5B,$82,$5C
	.byte $00,$50,$CE,$74,$4E,$85,$54,$55
	.byte $54,$55,$55,$54,$55,$54,$47,$8E
	.byte $3F,$4E,$56,$84,$D7,$3F,$4C,$5C
	.byte $84,$8C,$3C,$8B,$4E,$C5,$8C,$3E
	.byte $84,$3E,$86,$4C,$57,$84,$8C,$44
	.byte $52,$52,$53,$A4,$52,$53,$52,$53
	.byte $52,$63,$C5,$52,$52,$53,$52,$53
	.byte $52,$53,$52,$52,$53,$52,$52,$63
	.byte $5A,$5C,$58,$56,$00,$5C,$57,$5D
	.byte $00,$00,$5C,$C6,$5D,$58,$59,$5A
	.byte $5A,$59,$00,$59,$00,$59,$56,$57
	.byte $D2,$DE,$FF
level2_r3:
	.byte 44, 0
	.byte 14, 255, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_r3_t
	.word level2_r3_p
	.word level2_r3_e
level2_s2_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FF
level2_s2_e:
	.byte $B0,$88,$01,$00
	.byte $FF
level2_s2_t:
	.byte $DE,$9E,$53,$53,$53,$52,$53,$52
	.byte $52,$52,$53,$46,$94,$56,$00,$00
	.byte $56,$57,$5A,$00,$00,$60,$54,$66
	.byte $5E,$92,$C7,$60,$4B,$D5,$87,$50
	.byte $D6,$86,$60,$47,$96,$85,$59,$51
	.byte $D7,$85,$00,$50,$97,$85,$60,$47
	.byte $97,$85,$50,$D2,$48,$52,$A4,$53
	.byte $84,$5B,$4F,$92,$4E,$5D,$00,$5A
	.byte $5C,$5B,$84,$00,$93,$4D,$5B,$C4
	.byte $85,$50,$92,$4C,$C5,$85,$51,$90
	.byte $48,$52,$63,$85,$84,$59,$4F,$90
	.byte $4E,$5B,$C6,$84,$00,$61,$52,$46
	.byte $8E,$4C,$C7,$85,$00,$00,$4F,$8F
	.byte $5B,$86,$85,$60,$54,$4B,$8E,$4E
	.byte $C7,$84,$5C,$51,$D0,$4C,$5B,$86
	.byte $84,$56,$4F,$90,$4D,$59,$86,$85
	.byte $50,$8F,$48,$63,$C7,$84,$5D,$4F
	.byte $8F,$4C,$5A,$87,$84,$56,$51,$8F
	.byte $4D,$5C,$87,$84,$57,$4F,$8F,$45
	.byte $62,$87,$84,$00,$50,$8F,$00,$4C
	.byte $87,$84,$5B,$4F,$91,$5B,$86,$84
	.byte $56,$50,$90,$4E,$56,$86,$84,$00
	.byte $61,$53,$53,$4A,$8D,$4C,$5D,$86
	.byte $85,$00,$00,$00,$61,$53,$53,$53
	.byte $4A,$89,$4D,$5B,$86,$88,$00,$5B
	.byte $58,$00,$61,$53,$53,$52,$52,$52
	.byte $A4,$53,$63,$C7,$89,$C5,$5B,$00
	.byte $5C,$58,$5C,$5B,$57,$5A,$C8,$FF
level2_s2:
	.byte 32, 0
	.byte 255, 17, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_s2_t
	.word level2_s2_p
	.word level2_s2_e
level2_r4_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$8A,$00,$00
	.byte $00,$00,$00,$84,$00,$AA,$08,$00
	.byte $00,$00,$12,$31,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$80,$C4,$00,$00,$00
	.byte $00,$20,$D0,$A6,$92,$6D,$08,$00
	.byte $00,$00,$00,$88,$00,$00,$00,$00
	.byte $00,$00,$00,$AA,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FF
level2_r4_e:
	.byte $FE
	.byte $38,$48,$01,$00
	.byte $FF
level2_r4_t:
	.byte $DE,$9E,$92,$59,$58,$8A,$00,$5B
	.byte $00,$5C,$5B,$5C,$5A,$58,$58,$84
	.byte $58,$5D,$5C,$59,$60,$55,$54,$62
	.byte $89,$55,$55,$54,$54,$55,$55,$54
	.byte $55,$54,$55,$62,$00,$60,$55,$55
	.byte $54,$55,$47,$00,$00,$21,$2F,$88
	.byte $CA,$4E,$5B,$50,$C7,$23,$32,$88
	.byte $8A,$4D,$56,$4F,$87,$1E,$36,$88
	.byte $8B,$57,$61,$46,$86,$00,$22,$33
	.byte $87,$52,$53,$A4,$52,$53,$4A,$82
	.byte $4C,$59,$5A,$4F,$87,$23,$2B,$87
	.byte $00,$5A,$5D,$00,$60,$55,$54,$47
	.byte $82,$45,$54,$54,$4B,$87,$22,$2F
	.byte $87,$00,$00,$00,$58,$4F,$00,$00
	.byte $00,$A1,$A8,$A1,$89,$A1,$8A,$A1
	.byte $8B,$A1,$8C,$A1,$8D,$A1,$AC,$86
	.byte $1E,$2A,$36,$86,$83,$59,$51,$83
	.byte $A1,$9B,$7F,$A1,$83,$A1,$87,$7B
	.byte $7F,$A1,$A3,$86,$00,$74,$23,$30
	.byte $85,$83,$5C,$84,$A1,$9C,$7C,$80
	.byte $A1,$84,$78,$7C,$A1,$A4,$87,$3F
	.byte $4E,$58,$85,$83,$5A,$4F,$82,$64
	.byte $A1,$AB,$A1,$91,$A1,$92,$A1,$93
	.byte $A1,$94,$A1,$95,$A1,$AF,$88,$4C
	.byte $5C,$85,$83,$58,$51,$82,$E5,$00
	.byte $00,$48,$53,$53,$46,$C8,$3F,$4D
	.byte $57,$85,$83,$00,$50,$82,$65,$82
	.byte $4E,$56,$59,$50,$89,$4C,$5A,$85
	.byte $83,$5C,$83,$00,$00,$00,$4D,$58
	.byte $56,$51,$88,$48,$63,$C6,$83,$00
	.byte $51,$85,$4C,$5D,$60,$47,$88,$4C
	.byte $5C,$86,$84,$61,$4A,$84,$4D,$60
	.byte $47,$C9,$4D,$C7,$84,$00,$61,$53
	.byte $4A,$82,$4C,$4F,$C8,$44,$53,$63
	.byte $87,$85,$00,$5A,$61,$53,$53,$63
	.byte $47,$88,$4D,$57,$59,$87,$87,$00
	.byte $5D,$5D,$50,$C9,$4C,$5C,$82,$5A
	.byte $58,$84,$85,$60,$55,$55,$55,$54
	.byte $47,$89,$49,$54,$55,$54,$55,$54
	.byte $62,$83,$84,$5A,$51,$A1,$A9,$A1
	.byte $8F,$A1,$88,$A1,$89,$A1,$8A,$A1
	.byte $8B,$A1,$8C,$A1,$8D,$A1,$8E,$A1
	.byte $8F,$A1,$8A,$A1,$8C,$A1,$8A,$A1
	.byte $8B,$A1,$8C,$A2,$8E,$A1,$8F,$A1
	.byte $8C,$A1,$AC,$4D,$56,$82,$84,$5C
	.byte $4F,$A1,$98,$A1,$84,$80,$A1,$81
	.byte $80,$A1,$84,$78,$7C,$80,$A1,$84
	.byte $A1,$81,$A1,$86,$80,$A1,$84,$78
	.byte $7C,$80,$A1,$84,$A1,$85,$A0,$4C
	.byte $5B,$82,$84,$5B,$51,$A1,$99,$A1
	.byte $85,$79,$7D,$A1,$81,$A1,$85,$79
	.byte $7D,$A1,$81,$A1,$85,$79,$7D,$A1
	.byte $81,$A1,$85,$79,$7D,$A1,$81,$A1
	.byte $85,$79,$A1,$A1,$4E,$58,$82,$84
	.byte $56,$51,$A1,$9A,$A1,$86,$7A,$7E
	.byte $A1,$82,$A1,$86,$7A,$7E,$A1,$82
	.byte $A1,$86,$7A,$7E,$A1,$82,$A1,$86
	.byte $7A,$7E,$A1,$82,$A1,$86,$7A,$A1
	.byte $A2,$4C,$00,$00,$00,$84,$57,$4F
	.byte $A1,$AB,$A1,$97,$A1,$90,$A1,$91
	.byte $A1,$92,$A1,$93,$A1,$94,$A1,$95
	.byte $A1,$96,$A1,$97,$A1,$90,$A1,$91
	.byte $A1,$92,$A1,$93,$A1,$94,$A1,$95
	.byte $A1,$96,$A1,$97,$A1,$90,$A1,$AE
	.byte $84,$84,$00,$61,$46,$C5,$44,$52
	.byte $53,$52,$52,$46,$C8,$4C,$5B,$82
	.byte $85,$60,$4B,$85,$45,$62,$5A,$5A
	.byte $57,$50,$88,$4D,$5D,$82,$84,$58
	.byte $50,$C7,$21,$31,$00,$00,$61,$46
	.byte $87,$4E,$00,$00,$00,$84,$00,$4F
	.byte $88,$2C,$82,$5A,$51,$86,$44,$63
	.byte $83,$8E,$31,$83,$50,$86,$4D,$C4
	.byte $84,$57,$51,$87,$23,$33,$8A,$4C
	.byte $84,$84,$58,$50,$87,$1E,$36,$83
	.byte $4F,$87,$56,$83,$84,$60,$4B,$87
	.byte $74,$22,$82,$57,$87,$4E,$59,$58
	.byte $5B,$5B,$83,$58,$50,$C8,$3F,$4D
	.byte $82,$60,$47,$86,$45,$55,$55,$54
	.byte $55,$83,$59,$8A,$4E,$5B,$60,$4B
	.byte $C7,$6C,$C4,$83,$00,$8A,$45,$62
	.byte $51,$C8,$6B,$84,$83,$57,$89,$00
	.byte $3F,$4C,$4F,$8D,$83,$5D,$51,$8A
	.byte $4D,$61,$4A,$87,$6D,$84,$83,$00
	.byte $61,$52,$4A,$88,$4C,$57,$61,$53
	.byte $52,$52,$A4,$53,$52,$53,$53,$52
	.byte $52,$84,$00,$56,$61,$53,$53,$53
	.byte $52,$53,$52,$53,$52,$63,$00,$00
	.byte $00,$5A,$00,$58,$00,$00,$5C,$5C
	.byte $5C,$5A,$00,$5B,$85,$00,$00,$5A
	.byte $58,$5C,$5B,$58,$5A,$5B,$56,$CF
	.byte $FF
level2_r4:
	.byte 44, 0
	.byte 18, 255, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_r4_t
	.word level2_r4_p
	.word level2_r4_e
level2_r5_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$00,$00,$00,$50,$20
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$FE,$00,$00,$00,$00
	.byte $70,$02,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$FE,$FE,$FF
level2_r5_e:
	.byte $28,$58,$01,$00
	.byte $FF
level2_r5_t:
	.byte $DE,$9E,$8B,$58,$59,$00,$59,$5D
	.byte $00,$58,$58,$56,$5A,$5C,$56,$87
	.byte $89,$60,$54,$A4,$55,$54,$62,$60
	.byte $54,$55,$54,$54,$55,$62,$59,$00
	.byte $5D,$5A,$5D,$56,$88,$5C,$50,$C6
	.byte $4E,$50,$C5,$49,$54,$55,$55,$54
	.byte $55,$55,$88,$00,$51,$86,$4C,$51
	.byte $85,$00,$00,$6C,$C4,$88,$59,$87
	.byte $4D,$50,$87,$6B,$84,$88,$57,$4F
	.byte $86,$4E,$4F,$87,$6D,$84,$88,$00
	.byte $61,$52,$53,$53,$4A,$82,$4C,$61
	.byte $52,$46,$85,$44,$53,$52,$53,$52
	.byte $89,$00,$5B,$00,$00,$51,$82,$4E
	.byte $59,$59,$50,$85,$4C,$58,$00,$57
	.byte $59,$89,$5C,$5A,$85,$4C,$00,$5C
	.byte $61,$53,$4A,$83,$4E,$57,$00,$00
	.byte $00,$83,$5B,$5A,$5C,$57,$60,$55
	.byte $54,$54,$54,$62,$50,$82,$4D,$00
	.byte $00,$60,$55,$47,$84,$C4,$83,$00
	.byte $56,$60,$55,$47,$00,$00,$00,$3F
	.byte $4C,$83,$4E,$58,$57,$51,$C5,$4C
	.byte $5D,$83,$83,$5A,$60,$47,$C5,$82
	.byte $51,$83,$00,$5B,$50,$85,$45,$62
	.byte $83,$83,$5D,$50,$C6,$3F,$4D,$50
	.byte $82,$4D,$5A,$59,$51,$85,$3F,$4C
	.byte $56,$82,$83,$56,$4F,$87,$49,$47
	.byte $82,$45,$55,$54,$4B,$86,$4D,$59
	.byte $82,$83,$5B,$87,$00,$3F,$A1,$A9
	.byte $A1,$8E,$A1,$8F,$A1,$88,$A1,$89
	.byte $A1,$AC,$C6,$3F,$4E,$00,$00,$00
	.byte $83,$5A,$89,$A1,$99,$A1,$81,$A1
	.byte $85,$79,$7D,$A1,$A1,$88,$5B,$82
	.byte $83,$5B,$51,$88,$A1,$AB,$A1,$96
	.byte $A1,$97,$A1,$90,$A1,$91,$A1,$AE
	.byte $87,$4C,$00,$00,$00,$83,$58,$50
	.byte $87,$C4,$3F,$44,$53,$4A,$86,$4D
	.byte $57,$82,$83,$59,$51,$8C,$49,$62
	.byte $61,$52,$53,$52,$53,$52,$53,$63
	.byte $00,$00,$00,$83,$58,$8C,$00,$3F
	.byte $49,$A4,$54,$55,$62,$00,$5A,$83
	.byte $83,$00,$4F,$8C,$C6,$3F,$4C,$5B
	.byte $C4,$84,$51,$93,$45,$62,$84,$84
	.byte $61,$53,$4A,$90,$00,$3F,$4E,$5A
	.byte $83,$84,$56,$56,$51,$93,$59,$83
	.byte $84,$00,$00,$61,$52,$52,$4A,$8F
	.byte $4D,$5D,$83,$86,$56,$5D,$5D,$61
	.byte $52,$52,$52,$53,$53,$52,$4A,$88
	.byte $4C,$C4,$86,$C4,$5D,$5C,$5B,$00
	.byte $56,$00,$50,$A1,$A9,$A1,$8A,$A1
	.byte $8B,$A1,$8C,$A1,$AD,$83,$4E,$5D
	.byte $83,$85,$58,$59,$5C,$5B,$58,$58
	.byte $C5,$51,$A1,$9D,$A1,$81,$A1,$85
	.byte $79,$A1,$A5,$48,$52,$53,$63,$84
	.byte $85,$60,$A5,$55,$62,$83,$58,$51
	.byte $A1,$9E,$A1,$82,$A1,$86,$7A,$A1
	.byte $A6,$49,$55,$54,$54,$62,$83,$85
	.byte $50,$C5,$4E,$58,$60,$55,$54,$4B
	.byte $A1,$AA,$A1,$92,$A1,$93,$A1,$94
	.byte $A1,$AE,$00,$00,$00,$3F,$4D,$83
	.byte $84,$5A,$86,$45,$54,$47,$CB,$3F
	.byte $4E,$58,$82,$84,$60,$4B,$85,$CE
	.byte $3F,$4D,$59,$82,$83,$5C,$51,$D4
	.byte $3F,$4E,$58,$82,$83,$59,$96,$4C
	.byte $5D,$82,$56,$56,$5C,$57,$50,$93
	.byte $3F,$48,$63,$00,$00,$00,$54,$55
	.byte $55,$54,$47,$94,$4E,$5B,$83,$CE
	.byte $48,$52,$53,$52,$53,$53,$53,$52
	.byte $4A,$82,$4D,$56,$83,$87,$64,$86
	.byte $4C,$5A,$00,$00,$57,$5B,$5A,$5C
	.byte $61,$53,$53,$63,$C4,$87,$4C,$52
	.byte $46,$85,$5C,$82,$C5,$56,$C6,$53
	.byte $52,$53,$53,$52,$53,$52,$63,$57
	.byte $61,$52,$52,$53,$53,$63,$CF,$59
	.byte $58,$58,$56,$56,$00,$59,$00,$00
	.byte $00,$5A,$57,$56,$58,$D0,$DE,$FF
level2_r5:
	.byte 44, 0
	.byte 19, 255, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_r5_t
	.word level2_r5_p
	.word level2_r5_e
level2_r6_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$00,$80,$00,$00,$00,$00,$00
	.byte $00,$00,$D0,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$50,$05,$0A,$00
	.byte $00,$00,$00,$00,$10,$01,$0A,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FE,$FE,$FE,$FE,$FF
level2_r6_e:
	.byte $FF
level2_r6_t:
	.byte $DE,$9E,$90,$5A,$00,$5A,$00,$5A
	.byte $00,$56,$5C,$86,$8F,$60,$A8,$54
	.byte $62,$85,$5D,$59,$00,$5A,$83,$5A
	.byte $5D,$85,$60,$4B,$C8,$4C,$5C,$84
	.byte $55,$54,$55,$54,$54,$54,$55,$55
	.byte $54,$62,$00,$56,$60,$55,$47,$C9
	.byte $4C,$57,$84,$C9,$4E,$60,$54,$47
	.byte $CB,$45,$55,$62,$83,$89,$4C,$50
	.byte $CE,$3F,$4E,$59,$82,$89,$4E,$54
	.byte $56,$8F,$00,$00,$00,$52,$53,$53
	.byte $53,$46,$84,$E5,$CF,$82,$56,$82
	.byte $5A,$5C,$5B,$59,$61,$46,$A1,$A8
	.byte $A1,$8F,$A1,$AC,$67,$91,$00,$00
	.byte $00,$C5,$50,$A1,$9B,$A1,$87,$A1
	.byte $A3,$91,$4C,$83,$84,$59,$51,$A1
	.byte $9C,$A1,$84,$A1,$A4,$89,$48,$53
	.byte $53,$4A,$84,$4D,$58,$82,$84,$5A
	.byte $4F,$A1,$9D,$A1,$85,$A1,$A5,$4E
	.byte $4A,$87,$45,$62,$00,$61,$52,$53
	.byte $52,$53,$63,$00,$00,$00,$84,$59
	.byte $50,$A1,$AA,$A1,$97,$A1,$AE,$4C
	.byte $4F,$87,$00,$4E,$00,$00,$59,$00
	.byte $5B,$5C,$C4,$84,$5A,$50,$00,$00
	.byte $00,$4E,$61,$4A,$87,$4C,$5D,$C9
	.byte $84,$5C,$4F,$83,$49,$54,$47,$87
	.byte $45,$36,$89,$84,$59,$84,$C6,$01
	.byte $0C,$03,$00,$00,$21,$31,$88,$8F
	.byte $06,$18,$0A,$82,$23,$89,$84,$5C
	.byte $50,$89,$07,$16,$08,$82,$21,$30
	.byte $88,$84,$56,$4F,$8A,$13,$84,$2D
	.byte $88,$84,$00,$51,$89,$02,$0F,$04
	.byte $82,$22,$31,$88,$85,$61,$53,$53
	.byte $53,$52,$4A,$84,$00,$00,$00,$44
	.byte $52,$37,$C9,$85,$00,$58,$00,$00
	.byte $00,$50,$87,$49,$62,$CA,$86,$00
	.byte $00,$00,$60,$47,$87,$00,$4E,$00
	.byte $5B,$88,$88,$58,$51,$C9,$4E,$59
	.byte $58,$88,$88,$56,$4F,$8A,$57,$5D
	.byte $57,$57,$58,$85,$88,$58,$8A,$4D
	.byte $58,$60,$55,$54,$54,$62,$84,$88
	.byte $57,$8A,$49,$54,$47,$00,$00,$3F
	.byte $4E,$56,$83,$88,$00,$61,$52,$5E
	.byte $87,$C5,$82,$58,$83,$89,$60,$47
	.byte $CD,$3F,$45,$62,$83,$88,$59,$51
	.byte $CF,$3F,$4E,$5D,$82,$88,$60,$4B
	.byte $90,$4C,$59,$82,$88,$4F,$C5,$3F
	.byte $48,$52,$53,$46,$88,$5B,$82,$88
	.byte $51,$86,$49,$54,$54,$54,$5E,$86
	.byte $4D,$00,$00,$00,$88,$61,$4A,$84
	.byte $00,$A5,$68,$85,$48,$63,$83,$88
	.byte $57,$50,$85,$CA,$4E,$00,$58,$59
	.byte $00,$88,$00,$61,$46,$8E,$45,$54
	.byte $54,$55,$54,$89,$60,$55,$5E,$8D
	.byte $6C,$C4,$88,$5D,$50,$CF,$6B,$84
	.byte $88,$00,$61,$52,$52,$53,$4A,$8B
	.byte $6D,$84,$89,$00,$00,$56,$5C,$61
	.byte $52,$52,$53,$53,$52,$52,$53,$52
	.byte $53,$52,$53,$53,$53,$52,$52,$52
	.byte $8B,$00,$00,$00,$59,$5C,$56,$57
	.byte $59,$5C,$00,$5A,$5D,$5A,$59,$59
	.byte $5C,$56,$56,$58,$8E,$D0,$FF
level2_r6:
	.byte 44, 0
	.byte 20, 255, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_r6_t
	.word level2_r6_p
	.word level2_r6_e
level2_r7_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$00,$00,$00,$00,$80,$00,$00
	.byte $00,$00,$00,$00,$00,$20,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$80,$08
	.byte $00,$00,$00,$A0,$85,$05,$A0,$0A
	.byte $00,$00,$00,$20,$01,$02,$A0,$0A
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FE,$00,$00,$00,$40,$04,$08
	.byte $00,$00,$00,$00,$00,$10,$01,$0A
	.byte $00,$00,$FF
level2_r7_e:
	.byte $FF
level2_r7_t:
	.byte $DE,$9E,$93,$56,$57,$5C,$00,$59
	.byte $86,$86,$56,$8B,$60,$54,$55,$54
	.byte $55,$62,$86,$84,$60,$54,$55,$62
	.byte $56,$86,$5A,$59,$5B,$4F,$C4,$4E
	.byte $5D,$5C,$00,$5B,$5C,$5B,$83,$59
	.byte $51,$00,$00,$49,$55,$62,$00,$5D
	.byte $00,$60,$55,$55,$54,$54,$4B,$84
	.byte $49,$A6,$55,$83,$00,$4F,$82,$00
	.byte $00,$4C,$60,$54,$54,$4B,$CB,$6C
	.byte $C4,$83,$5D,$51,$84,$4E,$4F,$CE
	.byte $6B,$84,$83,$59,$85,$4D,$51,$8E
	.byte $6D,$84,$83,$5D,$4F,$85,$47,$8E
	.byte $44,$A4,$52,$83,$00,$51,$84,$67
	.byte $CF,$4D,$5A,$00,$58,$58,$89,$65
	.byte $88,$74,$40,$85,$4E,$57,$00,$00
	.byte $00,$83,$5D,$50,$84,$C9,$74,$41
	.byte $85,$4D,$5C,$83,$83,$00,$4F,$8D
	.byte $C7,$4C,$C4,$83,$58,$95,$4D,$58
	.byte $83,$83,$00,$61,$53,$5E,$92,$45
	.byte $62,$83,$84,$5D,$4F,$D4,$4E,$5A
	.byte $82,$84,$60,$47,$95,$5C,$82,$83
	.byte $57,$51,$D5,$4C,$58,$82,$83,$59
	.byte $50,$92,$1D,$28,$27,$63,$00,$00
	.byte $00,$84,$4F,$86,$74,$A1,$A8,$A1
	.byte $8D,$A1,$8E,$A1,$8F,$A1,$88,$A1
	.byte $AD,$85,$23,$2B,$33,$C4,$84,$61
	.byte $56,$86,$A1,$9D,$7D,$A1,$81,$A1
	.byte $85,$79,$A1,$A5,$85,$22,$32,$C5
	.byte $83,$5A,$51,$C6,$74,$A1,$9E,$7E
	.byte $A1,$82,$A1,$86,$7A,$A1,$A6,$86
	.byte $30,$85,$83,$59,$88,$A1,$9F,$7F
	.byte $A1,$83,$A1,$87,$7B,$A1,$A7,$85
	.byte $23,$2B,$85,$83,$00,$61,$56,$86
	.byte $A1,$98,$7C,$80,$A1,$84,$78,$A0
	.byte $85,$22,$31,$85,$83,$5D,$4F,$C6
	.byte $74,$A1,$AB,$A1,$95,$A1,$96,$A1
	.byte $97,$A1,$90,$A1,$AE,$85,$23,$32
	.byte $85,$84,$50,$86,$CC,$21,$2E,$85
	.byte $83,$00,$61,$52,$4A,$90,$1E,$36
	.byte $85,$84,$58,$60,$54,$66,$5E,$8E
	.byte $3F,$4E,$5A,$84,$84,$60,$47,$D1
	.byte $3F,$45,$62,$84,$83,$5D,$4F,$D3
	.byte $3F,$4D,$5C,$83,$83,$00,$51,$94
	.byte $4E,$5A,$83,$84,$4F,$94,$4C,$C4
	.byte $83,$57,$61,$53,$5E,$92,$4E,$84
	.byte $83,$5C,$00,$4F,$D2,$82,$5D,$83
	.byte $83,$00,$00,$51,$93,$4C,$5B,$83
	.byte $56,$5B,$5A,$5B,$5D,$92,$3F,$44
	.byte $63,$C4,$54,$55,$A4,$54,$66,$66
	.byte $5E,$8F,$4E,$5C,$84,$CE,$01,$0D
	.byte $03,$87,$4C,$56,$84,$8E,$06,$14
	.byte $09,$83,$1D,$28,$52,$52,$63,$C5
	.byte $8E,$02,$12,$04,$83,$22,$2D,$56
	.byte $59,$C6,$52,$52,$53,$52,$53,$53
	.byte $52,$53,$52,$53,$46,$83,$C6,$21
	.byte $2C,$C8,$58,$58,$5D,$00,$5D,$5A
	.byte $56,$5D,$00,$00,$50,$8A,$31,$88
	.byte $CA,$61,$52,$53,$53,$52,$53,$52
	.byte $52,$53,$53,$37,$C9,$FF
level2_r7:
	.byte 44, 0
	.byte 21, 255, 255, 255
	.byte 252, 0, 0, 0
	.byte 0
	.byte 255
	.word level2_r7_t
	.word level2_r7_p
	.word level2_r7_e
level2_r9z_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$00,$00,$00,$00,$00,$22,$00
	.byte $00,$00,$00,$00,$00,$00,$88,$00
	.byte $00,$00,$00,$00,$00,$00,$22,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FE,$FE,$FF
level2_r9z_e:
	.byte $FF
level2_r9z_t:
	.byte $C5,$4D,$51,$CB,$4E,$5B,$CA,$92
	.byte $4C,$59,$8A,$92,$4D,$58,$5A,$89
	.byte $83,$44,$52,$63,$50,$8B,$49,$55
	.byte $55,$62,$5B,$5A,$5D,$82,$57,$5B
	.byte $5B,$83,$49,$54,$62,$61,$46,$8A
	.byte $00,$00,$00,$49,$A4,$54,$55,$54
	.byte $55,$54,$83,$00,$00,$4E,$59,$61
	.byte $52,$46,$8B,$C9,$85,$4C,$00,$00
	.byte $60,$4B,$94,$83,$48,$53,$63,$5A
	.byte $60,$47,$D5,$83,$45,$55,$62,$57
	.byte $51,$CD,$1D,$28,$28,$A5,$53,$52
	.byte $83,$00,$00,$4D,$00,$8E,$23,$30
	.byte $2D,$5A,$5D,$00,$57,$00,$5D,$85
	.byte $4C,$5D,$61,$46,$8C,$4C,$C8,$83
	.byte $48,$52,$63,$00,$00,$61,$53,$46
	.byte $8B,$5A,$87,$83,$45,$55,$62,$82
	.byte $00,$00,$61,$52,$46,$88,$4E,$88
	.byte $83,$00,$00,$4C,$84,$00,$5A,$61
	.byte $53,$66,$66,$66,$5E,$83,$4C,$88
	.byte $8B,$00,$56,$4F,$C7,$23,$2D,$87
	.byte $83,$48,$52,$63,$5C,$86,$50,$87
	.byte $21,$31,$87,$83,$45,$55,$55,$62
	.byte $85,$00,$51,$87,$23,$2D,$87,$83
	.byte $00,$00,$00,$4E,$85,$56,$4F,$87
	.byte $22,$2B,$87,$86,$4C,$85,$59,$88
	.byte $4D,$57,$87,$83,$48,$52,$52,$63
	.byte $85,$00,$61,$52,$52,$52,$46,$84
	.byte $5A,$87,$83,$49,$55,$62,$C7,$58
	.byte $00,$5A,$57,$51,$83,$4C,$88,$83
	.byte $00,$00,$4D,$87,$00,$00,$00,$5A
	.byte $84,$4D,$C8,$85,$4E,$8B,$4F,$8C
	.byte $83,$48,$52,$63,$8A,$00,$61,$52
	.byte $52,$52,$63,$88,$83,$4D,$58,$00
	.byte $59,$5A,$82,$59,$00,$59,$5B,$5A
	.byte $00,$58,$5D,$5A,$00,$5A,$00,$59
	.byte $5D,$00,$5B,$00,$59,$5D,$5A,$83
	.byte $4E,$60,$54,$54,$55,$54,$54,$55
	.byte $A5,$54,$55,$55,$54,$A4,$55,$54
	.byte $A4,$55,$54,$55,$83,$49,$47,$D9
	.byte $83,$DB,$9E,$9E,$9E,$9E,$FF
level2_r9z:
	.byte 32, 0
	.byte 255, 27, 26, 255
	.byte 0, 232, 250, 0
	.byte 0
	.byte 255
	.word level2_r9z_t
	.word level2_r9z_p
	.word level2_r9z_e
