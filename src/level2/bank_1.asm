; Copyright (C) 2024 iProgramInCpp

.segment "PRG_LVL2B"
.include "metatile.asm"

music_data_ch2_dmc:
.incbin "music/level2.dmc"

level2_music:
	.word music_data_ch2 ; song list
	.byte $00            ; default song

.include "rooms/1.asm"
.include "roomlist.asm"
.include "warplist.asm"
.include "palette.asm"
.include "structs.asm"
.include "dialog.asm"
.include "entity.asm"

level2_alt_palette:
	.byte $0f,$30,$1c,$0c
	.byte $0f,$37,$16,$06
	.byte $0f,$30,$21,$11
	.byte $0f,$30,$10,$00
	.byte $0f

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
	; below doesn't work because of bank conflicts
	;.byte $66,$6E,$6E,$76
	;.byte $68,$70,$70,$78
	;.byte $6A,$7E,$7E,$7A
	;.byte $68,$72,$72,$78
	;.byte $6C,$74,$74,$7C
	
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
