; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: gm_init_respawn
; desc: Performs the respawn scene.
.proc gm_do_respawn
	lda nmictrl
	ora #nc_turnon
	sta nmictrl
	
	jsr gm_init_death_wipe
	
	lda deathwipe
	ldx deathwipe2
	sta deathwipe2
	stx deathwipe
	
	lda #$04
	sta plr_spr_l
	lda #$06
	sta plr_spr_r
	lda #$32
	sta plh_spr_l
	lda #$30
	sta plh_spr_r
	lda #0
	sta sprxoff
	sta spryoff
	sta spryoffbase
	
	jsr gm_respawn_leave_doframe2
	
loop:
	lda respawntmr
	sta deathtimer
	sta transtimer
	
	; temp11 is the divider count in like gm_dead_sub3 or something
	lda #16
	sta plattemp1
	lda #4
	sta temp11
	
	jsr gm_draw_dead::respawnOverride
	
	lda respawntmr
	cmp #$10
	bcs doWindWipeUpdate
	
	lda #0
	sta miscsplit
	lda #def_ppu_msk
	sta deathwipe
	sta deathwipe2
	
	lda #<irq_death_wipe
	sta irqaddr
	lda #>irq_death_wipe
	sta irqaddr+1
	
	bne doneWipe
	
doWindWipeUpdate:
	jsr gm_wind_wipe_update

	lda #16
	sta miscsplit
doneWipe:
	jsr gm_respawn_leave_doframe2
	
	dec respawntmr
	bne loop
	
	lda #0
	sta spr0_bknum
	sta miscsplit
	sta deathwipe
	sta deathwipe2
	lda #def_ppu_msk
	sta ppu_mask
	
	jsr gm_leave_doframe
	rts
.endproc
