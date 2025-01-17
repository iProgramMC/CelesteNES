; Copyright (C) 2024 iProgramInCpp

; Desc: If you put these functions in the game segment, it will overflow.
; These functions are instead implemented in the main segment.
.include "g_decomp.asm"
.include "g_scroll.asm"
.include "g_sfx.asm"

; ** SUBROUTINE: gm_load_hair_palette
; desc: Loads Madeline's hair's palette
gm_load_hair_palette:
	lda plh_forcepal
	bne :+
	lda #maxdashes
	sec
	sbc dashcount
:	jsr gm_allocate_palette
	sta plh_attrs
	rts

; ** SUBROUTINE: gm_update_ptstimer
gm_update_ptstimer:
	lda ptstimer
	beq :+            ; if ptstimer != 0, then just decrement it
	dec ptstimer
	rts
:	sta ptscount      ; if they're both 0, reset the points count and return
	rts
