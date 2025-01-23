; Copyright (C) 2024 iProgramInCpp

gamemode_prologue_update_NEAR:
	jmp gamemode_prologue_update_FAR

gamemode_prologue:
	lda #ps_1stfr
	bit prolctrl
	bne gamemode_prologue_update_NEAR
	
	jsr aud_reset
	
	; Load the title bank.
	lda #mmc3bk_prg0
	ldy #prgb_ttle
	jsr mmc3_set_bank
	
	jmp gamemode_prologue_init_FAR
