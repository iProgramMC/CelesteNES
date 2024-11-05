; Copyright (C) 2024 iProgramInCpp

;  This code belongs in the PRG_DIAL segment

;dialog_data:
;	.incbin "data.bin"

dlg_update_d:
	rts

; ** SUBROUTINE: dlg_get_clear_start
; desc: Get the column where dialog data is to be loaded.
dlg_get_clear_start:
	lda camera_x_hi
	eor #1
	lsr
	lda camera_x
	ror
	lsr
	lsr
	; now it's between 0 and 63.
	rts

; ** SUBROUTINE: dlg_start_dialog
; desc: Begins a dialog instance.
dlg_start_dialog:
	ldy #0
@loopOpen:
	; TODO LIMITATION:
	; once a dialog is initiated, you CANNOT scroll left.
	lda camera_x
	sta camleftlo
	lda camera_x_pg
	sta camlefthi
	
	lda #gs_camlock
	ora gamectrl
	sta gamectrl
	
	lda #nc2_clr256
	ora nmictrl2
	sta nmictrl2
	
	jsr dlg_get_clear_start
	
	sta clearpalo
	tya
	asl
	asl
	asl
	clc
	adc clearpalo
	and #$3F
	
	; ok, now we added the transition timer properly.
	; calculate the address
	pha
	and #%00011111
	sta clearpalo
	pla
	and #%00100000
	lsr
	lsr
	lsr
	ora #%00100000
	sta clearpahi
	
	jsr dlg_leave_doframe
	
	ldx #0
	lda #0
	sta dlg_updc1
	sta dlg_updc2
	sta dlg_updc3
:	sta dlg_bitmap, x
	sta dlg_bitmap+$100, x
	sta dlg_bitmap+$200, x
	inx
	bne :-
	ldx #0
:	sta dlg_upds1, x
	inx
	cpx #96
	bne :-
	
	iny
	cpy #$4
	bne @loopOpen
	
	jsr @calculatePPUAddresses
	
	; dialog is now open, scrollsplit time
	lda #64
	sta scrollsplit
	
	lda #12
	sta dialogsplit
	
	lda #chrb_dcntr
	sta bg0_bkspl
	lda #chrb_dcntr+2
	sta bg1_bkspl
	
	; now the dialog is open, try drawing some things
	lda #'A'
	ldx #10
	ldy #0
	jsr dlg_draw_char
	lda #'B'
	ldx #16
	ldy #0
	jsr dlg_draw_char
	lda #'C'
	ldx #21
	ldy #0
	jsr dlg_draw_char
	lda #'D'
	ldx #26
	ldy #0
	jsr dlg_draw_char
	
	rts

@calculatePPUAddresses:
	; calculate the initial ppuaddr for the first column of the dialog
	; temp1 - HIGH address, temp2 - LOW address
	
	; calculate the tile index
	lda camera_x_hi
	eor #1
	lsr
	lda camera_x
	ror
	lsr
	lsr
	; said tile index is now between 0 and 63.
	pha
	and #%00100000
	lsr
	lsr
	lsr
	ora #%00100000
	sta temp1         ; calculated the high address
	sta temp3
	pla
	and #%00011111
	ora #%10100000
	sta temp2         ; calculated the low address
	sta temp4
	
	; first row
	ldy #0
@loopRow0:
	jsr @storeAndIncrementTempAddress
	iny
	cpy #32
	bne @loopRow0
	
	; second row
	lda temp4
	sta temp2
	lda temp3
	clc
	adc #1
	sta temp1
	
@loopRow1:
	jsr @storeAndIncrementTempAddress
	iny
	cpy #64
	bne @loopRow1
	
	; third row
	lda temp4
	sta temp2
	lda temp3
	clc
	adc #2
	sta temp1
	
@loopRow2:
	jsr @storeAndIncrementTempAddress
	iny
	cpy #96
	bne @loopRow2
	
	rts
	
@storeAndIncrementTempAddress:
	lda temp2
	sta dlg_updpaddrlo, y
	lda temp1
	sta dlg_updpaddrhi, y
	
	inc temp2
	lda temp2
	and #%00011111
	bne :+
	
	; it is now zero!
	sec
	sbc #%00100000
	sta temp2
	lda temp1
	eor #%00000100  ; use the other nametable
	sta temp1
:	rts

; ** SUBROUTINE: dlg_end_dialog
; desc: Ends a dialog.
dlg_end_dialog:
	; wait for irqcounter to be 3 or 0.
	; chances are we hit this in the middle of the scroll split thing.
@loopWait:
	lda irqcounter
	beq @doneWaiting
	cmp #3
	bne @loopWait
	
@doneWaiting:
	lda #0
	sta scrollsplit
	sta dialogsplit
	
	; load and push the old nametable write head
	lda ntwrhead
	sta dialogsplit ; note: dialogsplit will not be checked if scrollsplit is zero!
	
	lda gamectrl
	pha
	
	; ensure that the palette read head isn't modified ACROSS this call.
	lda palrdheadlo
	pha
	lda palrdheadhi
	pha
	
	and #((gs_scrstodR | gs_scrstopR) ^ $FF)
	; don't generate NEW tiles, don't reload palette data.
	ora #(gs_dontgen | gs_dontpal)
	sta gamectrl
	
	jsr dlg_get_clear_start
	cmp ntwrhead
	; if the clear start head would actually be *bigger* than ntwrhead, then
	; simply return
	bcs @loop_end
	
	sta ntwrhead
	
@loop:
	; use far_call to load the level data bank back in
	lda #<h_gener_col_r
	sta temp1
	lda #>h_gener_col_r
	sta temp2
	ldy musicbank
	jsr far_call
	
	lda #nc_flshpalv
	bit nmictrl
	bne @loopcontinue
	
	; palettes to be flushed
	; copied from g_level :: h_flush_pal_r
	jsr h_calc_ntattrdata_addr
	
	ldy #0
@subloop:
	ldx temp1
	lda ntattrdata, x
	sta temppal, y
	txa
	clc
	adc #8
	sta temp1
	iny
	cpy #8
	bne @subloop

@loopcontinue:
	jsr dlg_leave_doframe
	
	lda ntwrhead
	cmp dialogsplit
	
	bne @loop

@loop_end:
	pla
	sta palrdheadhi
	pla
	sta palrdheadlo
	pla
	sta gamectrl
	
	lda #0
	sta dialogsplit
	
	lda #(gs_camlock ^ $FF)
	and gamectrl
	sta gamectrl
	
	rts

dlg_test_d:
	lda dialogsplit
	beq @initializeDialog
	jmp dlg_end_dialog

@initializeDialog:
	jmp dlg_start_dialog


; ** SUBROUTINE: dlg_leave_doframe
; desc: Waits for a new frame to start to continue operation.
;       This does NOT draw new sprites, nor does it clear shadow OAM.
; clobbers: A
dlg_leave_doframe:
	jsr gm_calc_camera_nosplit
	jsr soft_nmi_on
	jsr nmi_wait
	jmp soft_nmi_off

.align $100
; ** SUBROUTINE: dlg_nmi_clear_256
; desc: Clears (almost) 256 bytes in an 8X30 column fashion.
dlg_nmi_clear_256:
	lda ctl_flags
	ora #pctl_adv32
	sta ppu_ctrl
	
	ldy #$8 ; write 4 columns
@beginning:
	lda clearpahi
	sta ppu_addr
	lda clearpalo
	sta ppu_addr
	
	; 30 writes.
	lda #0
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
	sta ppu_data
	sta ppu_data
	
	lda clearpalo
	clc
	adc #1
	sta clearpalo
	
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
	
:	dey
	bne @beginning
	
	lda ctl_flags
	sta ppu_ctrl
	
	rts

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
	
:	rts

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
	rts
