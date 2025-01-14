; Copyright (C) 2024 iProgramInCpp
; This code belongs in the PRG_DIAL segment.

.align $100
; ** SUBROUTINE: dlg_nmi_clear_256
; desc: Clears (almost) 256 bytes in an 8X30 column fashion.
dlg_nmi_clear_256:
	lda ctl_flags
	ora #pctl_adv32
	sta ppu_ctrl
	
	ldy dlg_colnum
	ldx #$FF
@beginning:
	lda clearpahi
	sta ppu_addr
	lda clearpalo
	sta ppu_addr
	cpy #1
	beq @writeLeftEdge
	bcc @writeNoEdge
	cpy #30
	beq @writeRightEdge
	bcs @writeNoEdge
	
	; 30 writes.
	lda #0
	sta ppu_data
	stx ppu_data
	beq @write28x
	
@wr28xReturn:
	lda clearpalo
	clc
	adc #1
	
	; check if it's zero
	and #%00011111
	sta clearpalo
	bne :+
	
	lda #0
	sta clearpalo
	
	; it is, so change nametable
	lda clearpahi
	eor #$4
	sta clearpahi
	
:	iny
	tya
	and #7
	bne @beginning
	
	sty dlg_colnum
	lda ctl_flags
	sta ppu_ctrl
	
	rts

@writeNoEdge:
	lda #0
	sta ppu_data
	sta ppu_data
	beq @write28x

@writeLeftEdge:
	ldx #%11111000
	lda #%00001000
	bne @write30x
	sta ppu_data
	sta ppu_data

@writeRightEdge:
	ldx #%00011111
	lda #%00010000

@write30x:
	sta ppu_data
	stx ppu_data

@write28x:
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	sta ppu_data
	ldx #$FF
	jmp @wr28xReturn

; ** SUBROUTINE: dlg_nmi_check_upds
; desc: Checks for updates for the dialog columns.
dlg_nmi_check_upds:
	lda ctl_flags
	ora #pctl_adv32
	sta ppu_ctrl
	
	; temp5 is going to be the same because we increment by 256
	lda #<dlg_bitmap
	sta temp5
	
	lda #1
	bit dlg_updates
	beq :+
	
	; clear the bit that got us here
	eor dlg_updates
	sta dlg_updates
	lda #>dlg_bitmap
	sta temp6
	lda #0
	sta temp7
	lda #<dlg_upds1
	sta temp8
	lda #>dlg_upds1
	sta temp9
	
	jmp @updateRow
	
:	lda #2
	bit dlg_updates
	beq :+
	
	; clear the bit that got us here
	eor dlg_updates
	sta dlg_updates
	lda #>(dlg_bitmap+$100)
	sta temp6
	lda #1
	sta temp7
	lda #<dlg_upds2
	sta temp8
	lda #>dlg_upds2
	sta temp9
	
	jmp @updateRow
	
:	lda #4
	bit dlg_updates
	beq :+
	
	; clear the bit that got us here
	eor dlg_updates
	sta dlg_updates
	lda #>(dlg_bitmap+$200)
	sta temp6
	lda #2
	sta temp7
	lda #<dlg_upds3
	sta temp8
	lda #>dlg_upds3
	sta temp9
	
	jmp @updateRow
	
:	lda ctl_flags
	sta ppu_ctrl
	rts

; ** SUBROUTINE: dlg_nmi_check_upds::@updateRow
; desc: Updates a single row of text.
; arguments:
;     temp1 - Low byte of starting ppuaddr
;     temp2 - High byte of starting ppuaddr
;     temp5 - Low byte of row bitmap start addr
;     temp6 - High byte of row bitmap start addr
;     temp7 - Row number
;     temp8 - Low byte of updates array
;     temp9 - High byte of updates array
; reserves also:
;     temp3
;     temp4
;     temp10
@updateRow:
	ldx temp7
	lda dlg_updc1, x
	sta dlg_updccurr
	; acknowledge these updates
	lda #0
	sta dlg_updc1, x
	
	; add $A0
	lda temp2
	ora #$A0
	sta temp2
	
	lda temp7
	clc
	adc temp1
	sta temp1
	
	lda temp7
	asl
	asl
	asl
	asl
	asl
	sta temp10 ; 0,32,64
	
	;lda temp1
	;pha
	;lda temp2
	;pha
	
	; ok, now each column
	; TODO: only copy a few columns at a time.
	ldy #0
@loopRow:
	; store a backup of the update index in temp4
	sty temp4
	
	; load the column to be updated
	lda (temp8), y
	
	; use temp3 as the index into dlg_bitmap
	sta temp3
	
	; add either 0, 32, or 64. this'll get the index into dlg_updpaddr*
	clc
	adc temp10
	
	; use the thing we calculated earlier as an index
	tay
	
	; load the next ppuaddr
	lda dlg_updpaddrhi, y
	sta ppu_addr
	lda dlg_updpaddrlo, y
	sta ppu_addr
	
	; subloop to copy 8 bytes
	ldx #0
@subLoopRow:
	; load the read head
	ldy temp3
	; load and write that data to the PPU
	lda (temp5), y
	sta ppu_data
	; increment the read head
	lda temp3
	clc
	adc #32
	sta temp3
	; next row
	inx
	cpx #8
	bne @subLoopRow
	
	ldy temp4
	
	; continue
@loopRow_continue:
	iny
	cpy dlg_updccurr
	bne @loopRow
	
	lda ctl_flags
	sta ppu_ctrl
	rts
