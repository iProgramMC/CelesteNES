; Copyright (C) 2025 iProgramInCpp

ch2_mirror_shatter:
	begin
	
	; play the 1st part of the dreamblock sting here
	play_music  1
	pause_music 1
	
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
	wait        10
	
	call_rt     level2_sfx_shatter
	wait        12
	
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
	trigger     12
	play_music  2
	pause_music 0
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
	
	play_music  3   ; Badeline Loop
	
	wait        5
	speaker     SPK_badeline
	expression  BAD_normal
	dialog2     @d0 ; slow down
	
	; TRIGGER 0 Madeline turns around
	face_player 1
	
	wait        60
	right
	speaker     SPK_madeline
	expression  MAD_distract
	dialog2     @d1 ; who said that?!
	
	wait        20
	left
	speaker     SPK_badeline
	expression  BAD_normal
	dialog2     @d2 ; just a normal observer, mate
	
	; TRIGGER 1 Badeline is revealed
	
	wait        50
	right
	speaker     SPK_madeline
	expression  MAD_sad
	dialog2     @d3 ; oi, are you me?
	
	left
	speaker     SPK_badeline
	expression  BAD_normal
	dialog2     @d4 ; i'm part of you
	
	right
	speaker     SPK_madeline
	expression  MAD_distract
	dialog2     @d5 ; why would you look so creepy
	
	left
	speaker     SPK_badeline
	expression  BAD_worried
	dialog      @d6 ; ...
	
	expression  BAD_angry
	dialog      @d7 ; it's just what i look like, ok?
	dialog2     @d8 ; deal with it
	
	right
	speaker     SPK_madeline
	expression  MAD_distract
	dialog2     @d9 ; sorry, didn't mean
	
	left
	speaker     SPK_badeline
	expression  BAD_angry
	dialog      @dA ; yeah, yeah, forget it
	dialog      @dB ; it's relieving to get out of your head finally
	
	expression  BAD_upset
	dialog      @dC ; but i'm worried about us
	
	expression  BAD_normal
	dialog2     @dD ; we need a hobby, but this
	
	right
	speaker     SPK_madeline
	expression  MAD_sad
	dialog2     @dE ; i know it sounds crazy, but we have to climb this mountain
	
	; TRIGGER 2 Badeline starts laughing
	
	left
	speaker     SPK_badeline
	expression  BAD_scoff
	dialog2     @dF ; you are many things but not a mountain climber~
	
	right
	speaker     SPK_madeline
	expression  MAD_distract
	dialog2     @dG ; who says i can't be?!
	
	; TRIGGER 3 Badeline stops laughing
	
	left
	speaker     SPK_badeline
	expression  BAD_upset
	dialog      @dH ; i know it's not your strong suit, but be reasonable for once
	dialog      @dI ; you have no clue what you're jumping into
	dialog2     @dJ ; you can't tackle this
	
	right
	speaker     SPK_madeline
	expression  MAD_upset
	dialog      @dK ; it's why i need to do this
	dialog2     @dL ; are you the weak or the lazy part?
	
	left
	speaker     SPK_badeline
	expression  BAD_upset
	dialog      @dM ; i'm the pragmatic part
	
	expression  BAD_scoff
	dialog      @dN ; and i'm trying to be diplomatic here
	
	;expression  BAD_serious TODO
	expression  BAD_normal
	dialogE     @dO ; it's time to go home, together.
	
	play_music  4   ; Chase
	
	trigger     10
	unlock_input
	end
	
	line @d0, "Madeline, darling, slow down."
	line @d1, "Who said that?"
	line @d2, "Oh, I'm simply a concerned observer."
	line @d3, "Are you... me?"
	line @d4, "I'm Part of You."
	line @d5, "Why would Part of Me look so creepy?"
	line @d6, "..."
	line @d7, "This is just what I look like, okay?"
	line @d8, "Deal with it."
	line @d9, "Sorry, I didn't mean-"
	line @dA, "Forget about it."
	line @dB, "I can't tell you what a relief it is\nto finally get out of your head."
	line @dC, "But look, I'm worried about us."
	line @dD, "We need a hobby, but this..."
	line @dE, "I know it sounds crazy, but\nI need to climb this Mountain."
	line @dF, "You are many things, darling,\nbut you are not a mountain climber."
	line @dG, "Who says I can't be?"
	line @dH, "I know it's not your strong suit,\nbut be reasonable for once."
	line @dI, "You have no idea what you're getting\ninto."
	line @dJ, "You can't handle this."
	line @dK, "That is exactly why I need to do this."
	line @dL, "Are you the weak Part of Me, or the\nlazy part?"
	line @dM, "I'm the pragmatic part."
	line @dN, "And I'm trying to be diplomatic here."
	line @dO, "Let's go home... together."

ch2_dream_phonecall:
	begin
	play_music  5  ; Phone Loop
	lock_input
	wait_ground
	walk_player $CD, $A0
	zerovel
	
	hide_player
	trigger     1  ; pick up
	wait        240
	
	left
	speaker     SPK_madeline
	expression  MAD_distract
	dialog2     @d0
	
	right
	speaker     SPK_momex
	expression  MOM_exph
	dialog      @d1
	dialog2     @d2
	
	left
	speaker     SPK_madeline
	expression  MAD_distract
	dialog      @d3
	expression  MAD_sad
	dialog2     @d4
	
	right
	speaker     SPK_momex
	expression  MOM_exph
	dialog2     @d5
	
	left
	speaker     SPK_madeline
	expression  MAD_distract
	dialog      @d6
	dialog      @d7
	expression  MAD_sad
	dialog2     @d8
	
	right
	speaker     SPK_momex
	expression  MOM_exph
	dialog      @d9
	dialog2     @dA
	
	left
	speaker     SPK_madeline
	expression  MAD_angry
	dialog      @dB
	dialog2     @dC
	
	right
	speaker     SPK_momex
	expression  MOM_exph
	dialog      @dD
	dialog      @dE
	dialog2     @dF
	
	left
	speaker     SPK_madeline
	expression  MAD_sad
	dialog      @dG
	expression  MAD_upset
	dialog      @dH
	dialog2     @dI
	
	right
	speaker     SPK_momex
	expression  MOM_exph
	dialog      @dJ
	dialog      @dK
	dialog2     @dL
	
	left
	speaker     SPK_madeline
	expression  MAD_angry
	dialog2     @dM
	
	; Badeline appears
	trigger     8
	
	right
	speaker     SPK_badeline
	expression  BAD_scoff
	dialog      @dN
	expression  BAD_upset
	dialog2     @dO
	
	play_music  6  ; Phone End
	
	trigger     3  ; jumpBack
	wait        16+20
	
	trigger     5  ; transform
	wait        64+64
	
	trigger     6  ; eat
	wait        80+20
	
	finish_level
	
	line @d0, "Hello?"
	line @d1, "Madeline?"
	line @d2, "...are you calling from a payphone?"
	line @d3, "Yeah."
	line @d4, "No, wait... you called me."
	line @d5, "What are you talking about?"
	line @d6, "It doesn't matter. I'm in trouble."
	line @d7, "I'm being chased by... someone."
	line @d8, "I don't really understand what's going\non, but I know I'm in danger. I\ncan feel it."
	line @d9, "Madeline, you only call me when you're\npanicking in the middle of the night."
	line @dA, "You don't have to make up some\nridiculous story just to get my\nattention."
	line @dB, "I'm not making it up!"
	line @dC, "You always do this!"
	line @dD, "Shhh it's alright, calm down."
	line @dE, "I'm sorry sweetheart."
	line @dF, "Talk to me."
	line @dG, "I'm climbing Celeste Mountain. I found\nthis old mirror, and it shattered,\nbut part of me escaped, and..."
	line @dH, "..."
	line @dI, "I'm dreaming, aren't I?"
	line @dJ, "Madeline. Of course you're dreaming."
	line @dK, "I haven't spoken to you in months."
	line @dL, "Why would I start now?"
	line @dM, "Ugh! Why am I even climbing this\nstupid Mountain?"
	line @dN, "I'm wondering the same thing."
	line @dO, "It's time to give up and go home."
