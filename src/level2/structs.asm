; Copyright (C) 2025 iProgramInCpp

; Pre-built structures created using one tile type. Not actually
; any kind of "struct" object type like you might think.

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
;       This is used by h_gener_row_u.
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

; ** SUBROUTINE: level2_struct_detour2
; desc: Jumps to the middle of level2_struct_detour after calculating the X coordinate.
;       This is used by h_gener_row_u_nice.
;
; parameters:
;     X register - The tile used
;     Y register - The Y position
;
; returns: A register - the CHR tile to use.
.proc level2_struct_detour3
	lda temp1
	and #$3F
	jmp level2_struct_detour::gotX
.endproc
