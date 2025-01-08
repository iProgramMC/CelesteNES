; Copyright (C) 2025 iProgramInCpp

; Pre-built structures created using one tile type. Not actually
; any kind of "struct" object type like you might think.

; Structures are stored column-wise
level2_s_memorial:
	.byte $00,$70,$64,$74,$68,$09,$19,$78
	.byte $7E,$71,$65,$75,$69,$0A,$1A,$79
	.byte $7F,$72,$66,$76,$69,$0B,$1B,$79
	.byte $00,$73,$67,$77,$6A,$0C,$1C,$7A

level2_s_info_kiosk_offsets:
	.byte 0, 9, 18, 27, 36, 45, 54, 63, 72, 81

level2_s_info_kiosk:
	.byte $00,$00,$00,$14,$39,$50,$49,$49,$3A
	.byte $00,$00,$00,$15,$40,$51,$4A,$5A,$3B
	.byte $10,$20,$30,$16,$41,$52,$00,$5B,$3C
	.byte $11,$21,$31,$17,$42,$52,$00,$5B,$3D
	.byte $12,$22,$32,$18,$43,$53,$00,$5B,$3E
	.byte $13,$23,$33,$26,$44,$54,$4B,$5C,$3C
	.byte $00,$00,$34,$27,$45,$55,$4C,$5D,$3F
	.byte $00,$00,$35,$28,$46,$56,$4D,$5E,$2A
	.byte $00,$24,$36,$38,$47,$57,$4E,$29,$2B ;done
	.byte $00,$25,$00,$00,$48,$58,$59,$59,$4F

level2_s_mirror_offsets:
	.byte 0, 5, 10, 15, 20, 25, 30, 35

level2_s_mirror:
	.byte $00,$60,$70,$68,$78
	.byte $3A,$61,$71,$69,$79
	.byte $3B,$62,$72,$6A,$7A
	.byte $3C,$63,$73,$6B,$7B
	.byte $3D,$64,$74,$6C,$7C
	.byte $3E,$65,$75,$6D,$7D
	.byte $3F,$66,$76,$6E,$7E
	.byte $00,$67,$77,$6F,$7F

level2_alt_palette:
	.byte $0f,$30,$1c,$0c
	.byte $0f,$37,$16,$06
	.byte $0f,$30,$21,$11
	.byte $0f,$30,$10,$00

; ** SUBROUTINE: level2_struct_detour
; desc: Called by h_gener_col_r to generate a tile for a structure, based on the
;       chosen X/Y coordinate.  Done this way because we do not support more than
;       256 metatiles.
;
; parameters:
;     X register - The tile used
;     (ntwrhead - roombeglo2) & 0x3F   - The X position
;     Y register                       - The Y position
;
; returns: A register - The CHR tile to use
;
; note: MUST NOT CLOBBER THE Y REGISTER
.proc level2_struct_detour
	lda ntwrhead

gotX:
	sec
	sbc roombeglo2
	and #$3F
	
	cpx #$EF  ; check if it's the memorial
	beq @memorial
	cpx #$F1  ; check if it's the mirror
	beq @mirror
	
	; info kiosk starts at tile 20,13
	sec
	sbc #20
	tax
	tya
	sec
	sbc #13
	clc
	adc level2_s_info_kiosk_offsets, x
	tax
	lda level2_s_info_kiosk, x
	rts

@mirror:
	; mirror starts at tile 16,15
	sec
	sbc #16
	tax
	tya
	sec
	sbc #15
	clc
	adc level2_s_mirror_offsets, x
	tax
	lda level2_s_mirror, x
	rts

@memorial:
	; the memorial starts at tile 18,11
	sec
	sbc #18
	and #3
	asl
	asl
	asl
	sta temp11
	
	tya
	sec
	sbc #11
	and #7
	ora temp11
	tax
	lda level2_s_memorial, x
	rts
.endproc

; ** SUBROUTINE: level2_struct_detour2
; desc: Jumps to the middle of level2_struct_detour after calculating the X coordinate.
;
; parameters:
;     X register - The tile used
;     Y register - The Y position
;
; returns: A register - the CHR tile to use.
.proc level2_struct_detour2
	lda ntwrhead
	clc
	adc temp1
	and #$3F
	jmp level2_struct_detour::gotX
.endproc
