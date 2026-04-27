; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: level3_transform_laundry_tile
; desc: Transforms a laundry tile into its disabled version if needed.
; args: X - The tile to transform
; retn: X - The transformed tile
; note: DO NOT clobber Y!
.proc level3_transform_laundry_tile
	cpx #$C4
	bcc @noTransform
	cpx #$F8
	bcs @noTransform
	
	cpx #$D4
	bcc @green
	cpx #$E4
	bcc @purple
	
	; brown
	lda launenable
	and #launboxes
	bne @disable
	beq @noTransform
	
@green:
	lda launenable
	and #launbooks
	bne @disable
	beq @noTransform
	
@purple:
	lda launenable
	and #launclothes
	beq @noTransform
	
@disable:
	ldx #0
@noTransform:
	jmp h_tile_tform_ret
.endproc

.proc level3_check_banks
	lda roomflags2
	and #r2_outside
	bne outsideTileSet
	
	lda #chrb_lvl3
	sta bg0_bknum
	
	lda #g4_altpal
	bit gamectrl4
	beq needChangeToInside
	rts

outsideTileSet:
	lda #chrb_lvl3al
	sta bg0_bknum
	
	lda #g4_altpal
	bit gamectrl4
	bne needChangeToOutside
	rts
needChangeToOutside:
	eor gamectrl4
	sta gamectrl4

	lda #<level3_palette
	sta vmcsrc
	lda #>level3_palette
	sta vmcsrc+1
	bne prepareUpload

needChangeToInside:
	ora gamectrl4
	sta gamectrl4
	lda #<level3_inside_palette
	sta vmcsrc
	lda #>level3_inside_palette
	sta vmcsrc+1

prepareUpload:
	lda #$3F
	sta vmcaddr+1
	lda #$00
	sta vmcaddr
	lda #$10
	sta vmccount
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
	rts
.endproc
