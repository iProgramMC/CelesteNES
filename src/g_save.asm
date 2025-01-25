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
; clobbers: temp1, temp2, temp3
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

; ** SUBROUTINE: save_file_level_end
; desc: Marks a level as complete and sets the collected strawberries flags.
.proc save_file_level_end
	; note: the Prologue can't be "finished" for now
	ldx levelnumber
	beq return
	dex
	
	; set the completed flag
	lda bitSet, x
	ora sf_completed
	sta sf_completed
	
	; note: this calls the checksum function
	jmp save_file_flush_berries

return:
	rts
	
bitSet:	.byte $01, $02, $04, $08, $10, $20, $40, $80
.endproc

; ** SUBROUTINE: save_file_flush_berries
; desc: Flushes the bitset of collected strawberries, and the death counter, to the save file.
.proc save_file_flush_berries
	lda levelnumber
	beq return
	
	asl
	tax
	lda sf_deaths-2, x
	clc
	adc deaths
	sta sf_deaths-2, x
	lda sf_deaths-1, x
	adc deaths+1
	sta sf_deaths-1, x
	
	ldx levelnumber
	dex
	lda strawberryBitOffsets, x
	lsr
	lsr
	lsr
	; that is the byte offset that we need to start writing to
	sta temp11
	
	; copy the strawberries to a temporary variable
	ldy #3
:	lda strawberries, y
	sta temp1, y
	dey
	bpl :-
	
	; temp1-4 have the bitset, temp5 will have a zero.
	lda #0
	sta temp5
	
	lda strawberryBitOffsets, x
	and #7
	beq noShifting
	tay
:	clc
	rol temp1
	rol temp2
	rol temp3
	rol temp4
	rol temp5
	dey
	bne :-

noShifting:
	; finally, OR with the save file's strawberry flags
	ldy temp11
	ldx #0
:	lda sf_berries, y
	ora temp1, x
	sta sf_berries, y
	iny
	inx
	cpx #5
	bne :-
	
	; done!! now calculate the checksum
	jmp save_file_calc_checksum
	
return:
	rts
strawberryBitOffsets:
	.byte 0    ; 20 - forsaken city
	.byte 20   ; 18 - old site
	.byte 38   ; 25 - celestial resort
	.byte 63   ; 29 - golden ridge
	.byte 92   ; 31 - mirror temple
	.byte 123  ; 0  - reflection
	.byte 123  ; 47 - summit
	.byte 170  ; 5  - core
.endproc

; ** SUBROUTINE: save_file_load_berries
; desc: Loads the berry flags from the save file.
.proc save_file_load_berries
	ldx levelnumber
	beq return
	dex
	
	lda save_file_flush_berries::strawberryBitOffsets, x
	sta temp11
	lsr
	lsr
	lsr
	
	; that is the byte offset that we need to start reading from
	tax
	ldy #0
:	lda sf_berries, x
	sta temp1, y
	inx
	iny
	cpy #5
	bne :-
	
	; shift that many times
	lda temp11
	and #7
	tay
	beq final
	
:	clc
	ror temp5
	ror temp4
	ror temp3
	ror temp2
	ror temp1
	dey
	bne :-
	
final:
	ldy #3
:	lda temp1, y
	sta sstrawberries, y
	dey
	bpl :-
	
return:
	rts
.endproc

