; Copyright (C) 2024 iProgramInCpp

gamemode_title:
	lda #ts_1stfr
	bit titlectrl                  ; might need to update the screen buffer
	bne gamemode_title_update_NEAR ; in PRG_TTLE
	
	; have to reset audio data because DPCM samples are loaded in at $C000
	; and we want to use that bank for title screen and overworld data.
	; We have 8K at our disposal.
	jsr aud_reset
	
	; Load said bank.
	lda #mmc3bk_prg0
	ldy #prgb_ttle
	jsr mmc3_set_bank
	
	jmp gamemode_title_init_FAR

gamemode_title_update_NEAR:
	jmp gamemode_title_update_FAR

tl_gameswitch:
	lda #gm_game
	sta gamemode
	lda #0
	sta gamectrl
	sta musictable
	sta musictable+1
	jsr gm_set_level
	rts

tl_prolswitch:
	lda #gm_prologue
	sta gamemode
	lda #0
	sta prolctrl
	rts
