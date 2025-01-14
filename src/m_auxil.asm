; Copyright (C) 2024 iProgramInCpp

; This file belongs in the main segment, and is located between the two IRQ alignments 
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
	; redirect execution to (farcalladdr)
	; this function SHOULD return. this is why we do the jsr indirection
	jmp (farcalladdr)

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

; ** SUBROUTINE: load_palette
; arguments:
;   paladdr[0, 1] -- the address of the palette to upload
; clobbers: A, X
; assumes: PPUCTRL increment bit is zero (+1 instead of +32)
load_palette:
	lda #$3F
	ldy #$00
	sta ppu_addr
	sty ppu_addr
@loop:
	lda (paladdr), y
	sta ppu_data
	iny
	cpy #$20
	bne @loop
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

; ** SUBROUTINE: ppu_nmi_on
; arguments: none
; clobbers: A
ppu_nmi_on:
	lda ctl_flags
	ora #pctl_nmi_on
	sta ctl_flags
	sta ppu_ctrl
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
	lda prgb_lvl0a
	sta mmc3_bdat
	
	; note: don't need to load default banks, the title screen init code will do that for me.
	
	;jsr mmc3_horzarr
	lda #0
	sta mmc3_mirror
	sta mmc3_irqdi   ; disable IRQs for now
	
	lda #%10000000   ; enable PRG RAM, disable write protection
	sta mmc3_pram
	rts

irqdelays:	.byte 2, 2, 4
