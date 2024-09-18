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
	.byte $00,$00,$00,$00 ; 00- Air
	.byte $61,$6B,$62,$6C ; 01- Dirt Top
	.byte $81,$8B,$82,$8C ; 02- Snow Top
	.byte $80,$87,$83,$8D ; 03- Snow Up Left Piece
	.byte $82,$9B,$84,$88 ; 04- Snow Up Right Piece
	.byte $87,$90,$8D,$91 ; 05- Snow Down Left Piece
	.byte $8B,$92,$98,$94 ; 06- Snow Down Right Piece
	.byte $96,$8F,$9E,$00 ; 07- Snow Inner Up+Left Piece
	.byte $8E,$00,$95,$9B ; 08- Snow Inner Up+Right Piece
	.byte $8C,$9C,$88,$98 ; 09- Snow Right Wall
	.byte $87,$97,$8B,$9B ; 0A- Snow Left Wall
	.byte $9D,$86,$00,$8D ; 0B- Snow Inner Down+Left Piece
	.byte $00,$8C,$9C,$85 ; 0C- Snow Inner Down+Right Piece
	.byte $61,$6B,$62,$6C ; 0D- Dirt Top
	.byte $60,$67,$63,$6D ; 0E- Dirt Up Left Piece
	.byte $62,$7B,$64,$68 ; 0F- Dirt Up Right Piece
	.byte $67,$70,$6D,$71 ; 10- Dirt Down Left Piece
	.byte $6B,$72,$78,$74 ; 11- Dirt Down Right Piece
	.byte $76,$6F,$7E,$00 ; 12- Dirt Inner Up+Left Piece
	.byte $6E,$00,$75,$7B ; 13- Dirt Inner Up+Right Piece
	.byte $6C,$7C,$68,$78 ; 14- Dirt Right Wall
	.byte $67,$77,$6B,$7B ; 15- Dirt Left Wall
	.byte $7D,$66,$00,$6D ; 16- Dirt Inner Down+Left Piece
	.byte $00,$6C,$7C,$65 ; 17- Dirt Inner Down+Right Piece
	.byte $00,$61,$00,$62 ; 18- Dirt Lower Half
	.byte $00,$60,$00,$63 ; 19- Dirt Lower Half Left Corner
	.byte $00,$63,$00,$64 ; 1A- Dirt Lower Half Right Corner
	.byte $00,$81,$00,$82 ; 1B- Snow Lower Half
	.byte $00,$80,$00,$83 ; 1C- Snow Lower Half Left Corner
	.byte $00,$83,$00,$84 ; 1D- Snow Lower Half Right Corner

metatile_palette:
	.byte $00 ; 00- Air
	.byte $01 ; 01- Dirt Top
	.byte $02 ; 02- Snow
	.byte $02 ; 03- Snow up left piece
	.byte $02 ; 04- Snow up right piece
	.byte $02 ; 05- Snow down left piece
	.byte $02 ; 06- Snow down right piece
	.byte $02 ; 07- Snow Inner Up+Left Piece
	.byte $02 ; 08- Snow Inner Up+Right Piece
	.byte $02 ; 09- Snow Right Wall
	.byte $02 ; 0A- Snow Left Wall
	.byte $02 ; 0B- Snow Inner Down+Left Piece
	.byte $02 ; 0C- Snow Inner Down+Right Piece
	.byte $01 ; 0D- Dirt Top
	.byte $01 ; 0E- Dirt Up Left Piece
	.byte $01 ; 0F- Dirt Up Right Piece
	.byte $01 ; 10- Dirt Down Left Piece
	.byte $01 ; 11- Dirt Down Right Piece
	.byte $01 ; 12- Dirt Inner Up+Left Piece
	.byte $01 ; 13- Dirt Inner Up+Right Piece
	.byte $01 ; 14- Dirt Right Wall
	.byte $01 ; 15- Dirt Left Wall
	.byte $01 ; 16- Dirt Inner Down+Left Piece
	.byte $01 ; 17- Dirt Inner Down+Right Piece
	.byte $01 ; 18- Dirt Lower Half
	.byte $01 ; 19- Dirt Lower Half Left Corner
	.byte $01 ; 1A- Dirt Lower Half Right Corner
	.byte $02 ; 1B- Snow Lower Half
	.byte $02 ; 1C- Snow Lower Half Left Corner
	.byte $02 ; 1D- Snow Lower Half Right Corner


metatile_collision:
	.byte ct_none     ; 00- Air
	.byte ct_full     ; 01- Dirt Top
	.byte ct_full     ; 02- Snow Top
	.byte ct_full     ; 03- Snow up left piece
	.byte ct_full     ; 04- Snow up right piece
	.byte ct_full     ; 05- Snow down left piece
	.byte ct_full     ; 06- Snow down right piece
	.byte ct_full     ; 07- Snow Inner Up+Left Piece
	.byte ct_full     ; 08- Snow Inner Up+Right Piece
	.byte ct_full     ; 09- Snow Right Wall
	.byte ct_full     ; 0A- Snow Left Wall
	.byte ct_full     ; 0B- Snow Inner Down+Left Piece
	.byte ct_full     ; 0C- Snow Inner Down+Right Piece
	.byte ct_full     ; 0D- Dirt Top
	.byte ct_full     ; 0E- Dirt Up Left Piece
	.byte ct_full     ; 0F- Dirt Up Right Piece
	.byte ct_full     ; 10- Dirt Down Left Piece
	.byte ct_full     ; 11- Dirt Down Right Piece
	.byte ct_full     ; 12- Dirt Inner Up+Left Piece
	.byte ct_full     ; 13- Dirt Inner Up+Right Piece
	.byte ct_full     ; 14- Dirt Right Wall
	.byte ct_full     ; 15- Dirt Left Wall
	.byte ct_full     ; 16- Dirt Inner Down+Left Piece
	.byte ct_full     ; 17- Dirt Inner Down+Right Piece
	.byte ct_lowhalf  ; 18- Dirt Lower Half
	.byte ct_lowhalf  ; 19- Dirt Lower Half Left Corner
	.byte ct_lowhalf  ; 1A- Dirt Lower Half Right Corner
	.byte ct_lowhalf  ; 1B- Snow Lower Half
	.byte ct_lowhalf  ; 1C- Snow Lower Half Left Corner
	.byte ct_lowhalf  ; 1D- Snow Lower Half Right Corner
