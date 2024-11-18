; Copyright (C) 2024 iProgramInCpp

gamemode_overwd_update_NEAR:
	jmp gamemode_overwd_update_FAR

; ** GAMEMODE: gamemode_overwd
gamemode_overwd:
	lda #os_1stfr
	bit owldctrl
	bne gamemode_overwd_update_NEAR
	
	jsr aud_reset
	
	; Load the title bank.
	lda #mmc3bk_prg0
	ldy #prgb_ttle
	jsr mmc3_set_bank
	
	jmp gamemode_overwd_init_FAR
