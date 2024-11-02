; Copyright (C) 2024 iProgramInCpp

ch0_granny:
	speaker     SPK_madeline
	dialog1     @d0
	
	face_ent    1
	
	; walk
	expression  0
	dialog2     @d1, @d2
	
	speaker     SPK_granny
	dialog2     @d3, @d4
	
	; walk
	speaker     SPK_madeline
	face_player 1
	face_ent    0
	dialog2     @d5, @d6
	
	trigger     0              ; "haha"
	wait        30             ; half a sec
	speaker     SPK_granny
	dialog2     @d7, @d8
	
	speaker     SPK_madeline
	dialog1     @d9
	
	expression  1
	dialog2     @d10, @d11
	
	trigger     1              ; stop laughing
	speaker     SPK_granny
	dialog1     @d12
	dialog2     @d13, @d14
	
	dialog1     @d15
	dialog1     @d16
	
	wait        30
	speaker     SPK_madeline
	dialog1     @d17
	
	end
	
	line @d0, "Excuse me, ma'am?"
	line @d1, "The sign out front is busted..."
	line @d2, "is this the Mountain trail?"
	line @d3, "You're almost there."
	line @d4, "It's just across the bridge."
	line @d5, "By the way, you should call someone about your"
	line @d6, "driveway. The ridge collapsed and I nearly died."
	line @d7, "If my \"driveway\" almost did you in,"
	line @d8, "the Mountain might be a bit much for you."
	line @d9, "..."
	line @d10,"Well, if an old bat like you can"
	line @d11,"survive out here, I think I'll be fine."
	line @d12,"Suit yourself."
	line @d13,"But you should know,"
	line @d14,"Celeste Mountain is a strange place."
	line @d15,"You might see things."
	line @d16,"Things you ain't ready to see."
	line @d17,"You should seek help, lady."