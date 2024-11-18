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
.byte %00000110 ; prg-ram / eeprom size (64 << 6 == 4096)
.byte %00000000 ; chr-ram size
.byte %00000000 ; cpu/ppu timing mode
.byte %00000000 ; vs. system type
.byte %00000000 ; misc ROMs
.byte %00000000 ; default exp device

; mapper 1 -- MMC1

.include "defines.asm"
.include "globals.asm"

.include "level0/bank_0.asm"
.include "level0/bank_1.asm"
.include "level1/bank_0.asm"
.include "level1/bank_1.asm"

.include "prg_game.asm"
.include "prg_main.asm"
.include "prg_ttle.asm"
.include "prg_dial.asm"
.include "prg_xtra.asm"

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

.segment "CHR_BGOWD"
.incbin  "chr/b_overw.chr"

.segment "CHR_SPOWD"
.incbin  "chr/sp_overw.chr"

.segment "CHR_BG000"
.incbin  "chr/b_lvl0.chr"

.segment "CHR_BG001"
.incbin  "chr/b_lvl1.chr"

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
.segment "PRG_LVL2A"
.segment "PRG_LVL3A"
.segment "PRG_LVL4A"
.segment "PRG_LVL5A"
.segment "PRG_LVL2B"
.segment "PRG_LVL3B"
.segment "PRG_LVL4B"
.segment "PRG_LVL5B"
.segment "CHR_SLVL1"
.segment "CHR_SLV0B"
.segment "CHR_SPR02"
.segment "CHR_SPR03"
.segment "CHR_BG002"
.segment "CHR_BG003"
.segment "CHR_BG004"
.segment "CHR_BG005"
.segment "CHR_BG006"
.segment "CHR_BG007"
.segment "CHR_BG008"
.segment "CHR_UN000"
.segment "CHR_UN001"
.segment "CHR_UN002"
.segment "CHR_UN003"
.segment "CHR_UN004"
.segment "CHR_UN005"
.segment "CHR_UN006"
.segment "CHR_UN007"
.segment "CHR_UN008"
.segment "CHR_UN009"
.segment "CHR_UN010"
