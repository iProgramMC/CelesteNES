; Copyright (C) 2024 iProgramInCpp

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
;
; ***********************************************************
; * THE ROOM TILE DATA STRUCTURE IS **OUTDATED**, IGNORE.   *
; * I'll come up with an explanation later.                 *
; ***********************************************************
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
; ROOM_ENTITIES: (not outdated)
;     .byte {X coord}, {Y coord}, {Entity Type}
;  OR .byte ec_scrnext     -- ends this screen's entity data
;  OR .byte ec_dataend     -- ends the level's entity stream
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
.include "level0.asm"

level_table:
	.word level0
	.word level0 ; 1
	.word level0 ; 2
	.word level0 ; 3
	.word level0 ; 4
	.word level0 ; 5
	.word level0 ; 6
	.word level0 ; 7
level_table_end:

level_table_size = level_table_end - level_table
