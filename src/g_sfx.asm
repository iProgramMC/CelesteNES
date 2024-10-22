; Copyright (C) 2024 iProgramInCpp

gm_jump_sfx:
	lda #1
	ldx #FAMISTUDIO_SFX_CH0
	jmp famistudio_sfx_play

gm_dash_sfx:
	lda #0
	ldx #FAMISTUDIO_SFX_CH1
	jmp famistudio_sfx_play

gm_death_sfx:
	lda #0
	ldx #FAMISTUDIO_SFX_CH1
	jmp famistudio_sfx_play


