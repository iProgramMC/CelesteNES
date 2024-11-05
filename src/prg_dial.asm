; Copyright (C) 2024 iProgramInCpp

; some defines:
dialog_char_timer = 3
dialog_border     = 8
dialog_border_upp = 20
dialog_port_size  = 40
dialog_port_brdr  = 8

.segment "DLGRAM" ; 64 bytes
dlg_chartimer: .res 1 ; when this timer ticks down to zero, show a new character
dlg_cursor_x:  .res 1 ; the X position of the cursor
dlg_cursor_y:  .res 1 ; the Y position of the cursor
dlg_crsr_home: .res 1 ; the home X position (on the $0A/'\n' character, will go here and advance row)
dlg_port_pal:  .res 1 ; the palette used by the portrait

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
.include "d_nmi.asm"
