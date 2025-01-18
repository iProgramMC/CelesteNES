; Copyright (C) 2024-2025 iProgramInCpp

; I know it sounds absurd that we're putting this type of code into the "pause"
; bank, of all things, but come on, it's 7K free, it's fine...

; ** Entity Draw/Update routines
; Parameters:
;   temp1 - Entity Index (passed in through X too)
;   temp2 - X Screen Position
;   temp3 - Y Screen Position
;   temp4 - X High Position

; ** ENTITY: Particle
.proc xt_draw_particle
	lda temp2
	cmp #$F8
	bcc @dontCheckOffScreen
	
	lda temp4
	bmi @returnEarly
	lda temp2

@dontCheckOffScreen:
	sta x_crd_temp
	lda temp3
	sta y_crd_temp
	ldy sprspace+sp_part_chrti, x
	lda sprspace+sp_part_chrat, x
	jsr oam_putsprite

@returnEarly:
	;jmp xt_update_particle
.endproc

.proc xt_update_particle
	ldx temp1
	lda #0
	sta temp7
	
	lda sprspace+sp_part_vel_x, x
	sta temp5
	bpl :+
	lda #$FF
	sta temp7
	
:	clc
	lda sprspace+sp_x, x
	adc temp5
	sta sprspace+sp_x, x
	lda sprspace+sp_x_pg, x
	adc temp7
	sta sprspace+sp_x_pg, x
	
	lda sprspace+sp_vel_y_lo, x
	clc
	adc sprspace+sp_y_lo, x
	sta sprspace+sp_y_lo, x
	
	lda sprspace+sp_part_vel_y, x
	bmi @velMinus
	
	; velocity is positive. that means that a SET carry determines overflow
	adc sprspace+sp_y, x
	bcc @setY
	
	lda #0
	sta sprspace+sp_kind, x  ; particle went off screen, actually!
	lda #$F0
	bne @setY
	
@velMinus:
	; velocity is negative. means that a CLEAR carry determines overflow
	adc sprspace+sp_y, x
	bcs @setY
	lda #$00
@setY:
	sta sprspace+sp_y, x
	
	; gravity
	lda sprspace+sp_vel_y_lo, x
	clc
	adc sprspace+sp_part_gravi, x
	sta sprspace+sp_vel_y_lo, x
	
	bcc @done
	inc sprspace+sp_vel_y, x
@done:
	dec sprspace+sp_part_timer, x
	bne :+
	lda #0
	sta sprspace+sp_kind, x
:	rts
.endproc

; ** ENTITY: Refill Placeholder
.proc xt_draw_refillhold
	lda #pal_green
	jsr gm_allocate_palette
	sta temp5
	ora #$40
	sta temp8
	lda #$9A
	sta temp6
	sta temp7
	jsr gm_draw_common
	;jmp xt_update_refillhold
.endproc

.proc xt_update_refillhold
	ldx temp1
	dec sprspace+sp_oscill_timer, x
	bne :+
	; time to replace with a normal one
	lda sprspace+sp_refill_oldos, x
	sta sprspace+sp_oscill_timer, x
	lda #e_refill
	sta sprspace+sp_kind, x
	
:	rts
.endproc

; ** ENTITY: Refill
.proc xt_draw_refill
	lda #pal_green
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	lda #$FC
	sta temp6
	lda #$FE
	sta temp7
	jsr gm_draw_common
	;jmp xt_update_refill
.endproc

.proc xt_update_refill
	jsr gm_ent_oscillate
	
	jsr gm_check_player_bb
	beq @return
	
	; collided!
	; check if the dash count is non zero.
	lda dashcount
	bne @break
	
	; dash count is zero (never dashed), so check stamina
	lda stamina+1
	bne @return
	
	lda stamina
	cmp #stamlowthre
	bcs @return
	
@break:
	; player has dashed which means 
	; break into 4 pieces, destroy, and give the player their dashes back
	
	lda #$98
	sta temp4   ; character tile
	lda #3
	sta temp5   ; tile attributes
	
	lda #8
	sta temp9   ; lifetime
	lda #0
	sta temp8   ; gravity
	
	ldx #0
	jsr gm_spawn_particle_at_ent
	inx
	jsr gm_spawn_particle_at_ent
	inx
	jsr gm_spawn_particle_at_ent
	inx
	jsr gm_spawn_particle_at_ent
	
	ldx temp1
	lda sprspace+sp_refill_flags, x
	and #erf_regen
	beq @setKind
	
	lda sprspace+sp_oscill_timer, x
	sta sprspace+sp_refill_oldos, x
	
	lda #$96
	sta sprspace+sp_oscill_timer, x
	lda #e_refillhd
	
@setKind:
	sta sprspace+sp_kind, x
	
	lda #0
	sta dashcount
	lda #<staminamax
	sta stamina
	lda #>staminamax
	sta stamina+1
	
@return:
	rts
.endproc

; ** ENTITY: Spring
.proc xt_draw_spring
	jsr xt_update_spring
	lda #pal_red
	jsr gm_allocate_palette
	sta temp5
	ora #obj_fliphz
	sta temp8
	ldy temp1
	ldx sprspace+sp_spring_frame, y
	lda @frames, x
	sta temp6
	sta temp7
	dec temp3 ; correction because sprites are drawn with a 1 px down offset
	jmp gm_draw_common

@frames: .byte $C0, $C2, $C4, $CA, $C4, $CA, $C4, $C2, $C6, $C8
.endproc

.proc xt_update_spring
	ldy temp1
	ldx temp1
	lda sprspace+sp_spring_frame, y
	beq @idleTime
	
	dec sprspace+sp_spring_timer, x
	bne @idleTime
	
	ldx sprspace+sp_spring_frame, y
	inx
	cpx #10
	bne :+
	ldx #0
:	txa
	sta sprspace+sp_spring_frame, y
	lda @frametimes, x
	sta sprspace+sp_spring_timer, y

@idleTime:
	; is the player colliding?
	lda #14
	sta temp8
	lda #0
	sta temp7
	lda #16
	sta temp9
	sta temp10
	jsr gm_check_collision_ent
	beq @return
	
	lda #1
	sta sprspace+sp_spring_frame, y
	lda #5
	sta sprspace+sp_spring_timer, y
	
	jsr gm_spring_sfx
	
	; propel the player!
	lda temp10
	jmp gm_superbounce
	
@return:
	rts

@frametimes:	.byte 5, 3, 6, 8, 7, 8, 9, 5, 4, 4
; note: frame 2 is constantly oscillating
.endproc

; ** ENTITY: Key
.proc xt_draw_key
	lda #pal_gold
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	lda #$DC
	sta temp6
	lda #$DE
	sta temp7
	jmp gm_draw_common
.endproc

; ** ENTITY: Points
.proc xt_draw_points
	lda #pal_blue
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	
	ldx temp1
	
	sec
	lda sprspace+sp_y_lo, x
	sbc #$60
	sta sprspace+sp_y_lo, x
	
	lda sprspace+sp_y, x
	sbc #0
	beq @clearKind
	sta sprspace+sp_y, x
	
	lda sprspace+sp_points_timer, x
	sec
	sbc #1
	bne @skipClearKind
@clearKind:
	sta sprspace+sp_kind, x
@skipClearKind:
	sta sprspace+sp_points_timer, x
	
	lda sprspace+sp_points_count, x
	pha
	cmp #6
	bne @no1UpMode
	
	; 1 up mode
	lda #$8E
	sta temp7
	bne @done
	
@no1UpMode:
	; normal points mode
	lda #$80
	sta temp7
	
@done:
	pla
	asl
	clc
	adc #$80
	sta temp6
	
	jmp gm_draw_common
.endproc

; ** ENTITY: Crumble Block
.proc xt_inactive_block
	lda sprspace+sp_flags, x
	and #<~ef_collidable
	sta sprspace+sp_flags, x
	jmp xt_draw_crumble_block_okay
.endproc

.proc xt_draw_crumble_block
	; set collision box
	ldx temp1
	
	lda sprspace+sp_crumbl_state, x
	cmp #2
	beq xt_inactive_block
	
	lda sprspace+sp_flags, x
	ora #ef_collidable
	sta sprspace+sp_flags, x
	
	lda sprspace+sp_crumbl_width, x
	sta sprspace+sp_wid, x
	lda #8
	sta sprspace+sp_hei, x
	
okay:
	lda sprspace+sp_crumbl_state, x
	beq @idleState
	
	cmp #1
	beq @shakingState
	
	; inactive state
	ldy sprspace+sp_crumbl_timer, x
	iny
	tya
	sta sprspace+sp_crumbl_timer, x
	cpy #120
	bcc @done
	
	lda #0
	sta sprspace+sp_crumbl_state, x
	sta sprspace+sp_crumbl_timer, x
	bne @done

@shakingState:
	ldy sprspace+sp_crumbl_timer, x
	iny
	tya
	sta sprspace+sp_crumbl_timer, x
	cpy #30
	bcc @done
	
	inc sprspace+sp_crumbl_state, x ; increment to inactive state
	bne @done
	
@idleState:
	lda entground
	cmp temp1
	bne @done
	
	inc sprspace+sp_crumbl_state, x ; increment to shaking state

@done:
	lda #0
	sta plattemp1
	
	lda temp3
	sta y_crd_temp
	
	; prepare the X coordinate
	lda temp2
	sta x_crd_temp
	cmp #$F8
	bcc @smallerThanF8
	
	lda temp4
	bpl @smallerThanF8
	
	; X high coord < $00, don't draw that part
	lda #8
	sta plattemp1
	clc
	adc x_crd_temp
	sta x_crd_temp
	
	; if it's only 1 wide then just return
	cmp sprspace+sp_crumbl_width, x
	bcs @justReturn
	
@smallerThanF8:
	lda #pal_gray
	jsr gm_allocate_palette
	sta temp5
	
	ldx temp1
	
	; initiate loop here
@loop:
	lda plattemp1
	lsr
	lsr
	and #2
	clc
	adc #$B6
	tay
	
	; tile number prepared
	lda sprspace+sp_crumbl_state, x
	cmp #1
	bne @notShaking
	
	; is shaking
	lda x_crd_temp
	pha
	lda y_crd_temp
	pha
	
	jsr randint
	clc
	adc x_crd_temp
	sta x_crd_temp
	
	jsr randint
	clc
	adc y_crd_temp
	sta y_crd_temp
	
	lda temp5
	jsr oam_putsprite
	
	pla
	sta y_crd_temp
	pla
	sta x_crd_temp
	jmp @shaken
	
@notShaking:
	cmp #2
	bne @notInactive
	ldy #$BA
	
@notInactive:
	lda temp5
	jsr oam_putsprite
	
@shaken:
	lda x_crd_temp
	clc
	adc #8
	bcs @justReturn
	sta x_crd_temp
	
	lda plattemp1
	clc
	adc #8
	sta plattemp1
	
	ldx temp1
	cmp sprspace+sp_crumbl_width, x
	bcc @loop
	
@justReturn:
	rts

randint:
	jsr rand
	and #3
	sec
	sbc #2
	rts
.endproc

xt_draw_crumble_block_okay = xt_draw_crumble_block::okay

; ** ENTITY: Breakable Block
.proc xt_draw_breakable_block
	ldx temp1
	lda dreinvtmr
	beq :+
	jmp transitionMode
	
:	lda sprspace+sp_flags, x
	ora #ef_collidable
	sta sprspace+sp_flags, x
	
	and #ef_collided
	pha
	bne collided

normal:
	pla
	rts

collided:
	; despawn this entity
	lda dashtime
	beq normal
	cmp #(defdashtime-dashchrgtm)
	bcs normal

collidedforce:
	lda #0
	sta sprspace+sp_kind, x
	
	lda sprspace+sp_wid, x
	lsr
	lsr
	lsr
	sta clearsizex
	sta temp10
	lda sprspace+sp_hei, x
	lsr
	lsr
	lsr
	sta clearsizey
	sta temp11
	
	lda sprspace+sp_y, x
	lsr
	lsr
	lsr
	clc
	adc vertoffshack
	cmp #30
	bcc :+
	sbc #30
:	tay
	
	lda sprspace+sp_x_pg, x
	lsr
	lda sprspace+sp_x, x
	ror
	lsr
	lsr
	tax
	
	lda #$01
	sta setdataaddr
	sta setdataaddr+1
	jsr h_request_transfer
	
	lda #0
	jsr h_clear_tiles
	
	lda temp10
	sta clearsizex
	lda temp11
	sta clearsizey
	
	; TODO: not yet that good
	;jsr gm_crumble_sfx
	
	pla
	beq return
	jmp gm_rebound

transitionMode:
	; In transition mode, check if the player is interacting with us in the final frames
	lda sprspace+sp_flags, x
	and #<~ef_collidable
	sta sprspace+sp_flags, x
	
	; check if the player's hitbox is inside
	lda sprspace+sp_wid, x
	sta temp9
	lda sprspace+sp_hei, x
	sta temp10
	lda #0
	sta temp7
	sta temp8
	
	txa
	tay
	jsr gm_check_collision_ent
	beq return
	
	; is collided, so just break, but DON'T rebound
	lda #0
	pha
	jmp collidedforce

return:
	rts
.endproc

xt_berry_bitset:	.byte 1,2,4,8,16,32,64,128

; ** ENTITY: Strawberry
.proc xt_draw_berry
	ldx temp1
	lda sprspace+sp_strawb_state, x
	bne @skipInit
	
	inc sprspace+sp_strawb_state, x
	lda sprspace+sp_strawb_ident, x
	lsr
	lsr
	lsr
	sta temp11
	
	lda sprspace+sp_strawb_ident, x
	and #7
	tay
	lda xt_berry_bitset, y
	pha
	ldy temp11
	and sstrawberries, y
	beq @wasntCollectedBefore
	
	lda sprspace+sp_strawb_flags, x
	ora #esb_ppicked
	sta sprspace+sp_strawb_flags, x
	
@wasntCollectedBefore:
	pla
	and strawberries, y
	beq @skipInit
	
	; actually it's not even supposed to be here
	lda #0
	sta sprspace+sp_kind, x
	rts
	
@skipInit:
	txa
	pha
	
	; NOTE: pal_red==1, pal_blue==0, this is what's being assumed here!]
	lda sprspace+sp_strawb_flags, x
	and #esb_ppicked
	lsr
	lsr
	eor #1
	sta temp11
	
	jsr xt_update_berry
	bne @shrinking
	
	; normal rendering
	lda temp11
	jsr gm_allocate_palette
	sta temp5
	sta temp8
	
	pla
	sta temp1
	tax
	
	lda #$F8
	sta temp6
	lda #$FA
	sta temp7
	jmp gm_draw_common

@shrinking:
	; shrinking
	lda temp11
	jsr gm_allocate_palette
	sta temp8
	ora #obj_fliphz
	sta temp5
	
	pla
	sta temp1
	tax
	lda sprspace+sp_strawb_timer, x
	and #$FC
	lsr
	clc
	adc #$CC
	sta temp6
	sta temp7
	jmp gm_draw_common
.endproc

.proc xt_update_berry
	ldx temp1
	
	lda sprspace+sp_strawb_flags, x
	and #esb_shrink
	bne @shrinkingMode_
	
	lda sprspace+sp_strawb_flags, x
	and #esb_picked
	beq @floatingMode
	
	; trailing behind player mode
	lda sprspace+sp_strawb_colid, x
	and #7
	beq :+
	
	dec sprspace+sp_strawb_colid, x
	
:	lda sprspace+sp_strawb_colid, x
	eor #$FF
	clc
	adc plrtrahd
	
	and #$3F
	tay
	
	clc
	lda temp2
	cmp #$F8
	bcc :+
	lda #0
:	adc plr_trace_x, y
	ror                 ; average between temp2 and plr_trace_x
	sta temp2
	
	clc
	lda temp3
	adc plr_trace_y, y
	ror
	sta temp3
	
	clc
	lda temp2
	adc camera_x
	sta sprspace+sp_x, x
	
	lda camera_x_pg
	adc #0
	sta sprspace+sp_x_pg, x
	
	lda temp3
	sta sprspace+sp_y, x
	
	lda groundtimer
	bmi @return
	cmp #9
	bcc @return
	
	lda sprspace+sp_strawb_colid, x
	cmp #9
	bcs @return
	
	jmp gm_pick_up_berry_entity
	
@return:
	lda #0
	rts

@shrinkingMode_:
	bne @shrinkingMode

@floatingMode:
	jsr gm_ent_oscillate
	; floating mode
	jsr gm_check_player_bb
	bne :+
	rts
	
:	; collided, set to picked up mode
	lda sprspace+sp_strawb_flags, x
	ora #esb_picked
	sta sprspace+sp_strawb_flags, x
	
	inc plrstrawbs
	lda plrstrawbs
	asl
	asl
	asl
	sta sprspace+sp_strawb_colid, x
	bne @return

@shrinkingMode:
	; TODO
	ldy sprspace+sp_strawb_timer, x
	iny
	tya
	cmp #15
	bcs @collect
	sta sprspace+sp_strawb_timer, x
	
	; sp_strawb_timer
	lda #1
	rts

@collect:
	lda #0
	sta sprspace+sp_kind, x
	
	lda temp3
	pha
	lda temp2
	pha
	jsr gm_give_points_ent
	pla
	sta temp2
	pla
	sta temp3
	
	lda #1
	rts
.endproc

; ** ENTITY: Falling Block
.proc xt_draw_falling_block
	lda #g3_transitA
	bit gamectrl3
	bne @return_first
	
	ldx temp1
	lda sprspace+sp_fall_state, x
	beq @state_Init
	cmp #1
	beq @state_Init2
	cmp #2
	beq @state_Hanging_
	cmp #3
	beq @state_Shaking
	cmp #4
	beq @state_Falling

@return_first:
	rts
	
@state_Init:
	inc sprspace+sp_fall_state, x
	
	; Initialization: load some properties from the data index
	lda sprspace+sp_fall_dindx, x
	asl
	tay
	lda xt_falling_block_table, y
	sta temp10
	sta sprspace+sp_fall_datlo, x
	iny
	lda xt_falling_block_table, y
	sta temp10+1
	sta sprspace+sp_fall_dathi, x
	
	ldy #0
	lda (temp10), y
	sta sprspace+sp_wid, x
	iny
	lda (temp10), y
	sta sprspace+sp_hei, x
	and #$80
	sta sprspace+sp_fall_spike, x
	lda sprspace+sp_hei, x
	and #$7F
	sta sprspace+sp_hei, x

@state_Init2:
	; Check if the entirety of the block is visble
	; If the screen position PLUS the width overflows, then the other
	; end is off screen and may not necessarily have been loaded.
	lda temp2
	clc
	adc sprspace+sp_wid, x
	bcs @return_first
	
	; Totally visible, so continue the init process
	inc sprspace+sp_fall_state, x
	
	; set ourself as collidable
	lda sprspace+sp_flags, x
	ora #ef_collidable
	sta sprspace+sp_flags, x
	
	; clear the tiles in the tile map though --
	; we want the player to collide with this object instead
	jsr computeClearSizeEntity
	jsr computeTileXYForEntity
	
	lda #0
	jmp h_clear_tiles

@state_Shaking:
	dec sprspace+sp_fall_timer, x
	beq @startFalling
	
	; shake!
	lda sprspace+sp_fall_timer, x
	and #3
	tay
	lda shakeTable, y
	clc
	adc temp2
	sta temp2
	lda temp4
	adc shakeTableH, y
	sta temp4
	jmp drawSpriteVersion

@state_Hanging_:
	beq @state_Hanging

@startFalling:
	lda #0
	sta sprspace+sp_vel_y, x
	sta sprspace+sp_vel_y_lo, x
	
	inc sprspace+sp_fall_state, x
	jmp drawSpriteVersion

@state_Falling:
	; set up the data pointer
	lda sprspace+sp_fall_datlo, x
	sta plattemp1
	lda sprspace+sp_fall_dathi, x
	sta plattemp1+1
	
	; Preliminarily try to add the Y vel to the Y and compare
	lda sprspace+sp_y, x
	clc
	adc sprspace+sp_vel_y, x
	ldy #5
	cmp (plattemp1), y
	bcc @dontNeedToClamp
	
	lda (plattemp1), y
	sec
	sbc sprspace+sp_y, x
	sta sprspace+sp_vel_y, x
	
@dontNeedToClamp:
	lda temp3
	pha
	
	txa
	pha
	tay
	jsr gm_ent_move_y
	pla
	sta temp1
	tax
	
	pla
	sta temp3
	
	; if it somehow fell >= $F0, then just return
	lda sprspace+sp_y, x
	cmp #240
	bcs @die
	
	; set up the data pointer again
	lda sprspace+sp_fall_datlo, x
	sta plattemp1
	lda sprspace+sp_fall_dathi, x
	sta plattemp1+1
	
	; maxY resides at index 5
	ldy #5
	lda sprspace+sp_y, x
	cmp (plattemp1), y
	bcs @landed
	
	; gravity
@didntLand:
	lda sprspace+sp_vel_y_lo, x
	clc
	adc #$20
	sta sprspace+sp_vel_y_lo, x
	bcc :+
	inc sprspace+sp_vel_y, x
	lda sprspace+sp_vel_y, x
	cmp #8
	bcc :+
	lda #8
	sta sprspace+sp_vel_y, x
:	jmp drawSpriteVersion

@die:
	lda #0
	sta sprspace+sp_kind, x
	rts

@state_Hanging:
	cpx entground
	bne @return
	
	inc sprspace+sp_fall_state, x
	lda #48
	sta sprspace+sp_fall_timer, x
	
	; clear it from the visible tiles
	lda #$01
	sta setdataaddr
	sta setdataaddr+1
	
	lda temp1
	pha
	
	jsr computeClearSizeEntity
	jsr computeTileXYForEntity
	jsr h_request_transfer
	
	pla
	sta temp1
	
	; start drawing the sprite version
	ldx temp1
	jsr drawSpriteVersion
	
@return:
	rts

@landed:
	lda #0
	sta sprspace+sp_kind, x
	
	lda (plattemp1), y
	sta sprspace+sp_y, x
	
	; prepare the data
	iny ; maxY resides at index 5, chr offset at index 6
	lda (plattemp1), y
	sta setdataaddr
	iny
	lda (plattemp1), y
	sta setdataaddr+1
	
	; get the tile number
	ldy #2
	lda (plattemp1), y
	sta temp11
	
	; first, modify the tilemap to set the solid tiles
	jsr computeClearSizeEntity
	jsr computeTileXYForEntity
	lda temp11
	jsr h_clear_tiles
	
	ldx temp1
	lda sprspace+sp_fall_spike, x
	;and #$80
	beq @notSpikedWhenSetting
	
	; well yeah we'll have to set the spikes
	; TODO depend on the level? for now, #$3F
	jsr computeClearSizeEntity
	lda #1
	sta clearsizey
	jsr computeTileXYForEntity
	lda #$3F
	jsr h_clear_tiles
	
	; then program the PPU transfer
	; TODO: figure out a way not to call these twice.
	; they're not that expensive, but they are annoying
@notSpikedWhenSetting:
	ldx temp1
	jsr computeClearSizeEntity
	jsr computeTileXYForEntity
	jsr h_request_transfer
	
	lda #$7
	sta quakeflags
	sta quaketimer
	
	lda temp11
	cmp #2
	beq @deleteBerries
	rts

@deleteBerries:
	ldy #0
:	lda sprspace+sp_kind, y
	cmp #e_strawb
	bne :+
	lda #0
	sta sprspace+sp_kind, y
:	iny
	cpy #sp_max
	bne :--
	rts

drawSpriteVersion:
; Falling Block Data struct offsets:
; 0 - Width
; 1 - Height
; 2 - Tile to set when landing
; 3 - Bank to set while rendering
; 4 - Palette to use
; 5 - Y before the platform lands
; 6 - Low byte of CHR data addr
; 7 - High byte of CHR data addr
;+8 - Sprite Data
@off_sprite_data = 8

@xLimit  := plattemp1
@yLimit  := plattemp2
@attrib  := temp9
@dataPtr := temp10 ; and temp11
@currY   := temp7
@spridx  := temp6
@oldoam  := temp8
	
	; TODO: this probably isn't the right place
	cpx entground
	bne @thisIsntTheGround
	
	lda sprspace+sp_fall_spike, x
	;and #$80
	beq @thisIsntTheGround
	
	lda playerctrl
	and #pl_ground
	beq @thisIsntTheGround
	
	; die!!
	jsr gm_killplayer
	
@thisIsntTheGround:
	; Draws the sprite version of this entity.
	lda sprspace+sp_fall_datlo, x
	sta @dataPtr+0
	lda sprspace+sp_fall_dathi, x
	sta @dataPtr+1
	
	; Check if the bank needs to be loaded
	ldy #3
	lda (@dataPtr), y
	beq @noBankNeeded
	sta spr1_bknum
@noBankNeeded:
	
	lda sprspace+sp_wid, x
	clc
	adc #7
	lsr
	lsr
	lsr
	sta @xLimit
	;dec @xLimit
	
	lda sprspace+sp_hei, x
	clc
	adc #15
	lsr
	lsr
	lsr
	lsr
	sta @yLimit
	
	iny ; now looking at the palette
	lda (@dataPtr), y
	jsr gm_allocate_palette
	sta @attrib
	
	lda #@off_sprite_data
	sta @spridx
	jsr @skipLeftSpriteIfNeeded
	
	; if the amount of cols to draw is now 0
	lda @xLimit
	beq @breakColumn
	
	ldx temp1
	lda sprspace+sp_fall_spike, x
	;and #$80
	beq @notSpiked
	
	lda @xLimit
	pha
	lda x_crd_temp
	pha
	lda y_crd_temp
	pha
	
	lda temp3
	sec
	sbc #16
	sta y_crd_temp
	
@loopSpikeColumn:
	lda @attrib
	ldy #$5E
	jsr oam_putsprite
	
	lda x_crd_temp
	clc
	adc #8
	sta x_crd_temp
	
	dec @xLimit
	bne @loopSpikeColumn
	
	pla
	sta y_crd_temp
	pla
	sta x_crd_temp
	pla
	sta @xLimit
@notSpiked:
	
	lda oam_wrhead
	sta @oldoam
	
@loopColumn:
	lda temp3
	sta y_crd_temp
	
	lda @yLimit
	sta @currY
	
@loopRow:
	ldy @spridx
	inc @spridx
	lda (@dataPtr), y
	tay
	lda @attrib
	jsr oam_putsprite
	
	lda y_crd_temp
	clc
	adc #16
	bcs @breakRow
	sta y_crd_temp
	
	dec @currY
	bne @loopRow
	
@breakRow:
	; row complete, increment column
	lda x_crd_temp
	clc
	adc #8
	bcs @breakColumn
	sta x_crd_temp
	
	dec @xLimit
	bne @loopColumn

@breakColumn:
	jmp @shuffleOAM

@skipLeftSpriteIfNeeded:
	lda temp2
	cmp #$F8
	bcc :+
	
	; sprite X is bigger than $F8, because either the sprite is to the
	; left of the screen (so fraudulently got there via overflow), or
	; legitimately to the right
	lda temp4
	bmi @skipLeftSprite
	lda temp2
:	sta x_crd_temp
	rts
	
@skipLeftSprite:
	lda x_crd_temp
	and #7
	sta x_crd_temp
	
	; decrement the width (used to terminate the loop)
	dec @xLimit
	
	; also skip the first column in the data
	lda sprspace+sp_hei, x
	lsr
	lsr
	lsr
	clc
	adc #@off_sprite_data
	sta @spridx

@dont:
	rts

@shuffleOAM:
	lda framectr
	and #1
	bne @dont
	
	; @oldoam    - OLD OAM head
	; oam_wrhead - NEW OAM head
	ldx @oldoam
	ldy oam_wrhead
	jmp invert_oam_order

computeClearSizeEntity:
	lda sprspace+sp_wid, x
	lsr
	lsr
	lsr
	sta clearsizex
	
	lda sprspace+sp_hei, x
	lsr
	lsr
	lsr
	sta clearsizey
	
	; if spiked on top, also take the upper tile with it
	lda sprspace+sp_fall_spike, x
	;and #$80
	beq :+
	inc clearsizey
:	rts

computeTileXYForEntity:
	lda sprspace+sp_y, x
	lsr
	lsr
	lsr
	tay
	
	; if spiked on top, also take the upper tile with it
	lda sprspace+sp_fall_spike, x
	;and #$80
	beq :+
	dey
	
:	lda sprspace+sp_x_pg, x
	lsr
	lda sprspace+sp_x, x
	ror
	lsr
	lsr
	tax
	rts

shakeTable:		.byte $01,$00,$FF,$00
shakeTableH:	.byte $00,$00,$FF,$00
.endproc

; FALLING BLOCK definitions

; NOTE about the "tile to set": 2 means to delete all strawberries!!
xt_falling_block_table:
	.word fall_ch1_a
	.word fall_ch1_b
	.word fall_ch1_c
	.word fall_ch1_d ; 3 - level1_r12, 24, 40, max Y 176
	.word fall_ch1_e ; 4 - level1_r12, 16, 24, max Y 200
	.word fall_ch1_f ; 5 - level1_r12, 24, 32+128, max Y 184
	.word fall_ch2_a ; 6
	.word fall_ch2_b ; 7



; *********************************************************

; ** SUBROUTINE: xt_draw_ent_call
; desc: Calls the relevant entity draw function.
; arguments:
;     A - entity type
;     temp1 - entity index
; note: temp1 is occupied by xt_draw_entities and represents the index within the sprspace array.
xt_draw_ent_call:
	pha
	lda #e_l2chaser
	cmp sprspace+sp_kind, x
	beq @isDarkChaser
	
	jsr xt_check_ent_onscreen
	bne @notOffScreen
	
	pla
	cmp #e_particle
	bne @notParticle
	
	; particle went off screen HAHA, destroy it
	lda #0
	sta sprspace+sp_kind, x
	
@notParticle:
	rts
	
@notOffScreen:
	; note: xt_check_ent_onscreen already calculated the x coordinate for us
	
	lda #e_strawb
	cmp sprspace+sp_kind, x
	bne @forceAddingCamY
	
	lda sprspace+sp_y, x
	sec
	sbc camera_y_sub
	sec
	sbc temp10
	sta temp3
	
	lda sprspace+sp_strawb_flags, x
	and #esb_picked    ; picked sprites do not need cameraY added to them
	bne @doNotAddCamY
	
@forceAddingCamY:
	jsr @decideLvlOff
	asl
	asl
	asl
	sta temp3
	lda sprspace+sp_y, x
	clc
	adc temp3
	sta temp3
	sec
	sbc camera_y_bs
	sec
	sbc camera_y_sub
	sec
	sbc temp10
	sta temp3
	
@doNotAddCamY:
@isDarkChaser:
	pla
	tax
	lda xt_entjtable_lo, x
	sta lvladdr
	lda xt_entjtable_hi, x
	sta lvladdrhi
	
	ldx temp1
	
	jmp (lvladdr)

@decideLvlOff:
	lda sprspace+sp_flags, x
	lsr ; assert: ef_oddroom == $02
	eor roomnumber
	and #1
	beq @decideLvlOff_same
	
	; different
	lda old_lvlyoff
	rts

@decideLvlOff_same:
	lda lvlyoff
	rts

level2_memorial_kludge:
	ldx #<level1_memorial
	ldy #>(level1_memorial - ($C000-$A000))
	lda #prgb_lvl1b
	jmp far_call2

.define entity_jump_table   \
	$0000,                  \
	xt_draw_berry,          \
	xt_draw_refill,         \
	xt_draw_spring,         \
	xt_draw_key,            \
	xt_draw_particle,       \
	xt_draw_refillhold,     \
	xt_draw_points,         \
	level0_intro_crusher,   \
	xt_draw_crumble_block,  \
	level0_bridge_manager,  \
	level0_granny,          \
	level0_bird_climb,      \
	level0_bird_dash,       \
	level1_zip_mover,       \
	level1_zip_mover,       \
	level2_payphone,        \
	xt_draw_breakable_block,\
	level2_mirror,          \
	level2_campfire,        \
	level1_campfire,        \
	level2_dark_chaser,     \
	xt_draw_falling_block,  \
	level1_memorial,        \
	level2_memorial_kludge

xt_entjtable_lo: .lobytes entity_jump_table
xt_entjtable_hi: .hibytes entity_jump_table

; ** SUBROUTINE: xt_check_ent_onscreen
; desc:     Checks if an entity is off of the screen.
; parms:    Y - entity index
; returns:  ZF - entity is off-screen
; clobbers: A, X, temp3, temp4, temp10. not Y
xt_check_ent_onscreen:
	lda #0
	sta temp10
	
	lda sprspace+sp_flags, x
	and #ef_limbo
	bne @returnZero             ; if entity is in limbo
	lda sprspace+sp_x, x
	sec
	sbc camera_x
	sta temp2
	
	lda sprspace+sp_x_pg, x
	sbc camera_x_pg
	sta temp4
	
	; result < 0: sprite went off the left side.
	; result = 0: sprite is in view.
	; result > 0: sprite is to the right.
	bmi @checkLeft
	beq @moreChecking
	
	; result is 0.
@returnZero:
	lda sprspace+sp_kind, x
	cmp #e_strawb
	bne @notStrawBerry
	
	lda sprspace+sp_strawb_flags, x
	and #esb_picked
	beq @notStrawBerry
	
	; ALWAYS render this
	bne @returnOne
	
@notStrawBerry:
	lda #0
	rts
	
@checkLeft:
	; result is different from 0. we should check if the low byte is > $F8
	lda temp2
	cmp #$F8
	bcc @returnZero

@moreChecking:
	; ok, totally in bounds, now see if we're in an up room transition
	lda #g3_transitU
	bit gamectrl3
	beq @returnOne
	
	; if the room numbers are different
	lda sprspace+sp_flags, x
	; ef_oddroom == $02
	lsr
	eor roomnumber
	and #1
	asl
	asl
	asl
	asl
	sta temp10
	
	lda sprspace+sp_y, x
	sec
	sbc camera_y
	
	; carry SET -- return zero for OLD ROOM
	lda #0
	rol
	; ef_oddroom == $02
	asl
	eor sprspace+sp_flags, x
	lsr
	eor roomnumber
	and #1
	
	; carry ^ (entityRoomNumberParity ^ activeRoomNumberParity)
	beq @returnZero
	
@returnOne:
	lda #1
	rts

; ** SUBROUTINE: xt_draw_entities
; desc: Draws visible entities to the screen.
.proc xt_draw_entities
	lda #1
	bit framectr
	
	beq @evenFrame
	
	; odd frame
	ldx #(sp_max - 1)
@loopOdd:
	lda sprspace+sp_kind, x
	beq :+             ; this is an empty entity slot. waste no time
	stx temp1
	jsr xt_draw_ent_call
	ldx temp1
:	dex
	cpx #$FF
	bne @loopOdd
	rts
	
@evenFrame:
	ldx #0
@loopEven:
	lda sprspace+sp_kind, x
	beq :+             ; this is an empty entity slot. waste no time
	stx temp1
	jsr xt_draw_ent_call
	ldx temp1
:	inx
	cpx #sp_max
	bne @loopEven
	rts
.endproc
