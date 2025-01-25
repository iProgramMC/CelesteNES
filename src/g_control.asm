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



; Note: The LR row must match the L row because gm_defaultdir requires it.
; This corresponds to DashDir*240 in the original Celeste.
dash_table:
	.byte $00, $00, $00, $00 ; ----
	.byte $04, $00, $00, $00 ; ---R
	.byte $FC, $00, $00, $00 ; --L-
	.byte $FC, $00, $00, $00 ; --LR

	.byte $00, $00, $04, $00 ; -D--
	.byte $02, $D4, $02, $D4 ; -D-R
	.byte $FD, $2C, $02, $D4 ; -DL-
	.byte $FD, $2C, $02, $D4 ; -DLR

	.byte $00, $00, $FC, $00 ; U---
	.byte $02, $D4, $FD, $2C ; U--R
	.byte $FD, $2C, $FD, $2C ; U-L-
	.byte $FD, $2C, $FD, $2C ; U-LR

	.byte $00, $00, $00, $00 ; UD--
	.byte $04, $00, $00, $00 ; UD-R
	.byte $FC, $00, $00, $00 ; UDL-
	.byte $FC, $00, $00, $00 ; UDLR

; This corresponds to DashDir*160 in the original Celeste (160/240 == 2/3)
dash_table_two_thirds:
	.byte $00, $00, $00, $00 ; ----
	.byte $02, $AA, $00, $00 ; ---R
	.byte $FD, $56, $00, $00 ; --L-
	.byte $FD, $56, $00, $00 ; --LR

	.byte $00, $00, $02, $AA ; -D--
	.byte $01, $E2, $01, $E2 ; -D-R
	.byte $FE, $1E, $01, $E2 ; -DL-
	.byte $FE, $1E, $01, $E2 ; -DLR

	.byte $00, $00, $FD, $56 ; U---
	.byte $01, $E2, $FE, $1E ; U--R
	.byte $FE, $1E, $FE, $1E ; U-L-
	.byte $FE, $1E, $FE, $1E ; U-LR

	.byte $00, $00, $00, $00 ; UD--
	.byte $02, $AA, $00, $00 ; UD-R
	.byte $FD, $56, $00, $00 ; UDL-
	.byte $FD, $56, $00, $00 ; UDLR
