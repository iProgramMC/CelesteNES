; Copyright (C) 2025 iProgramInCpp

ch2_mirror_shatter:
	begin
	
	; play the 1st part of the dreamblock sting here
	
	lock_input
	
	; yield return 1f;
	wait        60
	
	; player.Facing = (Facings)(-direction);
	wait_ground
	face_player 1
	
	; yield return 0.4f;
	wait        24
	
	; run towards the 
	walk_player 128, 144
	face_player 1
	
	; wait a bit
	wait        60
	
	; make the reflection walk forward
	trigger     3
	wait        39
	; TODO: Add the equivalent of event:/game/02_old_site/sequence_mirror
	wait        9
	
	; shatter the mirror
	trigger     5
	wait        32
	
	; trigger Badeline to wait, after shattering the mirror
	trigger     6
	wait        72
	
	; trigger Badeline to flee
	trigger     7
	wait        60
	
	unlock_input
	end
