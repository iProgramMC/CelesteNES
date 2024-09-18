; Level Data

; Level Format Concept
;
; This platformer engine will support four kinds of rooms:
; - Rooms where the player spawns on the left and the intended direction is right
; - Rooms where the player spawns on the right - the entirety of the room is loaded
; - Rooms where the player spawns on the bottom and the intended direction is up
; - Rooms where the player spawns above - the entirety of the room is loaded
;
; Obviously, for the "entire room is loaded" rooms, they are limited to 2 screens
; in size, but scrolling is allowed throughout the entire room.
;
; Normal rooms will only be scrollable to the right
;
; Format:
;
; ROOM_ENTITIES:
;     .byte {opCode}
;     .byte {attributes}
;     if bit 7 of flags is set: .byte {extraData}
;     
;     opCode:     same as Opcode attributes except for "size"
;     attributes: same as Tile attributes except bit 7
;     extraData:  entity specific data (strawberry ID etc)
;
;   - opCode == 0xFE and 0xFF are the same as Tile rooms
;
; ROOM_TILES:
;     .byte {opCode}
;     .byte {attributes}
;
;     opCode:     bits 0:3 - type
;                 bits 4:7 - X position
;     attributes: bits 0:3 - Y position
;                 bits 4:7 - size or flags
;
;   - opCode == 0xFE -- screen end, stop generating objects for this screen
;   - opCode == 0xFF -- room end
;   - size of 0 often means 16
;   - all objects MUST be ordered by X coordinate
;
;   - opcodes:
;       - horizontal ground:            0
;            size X 1 - horizontal sliver of ground
;       - vertical ground:              1
;            1 X size - vertical sliver of ground
;       - ground type change:           2
;            bits 0:1 of "flags" mean the type of ground to change to
;            only 4 loaded at a time due to CHR space issues
;            bits 2:3... some other stuff I don't know
;       - horizontal background sliver: 3
;            size X 1 - horizontal sliver of background
;       - vertical background sliver:   4
;            1 X size - vertical sliver of background
;       - background chunk:             5
;            size X h - chunk of background
;            h is the height between this chunk's Y and the bottom of the world
;       - horizontal ground with type   6
;            size X 1 - horizontal sliver of ground
;            has extra parameter: the metatile ID used
;       - horizontal ground with type   7
;            1 X size - vertical sliver of ground
;            has extra parameter: the metatile ID used
;       - player respawn:               SHOULD BE AN ENTITY
;            attributes:
;                bits 0:3: player Y
;                bit 4: player facing (if set, player faces left)
;                bit 5,6: spawn ID (when player dies, based on the origin side, they'll spawn here)
;            ignored when using the room connection warp mechanism
;
; ROOM_LABEL:
;     .byte {size}
;          the size of the room in screens
;              horizontal room - 16 tiles per screen
;              vertical room   - 15 tiles per screen
;     .byte {flags}
;          bit 0 - room is vertical
;          bit 1 - player spawns on opposite side, room is entirely loaded
;     .byte {entranceTilePos}
;          vertical room -> horizontal offset
;          horizontal room -> vertical offset
;          the player will always be placed 1 tile (horiz) or 2 tiles (vert) from
;          the edge of origin
;     .byte {startingGroundMetatile}
;     .byte {startingBackGroundMetatile}
;     .byte {warpUpRoomNumber}
;     .byte {warpDownRoomNumber}
;     .byte {warpLeftRoomNumber}
;     .byte {warpRightRoomNumber}
;     .byte {warpUpRoomX}
;     .byte {warpDownRoomX}
;     .byte {warpLeftRoomY}
;     .byte {warpRightRoomY}
;     .byte {spare}
;     .byte TilesLowAddr, TilesHighAddr
;     .byte EntitiesLowAddr, EntitiesHighAddr
;
; LEVEL_LABEL:
;     .byte {environmentType}
;     .byte {numRooms}
;     .byte room1Lo, room1Hi
;     .byte room2Lo, room2Hi
;     ...
;

lvl_1_r1_e: .byte $FF
lvl_1_r1_t:
	.byte $02, $01       ; ground change to $01 (dirt)
	.byte $00, $5A       ; 5X horizontal ground at X=0,Y=10
	.byte $56, $1A, $07  ; 1X horizontal ground at X=5,Y=10,id=$07 (snow corner inner U+L)
	.byte $56, $19, $03  ; 1X horizontal ground at X=5,Y=9, id=$03 (snow corner UL)
	.byte $66, $19, $02  ; 1X horizontal ground at X=6,Y=9, id=$02 (snow)
	.byte $66, $1A, $0C  ; 1X horizontal ground at X=6,Y=9, id=$0C (snow corner inner D+R)
	.byte $67, $4B, $09  ; 4X vertical ground at X=6,Y=11,id=$09 (snow r wall)
	.byte $76, $19, $04  ; 1X horizontal ground at X=7,Y=9, id=$04 (snow corner UR)
	.byte $76, $1A, $06  ; 1X horizontal ground at X=7,Y=10,id=$06 (snow corner DR)
	.byte $B6, $1A, $19  ; 1X horizontal ground at X=11,Y=10,id=$19(dirt lower half left corner)
	.byte $B7, $4B, $15  ; 4X vertical ground at X=11,Y=11,id=$15 (dirt l wall)
	.byte $C6, $1A, $18  ; 1X horizontal ground at X=12,Y=10,id=$1A(dirt lower half)
	.byte $FF            ; terminator
	
	
	
	; old prototype level:
	.byte $00, $0E  ; 16X horizontal ground, at Y=14
	.byte $22, $03  ; ground change to $03 at X=2
	.byte $20, $45  ; 4X horizontal ground at X=2, Y=5
	.byte $72, $02  ; ground change to $02
	.byte $71, $52  ; 5X  vertical ground stripe, at X=7,Y=2
	.byte $82, $02  ; ground change to $03
	.byte $80, $CA  ; 12X horizontal ground at X=8,Y=10
	.byte $A2, $03  ; ground change to $03
	.byte $A1, $53  ; 5X  vertical ground stripe, at X=10,Y=3
	.byte $B2, $01  ; ground change to $01
	.byte $FE
	.byte $00, $0D
	.byte $00, $0E
	.byte $10, $E7  ; 14X ground at X=1, Y=7
	.byte $22, $06  ; ground change to $06 (spikes)
	.byte $20, $4C  ; 4X row at X=2 Y=12
	.byte $80, $2A  ; 2X row at X=8 Y=10
	.byte $A0, $2B  ; 2X row at X=10 Y=11
	.byte $A2, $01  ; ground change to $01 (snow) at X=10
	.byte $FE
	.byte $00, $0C
	.byte $36, $4A, $07  ; 4X row at X=3, Y=10
	.byte $76, $4B, $07  ; 4X row at X=7, Y=11
	.byte $FE
	.byte $00, $0D
	.byte $00, $0E
	.byte $36, $4A, $09  ; 4X row at X=3, Y=10
	.byte $76, $4B, $09  ; 4X row at X=7, Y=11
	.byte $FE
	.byte $00, $0E
	.byte $36, $4B, $08  ; 4X row at X=3, Y=11
	.byte $76, $4D, $08  ; 4X row at X=7, Y=13
	.byte $FF       ; terminator

lvl_1_r1:
	.byte 1, 0, 12
	.byte 1, 0       ; starting ground, background
	.byte 0, 0, 0, 0 ; warp room numbers
	.byte 0, 0, 0, 0 ; warp room coords
	.byte 0          ; spare
	.word lvl_1_r1_t
	.word lvl_1_r1_e

lvl_1:
	.byte $00    ; normal environment
	.byte $01    ; room count
	.word lvl_1_r1

level_table:
	.word lvl_1
level_table_end:

level_table_size = level_table_end - level_table
