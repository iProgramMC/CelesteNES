; Copyright (C) 2025 iProgramInCpp

init_palette:
	.byte $0f,$20,$10,$00 ; grey tiles
	.byte $0f,$37,$16,$06 ; brown tiles
	.byte $0f,$20,$21,$11 ; blue tiles
	.byte $0f,$39,$29,$19 ; green tiles
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$00,$00,$00 ; red/strawberry sprite
	.byte $0f,$00,$00,$00 ; blue sprite
	.byte $0f,$00,$00,$00 ; green/refill sprite
owld_palette:
	.byte $0f,$0c,$01,$00
	.byte $0f,$0c,$10,$30
	.byte $0f,$0c,$00,$10
	.byte $0f,$30,$10,$00
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$36,$16,$06 ; red/strawberry sprite
	.byte $0f,$31,$21,$01 ; blue sprite
	.byte $0f,$30,$29,$09 ; green/refill sprite
title_palette:
	.byte $0f,$30,$10,$2d
	.byte $0f,$30,$11,$2d
	.byte $0f,$30,$32,$2d
	.byte $0f,$30,$11,$32
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$36,$16,$06 ; red/strawberry sprite
	.byte $0f,$20,$21,$11 ; blue sprite
	.byte $0f,$30,$29,$09 ; green/refill sprite
