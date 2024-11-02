; Copyright (C) 2024 iProgramInCpp

; These are defines and macros useful for dialog.

; NOTES:
; * Celeste defines an "anchor" for dialog. This game will have all dialog pinned to the
;   top. This is usually the case in the original as well, except for some dialog in Ch.3.

; ## OPCODES ##
DOP_wait    = $00  ; Wait N frames
DOP_1line   = $01  ; One line of dialog
DOP_2line   = $02  ; Two lines of dialog
DOP_3line   = $03  ; Three lines of dialog
DOP_speaker = $04  ; Change speaker
DOP_dirent  = $05  ; Change facing direction of Entity
DOP_dirplr  = $06  ; Change facing direction of Player
DOP_walkplr = $07  ; Walk to position
DOP_walkent = $08  ; Walk to position (entity)
DOP_express = $09  ; Change expression
DOP_trigger = $0A  ; Trip a hardcoded trigger

DOP_end     = $FF  ; Finish dialog

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

; Define a dialog line
.macro line name, text
name:
	.byte .strlen(text), text
.endmacro

; Wait N frames
; desc: Close the dialog, wait N frames, and then open it back up
.macro wait n
	.byte DOP_wait, n
.endmacro

; 1 line dialog
.macro dialog1 line1
	.byte DOP_1line
	.word line1
.endmacro

; 2 line dialog
.macro dialog2 line1, line2
	.byte DOP_2line
	.word line1, line2
.endmacro

; 3 line dialog
.macro dialog3 line1, line2, line3
	.byte DOP_3line
	.word line1, line2, line3
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
.macro walk_entity px, py
	.byte DOP_walkent, px, py
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

; Finish dialog
.macro end
	.byte DOP_end
.endmacro
