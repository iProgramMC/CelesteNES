; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL1B"
.include "metatile.asm"

music_data_ch1_dmc:
;.incbin "level1.dmc"
.incbin "firststepszeta.dmc"

level1_music:
	.word music_data_ch1 ; song list
	.byte $00            ; default song

.include "roomlist.asm"
.include "warplist.asm"
.include "palette.asm"
.include "dialog.asm"
.include "entity.asm"

fall_ch1_a:
	.byte 32, 24      ; width, height
	.byte 1           ; tile to set
	.byte chrb_splv1c ; sprite bank, or $00 for none
	.byte pal_blue    ; palette
	.byte 200         ; max Y
	.word fall_ch1_a_chr ; CHR data address
	; sprite data (stored column-wise)
	.byte $40,$68 ; col 1
	.byte $42,$6A ; col 2
	.byte $44,$6C ; col 3
	.byte $46,$6E ; col 4


fall_ch1_a_chr:
	; CHR data (stored column-wise)
	.byte $80,$90,$92
	.byte $8B,$84,$94
	.byte $8C,$85,$95
	.byte $81,$83,$93
