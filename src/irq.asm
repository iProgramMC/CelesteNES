; Copyright (C) 2024 iProgramInCpp

; ** IRQ
; thanks NESDev Wiki for providing an example of loopy's scroll method
irq:
	pha
	txa
	pha
	tya
	pha
	sta mmc3_irqdi
	
	lda gamemode       ; 3 cycles
	bne @otherGameMode ; 2 cycles if gamemode == 0
	
	lda dialogsplit
	bne @dialogSplit
	
	; regular border split.
@normalSplit:
	lda scroll_flags   ; bits 0 and 1 control the high name table address
	asl
	asl
	sta ppu_addr       ; nametable number << 2 to ppu_addr.
	
	; push the Y position to the ppu_scroll
	lda scroll_y
	sta ppu_scroll
	
	; prepare the 2 latter writes. we reuse scroll_x to hold (y & $f8) << 2.
	and #%11111000
	asl
	asl
	ldx scroll_x
	sta scroll_x
	
	; ((y & $f8) << 2) | (x >> 3) in A for ppu_addr later
	txa
	lsr
	lsr
	lsr
	ora scroll_x
	
	; carefully timed code!
	ldy #$7
:	dey        ; 2 cycles
	bne :-     ; 3 cycles (if branch succeeds)
	nop
	
	; the last two ppu writes MUST happen during horizontal blank
	stx ppu_scroll
	sta ppu_addr
	
	; restore scroll_x. not sure if this is needed
	stx scroll_x
	
	jsr nmi_anims_normal
	
	lda dialogsplit
	beq @otherGameMode
	
	jsr aud_run
	
@otherGameMode:
	pla
	tay
	pla
	tax
	pla
	rti

@dialogSplit:
	; hell yeah now we're talking
	
	; we're on scan line 12 right now.
	; this calculate the first 4 control bytes that we can re-use later (so we
	; save ROM space / cycles not trying to recalculate this)
	
	lda scroll_flags   ; bits 0 and 1 control the high name table address
	eor #%00000001     ; EOR the horizontal bit to use the OTHER, hidden, nametable
	asl
	asl
	sta ppu_addr       ; nametable number << 2 to ppu_addr.
	sta irqtmp1
	
	; push the Y position to the ppu_scroll
	lda #0
	sta ppu_scroll
	sta irqtmp2
	
	; prepare the 2 latter writes. we reuse scroll_x to hold (y & $f8) << 2.
	and #%11111000
	asl
	asl
	ldx scroll_x
	sta irqtmp3
	
	; ((y & $f8) << 2) | (x >> 3) in A for ppu_addr later
	txa
	lsr
	lsr
	lsr
	ora irqtmp3
	
	; carefully timed code!
	ldy #$4
:	dey        ; 2 cycles
	bne :-     ; 3 cycles (if branch succeeds)
	nop
	nop
	
	; the last two ppu writes MUST happen during horizontal blank
	stx ppu_scroll
	sta ppu_addr
	stx irqtmp3
	sta irqtmp4
	
	; we're coming up to scanline 13 now
	jsr @eightScanLines
	jsr @gapScanLines
	jsr @eightScanLines
	jsr @gapScanLines
	jsr @eightScanLines
	jsr @gapRestScanLines
	
	; once synched, just do the normal split
	jmp @normalSplit

; this waits for like 12 scanlines
@gapScanLines:
	ldy #$F3
:	dey
	bne :-
	nop
	nop
	nop
	rts

@gapRestScanLines:
	ldy #$70
:	dey
	bne :-
	rts

@eightScanLines:
	ldy #8
@loop_lineOne:
	; increase the address of the first character to move by 8 pixels
	lda #%00001000
	clc
	adc irqtmp2
	sta irqtmp2
	
	; increment irqtmp1 based on carry in a manner that
	; takes the same amount of cycles regardless of case
	lda irqtmp1
	adc #0
	sta irqtmp1
	sta ppu_addr
	
	lda irqtmp2
	sta ppu_scroll
	
	; also increment irqtmp4.  all 8 bits of irqtmp4 are used and slapped
	; onto the V register (so we probably didn't even need to increment irqtmp2!)
	lda irqtmp4
	;clc - probably not needed
	adc #%00100000
	sta irqtmp4
	
	ldx irqtmp3
	; re-load a bunch to waste cycles until next h-blank
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	ldx irqtmp3
	nop
	nop
	
	stx ppu_scroll
	sta ppu_addr
	
	dey
	bne @loop_lineOne
	rts
