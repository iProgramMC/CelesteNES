
game_sfx:
	.word @ntsc
	.word @ntsc
@ntsc:
	.word @sfx_ntsc_megamanhit  ; dash
	.word @sfx_ntsc_mushroom
	.word @sfx_ntsc_click       ; jump
	.word @sfx_ntsc_death       ; death
	.word @sfx_ntsc_coin        ; strawberry collect

; TODO: BORROWED FROM some kind of mega man game. Provide original version ASAP.
@sfx_ntsc_megamanhit:
	.byte $84,$b3,$85,$04,$83,$ff,$8a,$0a,$89,$3f,$01,$84,$f3,$8a,$0b,$01
	.byte $84,$32,$85,$05,$89,$f0,$01,$83,$f0,$01,$84,$07,$85,$01,$83,$f8
	.byte $8a,$09,$89,$37,$01,$84,$2d,$8a,$08,$89,$3f,$01,$84,$53,$8a,$07
	.byte $01,$84,$79,$8a,$06,$01,$84,$9f,$8a,$05,$01,$84,$c5,$8a,$04,$01
	.byte $84,$eb,$8a,$03,$01,$84,$11,$85,$02,$8a,$02,$01,$84,$37,$8a,$01
	.byte $01,$84,$5c,$8a,$00,$01,$8a,$0f,$01,$83,$f0,$00

; TODO: BORROWED FROM SMB1. Provide original version ASAP.
@sfx_ntsc_mushroom:
	.byte $84,$d5,$85,$00,$83,$7d,$89,$f0,$02,$84,$1c,$85,$01,$02,$84,$d5
	.byte $85,$00,$02,$84,$a9,$02,$84,$8e,$02,$84,$6a,$02,$84,$8e,$02,$84
	.byte $0c,$85,$01,$02,$84,$d5,$85,$00,$02,$84,$b3,$02,$84,$86,$02,$84
	.byte $b3,$02,$84,$86,$02,$84,$6a,$02,$84,$59,$02,$84,$42,$02,$84,$59
	.byte $02,$84,$ef,$02,$84,$bd,$02,$84,$9f,$02,$84,$77,$02,$84,$9f,$02
	.byte $84,$77,$02,$84,$5e,$02,$84,$4f,$02,$84,$3b,$02,$84,$4f,$01,$00

; TODO: BORROWED FROM FAMIDASH. Provide original version ASAP.
@sfx_ntsc_death:
	.byte $87,$d5,$88,$00,$86,$8f,$8a,$08,$89,$3f,$01,$87,$fd,$8a,$04,$89
	.byte $3e,$01,$86,$80,$01,$89,$3d,$01,$8a,$05,$89,$3c,$02,$8a,$06,$89
	.byte $3b,$01,$89,$3a,$01,$8a,$07,$01,$89,$39,$01,$8a,$08,$89,$38,$02
	.byte $8a,$09,$89,$37,$01,$89,$36,$01,$8a,$0a,$01,$89,$35,$01,$8a,$0b
	.byte $89,$34,$01,$8a,$0c,$01,$8a,$0d,$89,$33,$01,$8a,$0e,$89,$32,$01
	.byte $8a,$0f,$01,$00

; TODO: BORROWED FROM FAMIDASH. Provide original version ASAP.
@sfx_ntsc_coin:
	.byte $81,$e1,$82,$00,$80,$3a,$89,$f0,$02,$81,$70,$80,$38,$02,$80,$37
	.byte $02,$80,$36,$02,$80,$35,$04,$80,$34,$04,$80,$33,$06,$80,$32,$08
	.byte $80,$31,$09,$00

; TODO: BORROWED FROM FAMIDASH. Provide original version ASAP.
@sfx_ntsc_click:
	.byte $8a,$0b,$89,$3f,$01,$89,$35,$00