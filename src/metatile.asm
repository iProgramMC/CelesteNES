; Metatiles
;
; For a single metatile ID, the following properties:
; - metatiles: The char tiles that make up the visual representation of the metatile
; - metatile_palette: The palette used for the metatile
; - metatile_collision: The collision mask for the metatile.
;
; Format: Upleft, Downleft, Upright, Downright
; TODO: Allow more than 64 metatiles.  They are bound to repeat because we shift left twice.
metatiles:
	.byte $00,$00,$00,$00 ; Air
	.byte $80,$90,$84,$94 ; Snow
	.byte $60,$70,$64,$74 ; Dirt
	.byte $BC,$89,$BD,$8A ; Brick
	.byte $AD,$AC,$AE,$00 ; Girder Left
	.byte $AD,$AE,$AE,$AC ; Girder Right
	.byte $60,$70,$64,$74 ; Dirt
	.byte $BC,$89,$BD,$8A ; Brick

metatile_palette:
	.byte $00 ; Air
	.byte $02 ; Snow
	.byte $01 ; Dirt
	.byte $00 ; Brick
	.byte $00 ; Girder Left
	.byte $00 ; Girder Right
	.byte $01 ; Dirt
	.byte $00 ; Brick

; Format:
; bit 0: up-left
; bit 1: up-right
; bit 2: down-left
; bit 3: down-right
metatile_collision:
	.byte $0  ; Air
	.byte $F  ; Snow
	.byte $F  ; Dirt
	.byte $F  ; Brick
	.byte $F  ; Girder Left
	.byte $F  ; Girder Right
	.byte $F  ; Dirt
	.byte $F  ; Brick
