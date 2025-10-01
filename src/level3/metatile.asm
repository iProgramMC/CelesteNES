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
	.byte $36,$40,$37,$44,$38,$50,$39,$54  ; Stone Corners
	.byte $41,$42,$43     ; Stone Tops
	.byte $51,$52,$53     ; Stone Bottoms
	.byte $47,$48,$49,$4A ; Stone Left
	.byte $57,$58,$59,$5A ; Stone Right
	.byte $45,$46,$55,$56 ; Stone In-corners
	.byte $10,$11,$12     ; Stone Pillar
	.byte $20,$21,$22     ; Stone Pillar Top
	.byte $30,$31,$32     ; Stone Pillar Bottom
	.byte $13,$14,$15     ; Stone Bar Left
	.byte $23,$24,$25     ; Stone Bar Right
	.byte $33,$34,$35     ; Stone Bar
	.byte $4B,$4C,$4D,$4E,$5B,$5C,$5D,$5E ; Stone Middles
	.byte $07,$08,$17,$18 ; Stone Piller
	.byte $27,$28,$29,$2A ; Stone Piller (Dark)
	.byte $06,$16         ; Stone Pillar (1 tile version)
	.byte $01,$02         ; Sky
	.byte $A0,$A1,$A2,$A3 ; Roof Center
	.byte $A4,$A5,$A6,$A7 ; Roof Edge R
	.byte $B4,$B5,$B6,$B7 ; Roof Edge L
	.byte $69,$6A,$79     ; Jump Through
	.byte $C8,$C9,$CA,$CB ; Spikes
	.byte $C8,$C9,$CA,$CB ; Spikes (Alt)
	.byte $04,$05,$26,$3A,$3D,$3E,$3F,$4F,$5F,$2B,$3B ; Backgrounds
	.byte $B0,$B1,$B2,$C0,$C1,$B3,$C3,$D3,$C2,$D0,$D1,$D2 ; Dust Bunnies
	.byte $C4,$C5,$C6,$C7,$D4,$D5,$D6,$D7                 ; Dust Bunnies
	.byte $E0,$E1,$E2,$E3,$E4,$E5,$F0,$F1,$F2,$F3,$F4,$F5 ; Dust Bunnies
	.byte $2C,$3C,$0C,$1C ; Dust Bunnies
	.byte $80,$83,$90,$93 ; Wood Corners
	.byte $81,$82,$84     ; Wood Top + Bar End
	.byte $91,$92,$94     ; Wood Bottom + Bar End
	.byte $87,$97,$88,$98 ; Wood Left and Right
	.byte $89,$8A,$8B,$8C ; Wood Inside
	.byte $99,$9A,$9B,$9C ; Wood Bars
	.byte $85,$86,$95,$96 ; Wood In-corners
	.byte $8D,$9D         ; Wood Bar Ends
	.byte $8E,$8F,$9E,$9F ; Books
	.byte $AE,$AF,$BE,$BF ; Books
	.byte $AC,$AD,$BC,$BD ; Books
	.byte $AA,$AB,$BA,$BB ; Books
	.byte $A8,$A9,$B8,$B9 ; Clothes
	.byte $E6,$E7,$F6,$F7 ; Clothes
	.byte $E8,$E9,$F8,$F9 ; Clothes
	.byte $EA,$EB,$FA,$FB ; Clothes
	.byte $09,$0A,$19,$1A ; Box
	.byte $0B,$1B         ; Box Alt Half
	.byte $0D,$0E,$0F,$1D,$1E,$1F,$2D,$2E,$2F ; Big Box
	.byte $DA,$DB,$DC,$DD,$DE ; Boxes
	.byte $00             ; Ceiling Blocker

;metatile_info:
.align $100
	.byte ct_none                ; Air
	.res  33, ct_full            ; Snow
	.res  52, ct_full            ; Stone
	.res  10, ct_none            ; Stone Pillar
	.res   2, ct_none            ; Sky
	.res   4, ct_full            ; Roof
	.res   2, ct_none            ; Roof
	.res   2, ct_full            ; Roof
	.res   2, ct_none            ; Roof
	.res   2, ct_full            ; Roof
	.res   3, ct_jumpthru        ; Jump Through
	.byte ct_deadlyUP            ; Spikes
	.byte ct_deadlyRT            ; Spikes
	.byte ct_deadlyDN            ; Spikes
	.byte ct_deadlyLT            ; Spikes
	.byte ct_deadlyUP            ; Spikes
	.byte ct_deadlyRT            ; Spikes
	.byte ct_deadlyDN            ; Spikes
	.byte ct_deadlyLT            ; Spikes
	.res  11, ct_none            ; Backgrounds
	.res  36, ct_deadlyXX        ; Dust Bunnies
	.res  28, ct_full            ; Wood
	.res  16, ct_full            ; Clutter A
	.res  16, ct_full            ; Clutter B
	.res  20, ct_full            ; Clutter C
	.byte ct_fallthru            ; Ceiling Blocker

.align $100