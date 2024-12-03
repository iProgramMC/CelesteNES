; Copyright (C) 2024 iProgramInCpp

; Metatile Data for "Prologue" (Level 0)

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
	.byte $6B,$6C,$6D,$6E,$7B,$7C,$7D,$A5 ; Dirt Middles
	.byte $6F,$78         ; Dirt Left, Right Ends
	.byte $80,$84,$83,$87 ; Snow Corners
	.byte $88,$8C,$8A     ; Snow Tops
	.byte $8F,$93,$91     ; Snow Bottoms
	.byte $81,$82         ; Snow Left
	.byte $85,$86         ; Snow Right
	.byte $8D,$89,$8E,$92,$90,$98,$99,$9A,$9B ; Snow Middles
	.byte $94,$96,$95,$97 ; Snow In-corners
	.byte $65,$66,$75,$76 ; Dirt In-corners
	.byte $A2,$A3,$A4     ; Jump Through
	.byte $AA             ; Spikes
	.byte $AA,$AB,$AC,$AD ; Grass Decals
	.byte $B0,$B1,$B2,$B3,$B4 ; House Layer 0
	.byte $B5,$B6,$B7,$B8,$B9,$BA,$BC,$BD ; House Layer 1
	.byte $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CC ; House Layer 2
	.byte $D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF ; House Layer 3
	.byte $E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF ; House Layer 4
	.byte $F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$CD,$CE ; House Layer 5
	.byte $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F ; House Layer 6
	.byte $2F,$2D,$2E,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F ; House Layer 7
	.byte $CB,$BB         ; House Addenda
	.byte $10,$11,$12,$13,$24,$25,$26,$27,$28,$29,$2A,$2B ; Bridge 1
	.byte $3C,$3D,$7E,$7F,$BE,$BF,$CF,$D2,$D0,$D1,$E0,$E1 ; Bridge 2
	.byte $F0,$F1,$A8     ; Bridge 3
	.byte $E2,$F2,$3E,$2C,$A0,$A1 ; Bridge Pole
	.byte $00             ; Blank Tile for Intro Crusher
	.byte $CF,$D2,$E2,$F2 ; Bridge Pole (Gray)
	.byte $60,$67         ; Dirt (Gray)

;metatile_info:
.align $100
	.byte ct_none                ; Air
	.res  28, ct_full            ; Dirt
	.res  27, ct_full            ; Snow
	.res   4, ct_full            ; Dirt
	.res   3, ct_jumpthru        ; Jump Through
	.byte ct_deadlyUP            ; Spikes
	.res   4, ct_none            ; Grass Decals
	.res  96, ct_none            ; House Decal
	;.res  18, ct_full            ; Bridge
	.byte ct_jumpthru, ct_none, ct_jumpthru, ct_none, ct_jumpthru, ct_none, ct_jumpthru, ct_none
	.byte ct_jumpthru, ct_none, ct_jumpthru, ct_none, ct_jumpthru, ct_none, ct_jumpthru, ct_none
	.byte ct_jumpthru, ct_none
	.res   2, ct_none            ; Bridge Pole
	;.res   7, ct_full            ; Bridge
	.byte ct_jumpthru, ct_none, ct_jumpthru, ct_none, ct_jumpthru, ct_none, ct_none
	.res   6, ct_none            ; Bridge Pole
	.res   1, ct_none            ; Blank Tile for Intro Crusher
	.res   4, ct_none            ; Bridge Pole (Gray)
	.res   2, ct_full            ; Dirt (Gray)

.align $100