; Copyright (C) 2024 iProgramInCpp

; Dialog interface
; This allows to call into dialog functions by dynamically switching the loaded bank to the dialog's.
;
; The dialog must not reside at the address where DPCM samples reside.

dlg_update_g:
	lda #<dlg_update_d
	sta temp1
	lda #>dlg_update_d
	sta temp1+1
	ldy #prgb_dial
	jmp far_call

; ** SUBROUTINE: dlg_begin_cutscene_g
; desc: Initiates a cutscene.
; parameters:
;     A - The index of the entity the player is engaging with.
;     X - The low byte of the address of the cutscene data to load.
;     Y - The high byte of the address of the cutscene data to load.
dlg_begin_cutscene_g:
	sta dlg_entity
	stx dlg_cutsptr
	sty dlg_cutsptr+1
	
	lda #<dlg_begin_cutscene_d
	sta temp1
	lda #>dlg_begin_cutscene_d
	sta temp2
	ldy #prgb_dial
	jmp far_call
