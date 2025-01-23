; Copyright (C) 2024-2025 iProgramInCpp

ch0_granny:
	begin
	lock_input
	wait_ground
	face_player 0
	left
	
	; note: the camera should be fixed at a certain position, therefore
	; we can get away with hardcoding walking positions
	
	speaker     SPK_madeline
	expression  MAD_normal
	dialog2     @d0
	
	face_ent    1
	
	walk_player $7C, $70
	wait        6
	face_player 0
	expression  MAD_normal
	dialog2     @d1
	
	right
	speaker     SPK_granny
	expression  GRN_normal
	dialog2     @d2
	
	walk_player $BC, $70
	wait        6
	speaker     SPK_madeline
	expression  MAD_sad
	face_player 1
	wait        5
	face_ent    0
	dialog2     @d3
	
	trigger     2              ; "haha"
	wait        30             ; half a sec
	left
	speaker     SPK_granny
	expression  GRN_laugh
	dialog2     @d4
	
	right
	speaker     SPK_madeline
	expression  MAD_upset
	dialog      @d5
	
	expression  MAD_angry
	dialog2     @d6
	
	left
	trigger     0              ; stop laughing
	speaker     SPK_granny
	expression  GRN_normal
	dialog      @d7
	dialog      @d8
	expression  GRN_creepA
	dialog      @d9
	expression  GRN_creepB
	dialog2     @d10
	
	wait        30
	right
	speaker     SPK_madeline
	expression  MAD_upset
	dialogE     @d11
	
	unlock_input
	end
	
	line @d0, "Excuse me, ma'am?"
	line @d1, "The sign out front is busted...\nis this the Mountain trail?"
	line @d2, "You're almost there.\nIt's just across the bridge."
	line @d3, "By the way, you should call someone\nabout your driveway. The ridge\ncollapsed and I nearly died."
	line @d4, "If my \"driveway\" almost did you in,\nthe Mountain might be a bit much\nfor you."
	line @d5, "..."
	line @d6, "Well, if an old bat like you can\nsurvive out here, I think I'll be fine."
	line @d7, "Suit yourself."
	line @d8, "But you should know,\nCeleste Mountain is a strange place."
	line @d9, "You might see things."
	line @d10,"Things you ain't ready to see."
	line @d11,"You should seek help, lady."

ch0_dash_tutorial:
	begin
	pcdgOFF
	
	face_player 0
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	rm25pcvel
	wait 5
	
	trigger 2   ; fly down
	zerovel
	
	wait    80
	trigger 3   ; knock knock
	
	wait    64
	trigger 4   ; bawk!!
	
	wait_ground
	walk_player 188,160
	trigger 5   ; fly away
	
	; start panting
	call_rt gm_set_panting
	lock_input
	wait    80
	
	
	finish_level
	end
