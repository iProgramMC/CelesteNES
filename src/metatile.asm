; Metatiles
;
; For a single metatile ID, the following properties:
; - metatiles: The char tiles that make up the visual representation of the metatile
; - metatile_palette: The palette used for the metatile
; - metatile_collision: The collision mask for the metatile.
;
; Format: Upleft, Downleft, Upright, Downright
; TODO: Allow more than 64 metatiles.  They are bound to repeat because we shift left twice.
;
; new tile ID format:
; [groupID: 2 bits] [connections: 6 bits]
;
; group 0 will treat the lower 6 bits as connectionless metatile IDs
;
; groups 1-2 will use tilesets 1-2. can be changed using a tileset change command in the level
;
; connection bits:
; bit 0 - connect UP
; bit 1 - connect DOWN
; bit 2 - connect LEFT
; bit 3 - connect RIGHT
; bit 4 - corner gap
; bit 5 - corner gap direction
;
; explanation:
; 
;

metatiles:
	.byte $00,$00,$00,$00 ; Air
	.byte $80,$90,$84,$94 ; Snow
	.byte $60,$70,$64,$74 ; Dirt
	.byte $BC,$89,$BD,$8A ; Brick
	.byte $AD,$AC,$AE,$00 ; Girder Left
	.byte $AD,$AE,$AE,$AC ; Girder Right
	.byte $00,$AA,$00,$AA ; Spikes
	.byte $D1,$00,$D1,$00 ; Jump Through
	.byte $00,$80,$00,$84 ; Snow Half
	.byte $90,$00,$94,$00 ; Snow Up Half

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
	.byte ct_lowhalf|ct_deadly   ; Spikes
	.byte ct_upphalf|ct_jumpthru ; Jump Through
	.byte ct_lowhalf             ; Snow Half
	.byte ct_upphalf             ; Snow Up Half
