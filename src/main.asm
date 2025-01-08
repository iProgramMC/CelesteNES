; Copyright (C) 2024-2025 iProgramInCpp
.feature string_escapes
.feature line_continuations

.segment "INES"
.byte $4E,$45,$53,$1A
.byte 8         ; size of prg rom in 16kb units
.byte 16        ; size of chr rom in 8kb units
.byte %01000000 ; flags 6 -- switchable nametable mirroring, mapper 4
.byte %00001000 ; flags 7 -- NES 2.0 header
.byte %00000000 ; mapper msb / submapper
.byte %00000000 ; prg-rom / chr-rom size msb
.byte %00000111 ; prg-ram / eeprom size (64 << 7 == 8192)
.byte %00000000 ; chr-ram size
.byte %00000000 ; cpu/ppu timing mode
.byte %00000000 ; vs. system type
.byte %00000000 ; misc ROMs
.byte %00000000 ; default exp device

; mapper 1 -- MMC1

.include "defines.asm"
.include "globals.asm"

.include "d_macros.asm"

.include "level0/bank_0.asm"
.include "level0/bank_1.asm"
.include "level1/bank_0.asm"
.include "level1/bank_1.asm"
.include "level1/bank_2.asm"
.include "level1/bank_3.asm"
.include "level2/bank_0.asm"
.include "level2/bank_1.asm"
.include "level2/bank_2.asm"
.include "level2/bank_3.asm"

.include "prg_xtra.asm"
.include "prg_game.asm"
.include "prg_main.asm"
.include "prg_ttle.asm"
.include "prg_dial.asm"
.include "prg_paus.asm"

; NOTE(iProgram): Keep this up to date with LEVELEDITOR\MainGame.cs (public string bankNumbers[])
.segment "CHR_SPMAD"
.incbin  "chr/sp_player.chr"

.segment "CHR_SPGEN"
.incbin  "chr/sp_gener.chr"

.segment "CHR_SPANI"
.incbin  "chr/sp_anim.chr"

.segment "CHR_BGTTL"
.incbin  "chr/b_title.chr"

.segment "CHR_SLVL0"
.incbin  "chr/sp_level0.chr"
.segment "CHR_SLV0B"
.incbin  "chr/sp_level0b.chr"

.segment "CHR_SLVL1"
.incbin  "chr/sp_level1.chr"
.segment "CHR_SLV1B"
.incbin  "chr/sp_level1b.chr"

.segment "CHR_SLVL2"
.incbin  "chr/sp_level2.chr"
.segment "CHR_SLV2B"
.incbin  "chr/sp_level2b.chr"
.segment "CHR_PAPH1"
.incbin  "chr/sp_level2c.chr"
.incbin  "chr/sp_level2d.chr"
.incbin  "chr/sp_level2e.chr"
.incbin  "chr/sp_level2f.chr"
.segment "CHR_PAPH2"
.incbin  "chr/sp_level2g.chr"
.incbin  "chr/sp_level2h.chr"
.incbin  "chr/sp_level2i.chr"
.incbin  "chr/sp_level2j.chr"
.segment "CHR_PAPH3"
.incbin  "chr/sp_level2k.chr"
.segment "CHR_SLV2L"
.incbin  "chr/sp_level2lm.chr", $000, $400
.segment "CHR_SLV2M"
.incbin  "chr/sp_level2lm.chr", $400, $400

.segment "CHR_BGOWD"
.incbin  "chr/b_overw.chr"

.segment "CHR_SPOWD"
.incbin  "chr/sp_overw.chr"

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

.segment "CHR_DPLDI"
.incbin  "chr/sp_plrdie.chr"

.segment "CHR_PAUSE"
.incbin  "chr/sp_pause.chr"

; Main dialog tiles
.segment "CHR_DMAIN"
.incbin  "chr/d_main.chr"
.segment "CHR_DCNTR"
.incbin  "chr/d_count.chr"
; Madeline dialog frames
.segment "CHR_DMADE"
.incbin  "chr/d_made.chr"
; Theo dialog frames
.segment "CHR_DTHEO"
.incbin  "chr/d_theo.chr"
; Granny dialog frames
.segment "CHR_DGRAN"
.incbin  "chr/d_gran.chr"

; UNUSED segments
.segment "CHR_BG005"
.segment "CHR_BG006"
.segment "CHR_BG007"
.segment "CHR_BG008"
.segment "CHR_UN000"
.segment "CHR_UN001"

.segment "CHR_SLV2L"
.segment "CHR_SLV2M"
.segment "CHR_SLV2N"
.segment "CHR_UN003"
.segment "CHR_UN004"
.segment "CHR_UN005"
.segment "CHR_UN006"
.segment "CHR_UN007"
.segment "CHR_UN008"
.segment "CHR_UN009"
.segment "CHR_UN100"
.segment "CHR_UN101"
.segment "CHR_UN102"
.segment "CHR_U10_B"
.segment "CHR_U10_C"
.segment "CHR_U10_D"
