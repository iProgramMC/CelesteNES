
; Addresses
ppu_ctrl    = $2000
ppu_mask    = $2001
ppu_status  = $2002
oam_addr    = $2003
oam_data    = $2004	
ppu_scroll  = $2005
ppu_addr    = $2006
ppu_data    = $2007
palette_mem = $3F00
apu_dmc_cfg = $4010
apu_frctr   = $4017

; Constants
apu_irq_off = $40
lastpage    = $FF00

.org $8000

nmi:
	rti

vblank_wait:
	bit ppu_status
	bpl vblank_wait  ; check bit 7, equal to zero means not in vblank
	rts

; arguments:
;   y - the offset from the last page where the palette resides
; clobbers: a, x
; assumes: PPUCTRL increment bit is zero (+1 instead of +32)
load_palette:
	lda #$3F
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldx #$00
load_palette_loop:
	lda lastpage, x
	sta ppu_data
	inx
	iny
	cpx #$20
	bne load_palette_loop
	rts

reset:
	sei              ; disable interrupts
	cld              ; clear decimal flag - not really required
	ldx #apu_irq_off ; disable APU IRQ
	stx apu_frctr
	ldx #$ff         ; set stack pointer to 0xff
	txs
	inx              ; X = 0
	stx ppu_ctrl     ; disable PPU NMI
	stx ppu_mask     ; disable rendering
	stx apu_dmc_cfg  ; disable APU DMC IRQs
	bit ppu_status   ; clear status
	jsr vblank_wait
	
	ldx #$00
reset_clrmem:
	; clears all 2KB of work RAM. that includes the zero page.
	sta $100, x
	sta $200, x
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x
	sta $700, x
	inx
	bne reset_clrmem
	; TODO: other setup here
	jsr vblank_wait  ; second vblank wait
	
	ldy init_palette - lastpage
	jsr load_palette ; move palette to palette RAM
	
the:jmp the


.res lastpage - *, $FF
init_palette:
	.byte $0f,$20,$10,$00 ; grey tiles
	.byte $0f,$37,$16,$06 ; brown tiles
	.byte $0f,$20,$21,$11 ; blue tiles
	.byte $0f,$39,$29,$19 ; green tiles
	.byte $0f,$15,$37,$21 ; player sprite colors
	.byte $0f,$00,$00,$00 ; unused sprite 1
	.byte $0f,$00,$00,$00 ; unused sprite 2
	.byte $0f,$00,$00,$00 ; unused sprite 3

.res $FFFA - *, $FF
	.word nmi
	.word reset
	.word $fff0   ; unused
