; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL2B"
.include "metatile.asm"

music_data_ch2_dmc:
.incbin "music/level2.dmc"

level2_music:
	.word music_data_ch2 ; song list
	.byte $00            ; default song

.define  prgb_lvl2f prgb_dial
.include "roomlist.asm"
.undef   prgb_lvl2f

.include "rooms/1.asm"
.include "warplist.asm"
.include "palette.asm"
.include "structs.asm"
.include "dialog.asm"
.include "entity.asm"
.include "payphone.asm"

level2_mirror_frames_lo: 	.byte <level2_mirror_frame_0, <level2_mirror_frame_1, <level2_mirror_frame_2, <level2_mirror_frame_3, <level2_mirror_frame_4, <level2_mirror_frame_5
level2_mirror_frames_hi:	.byte >level2_mirror_frame_0, >level2_mirror_frame_1, >level2_mirror_frame_2, >level2_mirror_frame_3, >level2_mirror_frame_4, >level2_mirror_frame_5

level2_alt_palette:
	.byte $0f,$30,$1c,$0c
	.byte $0f,$37,$16,$06
	.byte $0f,$30,$21,$11
	.byte $0f,$30,$10,$00
	.byte $0f

lsfx_ntsc_shatter:
	.byte $87,$46,$88,$01,$86,$8f,$8a,$01,$89,$34,$01,$87,$60,$8a,$02,$01
	.byte $87,$79,$8a,$03,$01,$87,$93,$8a,$04,$01,$87,$ac,$8a,$05,$01,$87
	.byte $c6,$8a,$06,$01,$87,$df,$8a,$07,$01,$87,$f9,$8a,$08,$01,$87,$12
	.byte $88,$02,$8a,$09,$01,$87,$2c,$8a,$0a,$01,$87,$45,$8a,$0b,$01,$87
	.byte $5c,$8a,$0c,$01,$87,$60,$88,$03,$8a,$84,$89,$3e,$01,$87,$6a,$8a
	.byte $05,$01,$87,$74,$8a,$85,$01,$87,$7e,$8a,$04,$89,$3d,$01,$87,$88
	.byte $8a,$85,$01,$87,$92,$8a,$05,$01,$87,$9c,$8a,$84,$89,$3c,$01,$87
	.byte $a6,$8a,$05,$01,$87,$b0,$8a,$85,$01,$87,$ba,$8a,$04,$89,$3b,$01
	.byte $87,$c4,$8a,$85,$01,$87,$ce,$8a,$05,$01,$87,$d8,$8a,$84,$89,$3a
	.byte $01,$87,$e2,$8a,$05,$01,$87,$ec,$8a,$85,$01,$87,$f6,$8a,$04,$01
	.byte $87,$00,$88,$04,$8a,$85,$01,$87,$0a,$8a,$05,$89,$33,$01,$87,$14
	.byte $8a,$84,$89,$35,$01,$87,$1e,$8a,$05,$01,$87,$28,$8a,$85,$01,$87
	.byte $32,$8a,$04,$01,$87,$3c,$8a,$85,$01,$87,$46,$8a,$05,$01,$87,$50
	.byte $8a,$84,$01,$87,$5a,$8a,$05,$01,$87,$64,$8a,$85,$01,$87,$6e,$8a
	.byte $04,$01,$87,$74,$8a,$85,$01,$8a,$05,$01,$86,$80,$8a,$84,$89,$32
	.byte $01,$8a,$05,$01,$8a,$85,$01,$8a,$04,$01,$8a,$85,$01,$8a,$05,$01
	.byte $8a,$84,$01,$8a,$05,$01,$8a,$85,$01,$8a,$04,$01,$8a,$85,$01,$8a
	.byte $05,$01,$8a,$84,$89,$31,$01,$8a,$05,$01,$8a,$85,$01,$8a,$04,$01
	.byte $8a,$85,$01,$8a,$05,$01,$8a,$84,$01,$8a,$05,$01,$8a,$85,$01,$8a
	.byte $04,$01,$8a,$85,$01,$8a,$05,$01,$8a,$84,$01,$8a,$05,$01,$8a,$85
	.byte $01,$8a,$04,$01,$8a,$85,$01,$8a,$05,$00

level2_sfx_shatter:
	lda #8
	ldx #FAMISTUDIO_SFX_CH0
	jmp famistudio_sfx_play

level2_db_opening_rows_lo:
	.byte <level2_db_opening_row_6
	.byte <level2_db_opening_row_5
	.byte <level2_db_opening_row_4
	.byte <level2_db_opening_row_3
	.byte <level2_db_opening_row_2
	.byte <level2_db_opening_row_1
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
level2_db_opening_rows_hi:
	.byte >level2_db_opening_row_6
	.byte >level2_db_opening_row_5
	.byte >level2_db_opening_row_4
	.byte >level2_db_opening_row_3
	.byte >level2_db_opening_row_2
	.byte >level2_db_opening_row_1
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
level2_db_closing_rows_lo:
	.byte <level2_db_closing_row_1
	.byte <level2_db_closing_row_2
	.byte <level2_db_closing_row_3
	.byte <level2_db_closing_row_4
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
	.byte <level2_db_opening_empty
level2_db_closing_rows_hi:
	.byte >level2_db_closing_row_1
	.byte >level2_db_closing_row_2
	.byte >level2_db_closing_row_3
	.byte >level2_db_closing_row_4
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty
	.byte >level2_db_opening_empty

fall_ch2_a:
	.byte 24, 16      ; width, height
	.byte 1           ; tile to set
	.byte chrb_splvl2 ; sprite bank, or $00 for none
	.byte pal_stone   ; palette
	.byte 176         ; max Y
	.word fall_ch2_a_chr ; CHR data offset
	; sprite data
	.byte $60,$62,$64

fall_ch2_a_chr:
	.byte $36,$50
	.byte $43,$53
	.byte $44,$39
	
fall_ch2_b:
	.byte 40, 56      ; width, height
	.byte 2           ; tile to set
	.byte 0           ; sprite bank, or $00 for none
	.byte pal_tower   ; palette
	.byte 176         ; max Y
	.word fall_ch2_b_chr ; CHR data offset
	; sprite data
	.byte $03,$0B,$0B,$1F
	.byte $05,$0D,$0D,$3D
	.byte $07,$01,$01,$3F
	.byte $05,$1B,$1B,$3D
	.byte $09,$1D,$1D,$2B

fall_ch2_b_chr:
	.byte $A5,$A9,$B9,$A9,$B9,$A9,$B5
	.byte $A2,$AB,$BC,$BD,$BC,$BD,$B1
	.byte $A2,$AD,$00,$00,$00,$BC,$B3
	.byte $A2,$AB,$BD,$BC,$BD,$BC,$B1
	.byte $A6,$BA,$BA,$AA,$BA,$AA,$B6

