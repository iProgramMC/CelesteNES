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
	.byte $00,$AA,$00,$AA ; Spikes
	.byte $D1,$00,$D1,$00 ; Jump Through

metatile_palette:
	.byte $00 ; Air
	.byte $02 ; Snow
	.byte $01 ; Dirt
	.byte $00 ; Brick
	.byte $00 ; Girder Left
	.byte $00 ; Girder Right
	.byte $00 ; Spikes
	.byte $01 ; Jump Through


metatile_collision:
	.byte ct_none     ; Air
	.byte ct_full     ; Snow
	.byte ct_full     ; Dirt
	.byte ct_full     ; Brick
	.byte ct_full     ; Girder Left
	.byte ct_full     ; Girder Right
	.byte ct_upspike  ; Spikes
	.byte ct_jumpthru ; Jump Through
