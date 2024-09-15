
; ** SUBROUTINE: h_get_tile
; desc:    Gets the value of a tile in loaded areaspace for the horizontal layout
;          (equivalent of the C code "areaspace[y * 32 + x]")
; arguments:
;     x - X coordinate
;     y - Y coordinate
; returns:  a - Tile value
; clobbers: a,x
;
; NOTE for h_get_tile1: the Y coordinate must be in A when you call!
h_get_tile:
	tya
	asl                 ; shift left by 5.  The last shift will put the bit in carry
h_get_tile1:
	asl
	asl
	asl
	asl
	bcc h_load_4
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	tax
	lda areaspace+$100, x
	rts
h_load_4:
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	tax
	lda areaspace, x
	rts

; ** SUBROUTINE: h_set_tile
; desc:    Sets the value of a tile in loaded areaspace for the horizontal layout
;          (equivalent of the C code "areaspace[y * 32 + x]")
; arguments:
;     x - X coordinate
;     y - Y coordinate
;     a - Tile value
; clobbers: a,x
h_set_tile:
	pha
	tya
	asl                 ; shift left by 5.  The last shift will put the bit in carry
	asl
	asl
	asl
	asl
	bcc h_store_4
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	tax
	pla
	sta areaspace+$100, x
	rts
h_store_4:
	sta x_crd_temp
	txa
	clc
	adc x_crd_temp
	tax
	pla
	sta areaspace, x
	rts

; ** SUBROUTINE: h_flush_palette_init
; desc:    Flushes a generated palette column in temppal to the screen if gs_flstpal is set
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts), increment to 1
h_flush_palette_init:
	lda #gs_flstpal
	bit gamectrl
	bne h_flush_palette
	rts

; ** SUBROUTINE: h_flush_palette
; desc:    Flushes a generated palette column in temppal to the screen
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts), increment to 1
h_flush_palette:
	clc
	lda ntwrhead
	sbc #2
	and #$20
	beq h_flupal_high
	ldx #$27
	jmp h_flupal_done
h_flupal_high:
	ldx #$23
h_flupal_done:
	stx y_crd_temp      ; store the high byte of the nametable address there. we'll need it.
	ldx #$C0
	stx x_crd_temp
	lda ntwrhead
	lsr
	clc
	sbc #1
	lsr
	and #7
	clc
	adc x_crd_temp
	sta x_crd_temp
	; need to write 8 bytes.
	ldy #0
h_flupal_loop:
	ldx y_crd_temp
	stx ppu_addr
	ldx x_crd_temp
	stx ppu_addr
	lda temppal, y
	sta ppu_data
	lda #8
	adc x_crd_temp
	sta x_crd_temp
	iny
	cpy #8
	bne h_flupal_loop
	rts

; ** SUBROUTINE: h_flush_column
; desc:    Flushes a generated column in tempcol to the screen
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts)
h_flush_column:
	lda #ctl_irq_i32
	sta ppu_ctrl

	; the PPU address we want to start writing to is
	; 0x2000 + (ntwrhead / 32) * 0x400 + (ntwrhead % 32)
	lda ntwrhead
	ldy #$20
	and #$20
	beq h_dontadd4
	iny
	iny
	iny
	iny
h_dontadd4:
	lda ntwrhead
	and #$1F
	tax
	jsr ppu_loadaddr
	
	; start writing tiles.
	; each iteration will write 2 character tiles for one metatile.
	ldy #0
h_fls_wrloop:
	lda tempcol, y
	sta ppu_data
	iny
	cpy #$1E
	bne h_fls_wrloop

	; advance the write head but keep it within 64
	ldx ntwrhead
	inx
	txa
	and #$3F
	sta ntwrhead
	
	; set the PPUCTRL increment back to 1
	lda ctl_flags
	ora #ctl_irq_off
	sta ppu_ctrl
	rts

; ** SUBROUTINE: h_generate_column
; desc:    Generates a vertical column of characters corresponding to the respective
;          metatiles in area space.
; assumes: PPUCTRL has the IRQ bit set to zero (dont generate interrupts)
h_generate_column:
	; start writing tiles.
	; each iteration will write 2 character tiles for one metatile.
	ldy #0
h_gen_wrloop:
	lda ntwrhead
	lsr                 ; get the tile coordinate
	tax                 ; x = ntwrhead >> 1
	tya
	jsr h_get_tile1
	asl
	asl
	sta drawtemp
	lda ntwrhead
	and #1
	asl
	clc
	adc drawtemp
	tax
	
	lda metatiles,x
	sta tempcol, y
	inx
	iny
	lda metatiles,x
	sta tempcol, y
	iny
	
	cpy #$1E
	bne h_gen_wrloop

	; set the gamectrl gs_flstcols flag
	lda #gs_flstcols
	ora gamectrl
	sta gamectrl
	
	; check if we were writing the odd column
	; generate a column of metatiles if so
	lda ntwrhead
	and #$01
	beq h_gen_dont
	jsr h_generate_metatiles
	; check if we're writing the 3rd odd column
	lda ntwrhead
	and #$03
	cmp #$03
	beq h_generate_palette
h_gen_dont:
; TODO: make scroll stopping work well
;	lda #gs_scrstop
;	bit gamectrl
;	beq h_flupal_ret
;	lda gamectrl
;	ora #gs_scrstopd
;	sta gamectrl
;h_flupal_ret:
	rts

; ** SUBROUTINE: h_gen_pal_blk
; arguments: y - Y position of block
; desc:      Generates a palette value in A to use as attributes.
h_gen_pal_blk:
	tya
	asl
	asl
	clc
	adc #3
	tay           ; y = y << 2 + 3
	ldx temprender, y
	lda metatile_palette, x
	asl
	asl
	dey
	ldx temprender, y
	ora metatile_palette, x
	asl
	asl
	dey
	ldx temprender, y
	ora metatile_palette, x
	asl
	asl
	dey
	ldx temprender, y
	ora metatile_palette, x
	rts

; ** SUBROUTINE: h_generate_palette
; desc: Generates a palette for a 15X2 column of tiles.
h_generate_palette:
	; this loop puts the metatiles in the proper order to generate palettes
	; for them easily
	ldy #0
	sty tr_bufidx
h_genpal_loop:
	; fetch the upper left tile
	lda ntwrhead
	lsr
	clc
	sbc #0
	tax              ; x = ntwrhead >> 1, y is this loop's iterator
	stx tr_regsto    ; store x in tr_regsto because it's clobbered by h_get_tile
	jsr h_get_tile
	ldx tr_regsto
	sty tr_regsto    ; store y in tr_regsto to load the write offset
	ldy tr_bufidx    ; load the write offset from tr_bufidx
	sta temprender,y
	iny
	sty tr_bufidx
	ldy tr_regsto
	; fetch the upper right tile
	inx
	stx tr_regsto
	jsr h_get_tile
	ldx tr_regsto
	sty tr_regsto
	ldy tr_bufidx
	sta temprender,y
	iny
	sty tr_bufidx
	ldy tr_regsto
	; fetch the lower left tile
	iny
	dex
	stx tr_regsto
	jsr h_get_tile
	ldx tr_regsto
	sty tr_regsto
	ldy tr_bufidx
	sta temprender,y
	iny
	sty tr_bufidx
	ldy tr_regsto
	; fetch the lower right tile
	inx
	stx tr_regsto
	jsr h_get_tile
	ldx tr_regsto
	sty tr_regsto
	ldy tr_bufidx
	sta temprender,y
	iny
	sty tr_bufidx
	ldy tr_regsto
	; done, now increment Y
	dex
	iny
	cpy #$10
	bne h_genpal_loop
	
	ldy #0
h_gen_paltestloop:
	sty tr_regsto
	jsr h_gen_pal_blk
	ldy tr_regsto
	sta temppal, y
	iny
	cpy #8
	bne h_gen_paltestloop
	lda #gs_flstpal
	ora gamectrl
	sta gamectrl
	rts

; ** TILE OBJECT TYPE: h_tile_ground
; desc: Horizontal strip of ground.
h_tile_ground:
	jsr gm_read_tile
	jsr gm_read_tile    ; read into A: [4:7-flags] [0:3-y position]
	sta tr_regsto       ; save the attrs now
	lsr
	lsr
	lsr
	lsr                 ; get size from attributes
	tax                 ; save it into X
	lda tr_regsto       ; reload the attrs
	and #$F             ; JUST the y position please
	tay                 ; save the Y coordinate
	lda currground      ; load the current ground tile
	sta tilecounts,y    ; save it into the tilecounts[y] array
	txa                 ; get the size from X into A
	cmp #0
	bne h_tilegnd_dontset
	lda #16
h_tilegnd_dontset:
	sta tilecounts+16,y ; save t at tilecounts[y+16]
	jmp h_genmt_continue

; ** TILE OBJECT TYPE: v_tile_ground
; desc: Vertical strip of ground.
h_tile_ground_v:
	jsr gm_read_tile
	jsr gm_read_tile    ; read into A: [4:7-flags] [0:3-y position]
	sta tr_regsto       ; save the attrs now
	lsr
	lsr
	lsr
	lsr                 ; get size from attributes
	sta tr_bufidx       ; save it into tr_bufidx
	lda tr_regsto       ; reload the attrs
	and #$F             ; JUST the y position please
	tay                 ; save the Y coordinate
	ldx #0
h_tgv_loop:
	lda currground      ; load the current ground tile
	sta tilecounts,y    ; save it into the tilecounts[y] array
	lda #1
	sta tilecounts+16,y
	iny
	inx
	cpx tr_bufidx
	bne h_tgv_loop
	
	jmp h_genmt_continue

; ** TILE OBJECT TYPE: h_tile_change
; desc: Change the active ground type.
h_tile_change:
	jsr gm_read_tile
	jsr gm_read_tile
	sta currground
	jmp h_genmt_continue

; ** TILE OBJECT TYPE: h_tile_change
; desc: Change the active background type.
h_tile_backgd_c:
	jsr gm_read_tile
	jsr gm_read_tile
	sta currbackgd
	jmp h_genmt_continue

h_tile_backgd:
h_tile_backgd_v:
	; TODO
	jmp h_genmt_continue

h_tile_opcodes:
	.word h_tile_ground    ; 0
	.word h_tile_ground_v  ; 1
	.word h_tile_change    ; 2
	.word h_tile_backgd    ; 3
	.word h_tile_backgd_v  ; 4
	.word h_tile_backgd_c  ; 5

h_genmt_screenstop:
	lda #$10
	eor tr_scrnpos
	sta tr_scrnpos
	jsr gm_adv_tile
	jmp h_genmt_readdone

h_genmt_readstop:
	lda #gs_scrstop
	ora gamectrl
	sta gamectrl
	jmp h_genmt_readdone

; ** SUBROUTINE: h_generate_metatiles
; desc:    Generates a column of metatiles ahead of the visual column render head.
h_generate_metatiles:
	; read tile data until X is different
	jsr gm_read_tile_na
	cmp #$FF
	beq h_genmt_readstop
	cmp #$FE
	beq h_genmt_screenstop
	sta tr_mtaddrlo
	and #$F0             ; fetch the X coordinate
	lsr
	lsr
	lsr
	lsr
	clc
	adc tr_scrnpos       ; add it on top of the current screen position
	cmp arwrhead
	bne h_genmt_readdone ; if arwrhead2 == tr_scrnpos + objectX
	; process this object
	lda tr_mtaddrlo
	and #%1111
	asl
	tay
	lda h_tile_opcodes, y
	sta tr_mtaddrlo
	iny
	lda h_tile_opcodes, y
	sta tr_mtaddrhi
	jmp (tr_mtaddrlo)
h_genmt_continue:      ; the return address from the jump table
	jmp h_generate_metatiles
h_genmt_readdone:
	
	; generate any previously set up block rows
	; if there are none, simply generate blank
	ldy #$00
h_genmtloop:
	lda tilecounts+16,y
	cmp #0
	beq h_genmtsetzero
	clc
	sbc #0
	sta tilecounts+16,y
	lda tilecounts,y
	jmp asdsd
h_genmtsetzero:          ; when this label is BRANCHED to, a is zero
	;jsr rand
	;and #7
asdsd:
	ldx arwrhead
	jsr h_set_tile
	iny
	cpy #$0F
	bne h_genmtloop
	
	; loop done, increment arwrhead, ensuring it rolls over after 31
	clc
	lda #1
	adc arwrhead
	and #$1F
	sta arwrhead
	rts

; ** SUBROUTINE: gm_increment_ptr
; ** SUBROUTINE: gm_decrement_ptr
; args: x - offset in zero page to (in/de)crement 16-bit address
; clobbers: a
gm_increment_ptr:
	lda #00
	sec
	adc $0000, x
	sta $0000, x
	rts
gm_decrement_ptr:
	lda #00
	sec
	sbc $0000, x
	sta $0000, x
	rts
; ** SUBROUTINE: gm_set_level_ptr
; ** SUBROUTINE: gm_set_room_ptr
; ** SUBROUTINE: gm_set_tile_head
; ** SUBROUTINE: gm_set_ent_head
; args:
;     x - low byte
;     y - high byte
gm_set_level_ptr:
	stx lvlptrlo
	sty lvlptrhi
	rts
gm_set_room_ptr:
	stx roomptrlo
	sty roomptrhi
	rts
gm_set_tile_head:
	stx arrdheadlo
	sty arrdheadhi
	rts
gm_set_ent_head:
	stx entrdheadlo
	sty entrdheadhi
	rts

; ** SUBROUTINE: gm_adv_tile
; ** SUBROUTINE: gm_adv_ent
; desc:     Advances the tile or entity stream by 1 byte.
; clobbers: x
gm_adv_tile:
	pha
	ldx #<arrdheadlo
	jsr gm_increment_ptr
	pla
	rts
gm_adv_ent:
	pha
	ldx #<entrdheadlo
	jsr gm_increment_ptr
	pla
	rts

; ** SUBROUTINE: gm_read_tile_na
; ** SUBROUTINE: gm_read_ent_na
; ** SUBROUTINE: gm_read_tile
; ** SUBROUTINE: gm_read_ent
; desc: Reads a byte from the tile or entity streams. The _na versions don't
; advance the pointer.
; returns: a - the byte of data read in
; clobbers: x
gm_read_tile_na:
	ldx #0
	lda (arrdheadlo,x)
	rts
gm_read_ent_na:
	ldx #0
	lda (entrdheadlo,x)
	rts
gm_read_tile:
	jsr gm_read_tile_na
	jmp gm_adv_tile
gm_read_ent:
	jsr gm_read_ent_na
	jmp gm_adv_ent

; ** SUBROUTINE: gm_fetch_room
; args: y - offset into lvl array
; clobbers: a, x, y
; desc: loads a room, initializes the tile and entity streams
gm_fetch_room:
	; load room pointer from lvl pointer
	lda (lvlptrlo),y
	tax
	iny
	lda (lvlptrlo),y
	tay
	jsr gm_set_room_ptr
	ldy #3

gm_fetch_room_loop:
	lda (roomptrlo),y
	sta currground-3,y
	iny
	cpy #14
	bne gm_fetch_room_loop
	
	; load tile pointer from room pointer, Y=10
	lda (roomptrlo),y
	tax
	iny
	lda (roomptrlo),y
	tay
	jsr gm_set_tile_head
	iny

	; load entity pointer from room pointer
	lda (roomptrlo),y
	tax
	iny
	lda (roomptrlo),y
	tay
	jsr gm_set_ent_head
	rts

; ** SUBROUTINE: gm_set_level_1
gm_set_level_1:
	ldx #<lvl_1
	ldy #>lvl_1
	jsr gm_set_level_ptr
	ldy #2
	jsr gm_fetch_room
	rts

; ** SUBROUTINE: gm_draw_2xsprite
; arguments: x - offset into zero page with sprite structure
;            a - x position, y - y position
; structure:  [shared attributes] [left sprite] [right sprite]
gm_draw_2xsprite:
	sta x_crd_temp
	sty y_crd_temp
	lda $00,x       ; get shared attributes into a
	inx
	ldy $00,x       ; get left sprite
	inx
	stx temp7
	jsr oam_putsprite
	ldx temp7
	ldy $00,x       ; get right sprite
	lda x_crd_temp  ; add 8 to x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	dex
	dex
	lda $00,x       ; get shared attributes again
	jsr oam_putsprite
	rts

; ** SUBROUTINE: gm_draw_player
gm_draw_player:
	lda #pl_left
	bit playerctrl
	bne gm_facingleft
	lda #0
	ldx plr_spr_l
	ldy plr_spr_r
	sta temp1
	stx temp2
	sty temp3
	lda plh_attrs
	ldx plh_spr_l
	ldy plh_spr_r
	sta temp4
	stx temp5
	sty temp6
	jmp gm_donecomputing
gm_facingleft:
	lda #obj_fliphz
	ldx plr_spr_r
	ldy plr_spr_l
	sta temp1
	stx temp2
	sty temp3
	ora plh_attrs
	ldx plh_spr_r
	ldy plh_spr_l
	sta temp4
	stx temp5
	sty temp6
gm_donecomputing:
	ldx #temp1           ; draw player
	lda player_x
	ldy player_y
	jsr gm_draw_2xsprite
	ldx #temp4           ; draw hair
	lda player_x
	ldy player_y
	jsr gm_draw_2xsprite
	rts

; ** SUBROUTINE: gm_anim_player
; desc: Updates the sprite numbers for the player character and their hair.
; note: gm_anim_player starts a little below.
gm_jumping:
	ldx #plr_jump_l
	ldy #plr_jump_r
	stx plr_spr_l
	sty plr_spr_r
	ldx #plr_hamvu_l
	ldy #plr_hamvu_r
	stx plh_spr_l
	sty plh_spr_r
	rts
gm_falling:
	ldx #plr_fall_l
	ldy #plr_fall_r
	stx plr_spr_l
	sty plr_spr_r
	ldx #plr_hamvd_l
	ldy #plr_hamvd_r
	stx plh_spr_l
	sty plh_spr_r
	rts
gm_anim_player:
	ldx dashcount
	inx
	stx plh_attrs    ; set the palette to the dash count + 1
	lda dashtime
	cmp #0
	bne gm_dashing
	lda player_vl_y
	bmi gm_jumping   ; if it's <0, then jumping
	lda #pl_ground
	bit playerctrl
	beq gm_falling   ; if pl_ground set, then moving only in X direction
	lda player_vl_x  ; check if both components of the velocity are zero
	bne gm_anim_notidle
	lda player_vs_x
	beq gm_anim_idle
gm_anim_notidle:
	lda #pl_left     ; check if facing left
	bit playerctrl
	beq gm_anim_right
	lda player_vl_x  ; load the player's velocity but flip its sign
	eor #$FF
	clc
	adc #1
	bmi gm_flip      ; if A <= 0, then flipping
	beq gm_flip
	jmp gm_right
gm_anim_right:
	lda player_vl_x
	bmi gm_flip      ; if A < 0, then flipping
	jmp gm_right     ; if A >= 0, then running. vl_x==vs_x==0 case is already handled.
gm_anim_idle:
	ldx #plr_idle1_l
	ldy #plr_idle1_r
	stx plr_spr_l
	sty plr_spr_r
	ldx #plr_hasta_l
	ldy #plr_hasta_r
	stx plh_spr_l
	sty plh_spr_r
	rts
gm_flip:
	ldx #plr_flip_l
	ldy #plr_flip_r
	stx plr_spr_l
	sty plr_spr_r
	ldx #plr_haflp_l
	ldy #plr_haflp_r
	stx plh_spr_l
	sty plh_spr_r
	rts
gm_dashing:
	ldx #plr_dash_l
	ldy #plr_dash_r
	stx plr_spr_l
	sty plr_spr_r
	ldx #plr_hadsh_l
	ldy #plr_hadsh_r
	stx plh_spr_l
	sty plh_spr_r
	rts
gm_right:
	ldx #plr_walk3_l
	ldy #plr_walk3_r
	stx plr_spr_l
	sty plr_spr_r
	ldx #plr_hamvr_l
	ldy #plr_hamvr_r
	stx plh_spr_l
	sty plh_spr_r
	rts
	
; ** SUBROUTINE: gm_getdownforce
; desc:    Gets the downward force in the A register depending on their state.
gm_getdownforce:
	lda player_vl_y
	bpl gm_defaultgrav
	lda #cont_a
	bit p1_cont
	bne gm_defaultgrav  ; if A isn't held, then use a stronger gravity force
	lda #gravitynoA
	rts
gm_defaultgrav:
	lda #gravity
	rts
	
; ** SUBROUTINE: gm_gravity
; desc:    If player is not grounded, applies a constant downward force.
gm_gravity:
	lda #pl_ground
	bit playerctrl
	beq gm_apply_gravity
	rts
gm_apply_gravity:
	jsr gm_getdownforce
	clc
	adc player_vs_y
	sta player_vs_y
	lda #0
	adc player_vl_y
	sta player_vl_y
	rts

; ** SUBROUTINE: gm_dragshift
; desc:    Shifts the 16-bit number at (temp2, temp1) by 1.
gm_dragshift:
	clc
	lda temp2
	ror
	sta temp2
	lda temp1
	ror
	sta temp1
	rts
	
; ** SUBROUTINE: gm_drag
; desc:    Apply a constant dragging force that makes the X velocity tend to zero.
gm_drag:
	lda dashtime
	bne gm_drag4      ; while dashing, ensure drag doesn't take hold
	lda #%00000011    ; check if any direction on the D-pad is held
	bit p1_cont       ; don't apply drag while holding buttons (the
	bne gm_drag4      ; button routines pull the player towards maxwalk)
	lda player_vl_x
	bne gm_drag5
	lda player_vs_x
	beq gm_drag4      ; if both vl_x nor vs_x are zero, then return
gm_drag5:
	lda player_vl_x   ; perform one shift to the right, this divides by 2
	clc
	ror
	sta temp2
	lda player_vs_x
	ror
	sta temp1
	jsr gm_dragshift  ; perform another shift to the right
	lda #%00100000
	bit temp2         ; check if the high bit of the result is 1
	beq gm_drag2
	lda temp2
	ora #%11000000    ; extend the sign
	sta temp2
gm_drag2:
	ldx temp2
	bne gm_drag3
	ldx temp1         ; make sure the diff in question is not zero
	bne gm_drag3      ; this can't happen with a negative velocity vector
	inx               ; because it is not null. but it can happen with a
	stx temp1         ; positive velocity vector less than $00.$04
gm_drag3:
	sec
	lda player_vs_x
	sbc temp1
	sta player_vs_x
	lda player_vl_x
	sbc temp2
	sta player_vl_x
gm_drag4:
	rts

gm_appmaxwalkL:
	; this label was reached because the velocity is < -maxwalk.
	; if we are on the ground, we need to approach maxwalk.
	lda #pl_ground
	bit playerctrl
	beq gm_appmaxwalkrtsL
	lda player_vl_x
	bpl gm_appmaxwalkrtsL  ; If the player's velocity is >= 0, don't perform any adjustments
	clc
	lda player_vs_x
	adc #maxwalkad
	sta player_vs_x
	lda player_vl_x
	adc #0
	sta player_vl_x
	cmp #(maxwalk^$FF+1)
	bcc gm_appmaxwalkrtsL  ; A < -maxwalk, so there's still some approaching to be done
	beq gm_appmaxwalkrtsL  ; A == -maxwalk
	lda #(maxwalk^$FF+1)
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_appmaxwalkrtsL:
	rts

gm_appmaxwalkR:
	; this label was reached because the velocity is > maxwalk.
	; if we are on the ground, we need to approach maxwalk.
	lda #pl_ground
	bit playerctrl
	beq gm_appmaxwalkrtsR
	lda player_vl_x
	bmi gm_appmaxwalkrtsR  ; If the player's velocity is negative, don't perform any adjustments
	beq gm_appmaxwalkrtsR  ; Ditto with zero
	sec
	lda player_vs_x
	sbc #maxwalkad
	sta player_vs_x
	lda player_vl_x
	sbc #0
	sta player_vl_x
	cmp #maxwalk
	bcs gm_appmaxwalkrtsR  ; A >= maxwalk, so there's still some approaching to be done
	lda #maxwalk
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_appmaxwalkrtsR:
	rts

gm_add3xL:
	beq gm_dontadd3xL
	sec
	lda player_vs_x
	sbc #(accel*3)
	jmp gm_added3xL

gm_add3xR:
	clc
	lda player_vs_x
	adc #(accel*3)
	jmp gm_added3xR

gm_appmaxwalkR_BEQ:
	beq gm_appmaxwalkR

; ** SUBROUTINE: gm_pressedleft
gm_pressedleft:
	ldx #0
	lda player_vl_x
	bpl gm_lnomwc
	cmp #(maxwalk^$FF+1) ; compare it to the max walking speed
	bcc gm_lnomwc    ; carry clear if A < -maxwalk.
	ldx #1           ; if it was bigger than the walking speed already,
gm_lnomwc:           ; then we don't need to check the cap
	lda player_vl_x
	bpl gm_add3xL
gm_dontadd3xL:
	sec
	lda player_vs_x
	sbc #accel
gm_added3xL:
	sta player_vs_x
	lda player_vl_x
	sbc #accelhi
	sta player_vl_x
	lda #pl_left
	ora playerctrl
	sta playerctrl
	cpx #0           ; check if we need to cap it to -maxwalk
	beq gm_lnomwc2   ; no, instead, approach -maxwalk
	lda player_vl_x  ; load the player's position
	cmp #(maxwalk^$FF+1)
	bcs gm_lnomwc2   ; carry set if A >= -maxwalk meaning we don't need to
	lda #(maxwalk^$FF+1)
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_lnomwc2:
	rts

; ** SUBROUTINE: gm_pressedright
gm_pressedright:
	ldx #0
	lda player_vl_x
	bmi gm_rnomwc    ; if the player was moving left a comparison would lead to an overcorrectiom
	cmp #(maxwalk+1) ; compare it to the max walking speed
	bcs gm_rnomwc    ; if it was bigger than the walking speed already,
	ldx #1           ; then we don't need to check the cap
gm_rnomwc:
	lda player_vl_x
	bmi gm_add3xR    ; A < 0, then add stronger accel
	clc
	lda player_vs_x
	adc #accel
gm_added3xR:
	sta player_vs_x
	lda player_vl_x
	adc #accelhi
	sta player_vl_x
	lda #(pl_left ^ $FF)
	and playerctrl
	sta playerctrl
	cpx #0           ; check if we need to cap it to maxwalk
	beq gm_appmaxwalkR_BEQ ; no, instead, approach maxwalk
	lda player_vl_x  ; load the player's position
	cmp #maxwalk
	bcc gm_rnomwc2   ; carry set if A >= maxwalk meaning we don't need to
	lda #maxwalk     ; cap it at maxwalk
	sta player_vl_x
	lda #0
	sta player_vs_x
gm_rnomwc2:
	rts

; ** SUBROUTINE: gm_controls
; desc:    Check controller input and apply forces based on it.
gm_dontdash:
	lda #cont_right
	bit p1_cont
	bne gm_pressedright
	lda #cont_left
	bit p1_cont
	bne gm_pressedleft
	rts
gm_controls:
	lda #cont_a
	bit p1_cont
	beq gm_dontjump   ; if the player pressed A
	bit p1_conto
	bne gm_dontjump   ; if the player wasn't pressing A last frame
	lda #pl_ground
	bit playerctrl
	bne gm_jump
gm_dontjump:
	lda #cont_b
	bit p1_cont
	beq gm_dontdash   ; if the player pressed B
	bit p1_conto
	bne gm_dontdash   ; if the player wasn't pressing B last frame
	lda dashcount
	cmp #maxdashes
	bcs gm_dontdash   ; and if the dashcount is < maxdashes
	ldx dashcount
	inx
	stx dashcount
	ldx #defdashtime
	stx dashtime
	jmp gm_dontdash
gm_jump:
	lda #(jumpvel ^ $FF + 1)
	sta player_vl_y
	lda #(jumpvello ^ $FF + 1)
	sta player_vs_y
	; add a small boost to the currently held direction TODO
	jmp gm_dontdash

; ** SUBROUTINE: gm_sanevels
; desc:    Ensure sane maximums
gm_sanevels:
	ldy #0
	jsr gm_sanevelx
	jmp gm_sanevely
	
gm_sanevelx:
	lda player_vl_x
	bmi gm_negvelx
	; positive x velocity
	cmp #maxvelxhi
	bcc gm_nocorvelx
	lda #maxvelxhi
	sta player_vl_x
	sty player_vs_x
gm_nocorvelx:
	rts
gm_negvelx:
	cmp #(maxvelxhi^$FF + 1)
	bcs gm_nocorvelx
	lda #(maxvelxhi^$FF + 1)
	sta player_vl_x
	sty player_vs_x
	rts
gm_sanevely:
	lda player_vl_y
	bmi gm_negvely
	; positive y velocity
	cmp #maxvelyhi
	bcc gm_nocorvely
	lda #maxvelyhi
	sta player_vl_y
	sty player_vs_y
gm_nocorvely:
	rts
gm_negvely:
	cmp #(maxvelyhi^$FF + 1)
	bcs gm_nocorvely
	lda #(maxvelyhi^$FF + 1)
	sta player_vl_y
	sty player_vs_y
	rts

; ** SUBROUTINE: gm_getleftx
; desc: Gets the tile X position where the left edge of the player's hitbox resides
; returns: A - the X coordinate
; clobbers: A
gm_getleftx:
	clc
	lda player_x
	adc #(8-plrwidth/2); determine leftmost hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda player_x_hi
	adc camera_x_hi
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_getrightx
; desc:     Gets the tile X position where the right edge of the player's hitbox resides
; returns:  A - the X coordinate
; clobbers: A
; note:     this is NOT ALWAYS the same as the result of gm_getleftx!! though perhaps
;           some optimizations are possible..
gm_getrightx:
	clc
	lda player_x
	adc #(15-plrwidth/2); determine right hitbox position
	clc
	adc camera_x
	sta x_crd_temp    ; x_crd_temp = low bit of check position
	lda player_x_hi
	adc camera_x_hi
	ror               ; rotate it into carry
	lda x_crd_temp
	ror               ; rotate it into the low position
	lsr
	lsr
	lsr               ; finish dividing by the tile size
	rts

; ** SUBROUTINE: gm_gettopy
; desc:     Gets the tile Y position where the top edge of the player's hitbox resides
; returns:  A - the Y coordinate
; clobbers: A
gm_gettopy:
	clc
	lda player_y
	adc #(16-plrheight)
	lsr
	lsr
	lsr
	lsr
	rts

; ** SUBROUTINE: gm_getbottomy_w
; desc:     Gets the tile Y position where the bottom edge of the player's hitbox resides,
;           when checking for collision with walls.
; returns:  A - the Y coordinate
; clobbers: A
; note:     this is NOT ALWAYS the same as the result of gm_gettopy!! though perhaps
;           some optimizations are possible..
; note:     to allow for a bit of leeway, I took off one pixel from the wall check.
gm_getbottomy_w:
	clc
	lda player_y
	adc #$D
	lsr
	lsr
	lsr
	lsr
	rts

; ** SUBROUTINE: gm_getbottomy_f
; desc:     Gets the tile Y position where the bottom edge of the player's hitbox resides,
;           when checking for collision with floors.
; returns:  A - the Y coordinate
; clobbers: A
; note:     this is NOT ALWAYS the same as the result of gm_gettopy!! though perhaps
;           some optimizations are possible..
gm_getbottomy_f:
	clc
	lda player_y
	adc #$10
	lsr
	lsr
	lsr
	lsr
	rts

; ** SUBROUTINE: gm_collide
; desc:      Checks for collision.
; arguments: X - tile's x position, Y - tile's y position, A - direction
; returns:   zero flag set - not collided
; direction: 0 - floor, 1 - ceiling, 2 - left, 3 - right
gc_floor = $00
gc_ceil  = $01
gc_left  = $02
gc_right = $03
gm_collide:
	jsr h_get_tile    ; TODO: this just checks for blank tiles
	cmp #0
	rts               ; note: comparison to 0 is redundant as h_get_tile ends with a lda

; ** SUBROUTINE: gm_applyy
; desc:     Apply the velocity in the Y direction.
gm_applyy:
	clc
	lda #(pl_ground ^ $FF)
	and playerctrl
	sta playerctrl    ; remove the grounded flag - it'll be added back if we are on the ground
	lda player_vs_y
	adc player_sp_y
	sta player_sp_y
	lda player_vl_y
	adc player_y
	bcs gm_fellout    ; if an overflow happened while adding the velocity of the player over
	sta player_y
gm_didntdie:
	jsr gm_getleftx
	sta temp1
	jsr gm_getrightx
	sta temp2
	lda player_vl_y
	bmi gm_checkceil
	jmp gm_checkfloor
gm_fellout:           ; if the player fell out of the world
	sta player_y
	lda player_vl_y
	bmi gm_didntdie
	; player velocity is positive and the player fell out of the world
	; TODO: actually kill. right now just warp them up a bit
	lda #$80
	sta player_y
	rts
gm_checkceil:
	jsr gm_gettopy
	tay
	sty y_crd_temp
	ldx temp1         ; check block 1
	lda #gc_ceil
	jsr gm_collide
	bne gm_snaptoceil
	ldy y_crd_temp    ; check block 2
	ldx temp2
	lda #gc_ceil
	jsr gm_collide
	bne gm_snaptoceil
	rts
gm_snaptoceil:
	clc
	lda player_y
	adc #$0F
	and #$F0          ; calculate ((player_y + 15) % 16) * 16
	sec
	sbc #(16-plrheight)
	sta player_y      ; rounds player's position to higher mu;tiple of 16
	lda #0            ; set the subpixel to zero
	sta player_sp_y
	sta player_vl_y   ; also clear the velocity
	sta player_vs_y   ; since we ended up here it's clear that velocity was negative.
	rts
gm_checkfloor:
	jsr gm_getbottomy_f
	tay               ; keep the Y position into the Y register
	sty y_crd_temp
	ldx temp1         ; check block 1
	lda #gc_floor
	jsr gm_collide
	bne gm_snaptofloor
	ldy y_crd_temp    ; check block 2
	ldx temp2
	lda #gc_floor
	jsr gm_collide
	bne gm_snaptofloor
	rts
gm_snaptofloor:
	lda #%11110000    ; round player's position to lower multiple of 16
	and player_y
	sta player_y
	lda #0            ; set the subpixel to zero
	sta player_sp_y
	lda dashtime
	cmp #(defdashtime-dashchrgtm-2)
	bcs gm_sfloordone ; until the player has started their dash, exempt from ground check
	lda #pl_ground    ; set the grounded bit, only thing that can remove it is jumping
	ora playerctrl
	sta playerctrl
	lda #0
	sta player_vl_y
	sta player_vs_y
	sta dashcount
gm_sfloordone:
	rts
	
; ** SUBROUTINE: gm_applyx
; desc:    Apply the velocity in the X direction. 
gm_applyx:
	clc
	lda player_vl_x
	rol                      ; store the upper bit in carry
	lda #$FF
	adc #0                   ; add the carry bit if needed
	eor #$FF                 ; flip it because we need the reverse
	tay                      ; This is the "screenfuls" part that we need to add to the player position
	lda player_vs_x
	adc player_sp_x
	sta player_sp_x
	lda player_vl_x
	adc player_x
	bcs gm_nocheckoffs       ; If the addition didn't overflow, we need to detour.
	ldx player_vl_x          ; check if the velocity was positive
	bpl gm_nocheckoffs       ; yeah, of course it wouldn't overflow, it's positive!
	lda #0                   ; we have an underflow, means the player is trying to leave the screen
	ldy #0                   ; through the left side. we can't let that happen!
	clc                      ; zero out the player's new position
gm_nocheckoffs:
	sta player_x
	tya
	adc player_x_hi
	and #1
	sta player_x_hi
	jsr gm_gettopy
	sta temp1                ; temp1 - top Y
	jsr gm_getbottomy_w
	sta temp2                ; temp2 - bottom Y
	lda player_vl_x
	bmi gm_checkleft
gm_checkright:
	jsr gm_getrightx
	tax
	stx y_crd_temp           ; note: x_crd_temp is clobbered by gm_collide!
	ldy temp1
	lda #gc_right
	jsr gm_collide
	bne gm_collright         ; if collided, move a pixel back and try again
	ldy temp2                ;  snapping to the nearest tile is a BIT more complicated so
	ldx y_crd_temp           ;  I will not bother
	lda #gc_right
	jsr gm_collide
	beq gm_checkdone
gm_collright:
	ldx player_x
	beq gm_checkdone         ; if the player X is zero... we're stuck inside a wall
	dex
	stx player_x
	jmp gm_checkright        ; !! note: in case of a potential clip, this might cause lag frames!
gm_checkleft:
	jsr gm_getleftx
	tax
	stx y_crd_temp
	ldy temp1
	lda #gc_left
	jsr gm_collide
	bne gm_collleft          ; if collided, move a pixel to the right & try again
	ldy temp2
	ldx y_crd_temp
	lda #gc_left
	jsr gm_collide
	beq gm_checkdone
gm_collleft:
	ldx player_x
	cpx #$F0                 ; compare to [screenWidth-16]
	bcs gm_checkdone         ; if bigger or equal, just bail, we might be stuck in a wall
	inx
	stx player_x
	jmp gm_checkleft
gm_checkdone:
	lda player_vl_x
	bpl gm_scroll_if_needed  ; if moving positively, scroll if needed
	rts

; ** SUBROUTINE: gm_scroll_if_needed
gm_scroll_if_needed:
	lda #gs_scrstopd
	bit gamectrl
	bne gm_scroll_ret
	lda player_x
	cmp #scrolllimit
	bcc gm_scroll_ret ; A < scrolllimit
	beq gm_scroll_ret ; A = scrolllimit
gm_scroll_do:
	sec
	sbc #scrolllimit
	cmp #camspeed     ; see the difference we need to scroll
	bcc gm_scr_nofix  ; A < camspeed
	lda #camspeed
gm_scr_nofix:         ; A now contains the delta we need to scroll by
	clc
	tax               ; save the delta as we'll need it later
	adc camera_x      ; add the delta to the camera X
	sta camera_x
	lda #0
	adc camera_x_hi
	and #1
	sta camera_x_hi
	lda #scrolllimit  ; set the player's X relative-to-the-camera to scrolllimit
	sta player_x
	txa               ; restore the delta to add to camera_rev
	adc camera_rev
	sta camera_rev
	cmp #8
	bcs gm_go_generate; if camera_rev+diff < 8 return
gm_scroll_ret:
	rts
gm_go_generate:
	lda camera_rev    ; subtract 8 from camera_rev
	sec
	sbc #8
	sta camera_rev
	jmp h_generate_column

gm_dash_lock:
	ldx #0
	stx player_vl_x
	stx player_vl_y
	stx player_vs_x
	stx player_vs_y
	jmp gm_dash_update_done
gm_dash_over:
	jmp gm_dash_update_done

gm_defaultdir:
	ldy #0                  ; player will not be dashing up or down
	lda #pl_left
	and playerctrl          ; bit 0 will be the facing direction
	sec                     ; shift it left by 1 and append a 1
	rol                     ; this will result in either 1 or 3. we handle the L+R case by dashing left
	jmp gm_dash_nodir

gm_superjump:
	lda #pl_ground
	bit playerctrl
	beq gm_sjret            ; if player wasn't grounded, then ...
	lda dashdiry
	cmp #1
	bne gm_sj_normal
	; half the jump height here
	lda #((jumpvel >> 1) ^ $FF + 1)
	sta player_vl_y
	lda #((((jumpvel << 7) | (jumpvello >> 1)) ^ $FF + 1) & $FF)
	sta player_vs_y
	jmp gm_superjumph
gm_sj_normal:
	lda #(jumpvel ^ $FF + 1)
	sta player_vl_y
	lda #(jumpvello ^ $FF + 1)
	sta player_vs_y         ; super jump speed is the same as normal jump speed
gm_superjumph:
	lda #superjmphhi
	sta player_vl_x
	lda #superjmphlo
	sta player_vs_x
	lda #pl_left
	bit playerctrl
	beq gm_sjret
	lda player_vl_x
	eor #$FF
	sta player_vl_x
	lda player_vs_x
	eor #$FF
	sta player_vs_x
gm_sjret:
	rts

gm_dash_update:
	; NOTE: dashtime is loaded into A
	sec
	sbc #1
	sta dashtime
	beq gm_dash_over        ; if dashtime is now 0, then finish the dash
	cmp #(defdashtime-dashchrgtm)
	beq gm_dash_read_cont   ; if it isn't exactly defdashtime-dashchrgtm, let physics run its course
	bcs gm_dash_lock        ; dash hasn't charged
	jmp gm_dash_after
gm_dash_read_cont:
	lda p1_cont
	and #%00001111          ; check if holding any direction
	beq gm_defaultdir       ; if not, determine the dash direction from the facing direction	
	lda p1_cont
	and #%00001100          ; get just the up/down flags
	lsr
	lsr
	tay                     ; use them as an index into the dashY table
	lda p1_cont
	and #%00000011          ; get just the left/right flags
	; if horizontal flags are 0, then the vertical flags must NOT be zero, otherwise we ended up in gm_defaultdir
gm_dash_nodir:
	tax                     ; this is now an index into the X table
	stx dashdirx
	sty dashdiry
	lda #0
	sta player_vs_x
	sta player_vs_y
	lda dashY, y
	sta player_vl_y
	lda dashX, x
	bmi gm_leftdash
	sta player_vl_x
	lda playerctrl
	and #(pl_left^$FF)
	sta playerctrl
	jmp gm_dash_update_done
gm_leftdash:
	sta player_vl_x
	lda playerctrl
	ora #pl_left
	sta playerctrl
	jmp gm_dash_update_done
gm_dash_after:
	; this label is reached when the dash is "completed", i.e. it gives no more
	; boost to the player and physics are enabled.
	lda #%00000011
	bit p1_cont
	beq gm_dash_noflip  ; not pressing a direction, so no need to flip the character
	lda playerctrl
	ora #pl_left
	sta playerctrl      ; set the left bit...
	lda #cont_right     ; assumes cont_right == 1
	and p1_cont
	eor playerctrl
	sta playerctrl      ; so that, if right is pressed, then we can flip it back
gm_dash_noflip:
	lda #cont_a
	bit p1_cont
	beq gm_dash_nosj
	bit p1_conto
	bne gm_dash_nosj
	jsr gm_superjump
gm_dash_nosj:
	jmp gm_dash_update_done

; ** SUBROUTINE: gamemode_init
gm_game_init:
	lda #$00
	sta gamectrl      ; clear game related fields to zero
	sta ntwrhead
	sta arwrhead
	sta player_y
	sta player_sp_x
	sta player_sp_y
	sta camera_x
	sta camera_y
	sta camera_x_hi
	sta player_x_hi
	sta tr_scrnpos
	sta tr_mtaddrlo
	sta tr_mtaddrhi
	sta playerctrl
	sta player_vl_x
	sta player_vs_x
	sta player_vl_y
	sta player_vs_y
	sta dashtime
	sta dashcount
	sta ppu_mask      ; disable rendering
	
	; before waiting on vblank, clear game reserved spaces ($0300 - $0700)
	ldx #$00
gm_game_clear:
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
	inx
	bne gm_game_clear
	
	jsr vblank_wait
	lda #$20
	jsr clear_nt      ; clear the two nametables the game uses
	lda #$24
	jsr clear_nt
	ldy init_palette - lastpage
	jsr load_palette  ; load game palette into palette RAM
	jsr gm_set_level_1
	jsr h_generate_metatiles
	ldy #$00          ; generate tilesahead columns
loop2:
	tya
	pha
	jsr h_generate_column
	jsr h_flush_column
	jsr h_flush_palette_init
	pla
	tay
	iny
	cpy #tilesahead
	bne loop2
	
	lda #(gs_1stfr|gs_turnon)
	sta gamectrl
	jsr vblank_wait
	jmp gm_game_update

gm_dash_update1:
	jmp gm_dash_update; NOTE: remove if the gm_game_init function's slim enough!

; ** GAMEMODE: gamemode_game
gamemode_game:
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	lda dashtime
	bne gm_dash_update1
	jsr gm_gravity
	jsr gm_controls
gm_dash_update_done:
	jsr gm_drag
	jsr gm_sanevels
	jsr gm_applyy
	jsr gm_applyx
	jsr gm_anim_player
	jsr gm_draw_player
	
	lda #cont_select
	bit p1_cont
	bne gm_titleswitch
	jmp game_update_return

; ** SUBROUTINE: gm_titleswitch
gm_titleswitch:
	lda #gm_title
	sta gamemode
	lda #0
	sta titlectrl
	jmp game_update_return

dashX:
	.byte $00  ; --
	.byte $04  ; -R
	.byte $FC  ; L-
	.byte $FC  ; LR
dashY:
	.byte $00  ; --
	.byte $05  ; -D
	.byte $FB  ; U-
	.byte $00  ; UD
