; Copyright (C) 2024 iProgramInCpp

; This 16 byte code sequence is duplicated in every bank to prevent
; MMC1's unpredictable startup state from screwing us over.
;
; NOTE: this particular code segment will actually reside at $FFF0 if executed !!
.res $BFF0 - *, $FF
	sei
	ldx #$FF
	txs
	stx $FFF2   ; writing $80 - $FF anywhere in the range $8000 - $FFFF resets the MMC1 chip
	jmp reset

.res $BFFA - *, $FF
.word nmi
.word $FFF0
.word irq
