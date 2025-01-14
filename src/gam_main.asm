; Copyright (C) 2024 iProgramInCpp

; Desc: If you put these functions in the game segment, it will overflow.
; These functions are instead implemented in the main segment.
.include "g_decomp.asm"
.include "g_scroll.asm"
.include "g_sfx.asm"


; MOVED from g_wipe.asm
gm_respawn_leave_doframe2:
	jsr gm_calc_camera_nosplit
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	jmp com_clear_oam
