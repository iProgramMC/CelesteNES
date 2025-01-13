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
	wait        115
	
	trigger     11
	wait        180
	wait        210
	
	; done!
	play_music  2
	unlock_input
	end

; Madeline frames:
;   normal
;   distracted
;   sad
; Badeline frames:
;   normal
;   worried
;   angry
;   upset
;   scoff
;   serious

ch2_badeline_start:
	begin
	lock_input
	
	wait        5
	speaker     SPK_badeline
	expression  BAD_normal
	dialog2     @d0
	
	wait        60
	right
	speaker     SPK_madeline
	expression  MAD_distract
	dialog2     @d1
	
	wait        20
	left
	speaker     SPK_badeline
	expression  BAD_normal
	dialog2     @d2
	
	; trigger-- Badeline is revealed
	wait        50
	right
	speaker     SPK_madeline
	expression  MAD_sad
	dialog2     @d3
	
	left
	speaker     SPK_badeline
	expression  BAD_normal
	dialogE     @d4
	
	; TODO
	
	trigger     0
	unlock_input
	end
	
	line @d0, "Madeline, darling, slow down."
	line @d1, "Who said that?"
	line @d2, "Oh, I'm simply a concerned observer."
	line @d3, "Are you... me?"
	line @d4, "I'm Part of You."
	line @d5, "Why would Part of Me look so ~creepy~?"
	line @d6, "..."
	line @d7, "This is just what I look like, okay?"
	line @d8, "Deal with it."
	line @d9, "Sorry, I didn't mean-"
	line @dA, "Forget about it."
	line @dB, "I can't tell you what a relief it is\nto ~finally~ get out of your head."
	line @dC, "But look, I'm worried about us."
	line @dD, "We need a hobby, but this..."
	line @dE, "I know it sounds crazy, but\nI need to climb this Mountain."
	line @dF, "You are many things, darling, but you are not a ~mountain climber~."
	line @dG, "Who says I can't be?"
	line @dH, "I know it's not your strong suit,\nbut be reasonable for once."
	line @dI, "You have no idea what you're getting into."
	line @dJ, "You can't handle this."
	line @dK, "That is exactly why I need to do this."
	line @dL, "Are you the weak Part of Me, or the lazy part?"
	line @dM, "I'm the pragmatic part."
	line @dN, "And I'm ~trying~ to be diplomatic here."
	line @dO, "Let's go home...  together."
