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

; ** SUBROUTINE: far_call
; arguments:
;     Y - the bank index this code resides in
;     (temp2, temp1) - address of the function at hand.
; desc: Calls a function residing in a bank at $A000-$BFFF.  Cannot call functions residing
;       in other banks.
far_call:
	lda currA000bank
	pha                ; push the current bank number
	
	; change the bank
	lda #mmc3bk_prg1
	jsr mmc3_set_bank
	
	; bank switched, now call
	jsr @doTheCall
	
	; change the bank back
	pla
	tay
	lda #mmc3bk_prg1
	jmp mmc3_set_bank

@doTheCall:
	; redirect execution to (temp2, temp1)
	; this function SHOULD return. this is why we do the jsr indirection
	jmp (temp1)

; ** SUBROUTINE: mmc3_set_bank
; arguments:
;     A - the bank index to switch
;     Y - the bank number to switch to
; desc: Programs the MMC3 such that, after the execution of this subroutine, the
;       bank specified in Y is loaded at the bank address whose index is A.
; assumes: That this function does not run inside of an NMI.  To perform a bank
;          switch during an NMI, use mmc3_set_bank_nmi.

mmc3_set_bank:
	; note: I don't think we will switch the $A000-$BFFF bank during an NMI.
	cmp #mmc3bk_prg1
	bne :+
	sty currA000bank
:	ora #def_mmc3_bn  ; OR the default MMC3 configuration.
	sta mmc3_shadow   ; Store to the MMC3 shadow global variable.
	sta mmc3_bsel     ; Write this selector to the MMC3 chip.
	sty mmc3_bdat     ; Write the specified bank index to the MMC3 chip.
	rts
	
	; Explanation on why we also store the mmc3 selector in mmc3_shadow.
	;
	; This is done to avoid a race condition, in the case of game lag, that an
	; NMI might be fired while this function is executed, after the selector is
	; written, but before the data is written, and the NMI wants to perform a
	; bank switch of its own.
	;
	; Basically, the mmc3 shadow register is written back to the mmc3 chip when
	; exiting an NMI in case of such a race, thereby undoing the NMI's potential
	; effects.

; ** SUBROUTINE: mmc3_set_bank_nmi
; arguments: See mmc3_set_bank
; desc: Programs the MMC3 such that, after the execution of this subroutine, the
;       bank specified in Y is loaded at the bank address whose index is A.
;       This function restores the mmc3 selector from the shadow global variable
;       one this bank switch is performed.
; assumes: That this function is running inside an NMI. To perform a bank switch
;          during regular game execution, use mmc3_set_bank.

mmc3_set_bank_nmi:
	ora #def_mmc3_bn  ; OR the default MMC3 configuration.
	sta mmc3_bsel
	sty mmc3_bdat
	lda mmc3_shadow   ; Restore the old selector.
	sta mmc3_bsel
	rts

; ** SUBROUTINE: mmc3_horzarr
; desc: Sets the MMC1 to a horizontal arrangement (vertical mirroring) of nametables.
; clobbers: A
mmc3_horzarr:
	lda #0
	sta mmc3_mirror
	rts

; ** SUBROUTINE: mmc3_vertarr
; desc: Sets the MMC1 to a vertical arrangement (horizontal mirroring) of nametables.
; clobbers: A
;mmc3_vertarr:
;	lda #1
;	sta mmc3_mirror
;	rts

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
; NOTE: deprecated, Controller inputs are now read inside of NMI.
;read_cont:
;	lda p1_cont
;	sta p1_conto
;	lda #$01
;	sta apu_joypad1
;	; while the strobe bit is set, buttons will be continuously reloaded.
;	; this means that reading from joypad1 will always return the state
;	; of the A button, the first button.
;	sta p1_cont
;	lsr             ; A = 0 now
;	; stop the strobe by clearing joypad1. now we can start reading
;	sta apu_joypad1
;read_loop:
;	lda apu_joypad1
;	lsr a           ; bit 0 -> carry
;	rol p1_cont     ; carry -> bit 0, bit 7 -> carry
;	bcc read_loop
;	rts

; ** SUBROUTINE: rand
; arguments: none
; clobbers:  a
; returns:   a - the pseudorandom number
; desc:      generates a pseudo random number
rand:
	lda rng_state
	asl
	bcc @no_feedback
	eor #$21
@no_feedback:
	sta rng_state
	lda rng_state
	rts

; ** SUBROUTINE: oam_putsprite
; arguments:
;   a - attributes
;   y - tile number
;   [x_crd_temp] - y position of sprite
;   [y_crd_temp] - y position of sprite
; clobbers:  a, y
; desc:      inserts a sprite into OAM memory
oam_putsprite:
	pha             ; preserve the attributes
	tya
	pha             ; preserve the tile number
	ldy oam_wrhead  ; load the write head into Y
	lda y_crd_temp  ; store the Y coordinate into OAM
	sta oam_buf, y
	iny             ; move on to the tile number byte
	pla
	; flip bit 1 because I am lazy and don't want to make every tile index be odd...
	eor #$01
	sta oam_buf, y  ; store the tile number into OAM
	iny
	pla
	sta oam_buf, y  ; store the attributes into OAM
	iny
	lda x_crd_temp
	sta oam_buf, y  ; store the X coordinate into OAM
	iny
	sty oam_wrhead
	rts

; ** SUBROUTINE: load_palette
; arguments:
;   paladdr[0, 1] -- the address of the palette to upload
; clobbers: A, X
; assumes: PPUCTRL increment bit is zero (+1 instead of +32)
load_palette:
	lda #$3F
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldy #$00
@loop:
	lda (paladdr), y
	sta ppu_data
	iny
	cpy #$20
	bne @loop
	rts

; ** SUBROUTINE: ppu_nmi_off
; arguments: none
; clobbers: A
;ppu_nmi_off:
;	lda ctl_flags
;	and #(pctl_nmi_on ^ $FF)
;	sta ctl_flags
;	
;	sta ppu_ctrl
;	rts

; ** SUBROUTINE: ppu_nmi_on
; arguments: none
; clobbers: A
ppu_nmi_on:
	lda ctl_flags
	ora #pctl_nmi_on
	sta ctl_flags
	
	sta ppu_ctrl
	rts

; ** SUBROUTINE: soft_nmi_on
; desc: Enable racey NMIs in software.
; purpose: Most of the NMI routine is racey against the main thread. However, we want to run
;          audio every frame regardless of lag. This is why we block racey NMIs in software.
; clobbers: A
soft_nmi_on:
	lda #1
	sta nmienable
	rts

; ** SUBROUTINE: soft_nmi_off
; desc: Disable racey NMIs in software.
; clobbers: A
soft_nmi_off:
	lda #0
	sta nmienable
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

; ** SUBROUTINE: mmc3_initialize
; desc: Initializes the MMC3 mapper chip.
mmc3_initialize:
	; load PRG ROM banks
	lda #(def_mmc3_bn | 6)
	sta mmc3_bsel
	lda prgb_lvl0a
	sta mmc3_bdat
	
	lda #(def_mmc3_bn | 7)
	sta mmc3_bsel
	lda prgb_lvl0b
	sta mmc3_bdat
	
	; note: don't need to load default banks, the title screen init code will do that for me.
	
	jsr mmc3_horzarr
	
	lda #%10000000   ; enable PRG RAM, disable write protection
	sta mmc3_pram
	
	sta mmc3_irqdi   ; disable IRQs for now
	
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
	
	jsr mmc3_initialize
	
	; TODO: other setup here
	
	jsr vblank_wait  ; second vblank wait
	
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
	
	jsr ppu_nmi_on
	cli
	
; ** MAIN LOOP
main_loop:
	jsr soft_nmi_off
	jsr game_update
	jsr soft_nmi_on
	jsr nmi_wait
	jmp main_loop

.include "update.asm"
.include "gam_main.asm"
.include "audio/audio.asm"
.include "nmi.asm"

gm_clear_aux:
	stx camlefthi
	stx plrtrahd
	stx plrstrawbs
	stx scrollsplit
	stx dialogsplit
	stx camera_y_sub
	stx stamflashtm
	stx camleftlo	
	rts

.segment "PRG_VECS"
	.word nmi_
	.word reset
	.word irq