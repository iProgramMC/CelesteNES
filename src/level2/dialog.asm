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
	
	; yield return player.DummyRunTo(mirror.X + playerEndX);
	walk_player 128, 144
	
	; yield return 0.5f;
	; yield return level.ZoomTo(mirror.Position - level.Camera.Position - Vector2.UnitY * 24f, 2f, 1f);
	; yield return 0.5f;
	wait        60
	
	; yield return mirror.BreakRoutine(direction);
	;	autoUpdateReflection = false;
	;	reflectionSprite.Play("runFast");
	;	reflectionSprite.Play("runFast");
	trigger     3
	
	
	
	unlock_input
	end
