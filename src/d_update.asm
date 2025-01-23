; Copyright (C) 2024-2025 iProgramInCpp

;  This code belongs in the PRG_DIAL segment

; ** SUBROUTINE: dlg_get_clear_start
; desc: Get the column where dialog data is to be loaded.
dlg_get_clear_start:
	lda camera_x_pg
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
	lda dialogsplit
	beq :+
	jmp @wasAlreadyOpen
	
:	ldy #0
	sty dlg_speaktimer
	sty dlg_colnum
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
	
	lda #<irq_idle
	sta irqaddr
	lda #>irq_idle
	sta irqaddr+1
	
	jsr @enqueueColumnsForClearing
	
	jsr dlg_leave_doframe
	
	iny
	cpy #$4
	bne @loopOpen
	
	lda #0
	ldy #0
:	sta temppalH1
	sta temppalH2
	iny
	cpy #8
	bne :-
	
	; attribute memes
	ldy #0
@loopAttributes:
	tya
	asl
	asl
	asl
	sta temp1
	
	; calculate spill-over
	lda dlg_temporary
	and #$1F       ; 0-31, we care about the in-screen offs only
	lsr
	lsr
	sta wrcountHP2 ; that is how much we want to spill out
	
	; calculate non-spillover
	lda #8
	sec
	sbc wrcountHP2
	sta wrcountHP1
	
	; calculate beginning nametable
	lda dlg_temporary
	and #%00100000
	lsr
	lsr
	lsr
	eor #$23
	sta ppuaddrHP1+1
	
	; calculate start offset
	lda #$C0
	clc
	adc temp1
	clc
	adc wrcountHP2 ; (8 - wrcountHR1)
	sta ppuaddrHP1
	
	; calculate end nametable
	lda ppuaddrHP1+1
	eor #$04
	sta ppuaddrHP2+1
	
	; calculate midpoint
	lda #$C0
	clc
	adc temp1
	sta ppuaddrHP2
	
	; take one away from wrcountHP2
	;lda wrcountHP2
	;beq :+
	;dec wrcountHP2
	
	lda #nc_flushpal
	ora nmictrl
	sta nmictrl
	
	jsr dlg_leave_doframe
	
	iny
	cpy #$8
	bne @loopAttributes
	
@postGraphicsSetup:
	jsr @clearDialogMemory
	jsr @calculatePPUAddresses
	jsr @setupDialogSplit
	
	lda #dialog_char_timer
	sta dlg_chartimer
	
	lda dlg_crsr_home
	sta dlg_cursor_x
	
	lda #0
	sta dlg_cursor_y
	
	lda dlg_speaker
	bne @notMadeline
	
	lda playerctrl
	and #pl_left
	sta dlg_facing
	rts

@notMadeline:
	ldy dlg_entity
	lda sprspace+sp_flags, y
	and #ef_faceleft
	sta dlg_facing
	rts

@calculatePPUAddresses:
	; calculate the initial ppuaddr for the first column of the dialog
	; temp1 - HIGH address, temp2 - LOW address
	
	; calculate the tile index
	lda camera_x_pg
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
	pha
	ora #%00110000
	sta temp1         ; calculated the high address
	sta temp3
	pla
	ora #%00100000
	sta splgapaddr+1
	
	pla
	and #%00011111
	sta splgapaddr
	
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
	; disable the idle IRQ first though
	sta mmc3_irqdi
	
	lda #<irq_dialog_split_2
	sta irqaddr
	lda #>irq_dialog_split_2
	sta irqaddr+1
	
	lda #dialog_upper_space+dialog_total_height
	sta scrollsplit
	
	lda #dialog_upper_space-8
	sta dialogsplit
	
	lda #chrb_dcntr
	sta bg0_bkspl
	lda #chrb_dcntr+2
	sta bg1_bkspl
	rts

@clearDialogMemory:
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
	rts

@wasAlreadyOpen:
	jsr dlg_draw_portrait
	
	lda #0
	sta dlg_colnum
	
	ldy #0
@loopAlreadyOpenClear:
	jsr @enqueueColumnsForClearing
	jsr dlg_leave_doframe_split
	iny
	cpy #4
	bne @loopAlreadyOpenClear
	
	jmp @postGraphicsSetup

@enqueueColumnsForClearing:
	jsr dlg_get_clear_start
	sta dlg_temporary
	
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
	
	lda #nc2_clr256
	ora nmictrl2
	sta nmictrl2
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
	sta dlg_temporary
	
	lda dlg_endnoclear
	beq :+
	rts
	
:	lda gamectrl
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
	; actually we should subtract 1 tile because of some edge cases and ugh...
	sec
	sbc #2
	and #$3E
	
	cmp ntwrhead
	; if the clear start head would actually be *bigger* than ntwrhead, then
	; simply return
	bcs @loop_end
	
	sta ntwrhead
	
@loop:
	; use far_call to load the level data bank back in
	lda #<h_gener_col_r
	sta farcalladdr
	lda #>h_gener_col_r
	sta farcalladdr+1
	ldy lvldatabank
	jsr far_call
	
	lda #nc_flshpalv
	bit nmictrl
	bne @loopcontinue
	
	; palettes to be flushed
	; copied from g_level :: h_flush_pal_r
	lda ntwrhead
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
	cmp dlg_temporary
	
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

; ** SUBROUTINE: dlg_leave_doframe
; desc: Waits for a new frame to start to continue operation.
;       This does NOT draw new sprites, nor does it clear shadow OAM.
; clobbers: A, X
dlg_leave_doframe:
	jsr gm_calc_camera_nosplit
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	rts

; ** SUBROUTINE: dlg_leave_doframe_split
; desc: Waits for a new frame to start to continue operation while calculating
;       the new camera position to include a split.
;       This does NOT draw new sprites, nor does it clear shadow OAM.
; clobbers: A, X
dlg_leave_doframe_split:
	jsr gm_calc_camera_split
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	rts

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
	
:	cmp #$0A
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

; ** SUBROUTINE: dlg_update_d
; desc: Updates the current dialog.
;       Draws the active portrait, advances the dialog timer and pushes a character if needed, etc.
dlg_update_d:
	; preliminary check for the A button
	lda #cont_a
	bit p1_cont
	beq @skipPreliminaryCheck
	bit p1_conto
	bne @skipPreliminaryCheck
	
	; has the text finished.
	ldy #0
	lda (dlg_textptr), y
	bne @skipPreliminaryCheck
	
	; Ok, can continue.
	ldy dlg_havenext
	beq @exitDialog
	bne @continueCutscene
	
@skipPreliminaryCheck:
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
	
	; check if the character is speaking, if so, advance the speak timer, else make it stop
	ldy #0
	lda (dlg_textptr), y
	bne @dontSet
	
	; check if there's still some frames to advance through
	lda dlg_speaktimer
	and #%00000111
	bne @dontSet
	
	sta dlg_speaktimer
	beq @dontIncrement
	
@dontSet:
	inc dlg_speaktimer
	
@dontIncrement:
	ldy #0
	lda (dlg_textptr), y
	bne :+
	dey
	sty dlg_speaktimer
:	jsr dlg_draw_portrait
	rts

@exitDialog:
	jsr dlg_end_dialog
@continueCutscene:
	jmp dlg_run_cutscene

; ** SUBROUTINE: dlg_begin_cutscene_d
; desc: Initiates a cutscene.
; parameters:
;     [dlg_cutsptr+1, dlg_cutsptr] - The pointer to the cutscene to load.
;     [dlg_entity]                 - The index of the entity the player is engaging with.
dlg_begin_cutscene_d:
	; initialize things about the cutscene here TODO
	; TODO: When you add things here, change dlg_run_cutscene_g to run dlg_run_cutscene!!
	
	;fallthrough: jmp dlg_run_cutscene

; ** SUBROUTINE: dlg_run_cutscene
; desc: Runs the cutscene script until a blocking operation. Then, runs that blocking operation
;       and exits.
dlg_run_cutscene:
	; check if there is no cutscene to run.
	lda dlg_cutsptr+1
	beq @return
@loop:
	ldy #0
	lda (dlg_cutsptr), y
	beq @exitCutscene
	
	; increment the dialog pointer
	inc dlg_cutsptr
	bne :+
	inc dlg_cutsptr+1

:	pha
	asl
	tay
	pla
	jsr @executeCommand
	
	; if the command didn't block, then run again
	beq @loop
	rts

@exitCutscene:
	; The cutscene is over. Resume normal gameplay.
	lda #0
	sta dlg_cutsptr
	sta dlg_cutsptr+1

@return:
	rts

@executeCommand:
	ldx dlg_cmd_table, y
	stx temp1
	iny
	ldx dlg_cmd_table, y
	stx temp1+1
	jmp (temp1)

; ** SUBROUTINE: dlg_read_script
; desc: Reads a byte from the script and increments the dialog pointer.
dlg_read_script:
	ldy #0
	lda (dlg_cutsptr), y
	inc dlg_cutsptr
	bne :+
	inc dlg_cutsptr+1
:	rts

; ** Dialog Command Table
; Each of these represents a command that the cutscene script runner will execute.
;
; These functions should return:
;      0 - The function has run synchronously, all its effects have been done.
;  Non-0 - The function will run asynchronously. Cutscene script execution will be resumed
;          later.
;
; These functions get a single argument: A, which is the opcode that led to the execution
; of that command.  Due to the way the command table is laid out, bit 7 is ignored, and
; can be checked for.
dlg_cmd_table:
	.word $0000
	.word dlg_cmd_wait
	.word dlg_cmd_dialog
	.word dlg_cmd_speaker
	.word dlg_cmd_dirent
	.word dlg_cmd_dirplr
	.word dlg_cmd_walkplr
	.word dlg_cmd_walkent
	.word dlg_cmd_express
	.word dlg_cmd_trigger
	.word dlg_cmd_lockinp
	.word dlg_cmd_unlockinp
	.word dlg_cmd_waitgrn
	.word dlg_cmd_dialog2
	.word dlg_cmd_begin
	.word dlg_cmd_left
	.word dlg_cmd_right
	.word dlg_cmd_freeze
	.word dlg_cmd_physOFF
	.word dlg_cmd_physON
	.word dlg_cmd_pcdgOFF
	.word dlg_cmd_pcdgON
	.word dlg_cmd_rm25pcv
	.word dlg_cmd_zerovel
	.word dlg_cmd_callrt
	.word dlg_cmd_playmusic
	.word dlg_cmd_endlevel

dlg_cmd_begin:
	jsr dlg_cmd_left
	; since it returns 0, just store it to the waittimer
	sta dlg_waittimer
	sta dlg_walkdstx
	sta dlg_walkdsty
	rts

dlg_cmd_wait:
	; if there is no wait timer, set one up
	lda dlg_waittimer
	beq @loadWaitTimer
	
	; then decrement the wait timer, if it's not zero, check next frame
	dec dlg_waittimer
	bne @stillNotZero
	
	; it's zero now, so move on. ip is on the number of frames to wait,
	; so we must increment it again to move on to the next instruction
	jsr dlg_read_script
	lda #0
	rts
	
@loadWaitTimer:
	jsr dlg_read_script
	sta dlg_waittimer
	jsr dlg_recheck_next_frame ; roll it back once
	; then roll it back again
@stillNotZero:
	jmp dlg_recheck_next_frame

dlg_cmd_dialog2:
	ldy #1
	sty dlg_endnoclear
	dey
	sty dlg_havenext
	bne dlg_cmd_dialog_

dlg_cmd_dialog:
	asl                  ; shift the high bit of the command byte into C
	lda #0
	rol                  ; shift it into the low bit of A
	sta dlg_havenext     ; store it into the "have next"

	lda #0
	sta dlg_endnoclear

dlg_cmd_dialog_:	
	; read address
	jsr dlg_read_script
	sta dlg_textptr
	jsr dlg_read_script
	sta dlg_textptr+1
	
	jsr dlg_start_dialog
	
	lda #1
	rts

dlg_cmd_speaker:
	; read speaker
	jsr dlg_read_script
	
	; select speaker
	tax
	jsr dlg_set_speaker
	
	; return zero because this is a synchronous command
	lda #0
	rts

dlg_cmd_dirplr:
	jsr dlg_read_script
	tax
	beq @right
	lda playerctrl
	ora #pl_left
	sta playerctrl
	bne @skip
@right:
	lda playerctrl
	and #<~pl_left
	sta playerctrl
@skip:
	lda #0
	rts

; Not "DIRectory ENTry", but "DIRection ENTity"!
dlg_cmd_dirent:
	jsr dlg_read_script
	tax
	beq @right
	
	ldy dlg_entity
	lda sprspace+sp_flags, y
	ora #ef_faceleft
	sta sprspace+sp_flags, y
	bne @skip
@right:
	lda sprspace+sp_flags, y
	and #<~ef_faceleft
	sta sprspace+sp_flags, y

@skip:
	lda #0
	rts

dlg_cmd_walkplr:
	lda dlg_walkdsty
	beq @readAndSetUp
	
	lda #0
	sta trantmp1
	
	; try to approach from the X
	lda player_x
	cmp dlg_walkdstx
	bcs @walkXPos
	
	; player_x < dlg_walkdstx, so add
	lda #maxwalkLO
	sta player_vs_x
	lda #maxwalkHI
	sta player_vl_x
	
	lda playerctrl
	and #<~pl_left
	sta playerctrl
	
	lda player_sp_x
	;clc
	adc #maxwalkLO
	sta player_sp_x
	lda player_x
	adc #maxwalkHI
	sta player_x
	
	; now compare
	lda dlg_walkdstx
	cmp player_x
	bcs @doneX
	
	; player_x is now >= dlg_walkdstx
	sta player_x
	jmp @clearXVel
	
@walkXPos:
	; negative
	lda #<(-maxwalkLO)
	sta player_vs_x
	lda #>(-maxwalkHI)
	sta player_vl_x
	
	lda playerctrl
	ora #pl_left
	sta playerctrl
	
	lda player_sp_x
	;sec
	sbc #maxwalkLO
	sta player_sp_x
	lda player_x
	sbc #maxwalkHI
	sta player_x
	
	lda dlg_walkdstx
	cmp player_x
	bcc @doneX
	
	; player_x is now < dlg_walkdstx
	sta player_x

@clearXVel:
	lda #0
	sta player_vl_x
	sta player_vs_x
	
@doneX:
	lda dlg_walkdstx
	cmp player_x
	bne :+
	inc trantmp1

:	; check the Y now TODO
	
	
	lda trantmp1
	cmp #1
	; if not done, then recheck
	bne @recheck
	
	; finish the command
	jsr dlg_read_script
	jsr dlg_read_script
	
	lda gamectrl4
	and #<~g4_nophysic
	sta gamectrl4
	
	lda #0
	sta dlg_walkdstx
	sta dlg_walkdsty
	rts

@readAndSetUp:
	lda gamectrl4
	ora #g4_nophysic
	sta gamectrl4
	
	; set up the walk
	jsr dlg_read_script
	sta dlg_walkdstx
	jsr dlg_read_script
	sta dlg_walkdsty
	
	; then recheck next frame
	; (note: have to do this 3 times because we read 2 extra bytes)
	jsr dlg_recheck_next_frame
	jsr dlg_recheck_next_frame
@recheck:
	jmp dlg_recheck_next_frame

dlg_cmd_walkent:
	; TODO
	jsr dlg_read_script
	jsr dlg_read_script
	jsr dlg_read_script
	lda #0
	rts

dlg_cmd_express:
	; read expression
	jsr dlg_read_script
	
	; select expression
	jsr dlg_set_expression
	
	lda #0
	rts

dlg_cmd_trigger:
	jsr dlg_read_script
	
	ldx dlg_entity
	
	; this field was decided on by convention(TM).
	sta sprspace+sp_entspec1, x
	
	lda sprspace+sp_flags, x
	and #ef_timerspec2
	beq @return
	
	; this field was also decided by convention(TM).
	lda #0
	sta sprspace+sp_entspec2, x
@return:
	rts

; Lock Input
dlg_cmd_lockinp:
	lda gamectrl3
	ora #g3_blockinp
	sta gamectrl3
	
	lda #0
	sta player_vl_x
	rts

; Unlock Input
dlg_cmd_unlockinp:
	lda gamectrl3
	and #<~g3_blockinp
	sta gamectrl3
	
	lda #0
	rts

; Portrait Left
dlg_cmd_left:
	lda #dialog_border
	sta dlg_portraitx
	lda #(dialog_border+dialog_port_size+dialog_port_brdr)
	sta dlg_crsr_home
	lda #0
	rts

; Portrait Right
dlg_cmd_right:
	lda #(256-dialog_border-dialog_port_size)
	sta dlg_portraitx
	lda #(dialog_border+3)
	sta dlg_crsr_home
	lda #0
	rts

; Wait Ground
dlg_cmd_waitgrn:
	; check if player is on ground
	lda playerctrl
	and #pl_ground
	bne @justExit
	
	; Re-check next frame
	jmp dlg_recheck_next_frame
	
	; TODO
@justExit:
	lda #0
	rts

; Freeze
dlg_cmd_freeze:
	jsr dlg_read_script
	tay
	
:	sty transtimer
	jsr dlg_leave_doframe
	ldy transtimer
	dey
	bne :-
	
	lda #0
	rts

; Disable Physics
dlg_cmd_physOFF:
	lda gamectrl4
	ora #g4_nophysic
	sta gamectrl4
	lda #0
	rts

; Enable Physics
dlg_cmd_physON:
	lda gamectrl4
	and #<~g4_nophysic
	sta gamectrl4
	lda #0
	rts

; Disable PCDG
dlg_cmd_pcdgOFF:
	lda gamectrl3
	ora #g3_nogradra
	sta gamectrl3
	lda #0
	rts

; Enable PCDG
dlg_cmd_pcdgON:
	lda gamectrl3
	and #<~g3_nogradra
	sta gamectrl3
	lda #0
	rts

; Remove 25% of velocity
dlg_cmd_rm25pcv:
	lda temp1
	pha
	lda temp2
	pha
	
	lda player_vs_x
	sta temp2
	lda player_vl_x
	cmp #$80
	ror
	ror temp2
	cmp #$80
	ror
	ror temp2
	sta temp1
	
	lda player_vs_x
	sec
	sbc temp2
	sta player_vs_x
	lda player_vl_x
	sbc temp1
	sta player_vl_x
	
	lda player_vs_y
	sta temp2
	lda player_vl_y
	cmp #$80
	ror
	ror temp2
	cmp #$80
	ror
	ror temp2
	sta temp1
	
	lda player_vs_y
	sec
	sbc temp2
	sta player_vs_y
	lda player_vl_y
	sbc temp1
	sta player_vl_y
	
	pla
	sta temp2
	pla
	sta temp1
	
	lda #0
	rts

; Zero Velocity
dlg_cmd_zerovel:
	lda #0
	sta player_vl_x
	sta player_vs_x
	sta player_vl_y
	sta player_vs_y
	rts

; Call Subroutine
dlg_cmd_callrt:
	lda temp1
	pha
	lda temp2
	pha
	
	jsr dlg_read_script
	sta temp1
	jsr dlg_read_script
	sta temp1+1
	jsr @doCall
	
	pla
	sta temp2
	pla
	sta temp1
	
	lda #0
	rts
@doCall:
	jmp (temp1)

; Play Music
dlg_cmd_playmusic:
	jsr dlg_read_script
	; store the argument in temp11 because we want the music bank to be loaded
	sta temp11
	
	jsr aud_play_music_by_index
	lda #0
	rts

; Finish Level
dlg_cmd_endlevel:
	lda gamectrl2
	and #<~g2_exitlvl
	sta gamectrl2
	
	lda #2
	sta exitmaptimer
	rts

; ** SUBROUTINE: dlg_recheck_next_frame
; desc: Re-runs the exact same instruction next frame.
; Note: If you have read bytes from the cutscene stream, then you must run this function,
;       or decrement the cutscene pointer, that many times!
; Note: You can just `jmp` to this, it'll return a non zero value causing a return.
dlg_recheck_next_frame:
	lda dlg_cutsptr
	bne :+
	dec dlg_cutsptr+1
:	dec dlg_cutsptr
	
	lda gamectrl3
	ora #g3_updcuts
	sta gamectrl3
	rts
