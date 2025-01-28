; Copyright (C) 2025 iProgramInCpp

; Metatile Data for "Celestial Resort" (Level 3)

; Metatiles
;
; For a single metatile ID, the following properties:
; - metatiles: The char tiles that make up the visual representation of the metatile
; - metatile_palette: The palette used for the metatile
; - metatile_collision: The collision mask for the metatile.

; These are the metatiles for the Intro level.
; Eventually the metatile bank will be swappable with different level banks.

;metatiles:
.align $100
	.byte $00 ; Air
	.byte $60,$61,$72,$73 ; Snow Corners
	.byte $6B,$6C,$6D     ; Snow Tops
	.byte $74,$75,$76     ; Snow Bottoms
	.byte $70,$62         ; Snow Left
	.byte $71,$63         ; Snow Right
	.byte $64,$65,$66,$7E,$6F,$6E,$7B,$7C,$7D ; Snow Middles
	.byte $67,$68,$77,$78 ; Snow In-corners
	.byte $7F,$CC,$CD,$CE,$CF,$DF ; Snow
	.byte $36,$40,$37,$44,$38,$50,$39,$54  ; Stone Corners - $B0
	.byte $41,$42,$43     ; Stone Tops $B8
	.byte $51,$52,$53     ; Stone Bottoms $BB
	.byte $47,$48,$49,$4A ; Stone Left $BE
	.byte $57,$58,$59,$5A ; Stone Right $C2
	.byte $45,$46,$55,$56 ; Stone In-corners $C6
	.byte $10,$11,$12     ; Stone Pillar $CA
	.byte $20,$21,$22     ; Stone Pillar Top $CD
	.byte $30,$31,$32     ; Stone Pillar Bottom $D0
	.byte $13,$14,$15     ; Stone Bar Left $D3
	.byte $23,$24,$25     ; Stone Bar Right $D6
	.byte $33,$34,$35     ; Stone Bar $D9
	.byte $4B,$4C,$4D,$4E,$5B,$5C,$5D,$5E ; Stone Middles $DC
	.byte $69,$6A,$79     ; Jump Through
	.byte $C8,$C9,$CA,$CB ; Spikes
	.byte $C8,$C9,$CA,$CB ; Spikes (Alt)

;metatile_info:
.align $100
	.byte ct_none                ; Air
	.res  27, ct_full            ; Snow

.align $100