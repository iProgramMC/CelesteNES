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
	bne :-     ; 2 cycles (if branch succeeds)
	nop
	
	; the last two ppu writes MUST happen during horizontal blank
	stx ppu_scroll
	sta ppu_addr
	
	; restore scroll_x. not sure if this is needed
	stx scroll_x
	
	jsr nmi_anims_normal
	
@otherGameMode:
	pla
	tay
	pla
	tax
	pla
	rti
