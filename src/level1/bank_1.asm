; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL1B"
.include "metatile.asm"

music_data_ch1_dmc:
.incbin "music/level1.dmc"

level1_music:
	.word music_data_ch1 ; song list
	.byte $00            ; default song

.include "roomlist.asm"
.include "warplist.asm"
.include "palette.asm"
.include "dialog.asm"
.include "rooms/1.asm"
.include "entity.asm"

fall_ch1_a:
	.byte 32, 32      ; width, height
	.byte 1           ; tile to set
	.byte chrb_splv1c ; sprite bank, or $00 for none
	.byte pal_blue    ; palette
	.byte 255         ; max Y
	.word 0           ; CHR data address
	; sprite data (stored column-wise)
	.byte $40,$70 ; col 1
	.byte $42,$72 ; col 2
	.byte $44,$74 ; col 3
	.byte $46,$76 ; col 4

fall_ch1_b:
	.byte 16, 32      ; width, height
	.byte 1           ; tile to set
	.byte chrb_splv1c ; sprite bank, or $00 for none
	.byte pal_blue    ; palette
	.byte 255         ; max Y
	.word 0           ; CHR data address
	; sprite data (stored column-wise)
	.byte $40,$60 ; col 1
	.byte $46,$66 ; col 2

fall_ch1_c:
	.byte 16, 56+128  ; width, height (+128 for spiked on top)
	.byte 1           ; tile to set
	.byte chrb_splv1c ; sprite bank, or $00 for none
	.byte pal_blue    ; palette
	.byte 152         ; max Y
	.word fall_ch1_c_chr ; CHR data address
	; sprite data (stored column-wise)
	.byte $40,$50,$50,$68 ; col 1
	.byte $46,$52,$52,$6E ; col 2

fall_ch1_c_chr:
	.byte $C8,$60,$70,$70,$62,$70,$62,$72
	.byte $C8,$61,$63,$63,$71,$63,$71,$73

; Would be in level1_r8z, but falling blocks are buggy in new format levels and I'm lazy
;fall_ch1_d:
;	.byte 24, 16      ; width, height
;	.byte 1           ; tile to set
;	.byte chrb_splv1c ; sprite bank, or $00 for none
;	.byte pal_blue    ; palette
;	.byte 255         ; max Y
;	.word 0           ; CHR data offset
;	; sprite data
;	.byte $48
;	.byte $4A
;	.byte $4E

fall_ch1_d:
	.byte 24, 40      ; width, height
	.byte 1           ; tile to set
	.byte chrb_splv1c ; sprite bank, or $00 for none
	.byte pal_blue    ; palette
	.byte 176         ; max Y
	.word fall_ch1_d_chr ; CHR data offset
	; sprite data
	.byte $40,$50,$68
	.byte $42,$54,$6A
	.byte $46,$52,$6E

fall_ch1_d_chr:
	.byte $60,$70,$70,$62,$72
	.byte $6B,$64,$64,$7B,$75
	.byte $61,$63,$63,$71,$73

fall_ch1_e:
	.byte 16, 24      ; width, height
	.byte 1           ; tile to set
	.byte chrb_splv1c ; sprite bank, or $00 for none
	.byte pal_blue    ; palette
	.byte 200         ; max Y
	.word fall_ch1_e_chr ; CHR data offset
	; sprite data
	.byte $40,$68
	.byte $46,$6E

fall_ch1_e_chr:
	.byte $60,$70,$72
	.byte $61,$63,$73

fall_ch1_f:
	.byte 24, 32+128  ; width, height
	.byte 1           ; tile to set
	.byte chrb_splv1c ; sprite bank, or $00 for none
	.byte pal_blue    ; palette
	.byte 184         ; max Y
	.word fall_ch1_f_chr ; CHR data offset
	; sprite data
	.byte $40,$60
	.byte $42,$62
	.byte $46,$66

fall_ch1_f_chr:
	.byte $C8,$60,$70,$62,$72
	.byte $C8,$6B,$64,$7B,$75
	.byte $C8,$61,$63,$71,$73
