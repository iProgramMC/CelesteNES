; Copyright (C) 2024 iProgramInCpp

; Note A:
;
; Write to a *mirror* of PPUMASK.  Certain PPU revisions have an erratum
; wherein the CPU starts a write, but only later does it put the actual
; value on the data bus, leaving the PPU reading open bus for a bit. The
; PPU takes the open bus value (which happens to be $20 unless we correct
; course), and uses it for a few PPU clocks until the CPU places the value
; it means to write to the PPU, and the PPU then uses the correct value.
;
; Since it thinks we wrote $20 for a bit, that means rendering is disabled
; for a few PPU clocks, which means weird stuff might happen with the
; internal registers of the PPU.
;
; Instead, write to a mirror of the PPUMASK register, to prime the open
; bus with the value we "intend" on writing. (actually, sometimes it's
; not the correct value, but it's better than having "rendering disabled"
; be seen by the PPU)
death_wipe_off = %00010000 ; only sprites
death_wipe_on  = def_ppu_msk

.align $100
.proc irq_death_wipe
	pha
	lda deathwipe
	; This code runs at a 15 cycle delay from the interrupt, or 45 px.
	; This jitter can be up to 7 cycles (21px) from the start of h-blank.
	; H-blank is a total of around 84 pixels wide, so we have about 1/4,
	; or 21 pixels / 7 cycles, of h-blank left
	;
	; Store the value we loaded from deathwipe.  This is the PPU mask for
	; the first half.
	sta ppu_mask | (death_wipe_off << 8)       ; 4 cycles - Note A
	
	stx irqtmp9        ; 3 cycles
	sty irqtmp10       ; 3 cycles
	
	; load the PPU mask for the second half
	ldx deathwipe2     ; 3 cycles
	
.repeat 4, rep
	.if rep <> 0
		sta ppu_mask | (death_wipe_on << 8)      ; 4 cycles
	.endif
	; load the first counter, and decrement
	ldy a:irqtmp+rep*2+0 ; 4 cycles
:	dey                ; 2 cycles
	bne :-             ; 3 cycles (2 if fell out)
	; ^^this construction lasts (Y-1) * 5 + 7 cycles
	
	; entering the second half
	stx ppu_mask | (death_wipe_off << 8)        ; 4 cycles - Note A
	
	ldy a:irqtmp+rep*2+1 ; 4 cycles
:	dey                ; 2 cycles
	bne :-             ; 3 cycles (2 if fell out)
.endrepeat
	
	sta mmc3_irqdi
	dec irqcounter
	beq dontRescheduleInterrupt
	
	lda #1
	sta mmc3_irqla
	sta mmc3_irqrl
	sta mmc3_irqen
	
dontRescheduleInterrupt:
	lda #def_ppu_msk
	sta ppu_mask | (death_wipe_on << 8)
	ldx irqtmp9
	ldy irqtmp10
	pla
	rti
.endproc

.include "m_auxil.asm"

.align $100

;irq_deathwipe_:        ; +1 cycle from the BNE
;	jmp irq_deathwipe  ; 3 cycles
;; ** IRQ
;; thanks NESDev Wiki for providing an example of loopy's scroll method
;irq:
;	pha                ; 3 cycles
;	lda deathwipe      ; 3 cycles
;	bne irq_deathwipe_ ; 2 cycles

irq:
	jmp (irqaddr)      ; 5 cycles

; TODO refactor this!
irq_dialog_split:
	pha                ; 3 cycles
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
	jsr @delay_28
	
	; the last two ppu writes MUST happen during horizontal blank
	stx ppu_scroll
	sta ppu_addr
	
	; restore scroll_x. not sure if this is needed
	stx scroll_x
	
	lda #%00010100
	sta ppu_mask
	jsr nmi_anims_normal
	lda #def_ppu_msk
	sta ppu_mask
	
@otherGameMode:
	pla
	tay
	pla
	tax
	pla
	rti

@noCalculate:
	cmp #3
	bcs @normalSplit ; is it >= 3
	lda irqtmp1
	sta ppu_addr
	lda irqtmp2
	sta ppu_scroll
	ldx irqtmp3
	
	; carefully timed code!
	lsr
	lda irqtmp4   ; was after "ldx irqtmp3"
	jsr @delay_28
	
	jmp @loopSkip

@dialogSplit:
	; hell yeah now we're talking
	
	; we're on scan line 12 right now.
	; this calculate the first 4 control bytes that we can re-use later (so we
	; save ROM space / cycles not trying to recalculate this)
	lda irqcounter
	bne @noCalculate
	
	lda scroll_flags   ; bits 0 and 1 control the high name table address
	eor #%00000001     ; EOR the horizontal bit to use the OTHER, hidden, nametable
	asl
	asl
	sta ppu_addr       ; nametable number << 2 to ppu_addr.
	sta irqtmp1
	
	; push the Y position to the ppu_scroll
	lda #40
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
	;jsr @actuallyReturn ; was 12 cycles.  Since we added 5 cycles at the start
	pha        ; 3 cycles
	pla        ; 4 cycles
	
@loopSkip:
	nop
	nop
	nop
	nop
	; the last two ppu writes MUST happen during horizontal blank
	stx ppu_scroll
	sta ppu_addr
	stx irqtmp3
	sta irqtmp4
	
	; we're coming up to scanline 13 now
	jsr @eightScanLines
	
	; one more scanline to revert to the initial scroll
;	ldy #$13
;:	dey
;	bne :-
	; 91 cycles ^^
	jsr @delay_89
	
	lda splgapaddr+1
	sta ppu_addr
	lda splgapaddr
	sta ppu_addr
	
	; reprogram the MMC3 to give us a new interrupt in 12 scanlines
	ldy irqcounter
	lda dialog_irq_delays, y
	sta mmc3_irqla
	sta mmc3_irqrl
	sta mmc3_irqen
	inc irqcounter
	bne @otherGameMode ; just let it go

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
	
	; re-load a bunch to waste cycles until next h-blank
	jsr @delay_23_ldx_irqtmp3
	cpy #1
	beq @return
	jsr @delay_28
	
	stx ppu_scroll
	sta ppu_addr
	
	; stall a bit more
	cpy #6
	beq :+
	;ldx irqtmp3
	ldx irqtmp3
:	nop
	
	dey
	bne @loop_lineOne
	rts

@return:
	lda irqtmp1
	sta ppu_addr
	lda #0
	sta ppu_scroll
	
	;jsr @actuallyReturn
	lda irqtmp3
	and #%00000111
	tax
	lda irqtmp4
	and #%00011111
	nop
	stx ppu_scroll
	sta ppu_addr
@actuallyReturn:
	rts

; delays exactly 28 cycles
@delay_28:
	; entry: 6 cycles
	pha   ;  3 cycles
	pla   ;  4 cycles
	pha   ;  3 cycles
	pla   ;  4 cycles
	nop   ;  2 cycles
	rts   ;  6 cycles

; delays exactly 23 cycles and loads irqtmp3
@delay_23_ldx_irqtmp3:
	; entry:      6 cycles
	ldx irqtmp3 ; 3 cycles
	ldx irqtmp3 ; 3 cycles
	ldx irqtmp3 ; 3 cycles
	nop         ; 2 cycles
	rts   ;       6 cycles

; delay exactly 89 cycles
@delay_89:
	; entry:         6 cycles
	pha   ;          3 cycles
	pla   ;          4 cycles
	jsr @delay_28 ; 28 cycles
	jsr @delay_28 ; 28 cycles
	pha   ;          3 cycles
	pla   ;          4 cycles
	pha   ;          3 cycles
	pla   ;          4 cycles
	rts   ;          6 cycles

dialog_irq_delays:	.byte 2, 2, 5

irq_dialog_split_2:
	pha
	lda #def_ppu_msk
	sta ppu_mask
	sta mmc3_irqdi
	lda #<irq_dialog_split
	sta irqaddr
	lda #>irq_dialog_split
	sta irqaddr+1
	lda #8-2
	sta mmc3_irqla
	sta mmc3_irqrl
	sta mmc3_irqen
	pla
	rti

irq_memorial_split:
	sta mmc3_irqdi
	pha
	
	lda #mmc3bk_bg0 | def_mmc3_bn
	sta mmc3_bsel
	
	lda bg0_bknum
	sta mmc3_bdat
	
	lda mmc3_shadow
	sta mmc3_bsel
	
	pla
	rti
