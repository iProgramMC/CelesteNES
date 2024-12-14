; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: gm_respawn_leave_doframe
; desc: Completes processing of this frame early, waits for the frame to elapse, and returns.
;       Used by respawn code.
gm_respawn_leave_doframe:
	; note: hair palette is already loaded, don't update palettes, don't clear OAM
	; (whatever gm_draw_dead will draw, will override everything)
	jsr gm_wind_wipe_update
	jsr gm_draw_dead
	
gm_respawn_leave_doframe2:
	jsr gm_calc_camera_nosplit
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	ldx #$00
	stx oam_wrhead
	jmp com_clear_oam

; NOTE: The total of irqtmp1 + irqtmp2 MUST be 18

; these tables are 25 frames in size
death_irq_table_1:	.byte 1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17,17,17,17,17,17,17
death_irq_table_2:	.byte 1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17,17,17,17,17,17,17
death_irq_table_3:	.byte 1,1,1,1,1,1,2,3,4,5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,17,17,17
death_irq_table_4:	.byte 1,1,1,1,1,1,2,3,4,5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,17,17,17

; ** SUBROUTINE: gm_wind_wipe_update
; desc: Updates the wind wipe.
.proc gm_wind_wipe_update
	lda #32
	sec
	sbc transtimer
	; the table is only 25 items long
	cmp #24
	bcc :+
	lda #24
:	tay
	
.repeat 4, idx
	lda death_irq_table_1 + 25 * idx, y
	sta irqtmp + 2 * idx + 0
	lda #18
	sec
	sbc death_irq_table_1 + 25 * idx, y
	sta irqtmp + 2 * idx + 1
.endrepeat

	rts
	
.endproc

.proc gm_init_death_wipe
	; prepare the wind wipe
	lda #$01
	sta irqtmp1
	sta irqtmp3
	sta irqtmp5
	sta irqtmp7
	
	lda #$11
	sta irqtmp2
	lda #$13
	sta irqtmp4
	sta irqtmp6
	sta irqtmp8
	
	lda #def_ppu_msk
	sta deathwipe2
	lda #%00010000   ; only sprites
	sta deathwipe
	lda #16
	sta deathsplit
	rts
.endproc
