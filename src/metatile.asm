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
	.byte $00;,$00,$00 ; Air
	.byte $90;,$84,$94 ; Snow
	.byte $70;,$64,$74 ; Dirt
	.byte $89;,$BD,$8A ; Brick
	.byte $AC;,$AE,$00 ; Girder Left
	.byte $AE;,$AE,$AC ; Girder Right
	.byte $AA;,$00,$AA ; Spikes
	.byte $D0;,$D1,$00 ; Jump Through
	.byte $80;,$00,$84 ; Snow Half
	.byte $80;,$94,$00 ; Snow Up Half

metatile_palette:
	.byte $00 ; Air
	.byte $02 ; Snow
	.byte $01 ; Dirt
	.byte $00 ; Brick
	.byte $00 ; Girder Left
	.byte $00 ; Girder Right
	.byte $00 ; Spikes
	.byte $01 ; Jump Through
	.byte $02 ; Snow Half
	.byte $02 ; Snow Up Half


metatile_info:
	.byte ct_none                ; Air
	.byte ct_full                ; Snow
	.byte ct_full                ; Dirt
	.byte ct_full                ; Brick
	.byte ct_full                ; Girder Left
	.byte ct_full                ; Girder Right
	.byte ct_lowhalf|ct_deadly  |ct_horzonly|ct_4wayonly ; Spikes
	.byte ct_upphalf|ct_jumpthru|ct_horzonly             ; Jump Through
	.byte ct_lowhalf             ; Snow Half
	.byte ct_upphalf             ; Snow Up Half

conn_offset:
	; bits used as index into this table:
	; cf_xNyZ = $01 ---> (-1, 0)
	; cf_xPyZ = $02 ---> (+1, 0)
	; cf_xZyN = $04 ---> (0, -1)
	; cf_xZyP = $08 ---> (0, +1)
	; cf_xNyN = $10 ---> (-1,-1)
	; cf_xNyP = $20 ---> (-1,+1)
	; cf_xPyN = $40 ---> (+1,-1)
	; cf_xPyP = $80 ---> (+1,+1)
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00
