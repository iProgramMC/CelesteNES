; Copyright (C) 2024 iProgramInCpp

ch0_granny:
	speaker     SPK_madeline
	expression  MAD_normal
	dialogE     @d0
	
	face_ent    1
	
	; walk
	expression  MAD_normal
	dialogE     @d1
	
	speaker     SPK_granny
	expression  GRN_normal
	dialogE     @d2
	
	; walk
	speaker     SPK_madeline
	expression  MAD_normal
	face_player 1
	face_ent    0
	dialogE     @d3
	
	trigger     0              ; "haha"
	wait        30             ; half a sec
	speaker     SPK_granny
	expression  GRN_laugh
	dialogE     @d4
	
	speaker     SPK_madeline
	expression  MAD_upset
	dialog      @d5
	
	expression  MAD_angry
	dialogE     @d6
	
	trigger     1              ; stop laughing
	speaker     SPK_granny
	expression  GRN_normal
	dialog      @d7
	dialog      @d8
	expression  GRN_creepA
	dialog      @d9
	expression  GRN_creepB
	dialogE     @d10
	
	wait        30
	speaker     SPK_madeline
	expression  MAD_upset
	dialogE     @d11
	
	end
	
	line @d0, "Excuse me, ma'am?"
	line @d1, "The sign out front is busted...\nis this the Mountain trail?"
	line @d2, "You're almost there.\nIt's just across the bridge."
	line @d3, "By the way, you should call someone\nabout your driveway. The ridge collapsed\nand I nearly died."
	line @d4, "If my \"driveway\" almost did you in,\nthe Mountain might be a bit much\nfor you."
	line @d5, "..."
	line @d6, "Well, if an old bat like *you* can\nsurvive out here, I think I'll be fine."
	line @d7, "Suit yourself."
	line @d8, "But you should know,\nCeleste Mountain is a strange place."
	line @d9, "You might see things."
	line @d10,"Things you ain't ready to see."
	line @d11,"You should seek help, lady."