; Copyright (C) 2024 iProgramInCpp

.segment "PRG_MAIN"

.include "irq.asm"

; ** SUBROUTINE: oam_dma_and_read_cont
; desc: Performs OAM DMA, and reads the player 1 controller.
; This is done to avoid the DMC DMA process corrupting controller reads.
;
; note: This must all be located inside of one page. There is a one cycle
; cost associated with page boundary crosses, which is important because
; it will desync our read process.
oam_dma_and_read_cont:
	; back up old controller states
	lda p1_cont
	sta p1_conto
	lda p1_cont+1
	sta p1_conto+1
	
	lda #$01
	sta apu_joypad1
	; while the strobe bit is set, buttons will be continuously reloaded.
	; this means that reading from joypad1 will always return the state
	; of the A button, the first button.
	sta p1_cont
	lsr             ; A = 0 now
	; stop the strobe by clearing joypad1. now we can start reading
	sta apu_joypad1
	
	; but before reading, perform OAM DMA to align ourselves on a proper cycle
	lda #0
	sta oam_addr
	lda #>oam_buf     ; load the high byte of the OAM DMA address
	sta apu_oam_dma   ; and perform the DMA!
	
	; thanks NESDEV wiki! :D
	ldx #1             ; get put          <- strobe code must take an odd number of cycles total
	stx p1_cont        ; get put get      <- buttons must be in the zeropage
	stx p1_cont+1      ; get put get
	stx p1_cont+1      ; get put get      <- redundant write to align to a put cycle
	stx apu_joypad1    ; put get put get
	dex                ; put get
	stx apu_joypad1    ; put get put get
	
	; read the first byte
@loop:
	lda apu_joypad1    ; put get put GET
	and #3             ; put get
	cmp #1             ; put get
	rol p1_cont        ; put get put get put
	bcc @loop          ; get put [get]    <- this branch must not be allowed to cross a page
	
	; read the second byte
	lda $0             ; get put get      <- redundant read to align on a PUT cycle
@loop1:
	lda apu_joypad1    ; put get put GET
	and #3             ; put get
	cmp #1             ; put get
	rol p1_cont+1      ; put get put get put
	bcc @loop1         ; get put [get]    <- this branch must also not be allowed to cross a page
	
	; whew, finally don't need to align cycles...
	
	; check the second byte's 4 LSBs.
	;
	; * the S-NES controller reports them as zero.
	; * the official NES controller reports overread bits as 1, so it'd be $FF
	; * unofficial NES controllers might report overread bits as zero. no harm^
	;
	; ^- the controller may be detected as an S-NES controller, however, none of
	;    the SNES controller's associated buttons will be pressed.
	;
	;    the problem is how do we tell unofficial NES controllers from official
	;    S-NES controllers? On the title screen we might allow players to override
	;    the S-NES control scheme picked by default.
	lda #%00001111
	and p1_cont+1
	pha               ; push it because we'll want to check later
	
	beq @mayBeSnesController
	
	; is definitely not an SNES controller, so zero out the high byte
	lda #0
	sta p1_cont+1
	sta p1_conto+1
	
@mayBeSnesController:
	; check if we already determined a control scheme
	; note: soon, this might be saved in battery backed RAM
	lda ctrlscheme
	bne @returnPopSig
	
	; is it equal to zero?
	pla               ; pop the signature nybble
	bne @isNotSnesController
	
	; yes, therefore this is either an SNES controller or third-party NES
	; controller.
	lda #cns_snes
	sta ctrlscheme
	rts
	
@isNotSnesController:
	; the signature was not zero, therefore we can probably assume that this
	; is an NES controller.  If you plugged in a weird peripheral, what are
	; you doing?!?
	lda #cns_console
	sta ctrlscheme
	rts
	
@returnPopSig:
	pla               ; pop the signature nybble
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
	; explainer:
	; during a cold boot, NMIs are disabled, so the NMI will never hit
	; during a warm boot, since I doubt anyone will be able to reset the
	; console that often and that many times.
	;
	; during reset, only one opcode can be executed reliably
	inc nmi_disable
	
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
	;jsr vblank_wait
	
	; clear $01 - $FF ($00 must remain different from 0 until the reset sequence finishes)
	lda #0
	ldx #1
:	sta $000, x
	inx
	bne :-

	; clears all 2KB of work RAM, except the zero page
:	sta $100, x
	sta $200, x
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x
	sta $700, x
	inx
	bne :-
	
	jsr mmc3_initialize
	
	; TODO: other setup here
	
	bit ppu_status   ; clear status
	jsr vblank_wait
	
	ldy #<init_palette
	jsr load_palette ; move palette to palette RAM
	
	ldy #def_ppu_msk ; show background & sprites
	sty ppu_mask     ; set the ppu mask
	ldy #(pctl_sprsz | pctl_sppat | pctl_nmi_on) ; set sprite size (8x16), bg pattern addr and NMI enable
	sty ctl_flags
	sty ppu_ctrl
	
	jsr aud_init
	
	ldy #gm_title
	sty gamemode     ; set title screen mode
	
	ldy #$ac
	sty rng_state    ; initialize rng seed
	
	jsr vblank_wait  ; one final vblank wait
	
	jsr aud_load_sfx
	
	lda #0
	sta nmi_disable
	jsr ppu_nmi_on
	cli
	
; ** MAIN LOOP
main_loop:
	jsr soft_nmi_off
	jsr game_update
	jsr soft_nmi_on
	;jsr debug_profiler
	jsr nmi_wait
	jmp main_loop

debug_profiler:
	lda #$FF
	sta ppu_mask
	ldy #$90
:	dey
	bne :-
	lda #def_ppu_msk
	sta ppu_mask
	rts

.include "update.asm"
.include "gam_main.asm"
.include "audio/audio.asm"
.include "nmi.asm"
.include "math.asm"

.segment "PRG_VECS"
	.word nmi_
	.word reset
	.word irq