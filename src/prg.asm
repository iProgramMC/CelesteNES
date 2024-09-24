
; Addresses
ppu_ctrl    = $2000
ppu_mask    = $2001
ppu_status  = $2002
oam_addr    = $2003
oam_data    = $2004	
ppu_scroll  = $2005
ppu_addr    = $2006
ppu_data    = $2007
palette_mem = $3F00
apu_dmc_cfg = $4010
apu_oam_dma = $4014
apu_joypad1 = $4016
apu_joypad2 = $4017
apu_frctr   = $4017

; Flags

; Sprite Indices
plr_idle1_l = $02
plr_idle1_r = $04
plr_idle2_l = $06
plr_idle2_r = $08
plr_jump_l  = $0A
plr_jump_r  = $0C
plr_lkup_l  = $20   ; look up
plr_lkup_r  = $22
plr_flip_l  = $24
plr_flip_r  = $26
plr_fall_l  = $28
plr_fall_r  = $2A
plr_push1_l = $36
plr_push1_r = $38
plr_clim1_l = $44   ; climb
plr_clim1_r = $46
plr_clim2_l = $48   ; climb
plr_clim2_r = $4A
plr_dang1_l = $4C
plr_dang1_r = $4E
plr_dang2_l = $50
plr_dang2_r = $52
plr_push2_l = $54
plr_push2_r = $56
plr_dash_l  = $58
plr_dash_r  = $5A
plr_walk1_l = $60
plr_walk1_r = $62
plr_walk2_l = $64
plr_walk2_r = $66
plr_walk3_l = $68
plr_walk3_r = $6A
plr_walk4_l = $6C
plr_walk4_r = $6E
plr_hasta_l = $0E   ; hair stationary
plr_hasta_r = $10
plr_hamvr_l = $12   ; hair move right
plr_hamvr_r = $14
plr_hamsr_l = $1A   ; hair move slight right
plr_hamsr_r = $1C
plr_hamvu_l = $2E   ; hair move up
plr_hamvu_r = $30
plr_hamvd_l = $2E   ; hair move down
plr_hamvd_r = $30
plr_haflp_l = $40   ; hair flip
plr_haflp_r = $42
plr_hadsh_l = $5C   ; hair dash
plr_hadsh_r = $5E

; Constants
mmc1bk_chr0 = 0     ; X reg in mmc1_selbank
mmc1bk_chr1 = 1
mmc1bk_prg  = 2
bank_spr    = $00   ; default sprite bank
bank_title  = $01   ; graphics bank used for title screen
bank_lvl0   = $02   ; graphics bank used for level 0 "prologue"
bank_lvl1   = $03   ; graphics bank used for level 1 "ruins"
blank_tile  = $00
apu_irq_off = $40
oam_buf_hi  = $07   ; matches the upper bytes of the address of oam_buf
obj_fliphz  = $40   ; flip horizontally
obj_flipvt  = $80   ; flip vertically
obj_backgd  = $20   ; behind background
leveldata   = $C000
lastpage    = $FF00
ctl_irq_off = %00110000 ; PPUCTRL with IRQs off
ctl_irq_on  = %10110000 ; PPUCTRL with IRQs on
ctl_irq_i32 = %00110100 ; PPUCTRL with IRQs off and 32 byte address advance when writing
ctl_highx   = %00000001 ; +256 to screen scroll
ctl_highy   = %00000010 ; +240 to screen scroll
def_ppu_msk = %00011110
gm_game     = $00   ; Game Modes
gm_title    = $01
gm_titletra = $02   ; title transition
tm_gametra  = 30    ; frames until the title->game transition ends
cont_a      = $80
cont_b      = $40
cont_select = $20
cont_start  = $10
cont_up     = $08
cont_down   = $04
cont_left   = $02
cont_right  = $01
ts_1stfr    = $01   ; first frame of title screen
ts_turnon   = $02   ; need to program the PPU mask to turn on rendering
gs_1stfr    = $01   ; first frame of game screen
gs_vertical = $02   ; is the level vertical?
gs_scrstopd = $04   ; camera scrolling is disabled
gs_scrstop  = $08   ; the end of level data was reached
gs_flstcols = $10   ; need to flush generated visual columns
gs_flstpal  = $20   ; need to flush generated palette columns
gs_turnon   = $40   ; need to program the PPU mask to turn on rendering
gs_deferpal = $80   ; defer palette generation
lf_vertical = $01   ; level flag: is this level vertical
pl_left     = $01   ; player is facing left
pl_ground   = $02   ; player is grounded
pl_pushing  = $04   ; player is pushing against a wall - either sliding or ground-pushing
pl_wallleft = $08   ; player is sliding along a wall on their LEFT side
pl_dashed   = $10   ; player has dashed before touching the ground
am_idle     = $00
am_walk     = $01
am_jump     = $02
am_fall     = $03
am_push     = $04
am_climb    = $05
am_dash     = $06
am_flip     = $07
am_climbidl = $08
af_none     = $00   ; animation flags
af_2frame   = $01   ; 2 frame animation. interpret player L and R as a pointer to a table
af_4frame   = $02   ; 4 frame animation. interpret player L and R as a pointer to a table
af_noloop   = $04   ; don't loop
af_wlkspd   = $08   ; advance timer by walk speed
af_oddryth  = $10   ; on odd frames, add 1 to the spryoff
tilesahead  = 36    ; tiles ahead of camera X
camspeed    = 4     ; maximum pixels advanced per frame by camera
maxvelyhi   = $06   ; max Y velocity in pixels
maxvelxhi   = $06   ; max X velocity in pixels
gravity     = $24   ; gravity acceleration per frame in subpixels
gravitynoA  = $90   ; gravity when A is not held and the player's going up
ctrpull     = $18   ; acceleration imposed by player pressing buttons
scrolllimit = $78   ; around halfway to the screen
jumpvel     = $03   ; jump velocity
jumpvello   = $B0   ; the low component of the jump force
;jumpvel     = $05   ; jump velocity
;jumpvello   = $20   ; the low component of the jump force
accelhi     = $00   ; acceleration when holding a direction in pixels
accel       = $10   ; subpixel component of acceleration
maxwalk     = $02   ; max walk speed in pixels
plrwidth    = $08   ; player hitbox width - 8 pixels wide
plrheight   = $0A   ; player hitbox height - 10 pixels wide
maxdashes   = 1     ; TODO: change to 2
defdashtime = 12    ; time to perform a dash
dashchrgtm  = 3     ; time to charge the dash (after this, the dash direction is checked)
maxwalkad   = $40   ; maximum walk approach delta in subpixels
superjmphhi = $04   ; super jump boost pixel part
superjmphlo = $80   ; super jump boost subpixel part
animspd     = $10   ; 256/animspd is the amount of frames per animation up-tick (for 32, it's 8 fr)
maxslidespd = $80   ; maximum slide speed in subpixels
defjmpbuff  = $04   ; 4 frames of buffering a jump
defjmpcoyot = $06   ; 6 frames of coyote time
defwjmpcoyo = $03   ; 3 frames of wall coyote time
jmphboost   = 170   ; boost applied to the player's jump when running
wjgrace     = 2     ; walls are checked this many pixels away from the hitbox for a wall jump
ct_none     = $00   ; no collision
ct_full     = $01   ; the entire tile has collision
ct_deadly   = $02   ; the tile is UP spike shaped
ct_jumpthru = $03   ; the tile is a jump through

; Variables (RAM: 0x0000 - 0x0800)
oam_buf     = $0700 ; OAM buffer, flushed every vblank to PPU OAM
oam_offset  = $0000
oam_wrhead  = $0001 ; OAM buffer write head
wr_str_temp = $0002 ; and $0003
x_crd_temp  = $0004 ; used by oam_putsprite and h_get_tile, MUST be x before y!
y_crd_temp  = $0005 ; used by oam_putsprite
tr_bufidx   = $0005 ; alias to y_crd_temp
rng_state   = $0006
p1_cont     = $0007
p1_conto    = $0008
temp1       = $0009 ; player left sprite - these 6 used by gm_draw_player
temp2       = $000A ; player right sprite
temp3       = $000B ; player sprite attrs
temp4       = $000C ; hair left sprite
temp5       = $000D ; hair right sprite
temp6       = $000E ; hair sprite attrs
temp7       = $000F ; used by gm_draw_player

player_x    = $0010 ; offset by the camera's position!
player_y    = $0011
player_sp_x = $0012 ; subpixel memory X
player_sp_y = $0013 ; subpixel memory Y
camera_x    = $0014
camera_y    = $0015
ctl_flags   = $0016 ; copied into ppuctrl
gamemode    = $0017 ; active game mode
titlectrl   = $0018 ; title control
camera_x_hi = $0019
player_x_hi = $001A ; player screen X - alternates between 0 and 1
camera_rev  = $001B ; revealed pixels - if it goes above 8, request a column to be generated
plr_spr_l   = $001C ; player sprite left
plr_spr_r   = $001D ; player sprite right
plh_spr_l   = $001E ; player hair sprite left
plh_spr_r   = $001F ; player hair sprite right

; NOTE: these addresses can and should be repurposed for in-game
tl_snow_y   = $0020 ; Y coordinates of the 16 snow particles
tl_snow_x   = $0030 ; X coordinates of the 16 snow particles
tl_timer    = $0040
tl_gametime = $0041 ; time until the transition to gm_game happens

gamectrl    = $0020 ; game control
ntwrhead    = $0021 ; name table write head (up to 64 columns)
arwrhead    = $0022 ; area space write head (up to 32 columns)
drawtemp    = $0023
lvlptrlo    = $0024 ; level pointer
lvlptrhi    = $0025
roomptrlo   = $0026 ; room pointer
roomptrhi   = $0027
arrdheadlo  = $0028 ; area read head
arrdheadhi  = $0029
entrdheadlo = $002A ; entity read head
entrdheadhi = $002B
tr_regsto   = $002C
tr_mtaddrlo = $002D ; address of the metatile
tr_mtaddrhi = $002E
tr_scrnpos  = $002F ; active screen position
currground  = $0030 ; current ground tiles placed by ground objects
currbackgd  = $0031
warp_u      = $0032 ; destination warp numbers
warp_d      = $0033
warp_l      = $0034
warp_r      = $0035
warp_u_x    = $0036 ; destination X or Y coordinates depending on warp side
warp_d_x    = $0037
warp_l_y    = $0038
warp_r_y    = $0039
roomspare   = $003A
playerctrl  = $003B
player_vl_x = $003C ; velocity X, pixels
player_vs_x = $003D ; velocity X, subpixels
player_vl_y = $003E ; velocity Y, pixels
player_vs_y = $003F ; velocity Y, subpixels
plh_attrs   = $0040 ; player hair attributes
dashtime    = $0041
dashcount   = $0042 ; times player has dashed
dashdirx    = $0043 ; dash direction X (0 - none, 1 - right, 2|3 - left)
dashdiry    = $0044 ; dash direction Y (0|3-none, 1 - down,  2   - up)
spryoff     = $0045 ; hair sprite Y offset
animmode    = $0046 ; current animation mode
animtimer   = $0047 ; current animation timer. It has a subunitary component because
animtimersb = $0048 ; the upper component is directly used as the frame index.
animflags   = $0049 ; animation flags copied from anim data
anfrptrlo   = $004A ; animation frame pointer low
anfrptrhi   = $004B ; animation frame pointer high
sprxoff     = $004C ; hair sprite X offset
spryoffbase = $004D ; hair sprite Y offset base (used for af_oddryth)
jumpbuff    = $004E ; jump buff time
jumpcoyote  = $004F ; jump coyote time, if not zero, player may jump
wjumpcoyote = $0050 ; wall jump coyote time
player_yo   = $0051 ; player Y old. used for spike collision
player_xo   = $0052 ; player Y old. used for horizontal spike collision
transoff    = $0053
lvladdr     = $0054 ; temporaries used by h_get_tile and h_set_tile
lvladdrhi   = $0055
palrdheadlo = $0056 ; palette read head
palrdheadhi = $0057
camlimit    = $0058
camlimithi  = $0059
transtimer  = $005A
trantmp3    = $005B
trntwrhead  = $005C
scrchklo    = $005D ; temporaries used for scroll checking
scrchkhi    = $005E
lvlyoff     = $005F ; level Y offset when writing name table data
trantmp1    = $0060 ; temporaries used for transitioning
trantmp2    = $0061

; large areas reserved by the game
sprspace    = $0500 ; 256 bytes

tempcol     = $0600 ; 32 bytes - temporary column to be flushed to the screen
temppal     = $0620 ; 8 bytes  - temporary palette column to be flushed to the screen
freespace1  = $06F8 ; 8 bytes of free space

areaspace   = $6000 ; 2048 bytes -- 64 X 32 area, OR 32 X 64 in V mode

.org $8000

; ** SUBROUTINE: vblank_wait
; arguments: none
; clobbers: A
vblank_wait:
	lda #$00
	bit ppu_status
	bpl vblank_wait  ; check bit 7, equal to zero means not in vblank
	rts

; ** SUBROUTINE: read_cont
; arguments: none
; clobbers:  A
; desc:      reads controller input from the player 1 port
read_cont:
	lda p1_cont
	sta p1_conto
	lda #$01
	sta apu_joypad1
	; while the strobe bit is set, buttons will be continuously reloaded.
	; this means that reading from joypad1 will always return the state
	; of the A button, the first button.
	sta p1_cont
	lsr             ; A = 0 now
	; stop the strobe by clearing joypad1. now we can start reading
	sta apu_joypad1
read_loop:
	lda apu_joypad1
	lsr a           ; bit 0 -> carry
	rol p1_cont     ; carry -> bit 0, bit 7 -> carry
	bcc read_loop
	rts

; ** SUBROUTINE: rand
; arguments: none
; clobbers:  a
; returns:   a - the pseudorandom number
; desc:      generates a pseudo random number
rand:
	lda rng_state
	asl
	bcc no_feedback
	eor #$21
no_feedback:
	sta rng_state
	lda rng_state
	rts

; ** SUBROUTINE: mmc1_selsprbank
; arguments:
;   a - bank offset in 4K blocks
mmc1_selsprbank:
	sta $A000
	lsr
	sta $A000
	lsr
	sta $A000
	lsr
	sta $A000
	lsr
	sta $A000
	rts

; ** SUBROUTINE: mmc1_selcharbank
; arguments:
;   a - bank offset in 4K blocks
mmc1_selcharbank:
	sta $C000
	lsr
	sta $C000
	lsr
	sta $C000
	lsr
	sta $C000
	lsr
	sta $C000
	rts

; ** SUBROUTINE: mmc1_selprgbank
; arguments:
;   a - bank offset in 16K blocks
mmc1_selprgbank:
	sta $E000
	lsr
	sta $E000
	lsr
	sta $E000
	lsr
	sta $E000
	lsr
	sta $E000
	rts

; ** SUBROUTINE: mmc1_control
; arguments:
;   a - the value to send to the control register
; desc: Sets the internal control register of the MMC1 mapper.
mmc1_control:
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	lsr
	sta $8000
	rts

; ** SUBROUTINE: oam_putsprite
; arguments:
;   a - attributes
;   y - tile number
;   [x_crd_temp] - y position of sprite
;   [y_crd_temp] - y position of sprite
; clobbers:  a, x
; desc:      inserts a sprite into OAM memory
oam_putsprite:
	ldx oam_wrhead  ; load the write head into X
	pha             ; push the tile number
	lda y_crd_temp  ; store the Y coordinate into OAM
	sta oam_buf, x
	inx
	tya
	sta oam_buf, x  ; store the attributes into OAM
	inx
	pla
	sta oam_buf, x  ; store the tile number into OAM
	inx
	lda x_crd_temp
	sta oam_buf, x  ; store the X coordinate into OAM
	inx
	stx oam_wrhead
	rts

; ** SUBROUTINE: load_palette
; arguments:
;   y - the offset from the last page where the palette resides
; clobbers: A, X
; assumes: PPUCTRL increment bit is zero (+1 instead of +32)
load_palette:
	lda #$3F
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldx #$00
load_palette_loop:
	lda lastpage, y
	sta ppu_data
	inx
	iny
	cpx #$20
	bne load_palette_loop
	rts

; ** SUBROUTINE: ppu_nmi_off
; arguments: none
; clobbers: A
ppu_nmi_off:
	lda ctl_flags
	ora #ctl_irq_off
	sta ppu_ctrl
	rts

; ** SUBROUTINE: ppu_nmi_on
; arguments: none
; clobbers: A
ppu_nmi_on:
	lda ctl_flags
	ora #ctl_irq_on
	sta ppu_ctrl
	rts

; ** SUBROUTINE: ppu_rstaddr
; arguments: none
; clobbers:  A
; desc:      writes $2000 to PPUADDR in vblank or after a render disable section
ppu_rstaddr:
	lda #$20
	sta ppu_addr
	lda #$00
	sta ppu_addr
	rts

; ** SUBROUTINE: ppu_loadaddr
; arguments:
;   x - low 8 bits of address
;   y - high 8 bits of address
; clobbers: none
; assumes:  none
; desc:     loads a 16-bit address into PPUADDR
ppu_loadaddr:
	sty ppu_addr
	stx ppu_addr
	rts

; ** SUBROUTINE: ppu_wrstring
; arguments:
;   x - low 8 bits of address
;   y - high 8 bits of address
;   a - length of string
; assumes:  - PPUADDR was programmed to the PPU dest address
;             writes can happen (in vblank or rendering disabled)
;           - that the string does not straddle a page
;             boundary (256 bytes)
; desc:     copies a string from memory to the PPU
; clobbers: PPUADDR, all regs
ppu_wrstring:
	stx wr_str_temp       ; store the address into a temporary
	sty wr_str_temp + 1   ; indirection slot
	ldy #$00
	tax                   ; A cannot be incremented with 1 instruction
ppu_wrsloop:              ; so use X for that purpose
	lda (wr_str_temp), y  ; use that indirection we setup earlier
	sta ppu_data
	iny
	dex
	bne ppu_wrsloop       ; if X != 0 print another
	rts

; ** SUBROUTINE: clear_nt
; arguments: a - high 8 bits of nametable address (20,24,28,2C)
; clobbers:  a, x, y
; assumes:   rendering is disabled (not enough bandwidth to clear the entire nametable during vblank)
; desc:      clears 1KB of RAM in PPU memory with video output disabled
clear_nt:
	sta ppu_addr
	lda #$00
	sta ppu_addr
	lda #blank_tile  ; clear all 1K of vram to 0x20 - the blank tile
	ldx #$00
	ldy #$00
inner_loop:
	sta ppu_data
	iny
	bne inner_loop
	inx
	cpx #$04
	bcc inner_loop   ; jump to the inner loop because y==0 guaranteed
                     ; we didn't branch because carry was set so y==0
	rts

; ** ENTRY POINT
reset:
	sei              ; disable interrupts
	cld              ; clear decimal flag - not really required
	ldx #apu_irq_off ; disable APU IRQ
	stx apu_frctr
	ldx #$ff         ; set stack pointer to 0xff
	txs
	inx              ; X = 0
	stx ppu_ctrl     ; disable PPU NMI
	stx ppu_mask     ; disable rendering
	stx apu_dmc_cfg  ; disable APU DMC IRQs
	bit ppu_status   ; clear status
	jsr vblank_wait
	
	ldx #$00
reset_clrmem:
	; clears all 2KB of work RAM. that includes the zero page.
	sta $000, x
	sta $100, x
	sta $200, x
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x
	sta $700, x
	inx
	bne reset_clrmem
	
	; bits 0-1 : mirroring (vertical)
	; bits 2-3 : prg rom bank mode (fix last bank at $C000 and switch 16K bank at $8000)
	; bit  4   : chr rom bank mode (switch two separate 4kb banks)
	lda #%11110
	jsr mmc1_control
	lda #bank_spr
	jsr mmc1_selsprbank
	
	; TODO: other setup here
	
	jsr vblank_wait  ; second vblank wait
	
	ldy init_palette - lastpage
	jsr load_palette ; move palette to palette RAM
	
	lda #$20         ; clear the two nametables
	jsr clear_nt
	lda #$24
	jsr clear_nt
	
	ldy #def_ppu_msk ; show background & sprites
	sty ppu_mask     ; set the ppu mask
	ldy #ctl_irq_on  ; set sprite size (8x16) and NMI enable
	sty ppu_ctrl
	
	ldy #gm_title
	;ldy #gm_game
	sty gamemode     ; set title screen mode
	
	ldy #$ac
	sty rng_state    ; initialize rng seed
	
	jsr vblank_wait  ; one final vblank wait
	cli
	
; ** MAIN LOOP
main_loop:
	jsr ppu_nmi_off
	jsr game_update
	jsr ppu_nmi_on
	jsr vblank_wait
	jmp main_loop

.include "update.asm"

.res leveldata - *, $FF
.include "levels.asm"
.include "metatile.asm"

.res lastpage - *, $FF
init_palette:
	.byte $0f,$20,$10,$00 ; grey tiles
	.byte $0f,$37,$16,$06 ; brown tiles
	.byte $0f,$20,$21,$11 ; blue tiles
	.byte $0f,$39,$29,$19 ; green tiles
	.byte $0f,$37,$14,$21 ; player sprite colors
	.byte $0f,$35,$15,$06 ; red/strawberry sprite
	.byte $0f,$20,$21,$11 ; blue sprite
	.byte $0f,$30,$29,$09 ; green/refill sprite

; logo data
logo_row1: .byte $20,$20,$20,$10,$20,$20,$20
logo_row2: .byte $16,$15,$11,$15,$13,$14,$15
logo_row3: .byte $17,$18,$1a,$19,$1b,$1c,$19
logo_row4: .byte $1d,$20,$20,$20,$20,$1e,$1f
logo_pal:  .byte $aa,$aa,$aa,$aa
logo_pressstart: .byte "PRESS START"

.res $FFFA - *, $FF
	.word nmi
	.word reset
	.word $fff0   ; unused
