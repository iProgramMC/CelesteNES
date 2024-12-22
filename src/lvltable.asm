; Copyright (C) 2024 iProgramInCpp

level_table:
	.word level0
	.word level1 ; 1
	.word level2 ; 2
	.word level0 ; 3
	.word level0 ; 4
	.word level0 ; 5
	.word level0 ; 6
	.word level0 ; 7

level_banks:
	.byte prgb_lvl0a
	.byte prgb_lvl1a
	.byte prgb_lvl2a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a

level_banks2:
	.byte prgb_lvl0b
	.byte prgb_lvl1b
	.byte prgb_lvl2b
	.byte prgb_lvl0b
	.byte prgb_lvl0b
	.byte prgb_lvl0b
	.byte prgb_lvl0b
	.byte prgb_lvl0b

level_banks_mus:
	.byte prgb_lvl0a
	.byte prgb_lvl1c
	.byte prgb_lvl2a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a
	.byte prgb_lvl0a

level_banks_spr:
	.byte chrb_splvl0
	.byte chrb_splvl1
	.byte chrb_splvl0
	.byte chrb_splvl0
	.byte chrb_splvl0
	.byte chrb_splvl0
	.byte chrb_splvl0
	.byte chrb_splvl0
