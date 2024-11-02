; Copyright (C) 2024 iProgramInCpp

.segment "DLGRAM"
d_old_attrs: .res 16  ; copied from VRAM in an NMI

.segment "DLGTEMP"
d_old_tiles: .res 512 ; copied from VRAM in an NMI

.segment "PRG_DIAL"
.include "d_macros.asm"
.include "d_test.asm"    ; piece of test dialog
.include "d_update.asm"
