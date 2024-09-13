
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
	tya
	ldx x_crd_temp
	ldy y_crd_temp
	jsr ppu_loadaddr
	tay
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
	.word h_tile_ground
	.word h_tile_ground_v
	.word h_tile_change
	.word h_tile_backgd
	.word h_tile_backgd_v
	.word h_tile_backgd_c

h_genmt_screenstop:
	lda #$10
	eor tr_scrnpos
	sta tr_scrnpos
	jsr gm_adv_tile
	jmp h_genmt_readdone

; ** SUBROUTINE: h_generate_metatiles
; desc:    Generates a column of metatiles ahead of the visual column render head.
h_generate_metatiles:
	; read tile data until X is different
	jsr gm_read_tile_na
	cmp #$FF
	beq h_genmt_readdone
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
	cpy #10
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
	
; ** SUBROUTINE: gamemode_init
gm_game_init:
	lda #$00
	sta gamectrl      ; clear some game fields
	sta ntwrhead
	sta arwrhead
	sta tr_scrnpos
	sta ppu_mask      ; disable rendering
	sta camera_x
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
	
	jsr vblank_wait
	jsr ppu_rstaddr   ; reset PPUADDR
	lda #def_ppu_msk  ; turn rendering back on
	sta ppu_mask
	
	lda gamectrl
	ora #gs_1stfr
	eor #gs_flstcols  ; all columns have already been flushed
	sta gamectrl
	jmp gm_game_update

; ** GAMEMODE: gamemode_game
gamemode_game:
	lda gamectrl
	and #gs_1stfr
	beq gm_game_init
gm_game_update:
	; for now, check if the right key is pressed, and advance the
	; camera and column generation logic
	lda #cont_right
	bit p1_cont
	beq gm_dontright
	
	; add camspeed to camera_x / camera_x_hi. make sure camera_x_hi
	; is 0 and 1 only.
	lda #1
	clc
	adc camera_x
	sta camera_x
	lda #0
	adc camera_x_hi
	and #1
	sta camera_x_hi
	lda #7
	bit camera_x
	bne gm_dontright
	jsr h_generate_column
gm_dontright:
	jmp game_update_return

