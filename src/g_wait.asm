; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: gm_leave_doframe
; desc: Completes processing of this frame early, waits for the frame to elapse, and returns.
gm_leave_doframe:
	jsr gm_load_hair_palette
	jsr gm_draw_player
	jsr gm_draw_entities
	jsr gm_calc_camera_nosplit
	jsr gm_update_bg_effects
	jsr gm_check_updated_palettes
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	
	jsr com_clear_oam
	jmp gm_clear_palette_allocator

