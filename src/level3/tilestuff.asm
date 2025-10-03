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
