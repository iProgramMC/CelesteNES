; Copyright (C) 2024 iProgramInCpp

.org $C000

; ** SUBROUTINE: vblank_wait
; arguments: none
; clobbers: A
vblank_wait:
	lda #$00
	bit ppu_status
	bpl vblank_wait  ; check bit 7, equal to zero means not in vblank
	rts

; ** SUBROUTINE: nmi_wait
; arguments: none
; clobbers: A
nmi_wait:
	lda nmicount
:	cmp nmicount
	beq :-
	rts

; ** SUBROUTINE: read_cont
; arguments: none
; clobbers:  A
; desc:      reads controller input from the player 1 port
read_cont:
	lda p1_cont
	sta p1_conto
	lda #$01
	sta apu_joypad1
	; while the strobe bit is set, buttons will be continuously reloaded.
	; this means that reading from joypad1 will always return the state
	; of the A button, the first button.
	sta p1_cont
	lsr             ; A = 0 now
	; stop the strobe by clearing joypad1. now we can start reading
	sta apu_joypad1
read_loop:
	lda apu_joypad1
	lsr a           ; bit 0 -> carry
	rol p1_cont     ; carry -> bit 0, bit 7 -> carry
	bcc read_loop
	rts

; ** SUBROUTINE: rand
; arguments: none
; clobbers:  a
; returns:   a - the pseudorandom number
; desc:      generates a pseudo random number
rand:
	lda rng_state
	asl
	bcc no_feedback
	eor #$21
no_feedback:
	sta rng_state
	lda rng_state
	rts

; ** SUBROUTINE: mmc1_selsprbank
; arguments:
;   a - bank offset in 4K blocks
mmc1_selsprbank:
	sta mmc1_chr0
	lsr
	sta mmc1_chr0
	lsr
	sta mmc1_chr0
	lsr
	sta mmc1_chr0
	lsr
	sta mmc1_chr0
	rts

; ** SUBROUTINE: mmc1_selcharbank
; arguments:
;   a - bank offset in 4K blocks
mmc1_selcharbank:
	sta mmc1_chr1
	lsr
	sta mmc1_chr1
	lsr
	sta mmc1_chr1
	lsr
	sta mmc1_chr1
	lsr
	sta mmc1_chr1
	rts

; ** SUBROUTINE: mmc1_selprgbank
; arguments:
;   a - bank offset in 16K blocks
mmc1_selprgbank:
	sta mmc1_prg
	lsr
	sta mmc1_prg
	lsr
	sta mmc1_prg
	lsr
	sta mmc1_prg
	lsr
	sta mmc1_prg
	rts

; ** SUBROUTINE: mmc1_control
; arguments:
;   a - the value to send to the control register
; desc: Sets the internal control register of the MMC1 mapper.
mmc1_control:
	sta mmc1_ctrl
	lsr
	sta mmc1_ctrl
	lsr
	sta mmc1_ctrl
	lsr
	sta mmc1_ctrl
	lsr
	sta mmc1_ctrl
	rts

; ** SUBROUTINE: mmc1_horzarr
; desc: Sets the MMC1 to a horizontal arrangement (vertical mirroring) of nametables.
; clobbers: A
mmc1_horzarr:
	; bits:
	; bits 0-1: mirroring (%10 for vert mirr, %11 for horz mirr)
	; bits 2-3: PRG ROM bank mode. fix last bank at $C000 and switch 16K bank at $8000
	; bit  4:   CHR ROM bank mode (1: switch two separate 4K banks)
	lda #%11110
	jmp mmc1_control

; ** SUBROUTINE: mmc1_vertarr
; desc: Sets the MMC1 to a vertical arrangement (horizontal mirroring) of nametables.
; clobbers: A
mmc1_vertarr:
	lda #%11111
	jmp mmc1_control

; ** SUBROUTINE: oam_putsprite
; arguments:
;   a - attributes
;   y - tile number
;   [x_crd_temp] - y position of sprite
;   [y_crd_temp] - y position of sprite
; clobbers:  a, x
; desc:      inserts a sprite into OAM memory
oam_putsprite:
	ldx oam_wrhead  ; load the write head into X
	pha             ; push the tile number
	lda y_crd_temp  ; store the Y coordinate into OAM
	sta oam_buf, x
	inx
	tya
	sta oam_buf, x  ; store the attributes into OAM
	inx
	pla
	sta oam_buf, x  ; store the tile number into OAM
	inx
	lda x_crd_temp
	sta oam_buf, x  ; store the X coordinate into OAM
	inx
	stx oam_wrhead
	rts

; ** SUBROUTINE: load_palette
; arguments:
;   y - the offset from the last page where the palette resides
; clobbers: A, X
; assumes: PPUCTRL increment bit is zero (+1 instead of +32)
load_palette:
	lda #$3F
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldx #$00
load_palette_loop:
	lda palettepage, y
	sta ppu_data
	inx
	iny
	cpx #$20
	bne load_palette_loop
	rts

; ** SUBROUTINE: ppu_nmi_off
; arguments: none
; clobbers: A
ppu_nmi_off:
	lda ctl_flags
	and #(pctl_nmi_on ^ $FF)
	sta ctl_flags
	
	sta ppu_ctrl
	rts

; ** SUBROUTINE: ppu_nmi_on
; arguments: none
; clobbers: A
ppu_nmi_on:
	lda ctl_flags
	ora #pctl_nmi_on
	sta ctl_flags
	
	sta ppu_ctrl
	rts

; ** SUBROUTINE: ppu_rstaddr
; arguments: none
; clobbers:  A
; desc:      writes $2000 to PPUADDR in vblank or after a render disable section
ppu_rstaddr:
	lda #$20
	sta ppu_addr
	lda #$00
	sta ppu_addr
	rts

; ** SUBROUTINE: ppu_loadaddr
; arguments:
;   x - low 8 bits of address
;   y - high 8 bits of address
; clobbers: none
; assumes:  none
; desc:     loads a 16-bit address into PPUADDR
ppu_loadaddr:
	sty ppu_addr
	stx ppu_addr
	rts

; ** SUBROUTINE: ppu_wrstring
; arguments:
;   x - low 8 bits of address
;   y - high 8 bits of address
;   a - length of string
; assumes:  - PPUADDR was programmed to the PPU dest address
;             writes can happen (in vblank or rendering disabled)
;           - that the string does not straddle a page
;             boundary (256 bytes)
; desc:     copies a string from memory to the PPU
; clobbers: PPUADDR, all regs
ppu_wrstring:
	stx wr_str_temp       ; store the address into a temporary
	sty wr_str_temp + 1   ; indirection slot
	ldy #$00
	tax                   ; A cannot be incremented with 1 instruction
ppu_wrsloop:              ; so use X for that purpose
	lda (wr_str_temp), y  ; use that indirection we setup earlier
	sta ppu_data
	iny
	dex
	bne ppu_wrsloop       ; if X != 0 print another
	rts

; ** SUBROUTINE: clear_nt
; arguments: a - high 8 bits of nametable address (20,24,28,2C)
; clobbers:  a, x, y
; assumes:   rendering is disabled (not enough bandwidth to clear the entire nametable during vblank)
; desc:      clears 1KB of RAM in PPU memory with video output disabled
clear_nt:
	sta ppu_addr
	lda #$00
	sta ppu_addr
	lda #blank_tile  ; clear all 1K of vram to 0x20 - the blank tile
	ldx #$00
	ldy #$00
inner_loop:
	sta ppu_data
	iny
	bne inner_loop
	inx
	cpx #$04
	bcc inner_loop   ; jump to the inner loop because y==0 guaranteed
                     ; we didn't branch because carry was set so y==0
	rts

; ** ENTRY POINT
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
	sta $000, x
	sta $100, x
	sta $200, x
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x
	sta $700, x
	inx
	bne reset_clrmem
	
	lda #$80
	sta mmc1_ctrl  ; reset mmc1 shift register
	
	jsr mmc1_horzarr
	lda #bank_spr
	jsr mmc1_selsprbank
	
	; TODO: other setup here
	
	jsr vblank_wait  ; second vblank wait
	
	ldy #(init_palette - palettepage)
	jsr load_palette ; move palette to palette RAM
	
	lda #$20         ; clear the two nametables
	jsr clear_nt
	lda #$24
	jsr clear_nt
	
	ldy #def_ppu_msk ; show background & sprites
	sty ppu_mask     ; set the ppu mask
	ldy #(pctl_sprsz | pctl_bgpat | pctl_nmi_on) ; set sprite size (8x16), bg pattern addr and NMI enable
	sty ctl_flags
	sty ppu_ctrl
	
	jsr aud_init
	
	ldy #gm_title
	;ldy #gm_game
	sty gamemode     ; set title screen mode
	
	ldy #$ac
	sty rng_state    ; initialize rng seed
	
	jsr vblank_wait  ; one final vblank wait
	cli
	
; ** MAIN LOOP
main_loop:
	jsr ppu_nmi_off
	jsr game_update
	jsr ppu_nmi_on
	jsr nmi_wait
	jmp main_loop

.include "update.asm"
.include "audio.asm"

.res miscdata - *, $FF
.include "o_mtndat.asm"
.include "t_data.asm"

level_table:
	.word level0
	.word level1 ; 1
	.word level0 ; 2
	.word level0 ; 3
	.word level0 ; 4
	.word level0 ; 5
	.word level0 ; 6
	.word level0 ; 7
level_table_end:

level_banks:
	.byte $00
	.byte $01
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00
level_banks_end:

level_table_size = level_table_end - level_table

.res palettepage - *, $FF
init_palette:
	.byte $0f,$20,$10,$00 ; grey tiles
	.byte $0f,$37,$16,$06 ; brown tiles
	.byte $0f,$20,$21,$11 ; blue tiles
	.byte $0f,$39,$29,$19 ; green tiles
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$36,$16,$06 ; red/strawberry sprite
	.byte $0f,$20,$21,$11 ; blue sprite
	.byte $0f,$30,$29,$09 ; green/refill sprite
owld_palette:
	.byte $0f,$0c,$01,$00
	.byte $0f,$0c,$10,$30
	.byte $0f,$0c,$00,$10
	.byte $0f,$00,$10,$30
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$36,$16,$06 ; red/strawberry sprite
	.byte $0f,$31,$21,$01 ; blue sprite
	.byte $0f,$30,$29,$09 ; green/refill sprite

.res $FFFA - *, $FF
	.word nmi
	.word reset
	.word irq     ; unused
