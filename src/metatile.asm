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
	.byte $61,$6B,$62,$6C ; 01- Dirt
	.byte $81,$8B,$82,$8C ; 02- Snow
	.byte $80,$87,$83,$8D ; 03- Snow
	.byte $82,$9B,$84,$88 ; 04- Snow
	.byte $87,$90,$8D,$91 ; 05- Snow
	.byte $8B,$92,$98,$94 ; 06- Snow
	.byte $96,$8F,$9E,$00 ; 07- Snow
	.byte $8E,$00,$95,$9B ; 08- Snow
	.byte $8C,$9C,$88,$98 ; 09- Snow
	.byte $87,$97,$8B,$9B ; 0A- Snow
	.byte $9D,$86,$00,$8D ; 0B- Snow
	.byte $00,$8C,$9C,$85 ; 0C- Snow
	.byte $61,$6B,$62,$6C ; 0D- Dirt
	.byte $60,$67,$63,$6D ; 0E- Dirt
	.byte $62,$7B,$64,$69 ; 0F- Dirt
	.byte $67,$70,$6D,$71 ; 10- Dirt
	.byte $6B,$72,$69,$74 ; 11- Dirt
	.byte $76,$6F,$7E,$00 ; 12- Dirt
	.byte $6E,$00,$75,$7B ; 13- Dirt
	.byte $6C,$7C,$79,$69 ; 14- Dirt
	.byte $67,$77,$6B,$7B ; 15- Dirt
	.byte $7D,$66,$00,$6D ; 16- Dirt
	.byte $00,$6C,$7C,$65 ; 17- Dirt
	.byte $00,$61,$00,$62 ; 18- Dirt
	.byte $00,$60,$00,$63 ; 19- Dirt
	.byte $00,$63,$00,$64 ; 1A- Dirt
	.byte $00,$81,$00,$82 ; 1B- Snow
	.byte $00,$80,$00,$83 ; 1C- Snow
	.byte $00,$83,$00,$84 ; 1D- Snow
	.byte $77,$67,$6A,$79 ; 1E- Dirt
	.byte $60,$67,$64,$79 ; 1F- Dirt
	.byte $00,$60,$00,$64 ; 20- Dirt
	.byte $D0,$00,$D1,$00 ; 21- Jumpthru L
	.byte $D1,$00,$D2,$00 ; 22- Jumpthru R
	.byte $D1,$00,$D1,$00 ; 23- Jumpthru M
	.byte $60,$70,$61,$71 ; 24- Dirt
	.byte $62,$72,$64,$74 ; 25- Dirt
	.byte $64,$74,$00,$00 ; 26- Dirt
	.byte $00,$00,$60,$70 ; 27- Dirt
	.byte $69,$79,$00,$00 ; 28-Dirt
	.byte $00,$00,$67,$77 ; 29- Dirt

metatile_palette:
	.byte $00 ; 00- Air
	.byte $01 ; 01- Dirt
	.byte $02 ; 02- Snow
	.byte $02 ; 03- Snow
	.byte $02 ; 04- Snow
	.byte $02 ; 05- Snow
	.byte $02 ; 06- Snow
	.byte $02 ; 07- Snow
	.byte $02 ; 08- Snow
	.byte $02 ; 09- Snow
	.byte $02 ; 0A- Snow
	.byte $02 ; 0B- Snow
	.byte $02 ; 0C- Snow
	.byte $01 ; 0D- Dirt
	.byte $01 ; 0E- Dirt
	.byte $01 ; 0F- Dirt
	.byte $01 ; 10- Dirt
	.byte $01 ; 11- Dirt
	.byte $01 ; 12- Dirt
	.byte $01 ; 13- Dirt
	.byte $01 ; 14- Dirt
	.byte $01 ; 15- Dirt
	.byte $01 ; 16- Dirt
	.byte $01 ; 17- Dirt
	.byte $01 ; 18- Dirt
	.byte $01 ; 19- Dirt
	.byte $01 ; 1A- Dirt
	.byte $02 ; 1B- Snow
	.byte $02 ; 1C- Snow
	.byte $02 ; 1D- Snow
	.byte $01 ; 1E- Dirt
	.byte $01 ; 1F- Dirt
	.byte $01 ; 20- Dirt
	.byte $01 ; 21- Jumpthru
	.byte $01 ; 22- Jumpthru
	.byte $01 ; 23- Jumpthru
	.byte $01 ; 24- Dirt
	.byte $01 ; 25- Dirt
	.byte $01 ; 26- Dirt
	.byte $01 ; 27- Dirt
	.byte $01 ; 28- Dirt
	.byte $01 ; 29- Dirt


metatile_collision:
	.byte ct_none     ; 00- Air
	.byte ct_full     ; 01- Dirt
	.byte ct_full     ; 02- Snow
	.byte ct_full     ; 03- Snow
	.byte ct_full     ; 04- Snow
	.byte ct_full     ; 05- Snow
	.byte ct_full     ; 06- Snow
	.byte ct_full     ; 07- Snow
	.byte ct_full     ; 08- Snow
	.byte ct_full     ; 09- Snow
	.byte ct_full     ; 0A- Snow
	.byte ct_full     ; 0B- Snow
	.byte ct_full     ; 0C- Snow
	.byte ct_full     ; 0D- Dirt
	.byte ct_full     ; 0E- Dirt
	.byte ct_full     ; 0F- Dirt
	.byte ct_full     ; 10- Dirt
	.byte ct_full     ; 11- Dirt
	.byte ct_full     ; 12- Dirt
	.byte ct_full     ; 13- Dirt
	.byte ct_full     ; 14- Dirt
	.byte ct_full     ; 15- Dirt
	.byte ct_full     ; 16- Dirt
	.byte ct_full     ; 17- Dirt
	.byte ct_lowhalf  ; 18- Dirt
	.byte ct_lowhalf  ; 19- Dirt
	.byte ct_lowhalf  ; 1A- Dirt
	.byte ct_lowhalf  ; 1B- Snow
	.byte ct_lowhalf  ; 1C- Snow
	.byte ct_lowhalf  ; 1D- Snow
	.byte ct_full     ; 1E- Dirt
	.byte ct_full     ; 1F- Dirt
	.byte ct_lowhalf  ; 20- Dirt
	.byte ct_jumpthru ; 21- Jumpthru
	.byte ct_jumpthru ; 22- Jumpthru
	.byte ct_jumpthru ; 23- Jumpthru
	.byte ct_full     ; 24- Dirt
	.byte ct_full     ; 25- Dirt
	.byte ct_full     ; 26- Dirt; should be lefthalf
	.byte ct_full     ; 27- Dirt; should be righthalf
	.byte ct_full     ; 28- Dirt; should be lefthalf
	.byte ct_full     ; 29- Dirt; should be righthalf
