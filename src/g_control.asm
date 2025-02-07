; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: gm_check_climb_input
; desc: Depending on the control scheme, checks the state of the CLIMB button.
;
; For the SNES controller, checks the state of the L or R buttons.
; For the NES controller, if emulator mode is selected, the state of the SELECT button is checked.
; Otherwise, the UP button is checked.
gm_check_climb_input:
	lda climbcdown
	beq :+
	dec climbcdown
	lda #0
	sta climbbutton
	rts
	
:	lda ctrlscheme
	cmp #cns_snes
	beq @isSNES
	cmp #cns_emulat
	beq @isEmulator
	
	lda game_cont
	and #cont_up
	sta climbbutton
	rts

@isSNES:
	lda game_cont+1
	and #(cont_lsh|cont_rsh)
	sta climbbutton
	rts

@isEmulator:
	lda game_cont
	and #cont_select
	sta climbbutton
	rts

; ** SUBROUTINE: gm_update_lift_boost
; desc: Updates the lift boost.
.proc gm_update_lift_boost
	lda currlboostX
	bne notZero
	lda currlboostY
	bne notZero
	
	; it's zero, check if the lift boost is zero
	lda liftboosttm
	bne liftBoostGraceNonZero
	
	; lift boost grace is zero
	sta liftboostX
	sta liftboostY
	jmp ensureSane

liftBoostGraceNonZero:
	; not zero, so copy the last boost
	lda lastlboostX
	sta liftboostX
	lda lastlboostY
	sta liftboostY
	dec liftboosttm
	jmp ensureSane

notZero:
	; lift boost is not zero right now.
	lda liftboostX
	sta lastlboostX
	lda liftboostY
	sta lastlboostY
	
	lda currlboostX
	sta liftboostX
	lda currlboostY
	sta liftboostY
	
	lda #0
	sta currlboostX
	sta currlboostY
	
	lda #8
	sta liftboosttm

ensureSane:
	lda liftboostY
	bpl boostPositive
	rts

boostPositive:
	lda #0
	sta liftboostY
	rts
.endproc

; ** SUBROUTINE: gm_update_game_cont
; desc: Updates the game_cont variables to the state of p1_cont.  If input is blocked, then
;       it's actually set to zero.
gm_update_game_cont:
	lda #g3_blockinp
	bit gamectrl3
	beq @normalInput
	
	lda #0
	sta game_cont
	sta game_cont+1
	sta game_conto
	sta game_conto+1
	rts
	
@normalInput:
	lda p1_cont
	ora game_cont_force
	sta game_cont
	lda p1_cont+1
	ora game_cont_force+1
	sta game_cont+1
	
	lda p1_conto
	sta game_conto
	lda p1_conto+1
	sta game_conto+1
	
	lda #0
	sta game_cont_force
	sta game_cont_force+1
	rts
