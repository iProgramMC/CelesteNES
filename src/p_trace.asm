; Copyright (C) 2025 iProgramInCpp


; ** SUBROUTINE: ph_shifttrace
; desc: Shifts the player X trace left by an amount of pixels.
; parameters:
;     A - the amount of pixels to decrease the player X trace by
; note: The player X trace is capped to 0. It will never overflow.
.proc ph_shifttrace
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	cmp #0
	bmi actuallyNegative
nocheck:
	pha
	ldx #0
loop:
	lda plr_trace_x, x
	sec
	sbc temp1
	bcs :+
	lda #0
:	sta plr_trace_x, x
	inx
	cpx #$40
	bne loop
	pla
return:
	rts
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp ph_shiftrighttrace_nocheck
.endproc

; ** SUBROUTINE: ph_shiftrighttrace
; desc: Shifts the player X trace right by an amount of pixels.
; parameters:
;     A - the amount of pixels to increase the player X trace by
; note: The player X trace is capped to $FF. It will never overflow.
.proc ph_shiftrighttrace
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	cmp #0
	bmi actuallyNegative
nocheck:
	pha
	ldx #0
	sta temp1
:	lda plr_trace_x, x
	clc
	adc temp1
	bcc :+
	lda #$FF
:	sta plr_trace_x, x
	inx
	cpx #$40
	bne :--
	pla
return:
	rts
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp ph_shifttrace::nocheck
.endproc

ph_shiftrighttrace_nocheck := ph_shiftrighttrace::nocheck

; ** SUBROUTINE: ph_shifttraceYP
; desc: Shifts the player Y trace down by an amount of pixels
; parameters:
;     A - the amount of pixels to increase the player Y trace by
; note: The player X trace is capped to $F0. It will never overflow.
.proc ph_shifttraceYP
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	cmp #0
	bmi actuallyNegative
nocheck:
	pha
	ldx #0
	sta temp1
loop:
	lda plr_trace_y, x
	clc
	adc temp1
	bcc :+
	lda #$F0
:	cmp #$F0
	bcc :+
	lda #$F0
:	sta plr_trace_y, x
	inx
	cpx #$40
	bne loop
	pla
return:
	rts
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp ph_shifttraceYN_nocheck
.endproc

; ** SUBROUTINE: ph_shifttraceYN
; desc: Shifts the player Y trace up by an amount of pixels
; parameters:
;     A - the amount of pixels to increase the player Y trace by
; note: The player X trace is capped to 0. It will never overflow.
.proc ph_shifttraceYN
	sta temp1
	
	lda #g2_notrace
	bit gamectrl2
	bne return
	
	lda temp1
	bmi actuallyNegative
nocheck:
	pha
	ldx #0
	sta temp1
loop:
	lda plr_trace_y, x
	sec
	sbc temp1	
	bcs :+
	lda #0
:	sta plr_trace_y, x
	inx
	cpx #$40
	bne loop
	pla
return:
	rts
actuallyNegative:
	sta temp1
	lda #0
	sec
	sbc temp1
	jmp ph_shifttraceYP::nocheck
.endproc

ph_shifttraceYN_nocheck := ph_shifttraceYN::nocheck

ph_altshifttrace:
	lda temp12
	jmp ph_shifttrace
ph_altshiftrighttrace:
	lda temp12
	jmp ph_shiftrighttrace
ph_altshifttraceYN:
	lda temp12
	jmp ph_shifttraceYN
ph_altshifttraceYP:
	lda temp12
	jmp ph_shifttraceYP
