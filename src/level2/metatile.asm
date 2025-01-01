; Copyright (C) 2024 iProgramInCpp

; Metatile Data for "Forsaken City" (Level 1)

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
	.byte $60,$64,$70,$74 ; Dirt Corners
	.byte $61,$62,$63     ; Dirt Tops
	.byte $71,$72,$73     ; Dirt Bottoms
	.byte $67,$77,$68,$67 ; Dirt Left
	.byte $69,$79,$6A,$7A ; Dirt Right
	.byte $6B,$6C,$6D,$6E,$7B,$7C,$7D,$9A ; Dirt Middles
	.byte $6F,$78         ; Dirt Left, Right Ends
	.byte $80,$84,$90,$94 ; Snow Corners
	.byte $81,$82,$83     ; Snow Tops
	.byte $91,$92,$93     ; Snow Bottoms
	.byte $87,$97         ; Snow Left
	.byte $88,$98         ; Snow Right
	.byte $8B,$8C,$8D,$8E,$8F,$9B,$9C,$9D,$9E ; Snow Middles
	.byte $85,$86,$95,$96 ; Snow In-corners
	.byte $65,$66,$75,$76 ; Dirt In-corners
	.byte $89,$8A,$99     ; Jump Through
	.byte $C8             ; Spikes
	.byte $CC,$CD,$CE,$CF ; Snow Connections
	.byte $A0,$A4,$B0,$B4 ; Tower Corners
	.byte $A5,$A6,$B5,$B6 ; Tower Corners Alt
	.byte $A1,$A2,$A3     ; Tower Tops
	.byte $B1,$B2,$B3     ; Tower Bottoms
	.byte $A9,$B9         ; Tower Left
	.byte $AA,$BA         ; Tower Right
	.byte $AB,$AC,$AD,$AE,$AF,$BB,$BC,$BD
	.byte $BE             ; Tower Connection
	.byte $BF             ; Snow Connection
	.byte $A7,$A8,$B7,$B8 ; Tower Corners
	.byte $16,$26,$17,$27 ; Tower R, L, UD, LR
	.byte $C9,$CA,$CB     ; Spikes
	.byte $89,$8A,$99     ; Grey Jump Through
	.byte $0E             ; Memorial
	.byte $0F             ; Memorial
	.byte $2C,$2D,$2E,$2F ; Campfire
	.byte $C8,$C9,$CA,$CB ; Spikes (Blue)
	.byte $C0,$C1,$C2,$C3,$D0,$D1,$D2,$D3,$E0,$E1,$E2,$E3,$F0,$F1,$F2,$F3 ; Dream Block Middles
	.byte $C4,$D4,$E4,$F4,$C6,$D6,$E6,$F6  ; Dream Block Left
	.byte $C5,$D5,$E5,$F5,$C7,$D7,$E7,$F7  ; Dream Block Right
	.byte $D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF  ; Dream Block Top
	.byte $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF  ; Dream Block Bottom
	.byte $F8,$FC,$F9,$FD,$FA,$5F,$FB,$FF  ; Dream Block Corners
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
	.byte $18,$28         ; Tower U, D $E4
	.byte $3A             ; Snow LR $E6
	.byte $C8,$C9,$CA,$CB ; Spikes (Red)
	; $E7

;metatile_info:
.align $100
	.byte ct_none                ; Air
	.res  28, ct_full            ; Dirt
	.res  27, ct_full            ; Snow
	.res   4, ct_full            ; Dirt
	.res   3, ct_jumpthru        ; Jump Through
	.byte ct_deadlyUP            ; Spikes
	.res   4, ct_full            ; Snow Conns
	.res  36, ct_full            ; Tower (27) + SnowConn (1) + Tower (8)
	.byte ct_deadlyRT            ; Spikes
	.byte ct_deadlyDN            ; Spikes
	.byte ct_deadlyLT            ; Spikes
	.res   3, ct_jumpthru        ; Grey Jump Through
	.res   2, ct_none            ; Memorial
	.res   4, ct_none            ; Campfire
	.byte ct_deadlyUP            ; Spikes (Blue)
	.byte ct_deadlyRT            ; Spikes (Blue)
	.byte ct_deadlyDN            ; Spikes (Blue)
	.byte ct_deadlyLT            ; Spikes (Blue)
	.res  56, ct_dream           ; Dream Block
	.res  52, ct_full            ; Stone
	.res   3, ct_full            ; Tower + Snow
	.byte ct_deadlyUP            ; Spikes (Red)
	.byte ct_deadlyRT            ; Spikes (Red)
	.byte ct_deadlyDN            ; Spikes (Red)
	.byte ct_deadlyLT            ; Spikes (Red)

.align $100