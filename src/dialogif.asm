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

dlg_test_g:
	lda #<dlg_test_d
	sta temp1
	lda #>dlg_test_d
	sta temp1+1
	ldy #prgb_dial
	jmp far_call

