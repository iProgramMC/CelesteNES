; Copyright (C) 2024 iProgramInCpp

;  This code belongs in the PRG_DIAL segment

test_str:	.byte "Hello! I am a piece of dialog.\nI can stretch over multiple\nlines!", 0



; ** Speaker Banks Array
; desc: This defines the graphics banks loaded to display a certain speaker.
speaker_banks:
	.byte chrb_dmade ; SPK_madeline
	.byte chrb_dgran ; SPK_granny
	.byte chrb_dtheo ; SPK_theo

; ** SUBROUTINE: dlg_set_speaker
; desc: Sets the current speaker's portrait bank.
; arguments:
;     X - current speaker
dlg_set_speaker:
	lda speaker_banks, x
	tay
	sty spr0_bkspl
	iny
	sty spr1_bkspl
	iny
	sty spr2_bkspl
	iny
	sty spr3_bkspl
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
	jsr @setupDialogSplit
	
	; also setup some values for testing
	lda #<test_str
	sta dlg_textptr
	lda #>test_str
	sta dlg_textptr+1
	
	lda #dialog_char_timer
	sta dlg_chartimer
	
	lda #(dialog_border+dialog_port_size+dialog_port_brdr)
	sta dlg_cursor_x
	sta dlg_crsr_home
	
	lda #0
	sta dlg_cursor_y
	
	ldx #SPK_madeline
	jsr dlg_set_speaker
	
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
	lda temp2
	sec
	sbc #%00100000
	sta temp2
	lda temp1
	eor #%00000100  ; use the other nametable
	sta temp1
:	rts

@setupDialogSplit:
	; dialog is now open, scrollsplit time
	lda #64
	sta scrollsplit
	
	lda #12
	sta dialogsplit
	
	lda #chrb_dcntr
	sta bg0_bkspl
	lda #chrb_dcntr+2
	sta bg1_bkspl
	rts

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

; ** SUBROUTINE: dlg_advance_text
; desc: Advances the active text in a dialog.
dlg_advance_text:
	ldy #0
	lda (dlg_textptr), y
	; if the character is a zero, then return.
	beq @return
	
	; increment the text pointer
	inc dlg_textptr
	bne :+
	inc dlg_textptr+1
:

	cmp #$0A
	beq @newLine
	
	; regular old character. we should draw it.
	ldx dlg_cursor_x
	ldy dlg_cursor_y
	pha                  ; store the character because we'll need it later
	jsr dlg_draw_char
	
	pla                  ; pull the character, and determine its width.
	sec
	sbc #$20
	and #$7F
	lsr                  ; get the index into the widths array. carry will contain the even/odd bit
	tax
	lda dlg_font_widths, x
	bcc :+               ; if character was odd, shift the widths by 4
	lsr
	lsr
	lsr
	lsr
:	and #$F
	sta debug
	clc
	adc dlg_cursor_x
	sta dlg_cursor_x
	
@return:
	lda #dialog_char_timer
	sta dlg_chartimer
	rts

@newLine:
	; new line
	; revert cursor X back to home
	lda dlg_crsr_home
	sta dlg_cursor_x
	; advance new line
	lda dlg_cursor_y
	clc
	adc #8
	; note: what happens if dlg_cursor_y >= 24?!
	sta dlg_cursor_y
	jmp @return

; ** SUBROUTINE: dlg_draw_portrait
; desc: Draws the active portrait.
pall  = 1
pall2 = 0
pall3 = 2
dlg_draw_portrait:
	jsr @homeX
	lda #6
	sta y_crd_temp
	
	lda #pall
	ldy #$00
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$02
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$04
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$06
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$08
	jsr oam_putsprite
	jsr @incrementY
	jsr @homeX
	lda #pall
	ldy #$20
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$22
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$24
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$26
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$28
	jsr oam_putsprite
	jsr @incrementY
	jsr @homeX
	
	lda #pall
	ldy #$40
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$42
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$44
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$46
	jsr oam_putsprite
	jsr @incrementX
	lda #pall
	ldy #$48
	jsr oam_putsprite
	jsr @incrementY
	jsr @homeX
	
	rts

@incrementX:
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	rts
@incrementY:
	lda y_crd_temp
	clc
	adc #16
	sta y_crd_temp
	rts
@homeX:
	lda #dialog_border
	sta x_crd_temp
	rts
@home2:
	lda #(dialog_border+2)
	sta x_crd_temp
	rts

; ** SUBROUTINE: dlg_update_d
; desc: Updates the current dialog.
;       Draws the active portrait, advances the dialog timer and pushes a character if needed, etc.
dlg_update_d:
	dec dlg_chartimer
	bne @noAdvanceImmediately
@advanceGo:
	jsr dlg_advance_text
	jmp @advanced
	
@noAdvanceImmediately:
	; wasn't advanced immediately. check for the A button
	lda #cont_a
	bit p1_cont
	beq @advanced
	
	; pressed, so decrement it a lot faster
	dec dlg_chartimer
	beq @advanceGo
	dec dlg_chartimer
	beq @advanceGo

@advanced:
	jsr dlg_draw_portrait
	rts