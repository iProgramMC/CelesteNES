; Copyright (C) 2024 iProgramInCpp

; Desc: If you put these functions in the game segment, it will overflow.
; These functions are instead implemented in the main segment.
.include "g_decomp.asm"
.include "g_scroll.asm"
.include "g_sfx.asm"


; these tables are 25 frames in size
death_irq_table_1:	.byte 1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17,17,17,17,17,17,17
death_irq_table_2:	.byte 1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17,17,17,17,17,17,17
death_irq_table_3:	.byte 1,1,1,1,1,1,2,3,4,5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,17,17,17
death_irq_table_4:	.byte 1,1,1,1,1,1,2,3,4,5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,17,17,17
