; Copyright (C) 2024 iProgramInCpp

.segment "DLGRAM"
; 64 bytes

.segment "DLGTEMP"

; 768 bytes - 256 for each row of text.
dlg_bitmap:	.res 32*24

.align $100
; columns to be updated
dlg_upds1:	.res 32
dlg_upds2:	.res 32
dlg_upds3:	.res 32

dlg_updpaddrlo:	.res 32*3
dlg_updpaddrhi:	.res 32*3

; update count
dlg_updc1:	.res 1
dlg_updc2:	.res 1
dlg_updc3:	.res 1
dlg_updccurr:	.res 1

.segment "PRG_DIAL"
.include "d_macros.asm"
.include "d_test.asm"    ; piece of test dialog
.include "d_font.asm"
.include "d_update.asm"
