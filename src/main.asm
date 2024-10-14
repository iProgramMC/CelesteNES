.segment "INES"
.byte $4E,$45,$53,$1A
.byte 8         ; size of prg rom in 16kb units
.byte 8         ; size of chr rom in 8kb units
.byte %01000000 ; flags 6 -- switchable nametable mirroring, mapper 4
.byte %00001000 ; flags 7 -- NES 2.0 header
.byte %00000000 ; mapper msb / submapper
.byte %00000000 ; prg-rom / chr-rom size msb
.byte %00000101 ; prg-ram / eeprom size (64 << 5 == 2048)
.byte %00000000 ; chr-ram size
.byte %00000000 ; cpu/ppu timing mode
.byte %00000000 ; vs. system type
.byte %00000000 ; misc ROMs
.byte %00000000 ; default exp device

; mapper 1 -- MMC1

.include "defines.asm"

.segment "PRG_LVL0"
.include "prg_lvl0.asm"
.segment "PRG_LVL1"
.include "prg_lvl1.asm"

.segment "PRG_GAME"
.include "prg_game.asm"

.segment "PRG_MAIN"
.include "prg_main.asm"

; NOTE(iProgram): Keep this up to date with LEVELEDITOR\MainGame.cs (public string bankNumbers[])
.segment "CHR_SPR00"
.incbin  "sp_player.chr"
.segment "CHR_SPR01"
.incbin  "sprites.chr"

.segment "CHR_BGTTL"
.incbin  "b_title.chr"

.segment "CHR_BGOWD"
.incbin  "b_overw.chr"

.segment "CHR_SPOWD"
.incbin  "sp_overw.chr"

.segment "CHR_BG000"
.incbin  "b_lvl0.chr"

.segment "CHR_BG001"
.incbin  "b_lvl1.chr"

; Madeline dialog frames
.segment "CHR_DMADE"
.incbin  "d_made.chr"
; Theo dialog frames
.segment "CHR_DTHEO"
.incbin  "d_theo.chr"
; Granny dialog frames
.segment "CHR_DGRAN"
.incbin  "d_gran.chr"
