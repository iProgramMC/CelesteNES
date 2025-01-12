; Copyright (C) 2025 iProgramInCpp

ch2_mirror_shatter:
	begin
	
	; play the 1st part of the dreamblock sting here
	play_music  1
	
	lock_input
	
	wait        60
	
	wait_ground
	face_player 1
	
	wait        24
	
	; run towards the mirror
	walk_player 128, 144
	face_player 1
	
	; wait a bit
	wait        60
	
	; make the reflection walk forward
	trigger     3
	wait        80
	
	; shatter the mirror
	trigger     5
	wait        22
	
	; trigger Badeline to wait, after shattering the mirror
	trigger     6
	wait        80
	
	; trigger Badeline to flee, and wait for the camera to scroll towards the central dream block
	trigger     7
	wait        120
	
	; activate the dream block, and wait for the camera to scroll back to the main room
	trigger     10
	wait        80
	
	trigger     11
	wait        210
	wait        210
	
	; done!
	play_music  2
	unlock_input
	end
