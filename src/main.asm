.segment "INES"
.byte $4E,$45,$53,$1A
.byte 2        ; size of prg rom in 16kb units
.byte 1        ; size of chr rom in 8kb units
.byte %0000001 ; flags 6 -- horizontal nametable mirroring. TODO: this should be versatile

.segment "PRG"
.include "prg.asm"

.segment "CHR"
.incbin  "gfx.chr"
