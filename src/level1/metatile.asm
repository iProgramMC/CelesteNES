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
	.byte $C4,$C5,$C6,$C7 ; Grass Decals
	.byte $A0,$A4,$B0,$B4 ; Cement Corners
	.byte $A5,$A6,$B5,$B6 ; Cement Corners Alt
	.byte $A1,$A2,$A3     ; Cement Tops
	.byte $B1,$B2,$B3     ; Cement Bottoms
	.byte $A9,$B9         ; Cement Left
	.byte $AA,$BA         ; Cement Right
	.byte $AB,$AC,$AD,$AE,$AF,$BB,$BC,$BD,$BE,$BF ; Cement Middles
	.byte $A7,$A8,$B7,$B8 ; Cement Corners
	.byte $C0,$C1,$C2,$C3 ; Girders
	.byte $C9,$CA,$CB     ; Spikes
	.byte $89,$8A,$99     ; Grey Jump Through
	.byte $F4,$F5         ; Memorial
	.byte $F8,$D9,$F9,$E7 ; Memorial
	.byte $D0,$D1,$D2,$D3 ; Memorial
	.byte $E0,$E1,$E2,$E3 ; Memorial
	.byte $F6,$D4,$F7     ; Memorial
	.byte $F0,$F1,$F2,$F3 ; Memorial
	.byte $D5,$D6,$D7,$D8 ; Memorial
	.byte $E4,$E5,$E6,$E8,$E9 ; Memorial
	.byte $DA,$DB,$DC,$DD ; Campfire
	.byte $C8,$C9,$CA,$CB ; Spikes (Blue)

;metatile_info:
.align $100
	.byte ct_none                ; Air
	.res  28, ct_full            ; Dirt
	.res  27, ct_full            ; Snow
	.res   4, ct_full            ; Dirt
	.res   3, ct_jumpthru        ; Jump Through
	.byte ct_deadly              ; Spikes
	.res   4, ct_none            ; Grass Decals
	.res  32, ct_full            ; Cement
	.res   4, ct_full            ; Girder
	.res   3, ct_deadly          ; Spikes
	.res   3, ct_jumpthru        ; Grey Jump Through
	.res  30, ct_none            ; Memorial
	.res   4, ct_none            ; Campfire
	.res   4, ct_deadly          ; Spikes

.align $100