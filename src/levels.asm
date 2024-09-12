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
;     .byte {warpUpRoomNumber}
;     .byte {warpDownRoomNumber}
;     .byte {warpLeftRoomNumber}
;     .byte {warpRightRoomNumber}
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
	.byte $00, $0E  ; 16X horizontal ground, at Y=14
	.byte $00, $0D  ; 16X horizontal ground, at Y=13
	.byte $00, $0C  ; 16X horizontal ground, at Y=12
	.byte $40, $8B  ;  8X horizontal ground, at X=4,Y=11
	.byte $60, $8A  ;  8X horizontal ground, at X=4,Y=10
	.byte $FF    ; terminator

lvl_1_r1:
	.byte 1, 0, 12
	.byte 0, 0, 0, 0
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