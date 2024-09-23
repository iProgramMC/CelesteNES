; Metatiles
;
; For a single metatile ID, the following properties:
; - metatiles: The char tiles that make up the visual representation of the metatile
; - metatile_palette: The palette used for the metatile
; - metatile_collision: The collision mask for the metatile.

metatiles:
	.byte $00 ; Air
	.byte $60,$64,$70,$74 ; Dirt Corners
	.byte $61,$62,$63     ; Dirt Tops
	.byte $71,$72,$73     ; Dirt Bottoms
	.byte $67,$77,$68,$67 ; Dirt Left
	.byte $69,$79,$6A,$7A ; Dirt Right
	.byte $6B,$6C,$6D,$6E,$7B,$7C,$7D,$AF ; Dirt Middles
	.byte $6F,$78         ; Dirt Left, Right Ends
	.byte $80,$84,$90,$94 ; Snow Corners
	.byte $81,$82,$83     ; Snow Tops
	.byte $91,$92,$93     ; Snow Bottoms
	.byte $87,$97         ; Snow Left
	.byte $88,$98         ; Snow Right
	.byte $8B,$8C,$8D,$8E,$8F,$9B,$9C,$9D,$9E ; Snow Middles
	.byte $85,$86,$95,$96 ; Snow In-corners
	.byte $65,$66,$75,$76 ; Dirt In-corners
	.byte $D1,$D0,$D2     ; Jump Through
	.byte $AA             ; Spikes
	.byte $7E,$7F,$BE,$BF ; Grass Decals

metatile_info:
	.byte ct_none                ; Air
	.res  28, ct_full            ; Dirt
	.res  27, ct_full            ; Snow
	.res   4, ct_full            ; Dirt
	.res   3, ct_jumpthru        ; Jump Through
	.byte ct_deadly              ; Spikes
	.res   4, ct_none            ; Grass Decals
