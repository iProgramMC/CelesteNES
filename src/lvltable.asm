; Copyright (C) 2024 iProgramInCpp

level_table:
	.word level0
	.word level1 ; 1
	.word level0 ; 2
	.word level0 ; 3
	.word level0 ; 4
	.word level0 ; 5
	.word level0 ; 6
	.word level0 ; 7
level_table_end:

level_banks:
	.byte $00
	.byte $01
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
level_banks_end:

level_table_size = level_table_end - level_table
