; Copyright (C) 2025 iProgramInCpp

; This module handles save file management.

; ** SUBROUTINE: save_file_verify
; desc: Verifies the save file for correctness.  If the save file is incorrect,
;       it is cleared.
.proc save_file_verify
	lda #0
	sta temp1
	sta temp2
	sta temp3
	
	ldy #3
	
@loop:
	; NOTE: The "clc"s might not actually be required..
	lda temp1
	clc
	adc save_file_begin+0, y
	sta temp1
	
	lda temp2
	clc
	adc save_file_begin+1, y
	sta temp2
	
	lda temp3
	clc
	adc save_file_begin+2, y
	sta temp3
	
	iny
	iny
	iny
	cpy #<save_file_final_bit
	bne @loop
	
	; compare each of the three bytes
	lda temp1
	eor #$5A
	cmp save_file_checksum+0
	bne @invalidSaveFile
	
	lda temp2
	eor #$A5
	cmp save_file_checksum+1
	bne @invalidSaveFile
	
	lda temp3
	eor #$E7
	cmp save_file_checksum+2
	bne @invalidSaveFile
	
	lda save_file_final_bit
	cmp #$A5
	bne @invalidSaveFile
	
	; save file is valid!!
	rts
	
@invalidSaveFile:
	; save file is invalid!! So clear
	ldy #0
	tya
:	sta save_file_begin, y
	iny
	bne :-
	
	; of course, setup the checksum correctly
	lda #$5A
	sta save_file_checksum+0
	lda #$A5
	sta save_file_checksum+1
	sta save_file_final_bit
	lda #$E7
	sta save_file_checksum+2
	rts
.endproc
