; Copyright (C) 2025 iProgramInCpp

; Pre-built structures created using one tile type. Not actually
; any kind of "struct" object type like you might think.

; Structures are stored column-wise
level2_s_memorial:
	.byte $00,$70,$64,$74,$68,$09,$19,$78
	.byte $7E,$71,$65,$75,$69,$0A,$1A,$79
	.byte $7F,$72,$66,$76,$69,$0B,$1B,$79
	.byte $00,$73,$67,$77,$6A,$0C,$1C,$7A

level2_s_info_kiosk:


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
	
	cpx #$EF  ; check if it's the memorial
	beq @memorial
	
	; info kiosk TODO
	lda #$6F
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
	and #$7
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
