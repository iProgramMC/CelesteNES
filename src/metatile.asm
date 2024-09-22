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
	.byte $00 ; Air
	.byte $80 ; Snow
	.byte $60 ; Dirt
	.byte $BC ; Brick
	.byte $AD ; Girder Left
	.byte $AE ; Girder Right
	.byte $AA ; Spikes
	.byte $D1 ; Jump Through
	.byte $84 ; Snow Half
	.byte $94 ; Snow Up Half

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
