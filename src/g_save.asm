; Copyright (C) 2025 iProgramInCpp

; This module handles save file management.

; ** SUBROUTINE: save_file_verify
; desc: Verifies the save file for correctness.  If the save file is incorrect,
;       it is cleared.
.proc save_file_verify
	lda save_file_checksum+2
	pha
	lda save_file_checksum+1
	pha
	lda save_file_checksum+0
	pha
	
	jsr save_file_calc_checksum
	
	; compare each of the three bytes
	pla
	cmp save_file_checksum+0
	bne @invalidSaveFile_Pull2
	
	pla
	cmp save_file_checksum+1
	bne @invalidSaveFile_Pull1
	
	pla
	cmp save_file_checksum+2
	bne @invalidSaveFile
	
	lda save_file_final_bit
	cmp #$A5
	bne @invalidSaveFile
	
	; save file is valid!!
	rts

@invalidSaveFile_Pull2:
	pla
@invalidSaveFile_Pull1:
	pla
@invalidSaveFile:
	; save file is invalid!! So clear
	jmp save_file_wipe
.endproc

; ** SUBROUTINE: save_file_calc_checksum
; desc: Calculates the check sum for a save file.
.proc save_file_calc_checksum
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
	
	lda temp1
	eor #$5A
	sta save_file_checksum+0
	lda temp2
	eor #$A5
	sta save_file_checksum+1
	lda temp3
	eor #$E7
	sta save_file_checksum+2
	rts
.endproc

; ** SUBROUTINE: save_file_wipe
; desc: Wipes the current save file.
.proc save_file_wipe
	ldy #0
	tya
:	sta save_file_begin, y
	iny
	bne :-
	
	; write the name "Madeline" to the first save
	ldy #0
:	lda @defaultName, y
	sta sf_name, y
	iny
	cpy #8
	bne :-
	
	lda #$A5
	sta save_file_final_bit
	
	; finally, setup the checksum
	jmp save_file_calc_checksum

@defaultName:	.byte "Madeline"
.endproc
