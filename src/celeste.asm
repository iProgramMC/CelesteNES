;
;  ~=~=~=~=   C E L E S T E   N E S =~=~=~=~
;    Copyright (C) 2024-2025 iProgramInCpp
;

; This file ties everything together.

.feature string_escapes
.feature line_continuations

.segment "INES"
.byte $4E,$45,$53,$1A
.byte 8         ; size of prg rom in 16kb units
.byte 16        ; size of chr rom in 8kb units
.byte %01000010 ; flags 6 -- switchable nametable mirroring, mapper 4, battery present
.byte %00001000 ; flags 7 -- NES 2.0 header
.byte %00000000 ; mapper msb / submapper
.byte %00000000 ; prg-rom / chr-rom size msb
.byte %01110111 ; prg-ram / eeprom size (64 << 7 == 8192) (note)
.byte %00000000 ; chr-ram size
.byte %00000000 ; cpu/ppu timing mode
.byte %00000000 ; vs. system type
.byte %00000000 ; misc ROMs
.byte %00000000 ; default exp device

; note: not all 8K bytes of battery backed RAM are actually *used*,
; (only 256 bytes) but it's cheapest for hardware manufacturers to
; just hook up all 8K of PRG to the same battery backup chip

.include "defines.asm"
.include "globals.asm"

.include "d_macros.asm"

.include "level0/bank_0.asm"
.include "level1/bank_0.asm"
.include "level1/bank_1.asm"
.include "level1/bank_2.asm"
.include "level1/bank_3.asm"
.include "level2/bank_0.asm"
.include "level2/bank_1.asm"
.include "level2/bank_2.asm"
.include "level2/bank_3.asm"
.include "level2/bank_4.asm"
.include "level2/bank_5.asm" ; NOTE: Actually the same as PRG_DIAL for now!

.include "prg_xtra.asm"
.include "prg_game.asm"
.include "prg_main.asm"
.include "prg_ttle.asm"
.include "prg_dial.asm"
.include "prg_paus.asm"

; ** Global Sprite Banks
.segment "CHR_SPMAD"
.incbin  "chr/sp_player.chr"

.segment "CHR_DPLDI"
.incbin  "chr/sp_plrdie.chr"

.segment "CHR_SPGEN"
.incbin  "chr/sp_gener.chr"

.segment "CHR_SPANI"
.incbin  "chr/sp_anim.chr"

; ** Level Specific Sprite Banks
.segment "CHR_SLVL0"
.incbin  "chr/sp_level0.chr"
.segment "CHR_SLV0B"
.incbin  "chr/sp_level0b.chr"

.segment "CHR_SLVL1"
.incbin  "chr/sp_level1.chr"
.segment "CHR_SLV1B"
.incbin  "chr/sp_level1b.chr"
.segment "CHR_SLV1C"
.incbin  "chr/sp_level1c.chr"

.segment "CHR_SLVL2"
.incbin  "chr/sp_level2.chr"
.segment "CHR_SLV2B"
.incbin  "chr/sp_level2b.chr"
.segment "CHR_PAPH1"
.incbin  "chr/sp_level2c.chr"
.incbin  "chr/sp_level2cb.chr"
.incbin  "chr/sp_level2d.chr"
.incbin  "chr/sp_level2e.chr"
.segment "CHR_PAPH2"
.incbin  "chr/sp_level2f.chr"
.incbin  "chr/sp_level2g.chr"
.incbin  "chr/sp_level2h.chr"
.incbin  "chr/sp_level2i.chr"
.segment "CHR_PAPH3"
.incbin  "chr/sp_level2j.chr"
.segment "CHR_PAPH4"
.incbin  "chr/sp_level2k.chr"
.segment "CHR_SLV2L"
.incbin  "chr/sp_level2lm.chr"
.segment "CHR_SLV2N"
.incbin  "chr/sp_level2n.chr"

.segment "CHR_UN101" ; UNUSED

; ** Level Tilesets
.segment "CHR_BGTTL"
.incbin  "chr/b_title.chr"

.segment "CHR_BGOWD"
.incbin  "chr/b_overw.chr"

.segment "CHR_BG000"
.incbin  "chr/b_lvl0.chr"

.segment "CHR_BG001"
.incbin  "chr/b_lvl1.chr"

.segment "CHR_BG002"
.incbin  "chr/b_lvl2.chr"

.segment "CHR_BG003"
.incbin  "chr/b_lvl2b.chr" ; contains the memorial and infokiosk tiles
.incbin  "chr/b_lvl2c.chr" ; contains the mirror and stone tiles

.segment "CHR_BG004"
.incbin  "chr/b_lvl2d.chr" ; contains the dream block (full-white)
.incbin  "chr/b_lvl2e.chr" ; contains the dream block (disabled)

.segment "CHR_BG005"
.incbin  "chr/b_lvl2f.chr" ; contains the dream block (dither stage 1)
.incbin  "chr/b_lvl2g.chr" ; contains the dream block (dither stage 2)

.segment "CHR_BG006"
.incbin  "chr/b_lvl2h.chr" ; contains the dream block (dither stage 3)

.segment "CHR_CASS1"
.incbin  "chr/b_cass1.chr"
.segment "CHR_CASS2"
.incbin  "chr/b_cass2.chr"

; ** Complete Screens
.segment "CHR_LV1CA"
.incbin  "chr/b_ch1ca.chr"
.segment "CHR_LV1CB"
.incbin  "chr/b_ch1cb.chr"

.segment "CHR_LV2CA"
;.incbin  "chr/b_ch2ca.chr"
.segment "CHR_LV2CB"
;.incbin  "chr/b_ch2cb.chr"

.segment "CHR_SL1CO"
.incbin  "chr/sp_ch1c.chr"
.segment "CHR_SL2CO"
;.incbin  "chr/sp_ch1c.chr"

; ** User Interface
.segment "CHR_SPOWD"
.incbin  "chr/sp_overw.chr"

.segment "CHR_PAUSE"
.incbin  "chr/sp_pause.chr"

.segment "CHR_PCARD"
.incbin  "chr/b_postcard.chr"

.segment "CHR_OPTNS"
.incbin  "chr/b_options.chr"

; ** Dialog Pattern Tables
.segment "CHR_DMAIN"
.incbin  "chr/d_main.chr"
.segment "CHR_DCNTR"
.incbin  "chr/d_count.chr"

.segment "CHR_DMOME"
.incbin  "chr/d_mome.chr"
.segment "CHR_DBADE"
.incbin  "chr/d_bade.chr"
.segment "CHR_DMADE"
.incbin  "chr/d_made.chr"
.segment "CHR_DTHEO"
.incbin  "chr/d_theo.chr"
.segment "CHR_DGRAN"
.incbin  "chr/d_gran.chr"
