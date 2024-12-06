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

DOP_dialog  = $82  ; Show dialog box (with more dialog boxes following it)

DOP_end     = $00  ; Finish dialog

; ## SPEAKERS ##
; NOTE: These double as characters you can use. When one of these characters is encountered
; in the string stream, the name of the character is placed instead of the character.
SPK_madeline = $00
SPK_granny   = $01
SPK_theo     = $02
SPK_badeline = $03
SPK_ex       = $04
SPK_mom      = $05
SPK_oshiro   = $06

; ** Madeline's expressions
MAD_normal   = $00
MAD_sad      = $01
MAD_upset    = $02
MAD_angry    = $03

; ** Granny's expressions
GRN_normal   = $00
GRN_laugh    = $01
GRN_creepA   = $02
GRN_creepB   = $03

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
.macro walk_player px, py, dur
	.byte DOP_walkplr, px, py, dur
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
