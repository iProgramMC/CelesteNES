; Copyright (C) 2025 iProgramInCpp

.proc postcard
	ldx #<postcard_XTRA
	ldy #>postcard_XTRA
	lda #prgb_xtra
	jmp far_call2
.endproc
