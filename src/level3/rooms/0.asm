level3_s0_p:
	.byte $00,$00,$00,$00,$00,$8A,$88,$08
	.byte $00,$00,$00,$00,$00,$AA,$88,$08
	.byte $00,$00,$00,$00,$00,$2A,$22,$02
	.byte $00,$00,$00,$00,$00,$8A,$88,$08
	.byte $00,$00,$00,$00,$00,$0A,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$8A,$88,$08
	.byte $00,$00,$00,$00,$00,$0A,$00,$00
	.byte $00,$00,$00,$00,$00,$8A,$88,$08
	.byte $00,$00,$00,$00,$00,$0A,$00,$00
	.byte $FF
level3_s0_e:
	.byte $FF
level3_s0_t:
	.byte $D4,$06,$17,$C8,$94,$05,$15,$88
	.byte $8C,$6A,$87,$2B,$50,$54,$55,$4E
	.byte $55,$4E,$4E,$52,$55,$8C,$6B,$80
	.byte $87,$51,$38,$35,$37,$34,$37,$34
	.byte $35,$36,$8C,$63,$79,$A6,$7B,$2A
	.byte $55,$29,$C7,$8E,$7A,$7A,$7A,$7E
	.byte $7A,$7A,$82,$2D,$87,$94,$2B,$51
	.byte $2D,$5E,$5F,$5E,$5F,$5E,$5F,$5E
	.byte $95,$2F,$29,$5A,$5C,$5A,$5C,$5A
	.byte $5C,$5A,$94,$2C,$2D,$5D,$5B,$5D
	.byte $5B,$5D,$5B,$5D,$5B,$96,$C8,$93
	.byte $7C,$8A,$8E,$A5,$7B,$00,$8A,$8E
	.byte $7A,$7A,$7C,$00,$00,$00,$24,$89
	.byte $8F,$7C,$C5,$4B,$88,$8E,$C7,$4C
	.byte $26,$56,$58,$56,$58,$56,$58,$56
	.byte $95,$4B,$29,$57,$59,$57,$59,$57
	.byte $59,$57,$8E,$A6,$7B,$22,$2D,$C8
	.byte $8E,$7A,$7A,$7C,$00,$00,$00,$2A
	.byte $2E,$88,$94,$2B,$29,$88,$94,$48
	.byte $C9,$8C,$69,$79,$A7,$7B,$89,$8C
	.byte $68,$7D,$D0,$8C,$D2,$9E,$94,$47
	.byte $89,$94,$2B,$26,$88,$94,$2A,$2E
	.byte $26,$56,$58,$56,$58,$56,$58,$56
	.byte $94,$2B,$2D,$29,$57,$59,$57,$59
	.byte $57,$59,$57,$94,$2A,$2E,$C8,$8C
	.byte $6C,$7F,$86,$2C,$2D,$88,$8C,$63
	.byte $79,$7B,$86,$2E,$88,$8E,$A6,$7A
	.byte $2B,$2D,$88,$8C,$69,$79,$A6,$7B
	.byte $2A,$2F,$88,$8C,$E2,$68,$81,$C6
	.byte $2B,$89,$8C,$C8,$2C,$2D,$26,$56
	.byte $58,$56,$58,$56,$58,$56,$94,$2B
	.byte $2D,$29,$57,$59,$57,$59,$57,$59
	.byte $57,$94,$2C,$2D,$C8,$94,$2B,$2E
	.byte $88,$94,$2A,$89,$94,$2C,$2F,$88
	.byte $FF
level3_s0:
	.byte 40, 0
	.byte 255, 255, 255, 1
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level3_s0_t
	.word level3_s0_p
	.word level3_s0_e
level3_s1_p:
	.byte $00,$00,$00,$00,$00,$8A,$88,$08
	.byte $00,$00,$00,$00,$00,$2A,$22,$02
	.byte $00,$00,$00,$00,$00,$0A,$00,$00
	.byte $00,$00,$00,$00,$00,$8A,$88,$08
	.byte $00,$00,$00,$00,$00,$5A,$00,$00
	.byte $00,$00,$40,$00,$00,$12,$00,$00
	.byte $00,$00,$50,$05,$00,$A0,$AA,$0A
	.byte $00,$00,$10,$00,$00,$59,$00,$00
	.byte $00,$00,$00,$00,$00,$9A,$89,$08
	.byte $08,$00,$00,$00,$00,$8A,$88,$08
	.byte $8A,$00,$00,$00,$00,$2A,$22,$02
	.byte $A2,$88,$00,$00,$00,$2A,$22,$02
	.byte $00,$22,$00,$00,$00,$0A,$00,$00
	.byte $FF
level3_s1_e:
	.byte $FF
level3_s1_t:
	.byte $D4,$2C,$2F,$C8,$94,$2B,$2D,$88
	.byte $94,$2C,$2E,$88,$94,$2B,$2E,$26
	.byte $56,$58,$56,$58,$56,$58,$56,$94
	.byte $2C,$2D,$29,$57,$59,$57,$59,$57
	.byte $59,$57,$95,$2F,$C8,$9E,$94,$2B
	.byte $2E,$88,$9E,$95,$2F,$88,$94,$2C
	.byte $2D,$88,$94,$2B,$2F,$88,$94,$2C
	.byte $2D,$88,$9E,$96,$26,$56,$58,$56
	.byte $58,$56,$58,$56,$94,$2A,$2E,$29
	.byte $57,$59,$57,$59,$57,$59,$57,$88
	.byte $6A,$8D,$C8,$88,$6B,$80,$8A,$E4
	.byte $2C,$2E,$9C,$8D,$86,$88,$63,$79
	.byte $AA,$7B,$E4,$2B,$2F,$A4,$8F,$86
	.byte $8A,$7A,$7A,$7E,$7A,$7A,$7E,$A4
	.byte $7A,$2A,$29,$9F,$C7,$94,$E3,$4C
	.byte $00,$95,$87,$94,$4A,$C9,$8A,$E2
	.byte $8D,$00,$86,$7C,$CB,$8A,$9F,$93
	.byte $8A,$E6,$A5,$A1,$8D,$00,$7A,$7C
	.byte $C9,$74,$74,$83,$8A,$E5,$8A,$89
	.byte $9F,$00,$7C,$C8,$26,$56,$58,$56
	.byte $58,$56,$58,$8A,$E7,$88,$8B,$9E
	.byte $00,$7A,$7A,$82,$86,$29,$57,$59
	.byte $57,$59,$57,$59,$8A,$E3,$A4,$A2
	.byte $95,$82,$7E,$7A,$7A,$7C,$84,$00
	.byte $72,$72,$C4,$8A,$E5,$9E,$00,$7E
	.byte $7A,$7A,$89,$C6,$8A,$E1,$8F,$87
	.byte $E5,$00,$00,$00,$84,$8D,$87,$8A
	.byte $7A,$7A,$83,$7C,$C4,$22,$27,$9F
	.byte $87,$8E,$7C,$C5,$E4,$2B,$2E,$A5
	.byte $8D,$86,$8A,$A7,$7B,$83,$E5,$2C
	.byte $2F,$8A,$A5,$8D,$85,$88,$E2,$68
	.byte $81,$CA,$E5,$2A,$2F,$93,$9D,$95
	.byte $85,$88,$CC,$2A,$2D,$26,$56,$58
	.byte $56,$58,$56,$58,$56,$94,$2C,$2E
	.byte $29,$57,$59,$57,$59,$57,$59,$57
	.byte $94,$2B,$2D,$C8,$94,$2A,$2F,$88
	.byte $03,$93,$2B,$89,$19,$21,$92,$2A
	.byte $2E,$5C,$5A,$5C,$5A,$5C,$5A,$5C
	.byte $5A,$0A,$D3,$2B,$2F,$5D,$5B,$5D
	.byte $5B,$5D,$5B,$5D,$5B,$19,$03,$92
	.byte $2A,$2D,$C8,$18,$0D,$21,$91,$2B
	.byte $2F,$88,$08,$D3,$2A,$2E,$88,$19
	.byte $03,$86,$6C,$7F,$8A,$2B,$2F,$26
	.byte $56,$58,$56,$58,$56,$58,$56,$00
	.byte $19,$0B,$03,$84,$63,$79,$AA,$7B
	.byte $2C,$2D,$29,$57,$59,$57,$59,$57
	.byte $59,$57,$00,$00,$17,$19,$0C,$0B
	.byte $21,$83,$CA,$2A,$2D,$C8,$82,$00
	.byte $00,$14,$08,$00,$00,$8C,$2B,$89
	.byte $84,$00,$19,$0C,$0C,$8C,$2A,$89
	.byte $85,$00,$16,$17,$96,$86,$00,$00
	.byte $82,$A6,$7B,$84,$2C,$89,$8A,$CA
	.byte $2A,$89,$FF
level3_s1:
	.byte 52, 0
	.byte 3, 255, 2, 4
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level3_s1_t
	.word level3_s1_p
	.word level3_s1_e
level3_s1u_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE
	.byte $00,$00,$00,$00,$00,$00,$8A,$08
	.byte $00,$00,$00,$00,$00,$A0,$8A,$00
	.byte $00,$00,$00,$00,$00,$00,$AA,$00
	.byte $FE,$FF
level3_s1u_e:
	.byte $FF
level3_s1u_t:
	.byte $DE,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$99,$1D,$84,$99
	.byte $01,$84,$99,$07,$0B,$0C,$0C,$0C
	.byte $99,$06,$0F,$0F,$15,$15,$97,$22
	.byte $32,$1B,$C4,$97,$2B,$53,$C5,$97
	.byte $25,$35,$1A,$84,$97,$00,$00,$06
	.byte $13,$83,$9A,$14,$83,$99,$05,$84
	.byte $9A,$17,$83,$9A,$15,$83,$9A,$13
	.byte $83,$99,$06,$16,$83,$99,$05,$12
	.byte $83,$99,$06,$16,$83,$FF
level3_s1u:
	.byte 52, 0
	.byte 255, 5, 255, 6
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level3_s1u_t
	.word level3_s1u_p
	.word level3_s1u_e
level3_s2_p:
	.byte $80,$A8,$00,$00,$00,$0A,$00,$00
	.byte $AA,$00,$00,$00,$00,$2A,$22,$02
	.byte $A2,$08,$00,$00,$00,$AA,$AA,$0A
	.byte $A0,$6A,$44,$00,$00,$8A,$88,$08
	.byte $88,$AA,$50,$00,$00,$0A,$00,$00
	.byte $22,$00,$00,$00,$00,$0A,$00,$00
	.byte $00,$00,$00,$00,$00,$2A,$22,$02
	.byte $AA,$AA,$00,$00,$00,$0A,$00,$00
	.byte $80,$62,$50,$00,$00,$00,$00,$00
	.byte $A0,$10,$00,$00,$80,$88,$88,$08
	.byte $A8,$00,$00,$00,$00,$00,$00,$00
	.byte $22,$00,$88,$88,$88,$88,$88,$08
	.byte $00,$00,$AA,$22,$22,$22,$22,$02
	.byte $FE,$00,$00,$AA,$AA,$AA,$AA,$AA
	.byte $0A,$FF
level3_s2_e:
	.byte $FE
	.byte $30,$88,$03
	.byte $68,$B0,$01,$01
	.byte $FF
level3_s2_t:
	.byte $C8,$63,$79,$CA,$2A,$2E,$C8,$86
	.byte $12,$14,$8C,$2C,$89,$84,$16,$18
	.byte $0D,$0D,$8C,$2A,$2F,$88,$82,$0F
	.byte $18,$0E,$04,$00,$00,$8C,$2C,$89
	.byte $00,$18,$0D,$04,$C4,$82,$AA,$7B
	.byte $2C,$2E,$26,$56,$58,$56,$58,$56
	.byte $58,$56,$14,$0A,$C6,$82,$CA,$2B
	.byte $2F,$29,$57,$59,$57,$59,$57,$59
	.byte $57,$16,$09,$93,$2D,$C8,$00,$19
	.byte $0B,$21,$90,$2C,$2F,$88,$00,$11
	.byte $0A,$C5,$E2,$68,$81,$8A,$2B,$2E
	.byte $88,$00,$14,$09,$85,$CC,$2A,$2E
	.byte $5C,$5A,$5C,$5A,$5C,$5A,$5C,$5A
	.byte $00,$00,$19,$03,$92,$5D,$5B,$5D
	.byte $5B,$5D,$5B,$5D,$5B,$82,$00,$19
	.byte $0B,$03,$8E,$2C,$2E,$C8,$83,$00
	.byte $18,$0D,$21,$97,$83,$13,$08,$CF
	.byte $2A,$2F,$88,$83,$00,$19,$21,$8E
	.byte $2B,$2D,$26,$56,$58,$56,$58,$56
	.byte $58,$56,$83,$E5,$11,$0A,$00,$00
	.byte $84,$A2,$A1,$E1,$94,$89,$2C,$2E
	.byte $29,$57,$59,$57,$59,$57,$59,$57
	.byte $83,$E8,$00,$19,$0B,$03,$00,$6C
	.byte $7F,$8E,$89,$2B,$2F,$C8,$84,$EE
	.byte $11,$0F,$19,$0C,$63,$79,$9F,$00
	.byte $82,$00,$83,$7E,$7A,$82,$8C,$83
	.byte $15,$18,$0D,$0D,$0E,$82,$E5,$8F
	.byte $00,$7E,$7A,$7A,$82,$E4,$7A,$82
	.byte $00,$2C,$89,$14,$14,$18,$0D,$04
	.byte $00,$00,$00,$82,$AA,$7B,$2C,$2E
	.byte $88,$0E,$0D,$04,$C5,$E2,$66,$81
	.byte $CA,$2A,$2F,$88,$C8,$67,$CB,$8A
	.byte $88,$CC,$2B,$2D,$88,$94,$2C,$2F
	.byte $88,$94,$2B,$2D,$26,$56,$58,$56
	.byte $58,$56,$58,$56,$95,$2E,$29,$57
	.byte $59,$57,$59,$57,$59,$57,$95,$2D
	.byte $C8,$88,$6A,$8B,$2C,$2E,$88,$88
	.byte $6B,$80,$AA,$7B,$2B,$2D,$88,$0B
	.byte $0C,$0B,$0C,$0C,$0C,$0B,$0C,$63
	.byte $79,$7A,$7A,$7E,$7A,$7A,$7E,$A4
	.byte $7A,$2C,$28,$88,$11,$16,$14,$17
	.byte $0F,$16,$0F,$10,$8C,$48,$C9,$C6
	.byte $13,$17,$8B,$E1,$82,$CA,$85,$18
	.byte $0D,$0E,$82,$E2,$8D,$00,$87,$7A
	.byte $7C,$89,$84,$18,$04,$00,$00,$82
	.byte $9F,$87,$E1,$82,$CB,$83,$E5,$15
	.byte $6B,$7F,$88,$8A,$82,$E5,$A5,$94
	.byte $00,$00,$83,$82,$7C,$CC,$83,$E9
	.byte $10,$63,$79,$89,$8B,$68,$7D,$9D
	.byte $8F,$82,$D0,$83,$15,$82,$E2,$A2
	.byte $8F,$D6,$83,$12,$82,$D8,$83,$11
	.byte $8F,$26,$56,$58,$56,$58,$56,$58
	.byte $56,$58,$56,$58,$83,$0F,$82,$A9
	.byte $7B,$84,$29,$57,$59,$57,$59,$57
	.byte $59,$57,$59,$57,$59,$83,$17,$82
	.byte $7A,$7A,$7A,$7E,$7A,$7A,$7E,$7A
	.byte $7C,$84,$CB,$83,$12,$8A,$E1,$82
	.byte $8F,$83,$16,$8A,$7C,$8F,$14,$15
	.byte $10,$18,$87,$E1,$82,$D2,$0D,$0D
	.byte $0E,$04,$87,$7C,$92,$C4,$E5,$63
	.byte $81,$7B,$7B,$7B,$D5,$84,$66,$C7
	.byte $23,$31,$27,$8F,$84,$67,$84,$22
	.byte $32,$32,$3B,$4E,$2F,$26,$56,$58
	.byte $56,$58,$56,$58,$56,$58,$56,$58
	.byte $56,$58,$56,$58,$84,$C5,$2B,$54
	.byte $55,$52,$38,$28,$29,$57,$59,$57
	.byte $59,$57,$59,$57,$59,$57,$59,$57
	.byte $59,$57,$59,$89,$2A,$52,$38,$37
	.byte $28,$D0,$8A,$38,$29,$D2,$8A,$2D
	.byte $D3,$89,$2C,$2E,$26,$5A,$5C,$5A
	.byte $5C,$5A,$5C,$5A,$5C,$5A,$5C,$5A
	.byte $5C,$5A,$5C,$5A,$5C,$5A,$5C,$8A
	.byte $2F,$29,$5B,$5D,$5B,$5D,$5B,$5D
	.byte $5B,$5D,$5B,$5D,$5B,$5D,$5B,$5D
	.byte $5B,$5D,$5B,$5D,$8A,$2E,$D3,$89
	.byte $2B,$39,$26,$92,$89,$2A,$54,$39
	.byte $30,$26,$90,$8A,$55,$52,$52,$2E
	.byte $26,$56,$58,$56,$58,$56,$58,$56
	.byte $58,$56,$58,$56,$58,$56,$58,$56
	.byte $89,$2B,$53,$54,$4E,$2F,$29,$57
	.byte $59,$57,$59,$57,$59,$57,$59,$57
	.byte $59,$57,$59,$57,$59,$57,$8A,$4F
	.byte $38,$36,$28,$D0,$FF
level3_s2:
	.byte 60, 0
	.byte 255, 255, 7, 255
	.byte 0, 0, 0, 0
	.byte 32
	.byte 254, 0, 0, 128
	.byte 8, 0, 0, 9
	.byte 0, 0, 0, 242
	.word level3_s2_t
	.word level3_s2_p
	.word level3_s2_e
level3_s2u_p:
	.byte $00,$00,$00,$00,$00,$00,$AA,$00
	.byte $A8,$AA,$80,$0A,$80,$00,$AA,$00
	.byte $00,$A0,$2A,$02,$A0,$08,$A2,$08
	.byte $88,$88,$AA,$AA,$AA,$02,$00,$0A
	.byte $20,$22,$22,$00,$80,$88,$A0,$0A
	.byte $00,$00,$00,$00,$AA,$0A,$20,$02
	.byte $00,$00,$00,$00,$A0,$02,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$A0,$0A
	.byte $00,$00,$00,$00,$00,$00,$00,$0A
	.byte $FE,$00,$00,$00,$00,$00,$00,$A0
	.byte $0A,$00,$00,$00,$00,$00,$00,$20
	.byte $02,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$FE,$FE,$FF
level3_s2u_e:
	.byte $50,$78,$01,$00
	.byte $FF
level3_s2u_t:
	.byte $D9,$07,$15,$00,$00,$00,$99,$06
	.byte $84,$99,$05,$84,$9E,$8C,$1D,$8C
	.byte $07,$11,$83,$83,$01,$0B,$0C,$0C
	.byte $03,$84,$07,$91,$0B,$0B,$0B,$1B
	.byte $12,$13,$13,$08,$92,$12,$83,$14
	.byte $11,$15,$00,$00,$00,$15,$0A,$83
	.byte $01,$0A,$85,$75,$1D,$85,$05,$11
	.byte $83,$C6,$15,$09,$83,$07,$08,$86
	.byte $07,$85,$02,$1A,$83,$86,$00,$19
	.byte $03,$82,$02,$04,$8C,$00,$06,$11
	.byte $82,$87,$13,$0A,$82,$C7,$82,$03
	.byte $85,$02,$0E,$1A,$00,$87,$11,$8B
	.byte $06,$08,$85,$00,$00,$07,$17,$87
	.byte $00,$19,$0C,$0C,$0B,$03,$A5,$74
	.byte $75,$05,$89,$10,$88,$00,$14,$12
	.byte $13,$19,$A4,$0C,$0B,$0B,$0D,$04
	.byte $87,$02,$1A,$11,$15,$17,$86,$00
	.byte $00,$00,$12,$14,$12,$17,$18,$0E
	.byte $04,$CA,$07,$0E,$0D,$0D,$1A,$12
	.byte $13,$12,$10,$16,$17,$11,$18,$0D
	.byte $0E,$0D,$0D,$04,$CC,$06,$00,$00
	.byte $00,$02,$0E,$0D,$0E,$0D,$0D,$0D
	.byte $0E,$04,$D1,$07,$83,$D8,$01,$0B
	.byte $1B,$95,$01,$03,$84,$07,$13,$00
	.byte $93,$01,$0C,$1B,$0E,$21,$83,$06
	.byte $12,$10,$93,$05,$18,$04,$C5,$02
	.byte $0D,$0D,$91,$01,$0B,$1B,$09,$C9
	.byte $91,$02,$0D,$1A,$8A,$91,$00,$00
	.byte $07,$08,$89,$93,$05,$04,$89,$93
	.byte $07,$CA,$93,$1E,$8A,$93,$CB,$9E
	.byte $9A,$01,$0C,$0B,$0B,$9A,$02,$0E
	.byte $1A,$10,$9A,$00,$00,$02,$1A,$9C
	.byte $00,$05,$9D,$07,$9D,$06,$9D,$07
	.byte $9C,$01,$1B,$9C,$06,$12,$9C,$07
	.byte $14,$9C,$05,$17,$9C,$06,$16,$9B
	.byte $01,$1B,$00,$9B,$05,$11,$00,$9C
	.byte $13,$16,$9B,$02,$0E,$0D,$9B,$00
	.byte $00,$00,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $9E,$9E,$9E,$9E,$9E,$9E,$9E,$9E
	.byte $FF
level3_s2u:
	.byte 60, 0
	.byte 255, 11, 10, 255
	.byte 0, 0, 0, 0
	.byte 32
	.byte 255
	.word level3_s2u_t
	.word level3_s2u_p
	.word level3_s2u_e
level3_s3_p:
	.byte $00,$00,$AA,$00,$00,$00,$00,$00
	.byte $00,$00,$AA,$08,$00,$00,$00,$00
	.byte $00,$00,$AA,$2A,$00,$00,$00,$00
	.byte $00,$00,$AA,$00,$00,$00,$88,$00
	.byte $00,$00,$AA,$88,$00,$00,$00,$00
	.byte $00,$00,$AA,$02,$00,$00,$00,$00
	.byte $00,$00,$AA,$AA,$00,$00,$88,$00
	.byte $00,$A0,$AA,$88,$00,$00,$00,$00
	.byte $00,$A0,$AA,$AA,$00,$00,$00,$00
	.byte $AA,$A0,$0A,$22,$22,$22,$22,$02
	.byte $FF
level3_s3_e:
	.byte $60,$40,$04
	.byte $FF
level3_s3_t:
	.byte $D7,$2C,$2F,$C5,$97,$2A,$2E,$85
	.byte $9E,$97,$2C,$2F,$85,$9E,$97,$2B
	.byte $2D,$85,$98,$39,$26,$84,$97,$2A
	.byte $4E,$39,$26,$83,$97,$2B,$53,$50
	.byte $39,$27,$56,$58,$8B,$6A,$8B,$2C
	.byte $51,$50,$38,$29,$57,$59,$8B,$6B
	.byte $8B,$2B,$4E,$38,$29,$00,$00,$00
	.byte $83,$6A,$87,$63,$80,$8A,$2C,$38
	.byte $28,$C4,$83,$6B,$88,$79,$8B,$2E
	.byte $C5,$83,$63,$80,$92,$2B,$86,$84
	.byte $79,$7B,$7B,$71,$40,$3C,$3E,$44
	.byte $AB,$7B,$2A,$2F,$85,$85,$7A,$7A
	.byte $7E,$C4,$EC,$7A,$7E,$7A,$7C,$00
	.byte $00,$83,$7A,$7E,$7A,$00,$2B,$86
	.byte $88,$7A,$7A,$7E,$7A,$7A,$7E,$7C
	.byte $C4,$E6,$83,$7E,$7C,$00,$2C,$2E
	.byte $85,$8C,$E1,$82,$C7,$E2,$7E,$82
	.byte $82,$39,$27,$84,$8C,$7C,$88,$7C
	.byte $82,$4F,$39,$30,$27,$82,$95,$E9
	.byte $82,$00,$2B,$52,$4F,$51,$2F,$5E
	.byte $5F,$8B,$7C,$C8,$7E,$7A,$82,$53
	.byte $38,$37,$29,$00,$00,$89,$7C,$CA
	.byte $7E,$7C,$00,$2C,$38,$29,$C4,$87
	.byte $CD,$E5,$7E,$82,$00,$2B,$2D,$C5
	.byte $86,$7C,$8C,$E1,$83,$84,$2E,$85
	.byte $91,$E5,$83,$7A,$7A,$7E,$7C,$82
	.byte $2D,$85,$86,$E6,$7A,$82,$00,$83
	.byte $7E,$82,$89,$E9,$82,$00,$2A,$2E
	.byte $00,$5A,$5C,$5A,$5C,$87,$71,$41
	.byte $3C,$3C,$44,$AA,$7B,$23,$3B,$2D
	.byte $00,$5B,$5D,$5B,$5D,$86,$7C,$CF
	.byte $2C,$4E,$2F,$C5,$85,$7C,$D0,$2C
	.byte $54,$86,$85,$D0,$22,$3B,$53,$39
	.byte $26,$84,$95,$2A,$54,$00,$51,$2E
	.byte $84,$8E,$6A,$86,$2C,$4E,$00,$00
	.byte $39,$26,$56,$58,$56,$8E,$6B,$86
	.byte $2B,$51,$82,$38,$28,$57,$59,$57
	.byte $8E,$63,$80,$A5,$7B,$2A,$54,$00
	.byte $55,$2E,$C4,$86,$E4,$83,$7E,$7A
	.byte $82,$85,$EC,$79,$7A,$7A,$7E,$82
	.byte $00,$2A,$4E,$00,$00,$39,$26,$83
	.byte $85,$7A,$7A,$82,$7C,$89,$7C,$00
	.byte $2B,$54,$82,$00,$39,$32,$32,$33
	.byte $33,$31,$A7,$32,$30,$31,$30,$33
	.byte $30,$33,$30,$26,$C4,$2B,$53,$83
	.byte $00,$4E,$55,$51,$4F,$51,$50,$53
	.byte $50,$4E,$53,$51,$4F,$4E,$4F,$4E
	.byte $52,$4E,$54,$54,$2F,$85,$4F,$84
	.byte $00,$00,$00,$CF,$51,$85,$2A,$4E
	.byte $87,$8F,$38,$29,$85,$50,$87,$FF
level3_s3:
	.byte 40, 0
	.byte 255, 255, 12, 255
	.byte 0, 0, 14, 0
	.byte 4
	.byte 0, 0, 112, 0
	.byte 0, 0, 255, 0
	.byte 0, 0, 0, 0
	.word level3_s3_t
	.word level3_s3_p
	.word level3_s3_e
