; Copyright (C) 2024 iProgramInCpp

; Define an external config for FamiStudio
FAMISTUDIO_CFG_EXTERNAL = 1

.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  FMSRAM
.define FAMISTUDIO_CA65_CODE_SEGMENT PRG_MAIN

FAMISTUDIO_CFG_NTSC_SUPPORT   = 1 ; no PAL support yet
FAMISTUDIO_CFG_DPCM_SUPPORT   = 1
FAMISTUDIO_CFG_THREAD         = 1 ; to be able to call FamiStudio SFX routines from main thread

; things defined by the demo. I don't care about most of these
FAMISTUDIO_CFG_SFX_SUPPORT    = 1 
FAMISTUDIO_CFG_SFX_STREAMS    = 2
FAMISTUDIO_CFG_EQUALIZER      = 1
FAMISTUDIO_USE_VOLUME_TRACK   = 1
FAMISTUDIO_USE_PITCH_TRACK    = 1
FAMISTUDIO_USE_SLIDE_NOTES    = 1
FAMISTUDIO_USE_VIBRATO        = 1
FAMISTUDIO_USE_ARPEGGIO       = 1
FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1
FAMISTUDIO_USE_RELEASE_NOTES  = 1
FAMISTUDIO_USE_DUTYCYCLE_EFFECT = 1
FAMISTUDIO_USE_VOLUME_SLIDES = 1
;FAMISTUDIO_USE_DELTA_COUNTER = 1
;FAMISTUDIO_USE_PHASE_RESET = 1
;FAMISTUDIO_USE_INSTRUMENT_EXTENDED_RANGE = 1
FAMISTUDIO_USE_FAMITRACKER_TEMPO = 1 ; bruh
FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS = 1 ; bruuuh
FAMISTUDIO_DPCM_OFF           = $c000

.include "famistudio.asm"
;.include "famistudio_null.asm"

.include "sfx.asm"

; ** SUBROUTINE: aud_run
; desc: Run a 1/60 tick of the audio engine.
;
; note: MUST run in an interrupt-context!
aud_run:
	; load the music bank
	lda #(mmc3bk_prg1 | def_mmc3_bn)
	sta mmc3_bsel
	lda musicbank
	sta mmc3_bdat
	
	jsr famistudio_update
	
	lda #(mmc3bk_prg1 | def_mmc3_bn)
	sta mmc3_bsel
	lda currA000bank
	sta mmc3_bdat
	
	; Restore the old selector
	lda mmc3_shadow
	sta mmc3_bsel
	rts

; ** SUBROUTINE: aud_init
; desc: Initializes the audio engine.
aud_init:
	lda #1 ; NTSC
	ldx #0 ; no music data yet
	ldy #0
	jmp famistudio_init

; ** SUBROUTINE: aud_load_sfx
; desc: Loads the sound effect table.
aud_load_sfx:
	ldx #<game_sfx
	ldy #>game_sfx
	jmp famistudio_sfx_init

; ** SUBROUTINE: aud_reset
; desc: Removes all music from playback.
aud_reset:
	ldx #<music_data_blank
	ldy #>music_data_blank
	lda #1
	jmp famistudio_init

.include "blank.asm"
