; Copyright (C) 2025 iProgramInCpp

ch1_ending:
	begin
	lock_input
	
	wait        30
	walk_player $CE, $A0
	
	wait        90
	face_player 0
	
	wait        30
	
	speaker     SPK_madeline
	expression  MAD_distract
	dialog2     @d0
	
	wait        12
	walk_player $9C, $A0
	face_player 0
	wait        42
	
	trigger     2
	wait        84
	
	; trigger sleep
	wait        240
	
	; trigger bird stuff
	
	wait        30
	; trigger bird cawing
	
	; more bird stuff...
	speaker     SPK_madeline
	expression  MAD_sad ; deadpan
	dialog2     @d1
	
	wait        18

	finish_level

	line @d0, "Ugh, I'm exhausted."
	line @d1, "This might have been a mistake."