.segment "INES"
.byte $4E,$45,$53,$1A
.byte 4         ; size of prg rom in 16kb units
.byte 4         ; size of chr rom in 8kb units
.byte %00010000 ; flags 6 -- switchable nametable mirroring, mapper 1
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

.segment "BANK00"
.include "bank_00.asm"

.segment "BANK01"
.include "bank_01.asm"

.segment "BANK02"
.include "bank_02.asm"

.segment "PRG"
.include "prg.asm"

; NOTE(iProgram): Keep this up to date with LEVELEDITOR\MainGame.cs (public string bankNumbers[])
.segment "CHR"
.incbin  "sprites.chr"
.incbin  "sp_overw.chr"
.incbin  "b_title.chr"
.incbin  "b_overw.chr"
.incbin  "b_lvl0.chr"
