; Copyright (C) 2024 iProgramInCpp

; These are defines and macros useful for dialog.

; NOTES:
; * Celeste defines an "anchor" for dialog. This game will have all dialog pinned to the
;   top. This is usually the case in the original as well, except for some dialog in Ch.3.

; ## OPCODES ##
DOP_wait    = $01  ; Wait N frames
DOP_dialogE = $02  ; Show dialog box with end
DOP_speaker = $03  ; Change speaker
DOP_dirent  = $04  ; Change facing direction of Entity
DOP_dirplr  = $05  ; Change facing direction of Player
DOP_walkplr = $06  ; Walk to position
DOP_walkent = $07  ; Walk to position (entity)
DOP_express = $08  ; Change expression
DOP_trigger = $09  ; Trip a hardcoded trigger
DOP_lock    = $0A  ; Blocks input from player - also locks camera scrolling
DOP_unlock  = $0B  ; Unlocks input from player
DOP_waitgrn = $0C  ; Waits until Madeline touches the ground
DOP_dialog2 = $0D  ; Show dialog box, then close, but don't clear
DOP_begin   = $0E  ; Initialize cutscene variables
DOP_left    = $0F  ; Place portrait on the left
DOP_right   = $10  ; Place portrait on the right
DOP_freeze  = $11  ; Freeze game for N frames
DOP_physOFF = $12  ; Disable physics
DOP_physON  = $13  ; Enable physics
DOP_pcdgOFF = $14  ; Disable player controls, drag, and gravity (PCDG)
DOP_pcdgON  = $15  ; Enable PCDG
DOP_rm25pcv = $16  ; Remove 25% of both velocities
DOP_zerovel = $17  ; Set velocity to zero
DOP_callrt  = $18  ; Call subroutine
DOP_music   = $19  ; Play music track
DOP_finish  = $1A  ; Finish level

DOP_dialog  = $82  ; Show dialog box (with more dialog boxes following it)

DOP_end     = $00  ; Finish dialog

; ## SPEAKERS ##
; NOTE: These double as characters you can use. When one of these characters is encountered
; in the string stream, the name of the character is placed instead of the character.
SPK_madeline = $00
SPK_granny   = $01
SPK_theo     = $02
SPK_badeline = $03
SPK_momex    = $04
SPK_oshiro   = $05

; ** Madeline's expressions
MAD_normal   = $00
MAD_sad      = $01
MAD_upset    = $02
MAD_angry    = $03
MAD_distract = $04

; ** Badeline's expressions
BAD_normal   = $00
BAD_worried  = $01
BAD_scoff    = $02
BAD_angry    = $03
BAD_upset    = $04

; ** Granny's expressions
GRN_normal   = $00
GRN_laugh    = $01
GRN_creepA   = $02
GRN_creepB   = $03

; ** Mom's expression
MOM_normal   = $00
MOM_concern  = $01
MOM_exph     = $02

; Define a dialog line
.macro line name, text
name:
	.byte text, 0
.endmacro

; Wait N frames
; desc: Close the dialog, wait N frames, and then open it back up
.macro wait n
	.byte DOP_wait, n
.endmacro

; Dialog box
.macro dialog line
	.byte DOP_dialog
	.word line
.endmacro

; Dialog box, with close, but without end
.macro dialog2 line
	.byte DOP_dialog2
	.word line
.endmacro

; Dialog box with end
.macro dialogE line
	.byte DOP_dialogE
	.word line
.endmacro

; Change Speaker
; desc: This changes the current speaker, and the CHR bank where their portrait resides.
.macro speaker spkr
	.byte DOP_speaker, spkr
.endmacro

; Change facing of Entity
; desc: Changes the facing of the currently spoken-to entity.  This is 0 for facing right,
;       and 1 for facing left.
.macro face_ent facing
	.byte DOP_dirent, facing
.endmacro

; Change facing of Player
; desc: Changes the facing of Madeline.  This is 0 for facing right,
;       and 1 for facing left.
.macro face_player facing
	.byte DOP_dirplr, facing
.endmacro

; Walk to position
; desc: Walks the player to a position.
.macro walk_player px, py
	.byte DOP_walkplr, px, py
.endmacro

; Walk to position (entity)
; desc: Walks the spoken-to entity to a position.
.macro walk_entity px, py, dur
	.byte DOP_walkent, px, py, dur
.endmacro

; Change expression
; desc: Changes the expression of the character.  Whatever the expression the number
;       defines, depends on the character, and how its portrait table is set up.
.macro expression expid
	.byte DOP_express, expid
.endmacro

; Trip a hardcoded trigger
; desc: Some entities may have hardcoded triggers. This trips one of them.
.macro trigger trigid
	.byte DOP_trigger, trigid
.endmacro

; Lock player input.
.macro lock_input
	.byte DOP_lock
.endmacro

; Waits until the player has hit the ground.
.macro wait_ground
	.byte DOP_waitgrn
.endmacro

; Unlock player input.
.macro unlock_input
	.byte DOP_unlock
.endmacro

; Initialize cutscene
.macro begin
	.byte DOP_begin
.endmacro

; Finish cutscene
.macro end
	.byte DOP_end
.endmacro

.macro left
	.byte DOP_left
.endmacro

.macro right
	.byte DOP_right
.endmacro

; Freeze for N frames
; desc: Freezes the game for N frames. Unlike wait, doesn't run physics or any other processes
.macro freeze n
	.byte DOP_freeze, n
.endmacro

; Disable Physics
.macro physOFF
	.byte DOP_physOFF
.endmacro

; Enable Physics
.macro physON
	.byte DOP_physON
.endmacro

; Disable PCDG (Player Controls, Drag, and Gravity)
.macro pcdgOFF
	.byte DOP_pcdgOFF
.endmacro

; Enable PCDG
.macro pcdgON
	.byte DOP_pcdgON
.endmacro

; Remove 25% of velocity
.macro rm25pcvel
	.byte DOP_rm25pcv
.endmacro

; Clear Velocity
.macro zerovel
	.byte DOP_zerovel
.endmacro

; Call Routine
.macro call_rt rt
	.byte DOP_callrt
	.word rt
.endmacro

; Play music
.macro play_music idx
	.byte DOP_music, idx
.endmacro

; Finish level
.macro finish_level
	.byte DOP_finish
.endmacro
