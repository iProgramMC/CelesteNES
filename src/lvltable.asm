; Copyright (C) 2024 iProgramInCpp

level_table:
	.word level0
	.word level1 ; 1
	.word level2 ; 2
	.word level3 ; 3
	;.word level0 ; 4
	;.word level0 ; 5
	;.word level0 ; 6
	;.word level0 ; 7

level_banks2:
	.byte prgb_lvl0a
	.byte prgb_lvl1b
	.byte prgb_lvl2b
	.byte prgb_lvl3b
	;.byte prgb_lvl0a
	;.byte prgb_lvl0a
	;.byte prgb_lvl0a
	;.byte prgb_lvl0a

level_banks_mus:
	.byte prgb_lvl0a
	.byte prgb_lvl1c
	.byte prgb_lvl2e
	.byte prgb_lvl3a
	;.byte prgb_lvl0a
	;.byte prgb_lvl0a
	;.byte prgb_lvl0a
	;.byte prgb_lvl0a

level_banks_spr:
	.byte chrb_splvl0
	.byte chrb_splvl1
	.byte chrb_splvl2
	.byte chrb_splvl0
	;.byte chrb_splvl0
	;.byte chrb_splvl0
	;.byte chrb_splvl0
	;.byte chrb_splvl0

level_palettes:
	.word level0_palette
	.word level1_palette
	.word level2_palette
	.word level3_palette
	;.word level0_palette
	;.word level0_palette
	;.word level0_palette
	;.word level0_palette

level_berry_counts:
	.byte 0
	.byte 20
	.byte 17 ; 18 -- the "Awake" section doesn't exist yet.
	.byte 25
	;.byte 29
	;.byte 31
	;.byte 0
	;.byte 47
	;.byte 5

level_bg_banks_1:
	.byte chrb_lvl0
	.byte chrb_lvl1
	.byte chrb_lvl2
	.byte chrb_lvl3
	;.byte chrb_lvl0
	;.byte chrb_lvl0
	;.byte chrb_lvl0
	;.byte chrb_lvl0

level_bg_banks_2:
	.byte chrb_lvl0+2
	.byte chrb_lvl1+2
	.byte chrb_lvl2+2
	.byte chrb_lvl3+2
	;.byte chrb_lvl0+2
	;.byte chrb_lvl0+2
	;.byte chrb_lvl0+2
	;.byte chrb_lvl0+2
