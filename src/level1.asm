level1_r1_p:
	.byte $80,$1A,$01,$00,$00,$48,$04,$00
	.byte $80,$08,$00,$00,$00,$11,$50,$00
	.byte $A0,$02,$00,$00,$40,$44,$10,$00
	.byte $20,$55,$05,$00,$10,$01,$05,$00
	.byte $40,$01,$00,$00,$80,$88,$06,$00
	.byte $40,$00,$00,$00,$20,$08,$00,$00
	.byte $10,$00,$00,$00,$00,$12,$45,$04
	.byte $00,$00,$80,$08,$00,$00,$11,$01
	.byte $00,$88,$A8,$88,$00,$00,$00,$00
	.byte $00,$02,$02,$20,$52,$45,$44,$04
	.byte $FF
level1_r1_e:
	.byte $FF
level1_r1_t:
	.byte $C4,$2C,$2B,$16,$15,$14,$13,$5D
	.byte $64,$A9,$65,$64,$5F,$C7,$84,$34
	.byte $2A,$11,$12,$10,$0F,$54,$47,$C9
	.byte $4C,$5A,$87,$83,$2C,$24,$D0,$23
	.byte $18,$87,$83,$2B,$92,$1A,$19,$14
	.byte $85,$83,$64,$A5,$65,$64,$8B,$02
	.byte $11,$12,$54,$62,$84,$83,$66,$00
	.byte $00,$67,$00,$00,$66,$8B,$00,$00
	.byte $00,$3F,$4C,$18,$83,$83,$35,$1F
	.byte $00,$64,$92,$4D,$13,$83,$83,$2F
	.byte $26,$C4,$67,$8F,$4E,$14,$83,$83
	.byte $34,$29,$1D,$65,$65,$65,$64,$90
	.byte $15,$83,$82,$2B,$24,$D4,$3F,$4D
	.byte $16,$83,$82,$2C,$26,$8F,$01,$0B
	.byte $0C,$0D,$0C,$52,$63,$C4,$82,$2D
	.byte $25,$8F,$06,$18,$18,$18,$14,$5A
	.byte $5F,$84,$82,$2E,$24,$8F,$02,$0F
	.byte $10,$55,$62,$C6,$82,$00,$35,$0B
	.byte $0B,$0C,$0D,$03,$8A,$00,$00,$00
	.byte $3F,$4C,$18,$85,$83,$00,$00,$13
	.byte $14,$13,$08,$8E,$4D,$19,$85,$84
	.byte $14,$38,$10,$0F,$04,$8F,$1A,$85
	.byte $84,$13,$09,$D0,$3F,$4C,$2F,$85
	.byte $84,$38,$04,$91,$4D,$30,$85,$83
	.byte $13,$64,$C8,$64,$A4,$65,$27,$28
	.byte $27,$28,$28,$37,$02,$85,$83,$14
	.byte $66,$88,$66,$00,$00,$66,$00,$21
	.byte $2B,$2C,$2D,$2E,$C7,$83,$00,$8D
	.byte $64,$37,$CB,$83,$64,$65,$65,$64
	.byte $86,$64,$A4,$65,$2A,$36,$8A,$83
	.byte $08,$CE,$3F,$4C,$2B,$89,$83,$09
	.byte $8F,$4D,$2D,$89,$83,$0A,$8F,$4E
	.byte $2E,$2E,$13,$14,$86,$83,$08,$8F
	.byte $45,$29,$2A,$10,$3A,$15,$85,$82
	.byte $5C,$4F,$8E,$C4,$3F,$4C,$86,$82
	.byte $5D,$94,$4D,$13,$15,$16,$17,$18
	.byte $19,$82,$5E,$50,$93,$45,$02,$10
	.byte $10,$11,$12,$10,$59,$5A,$5F,$51
	.byte $92,$C8,$54,$55,$54,$47,$9A,$CA
	.byte $1D,$28,$1F,$91,$8B,$2B,$4F,$91
	.byte $8B,$2C,$50,$6A,$6A,$8F,$86,$1D
	.byte $1F,$83,$2D,$35,$27,$1F,$8F,$85
	.byte $1D,$37,$35,$28,$27,$37,$00,$00
	.byte $2E,$25,$8F,$52,$53,$52,$53,$28
	.byte $37,$00,$00,$2D,$2E,$C4,$35,$27
	.byte $28,$27,$03,$8B,$5B,$5A,$5E,$59
	.byte $2B,$CA,$31,$2C,$2D,$39,$0E,$03
	.byte $89,$D3,$13,$39,$03,$88,$93,$00
	.byte $13,$39,$0B,$0C,$0D,$0E,$0B,$0D
	.byte $0C,$0E,$FF
level1_r1:
	.byte 0, 0, 0
	.byte 16, 152
	.byte 2, 255, 255, 2
	.byte 20, 255, 255, 254
	.byte 0
	.word level1_r1_t
	.word level1_r1_p
	.word level1_r1_e
level1_r2_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $FE,$00,$00,$00,$00,$00,$80,$08
	.byte $00,$00,$00,$00,$00,$00,$20,$22
	.byte $02,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$80,$88,$00,$80,$88,$00
	.byte $00,$00,$A2,$2A,$00,$A0,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$80,$0A,$00
	.byte $00,$00,$00,$00,$00,$A0,$00,$00
	.byte $00,$00,$00,$00,$22,$22,$00,$00
	.byte $00,$FF
level1_r2_e:
	.byte $68,$58,$01
	.byte $FF
level1_r2_t:
	.byte $DE,$8E,$5B,$5C,$5D,$5E,$5F,$5D
	.byte $5D,$5A,$5F,$5A,$59,$5A,$5C,$5D
	.byte $5B,$5C,$8A,$5E,$57,$5F,$60,$54
	.byte $55,$55,$54,$55,$55,$55,$A4,$54
	.byte $55,$55,$55,$54,$55,$84,$5A,$5F
	.byte $5E,$5D,$5C,$60,$54,$55,$55,$47
	.byte $C9,$6C,$C6,$83,$60,$65,$64,$65
	.byte $64,$65,$66,$CD,$6B,$86,$82,$5F
	.byte $51,$00,$66,$00,$66,$00,$95,$82
	.byte $5E,$50,$9A,$82,$60,$4B,$93,$6D
	.byte $86,$00,$5C,$51,$00,$00,$92,$44
	.byte $52,$52,$53,$53,$53,$52,$00,$5D
	.byte $50,$94,$4C,$59,$5A,$5F,$5C,$5D
	.byte $5E,$00,$00,$61,$65,$65,$64,$65
	.byte $65,$65,$64,$8D,$22,$2C,$C5,$82
	.byte $60,$55,$55,$47,$D1,$21,$2D,$85
	.byte $82,$00,$4F,$D3,$21,$2E,$2B,$2C
	.byte $2E,$2F,$30,$83,$50,$93,$22,$29
	.byte $2A,$29,$29,$2A,$2A,$83,$51,$93
	.byte $66,$C6,$83,$50,$9A,$83,$64,$65
	.byte $65,$65,$64,$8D,$64,$65,$64,$A6
	.byte $65,$83,$4F,$D1,$82,$A7,$65,$83
	.byte $61,$46,$90,$C9,$83,$5A,$4F,$99
	.byte $83,$5B,$50,$99,$83,$5C,$51,$99
	.byte $83,$00,$00,$53,$28,$1F,$88,$3F
	.byte $44,$28,$1F,$8A,$85,$00,$2C,$35
	.byte $28,$28,$27,$1F,$85,$4C,$2B,$35
	.byte $28,$28,$27,$27,$52,$52,$53,$53
	.byte $53,$52,$86,$00,$00,$2B,$33,$32
	.byte $26,$85,$4E,$2C,$2B,$00,$56,$5F
	.byte $5B,$5A,$57,$58,$59,$5A,$5B,$85
	.byte $2E,$2D,$31,$34,$29,$29,$20,$86
	.byte $34,$2A,$54,$54,$54,$62,$C6,$84
	.byte $60,$54,$2A,$2A,$20,$C7,$3F,$45
	.byte $20,$00,$00,$00,$3F,$4C,$5C,$85
	.byte $83,$56,$4F,$D1,$3F,$4D,$62,$85
	.byte $83,$5F,$50,$91,$00,$3F,$4D,$5D
	.byte $84,$83,$00,$61,$46,$92,$4C,$5E
	.byte $84,$84,$00,$51,$8F,$44,$53,$53
	.byte $63,$C5,$85,$61,$52,$53,$46,$8C
	.byte $4C,$5C,$5F,$C6,$85,$00,$00,$5C
	.byte $50,$8C,$22,$5B,$C7,$87,$59,$4F
	.byte $8C,$23,$5A,$87,$5B,$5E,$5D,$5C
	.byte $5F,$5E,$5E,$5E,$61,$52,$53,$52
	.byte $46,$85,$1D,$27,$28,$37,$C8,$AE
	.byte $65,$64,$83,$21,$2C,$2D,$C9,$D2
	.byte $23,$2E,$CA,$93,$30,$8A,$92,$22
	.byte $31,$8A,$92,$21,$32,$8A,$52,$52
	.byte $A4,$53,$52,$53,$53,$53,$52,$52
	.byte $28,$28,$27,$27,$28,$28,$37,$CB
	.byte $00,$00,$00,$58,$59,$5A,$5C,$5E
	.byte $5D,$5F,$5E,$5A,$2C,$2D,$2E,$2F
	.byte $30,$31,$CC,$83,$DB,$9E,$FF
level1_r2:
	.byte 1, 0, 12
	.byte 1, 0
	.byte 4, 255, 255, 255
	.byte 20, 255, 255, 255
	.byte 0
	.word level1_r2_t
	.word level1_r2_p
	.word level1_r2_e
level1_r3_p:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$05,$00
	.byte $00,$00,$80,$08,$00,$00,$00,$00
	.byte $00,$00,$20,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$22,$22,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$08,$00,$00,$00,$00,$00,$00
	.byte $00,$02,$A0,$AA,$0A,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $22,$22,$22,$A2,$AA,$08,$00,$00
	.byte $FF
level1_r3_e:
	.byte $FF
level1_r3_t:
	.byte $DE,$89,$58,$57,$56,$57,$58,$59
	.byte $5A,$5B,$5C,$5D,$5E,$5F,$5E,$88
	.byte $87,$5A,$60,$AD,$65,$64,$5D,$5C
	.byte $5B,$5E,$5F,$5A,$5D,$86,$60,$54
	.byte $4B,$CD,$64,$A7,$65,$85,$5C,$4F
	.byte $D1,$3D,$C5,$85,$5D,$50,$91,$3C
	.byte $85,$85,$5E,$51,$97,$84,$64,$65
	.byte $64,$91,$3E,$85,$84,$4F,$D3,$44
	.byte $53,$53,$52,$53,$52,$83,$5E,$50
	.byte $93,$4D,$56,$5C,$5D,$5E,$5F,$83
	.byte $5D,$51,$93,$45,$54,$55,$54,$55
	.byte $54,$83,$5C,$87,$1D,$1F,$8B,$C6
	.byte $83,$5B,$50,$86,$22,$4F,$91,$83
	.byte $5A,$4F,$86,$1E,$65,$65,$65,$64
	.byte $8E,$83,$59,$50,$86,$D3,$83,$5C
	.byte $9A,$83,$5F,$51,$99,$83,$00,$61
	.byte $52,$46,$97,$84,$00,$60,$47,$88
	.byte $64,$65,$65,$65,$64,$8A,$84,$5F
	.byte $51,$CB,$4D,$56,$4F,$8A,$84,$5C
	.byte $4F,$8B,$21,$31,$35,$28,$1F,$88
	.byte $84,$5B,$50,$8B,$1E,$29,$2A,$29
	.byte $29,$20,$87,$84,$5C,$51,$8B,$CD
	.byte $84,$5E,$50,$98,$84,$56,$4F,$98
	.byte $84,$59,$51,$90,$3F,$64,$A6,$65
	.byte $84,$56,$50,$91,$4C,$56,$5E,$5F
	.byte $5C,$5E,$5F,$84,$57,$92,$4D,$5D
	.byte $C5,$84,$64,$65,$65,$64,$8B,$3F
	.byte $48,$53,$52,$63,$C6,$84,$50,$CE
	.byte $3F,$4D,$5A,$59,$C7,$84,$26,$8F
	.byte $45,$62,$C8,$93,$00,$3F,$4C,$5F
	.byte $87,$95,$4D,$58,$87,$84,$35,$1F
	.byte $85,$1D,$A4,$28,$1F,$84,$4C,$56
	.byte $87,$A6,$65,$64,$85,$2B,$A4,$29
	.byte $20,$83,$4E,$5A,$87,$CB,$1E,$29
	.byte $20,$C6,$3F,$45,$54,$62,$86,$8B
	.byte $CB,$3F,$4D,$5E,$85,$97,$4C,$5F
	.byte $85,$9E,$A9,$65,$64,$8D,$4D,$5A
	.byte $85,$2B,$2C,$2D,$30,$2F,$31,$32
	.byte $33,$32,$35,$A4,$28,$87,$3F,$44
	.byte $63,$C6,$CA,$33,$32,$31,$2E,$A6
	.byte $28,$52,$52,$63,$5C,$86,$8A,$C4
	.byte $2C,$2D,$2E,$31,$30,$32,$32,$32
	.byte $5F,$C7,$8E,$D0,$FF
level1_r3:
	.byte 0, 0, 0
	.byte 0, 0
	.byte 6, 255, 255, 255
	.byte 20, 0, 0, 0
	.byte 0
	.word level1_r3_t
	.word level1_r3_p
	.word level1_r3_e
level1_r4_p:
	.byte $00,$80,$AA,$AA,$22,$22,$22,$02
	.byte $00,$2A,$00,$00,$00,$00,$00,$00
	.byte $00,$0A,$00,$04,$40,$A0,$AA,$0A
	.byte $A0,$0A,$00,$00,$00,$00,$00,$00
	.byte $A0,$8A,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $88,$08,$00,$00,$00,$00,$00,$00
	.byte $00,$AA,$0A,$00,$00,$00,$00,$00
	.byte $80,$0A,$00,$00,$00,$00,$00,$00
	.byte $00,$A2,$88,$88,$88,$88,$88,$08
	.byte $FF
level1_r4_e:
	.byte $FF
level1_r4_t:
	.byte $D1,$2E,$2D,$2F,$32,$C9,$88,$2D
	.byte $2E,$31,$31,$2C,$2E,$30,$32,$34
	.byte $2A,$2A,$29,$29,$36,$33,$2F,$2D
	.byte $2F,$30,$32,$32,$2D,$87,$34,$2A
	.byte $A4,$29,$2A,$2A,$29,$4B,$A4,$68
	.byte $64,$A8,$65,$86,$2B,$25,$CF,$6C
	.byte $C6,$86,$34,$20,$8F,$6B,$86,$85
	.byte $34,$20,$D0,$87,$84,$32,$25,$D1
	.byte $6D,$86,$84,$2D,$92,$64,$A6,$65
	.byte $84,$30,$26,$86,$64,$65,$64,$A4
	.byte $6A,$84,$21,$2D,$2D,$30,$2E,$33
	.byte $32,$84,$31,$25,$88,$A4,$65,$64
	.byte $84,$23,$2E,$2E,$2B,$2E,$2E,$2E
	.byte $84,$32,$24,$86,$3D,$00,$00,$00
	.byte $3F,$64,$04,$84,$1E,$2A,$29,$2A
	.byte $29,$29,$2A,$84,$34,$20,$86,$3C
	.byte $85,$CC,$83,$32,$25,$D9,$83,$33
	.byte $26,$99,$83,$2F,$25,$99,$83,$32
	.byte $24,$99,$83,$2F,$26,$99,$83,$33
	.byte $24,$99,$83,$00,$35,$27,$27,$1F
	.byte $96,$83,$2B,$2B,$2B,$32,$25,$96
	.byte $A9,$65,$64,$94,$DE,$9E,$9E,$9E
	.byte $A5,$65,$64,$98,$27,$28,$27,$28
	.byte $28,$1F,$98,$2E,$2C,$2E,$2B,$2D
	.byte $35,$46,$A4,$6A,$93,$C5,$2E,$35
	.byte $28,$28,$27,$46,$93,$85,$00,$2B
	.byte $2D,$2B,$34,$A4,$65,$64,$8F,$85
	.byte $2F,$30,$31,$2B,$24,$D4,$85,$34
	.byte $29,$2A,$29,$20,$94,$84,$30,$25
	.byte $D8,$84,$2C,$99,$84,$34,$20,$98
	.byte $83,$2E,$24,$D9,$83,$00,$35,$27
	.byte $28,$1F,$96,$84,$00,$2C,$32,$26
	.byte $96,$85,$00,$00,$35,$27,$27,$27
	.byte $28,$28,$27,$28,$1F,$8E,$87,$00
	.byte $2E,$2F,$32,$33,$30,$2C,$32,$35
	.byte $27,$28,$A7,$27,$28,$28,$27,$28
	.byte $27,$FF
level1_r4:
	.byte 0, 0, 0
	.byte 0, 0
	.byte 8, 255, 255, 255
	.byte 8, 0, 0, 0
	.byte 0
	.word level1_r4_t
	.word level1_r4_p
	.word level1_r4_e
level1_rEnd_p:
	.byte $00,$00,$00,$00,$00,$A0,$08,$00
	.byte $00,$00,$00,$00,$00,$60,$22,$02
	.byte $00,$00,$00,$00,$00,$90,$AA,$0A
	.byte $00,$00,$00,$00,$00,$A0,$0A,$00
	.byte $00,$00,$00,$00,$00,$2A,$00,$00
	.byte $00,$00,$00,$00,$00,$0A,$00,$00
	.byte $00,$00,$00,$00,$00,$8A,$00,$00
	.byte $00,$00,$00,$00,$00,$54,$00,$00
	.byte $00,$00,$00,$00,$00,$51,$00,$00
	.byte $00,$00,$00,$00,$00,$A0,$00,$00
	.byte $FF
level1_rEnd_e:
	.byte $FF
level1_rEnd_t:
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
	.byte $A1,$87,$1D,$28,$37,$C8,$8C,$70
	.byte $74,$78,$7C,$7F,$A1,$83,$A1,$88
	.byte $23,$30,$C9,$8B,$6E,$71,$75,$79
	.byte $7D,$80,$A1,$84,$A1,$89,$21,$2D
	.byte $89,$8B,$6F,$72,$76,$7A,$7D,$A1
	.byte $81,$A1,$85,$82,$33,$89,$8B,$00
	.byte $73,$77,$7B,$7E,$A1,$82,$A1,$86
	.byte $A1,$8A,$21,$30,$89,$8C,$C6,$A1
	.byte $8B,$1E,$36,$2D,$88,$92,$00,$00
	.byte $23,$89,$95,$2E,$88,$94,$1E,$36
	.byte $88,$94,$00,$21,$31,$87,$95,$1E
	.byte $36,$87,$95,$00,$05,$87,$96,$07
	.byte $13,$86,$95,$A1,$8C,$07,$14,$86
	.byte $95,$A1,$8D,$05,$17,$86,$95,$A1
	.byte $8E,$05,$1A,$86,$95,$A1,$8F,$07
	.byte $13,$86,$95,$00,$06,$19,$86,$97
	.byte $C7,$96,$22,$87,$97,$2E,$86,$96
	.byte $23,$2B,$86,$96,$22,$32,$86,$FF
level1_rEnd:
	.byte 0, 0, 0
	.byte 0, 0
	.byte 255, 255, 255, 255
	.byte 0, 0, 0, 0
	.byte 0
	.word level1_rEnd_t
	.word level1_rEnd_p
	.word level1_rEnd_e
level1:
	.byte $01	; environment type
	.byte $05	; room count
	.word level1_r1
	.word level1_r2
	.word level1_r3
	.word level1_r4
	.word level1_rEnd
