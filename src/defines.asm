
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
apu_pulse1  = $4000
apu_pulse2  = $4004
apu_triang  = $4008
apu_noise   = $400C
apu_dmc_cfg = $4010
apu_oam_dma = $4014
apu_status  = $4015
apu_joypad1 = $4016
apu_joypad2 = $4017
apu_frctr   = $4017
mmc3_bsel   = $8000
mmc3_bdat   = $8001
mmc3_mirror = $A000
mmc3_pram   = $A001
mmc3_irqla  = $C000
mmc3_irqrl  = $C001
mmc3_irqdi  = $E000
mmc3_irqen  = $E001
mmc3bk_bg0  = 0
mmc3bk_bg1  = 1
mmc3bk_spr0 = 2
mmc3bk_spr1 = 3
mmc3bk_spr2 = 4
mmc3bk_spr3 = 5
mmc3bk_prg0 = 6   ; prg0 controls $C000-$DFFF
mmc3bk_prg1 = 7   ; prg1 controls $A000-$BFFF

; Offsets in Sprite Struct

; The sprite struct is 16 bytes.
; The sprite struct is spread across 16 segments of 16 bytes each, for a total of 256.
; So first, the sp_kind segment, then the sp_x segment, etc.
; This allows easy indexing via the X/Y registers as you can simply do:
;   lda sprspace + sp_kind, x

sp_max      = $10   ; maximum of 16 sprites.

sp_kind     = (sp_max * 0)   ; kind of sprite (see Entity Types)
sp_x        = (sp_max * 1)   ; X coordinate within a page
sp_x_hi     = (sp_max * 2)   ; X coordinate on the loaded game world
sp_x_lo     = (sp_max * 3)   ; X coordinate subpixels (used for things like crystal hearts for smooth bounceback)
sp_y        = (sp_max * 4)   ; Y coordinate
sp_y_lo     = (sp_max * 5)   ; Y coordinate subpixels
sp_x_pg     = (sp_max * 6)   ; X coordinate in pages
sp_entspec1 = (sp_max * 7)   ; entity specific 1
sp_entspec2 = (sp_max * 8)   ; entity specific 2
sp_entspec3 = (sp_max * 9)   ; entity specific 3
sp_entspec4 = (sp_max *10)   ; entity specific 4
sp_entspec5 = (sp_max *11)   ; entity specific 5
sp_entspec6 = (sp_max *12)   ; entity specific 6

; synonyms for entspec fields
sp_oscill_timer = sp_entspec1
sp_refill_flags = sp_entspec2
sp_refill_oldos = sp_entspec3
sp_strawb_flags = sp_entspec2
sp_strawb_colid = sp_entspec3
sp_points_count = sp_entspec1
sp_points_timer = sp_entspec2

sp_part_entty = sp_entspec1
sp_part_vel_x = sp_entspec2
sp_part_vel_y = sp_entspec3
sp_part_timer = sp_entspec4
sp_part_chrti = sp_entspec5
sp_part_chrat = sp_entspec6

; Entity Types
; NOTE(iProgram): Keep this up to date with LEVELEDITOR\Entity.cs (public enum eEntityType)
;                 and LEVELEDITOR\MainGame.cs (GetByteFromString)
e_none      = $00
e_strawb    = $01
e_refill    = $02
e_spring    = $03
e_key       = $04
e_particle  = $05
e_refillhd  = $06
e_points    = $07

; Entity types that turn into other entities on load
e_rerefill  = $FF ; refill with respawn flag set

; Entity Commands
ec_scrnext  = $FE
ec_dataend  = $FF

; Entity flags
erf_regen   = $01
esb_picked  = $01

; Sprite Indices
plr_idle1_l = $04
plr_idle1_r = $06
plr_jump_l  = $08
plr_jump_r  = $0A
plr_lkup_l  = $28   ; look up
plr_lkup_r  = $2A
plr_flip_l  = $0C
plr_flip_r  = $0E
plr_fall_l  = $10
plr_fall_r  = $12
plr_push1_l = $24
plr_push1_r = $26
plr_clim1_l = $1C   ; climb
plr_clim1_r = $1E
plr_dang1_l = $20   ; dangle
plr_dang1_r = $22
plr_dash_l  = $2C
plr_dash_r  = $2E
plr_walk1_l = $14
plr_walk1_r = $16
plr_walk2_l = $18
plr_walk2_r = $1A
plr_hasta_l = $32   ; hair stationary
plr_hasta_r = $30
plr_hamvr_l = $34   ; hair move right
plr_hamvr_r = $30
plr_hamsr_l = $36   ; hair move slight right
plr_hamsr_r = $30
plr_hamvu_l = $38   ; hair move up
plr_hamvu_r = $30
plr_hamvd_l = $3A   ; hair move down
plr_hamvd_r = $30
plr_haflp_l = $9C   ; hair flip
plr_haflp_r = $9E
plr_hadsh_l = $3C   ; hair dash
plr_hadsh_r = $3E

; Level Bank Format
metatiles     = $A000 ; address of metatile character data
metatile_info = $A100 ; address of metatile information
level_data    = $A200 ; address of actual level data

; SPRITE BANKS
chrb_plrsp0 = $00   ; player sprite banks
chrb_plrsp1 = $01
; unused bank 2
; unused bank 3
; unused bank 4
chrb_gesp00 = $05   ; generic sprite 0
chrb_gesp01 = $06
chrb_gesp02 = $07
chrb_gesp10 = $08   ; generic sprite 1
chrb_gesp11 = $09
chrb_gesp12 = $0A
chrb_gesp13 = $0B
chrb_gesp20 = $0C   ; generic sprite 2
chrb_gesp21 = $0D
chrb_gesp22 = $0E
chrb_gesp23 = $0F
chrb_owsp00 = $10   ; sprite banks for Overworld
chrb_owsp01 = $11
chrb_owsp02 = $12
chrb_owsp03 = $13
; BACKGROUND BANKS
chrb_bgttl  = $14   ; graphics bank for title screen
chrb_bgowd  = $18   ; graphics bank for Overworld
chrb_lvl0   = $1C   ; graphics bank for level 0 "Prologue"
chrb_lvl1   = $20   ; graphics bank for level 1 "Forsaken City"
chrb_lvl2   = $24   ; graphics bank for level 2 "Old Site"
chrb_lvl3   = $28   ; graphics bank for level 3 "Celestial Resort"
chrb_lvl4   = $2C   ; graphics bank for level 4 "Golden Ridge"
chrb_lvl5   = $30   ; graphics bank for level 5 "Mirror Temple"
chrb_lvl6   = $34   ; graphics bank for level 6 "Reflection"
chrb_lvl7   = $38   ; graphics bank for level 7 "The Summit"
chrb_lvl8   = $3C   ; graphics bank for level 8 "Core"
; PRGROM BANKS
prgb_lvl0   = $00   ; Main level data ($A000)
prgb_lvl1   = $01
prgb_lvl2   = $02
prgb_lvl3   = $03
prgb_lvl4   = $04
prgb_lvl5   = $05
prgb_lvl6   = $06
prgb_lvl7   = $07
prgb_lvl8   = $08
prgb_lvl9   = $09
prgb_lvla   = $0A   ; Shared level data ($C000)
prgb_lvlb   = $0B
prgb_lvlc   = $0C
prgb_lvld   = $0D
prgb_game   = $0E   ; bank containing game engine code.  This is fixed at $8000
prgb_main   = $0F   ; bank containing main code.  This is fixed at $E000

; Constants
def_mmc3_bn = %11000000 ; default mmc3 bank config.
                        ; two 2K banks at $1000-$1FFF, four 1K banks at $0000-$0FFF
                        ; PRG ROM fixed at $8000-$9FFF and $E000-$FFFF
blank_tile  = $00
apu_irq_off = $40
oam_buf_hi  = $07   ; matches the upper bytes of the address of oam_buf
obj_fliphz  = $40   ; flip horizontally
obj_flipvt  = $80   ; flip vertically
obj_backgd  = $20   ; behind background
miscdata    = $E000
palettepage = $FF00
pctl_nmi_on = %10000000
pctl_adv32  = %00000100
pctl_sprsz  = %00100000
pctl_bgpat  = %00010000
pctl_highx  = %00000001 ; +256 to screen scroll
pctl_highy  = %00000010 ; +240 to screen scroll
def_ppu_msk = %00011110
gm_game     = $00   ; Game Modes
gm_title    = $01
gm_titletra = $02   ; title transition
gm_overwld  = $03   ; overworld
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
os_1stfr    = $01   ; first frame of overworld screen
os_turnon   = $02   ; need to program the PPU mask to turn on rendering
os_updlvlnm = $04   ; need to update level name
os_leftmov  = $08   ; level selector moving left
os_rightmov = $10   ; level selector moving right
gs_1stfr    = $01   ; first frame of game screen
gs_vertical = $02   ; is the level vertical?
gs_scrstodR = $04   ; rightward camera scrolling is disabled
gs_scrstopR = $08   ; there is a camera limit to the right
gs_flstcolR = $10   ; need to flush generated visual columns to the right
gs_flstpalR = $20   ; need to flush generated palette columns to the right
gs_turnon   = $40   ; need to program the PPU mask to turn on rendering
gs_dontgen  = $80   ; don't generate more tiles
g2_flstrowU = $01   ; flush generated rows up
g2_flstpalU = $02   ; flush generated palette columns up
g2_autojump = $04   ; pretend the jump button is being held until landing
lf_vertical = $01   ; level flag: is this level vertical
pl_left     = $01   ; player is facing left
pl_ground   = $02   ; player is grounded
pl_pushing  = $04   ; player is pushing against a wall - either sliding or ground-pushing
pl_wallleft = $08   ; player is sliding along a wall on their LEFT side
pl_dashed   = $10   ; player has dashed before touching the ground
pl_dead     = $20   ; player has died and will be taken back to the beginning soon
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
af_lock     = $20   ; lock the anim timer to 0
af_lockto1  = $40   ; lock the anim timer to 1
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
ow_maxlvl   = $07   ; maximum level number

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
currpal     = $001B ; low byte of current palette's ROM address (offset from palettepage)
temp9       = $001C
mmc3_shadow = $001F ; shadow byte for the mmc3 bank select register

; Title specific addresses
tl_timer    = $0040
tl_gametime = $0041 ; time until the transition to gm_game happens

; Overworld specific addresses
owldctrl    = $0020 ; overworld control
ow_temp1    = $0021
ow_temp2    = $0022
ow_temp3    = $0023
ow_temp4    = $0024
ow_temp5    = $0025
ow_temp6    = $0026
ow_timer    = $0027
ow_sellvl   = $0028 ; selected level
ow_iconoff  = $0029
ow_slidetmr = $002A

; Game specific addresses
gamectrl    = $0020 ; game control
ntwrhead    = $0021 ; name table write head (up to 64 columns)
arwrhead    = $0022 ; area space write head (up to 32 columns)
camera_x_pg = $0023
lvlptrlo    = $0024 ; level pointer
lvlptrhi    = $0025
roomptrlo   = $0026 ; room pointer
roomptrhi   = $0027
arrdheadlo  = $0028 ; area read head
arrdheadhi  = $0029
entrdheadlo = $002A ; entity read head
entrdheadhi = $002B
tr_regsto   = $002C
lvladdr     = $002D ; temporaries used by h_get_tile and h_set_tile
lvladdrhi   = $002E
tr_scrnpos  = $002F ; active screen position
startpx     = $0030 ; starting player X position
startpy     = $0031 ; starting player Y position
warp_u      = $0032 ; destination warp numbers
warp_d      = $0033
warp_l      = $0034
warp_r      = $0035
warp_u_x    = $0036 ; destination X or Y coordinates depending on warp side
warp_d_x    = $0037
warp_l_y    = $0038
warp_r_y    = $0039
lvl_ntwrst  = $003A
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
ptscount    = $0054 ; last points count given
ptstimer    = $0055 ; time the ptscount is valid in frames
palrdheadlo = $0056 ; palette read head
palrdheadhi = $0057
camlimit    = $0058
camlimithi  = $0059
transtimer  = $005A
trantmp3    = $005B
trarwrhead  = $005C
scrchklo    = $005D ; temporaries used for scroll checking
scrchkhi    = $005E
lvlyoff     = $005F ; level Y offset when writing name table data
trantmp1    = $0060 ; temporaries used for transitioning
trantmp2    = $0061
camera_rev  = $0062 ; revealed pixels - if it goes above 8, request a column to be generated
plr_spr_l   = $0063 ; player sprite left
plr_spr_r   = $0064 ; player sprite right
plh_spr_l   = $0065 ; player hair sprite left
plh_spr_r   = $0066 ; player hair sprite right
gamectrl2   = $0067 ; second game control flags
deathtimer  = $0068
tmp_sprx    = $0069 ; used by gm_draw_entities to calculate the X and Y
tmp_spry    = $006A
palallochd  = $006B
temp8       = $006C
roombeglo   = $006D ; beginning of room in pixels.  Used for entity placement
roombeghi   = $006E
roombeglo2  = $006F ; beginning of room in tiles.
plrtrahd    = $0070 ; plr trace head
plrstrawbs  = $0071 ; strawberries following this player
ntrowhead   = $0072
ntrowhead2  = $0073
camdst_x    = $0074 ; temporary used by gm_leaveroomU
camdst_x_pg = $0075 ; temporary used by gm_leaveroomU
paloffs     = $0076 ; temporary used by gm_leaveroomU
wrcountHP1  = $0077 ; write count for HP1
ppuaddrHP1  = $0078 ; ppuaddr to write palH1 to
ppuaddrHP2  = $007A ; ppuaddr to write palH2 to
ppuaddrHR1  = $007C ; ppuaddr to write row1 to
ppuaddrHR2  = $007E ; ppuaddr to write row2 to
wrcountHP2  = $0080 ; write count for HP2
wrcountHR1  = $0081 ; write count for HR1
wrcountHR2  = $0082 ; write count for HR2
camoff_H    = $0083 ; temporaries used by gm_leaveroomU
camoff_M    = $0084
camoff_L    = $0085
camoff_sub  = $0086
player_x_d  = $0087
camoff2_M   = $0088
camoff2_L   = $0089

;audaddrlo   = $0072
;audaddrhi   = $0073
;audrdlo     = $0074
;audrdhi     = $0075
;audlock     = $0076 ; lock up the main sequencer for X frames
;audtemp1    = $0077

; note: these are used by title, overworld AND MAYBE game too.
tl_snow_y   = $00D0 ; Y coordinates of the 16 snow particles
tl_snow_x   = $00E0 ; X coordinates of the 16 snow particles

debug2      = $00FC
debug       = $00FD
nmicount    = $00FE

; large areas reserved by the game
sprspace    = $0200 ; 256 bytes
; 256 bytes free
plr_trace_x = $0400
plr_trace_y = $0440

tempcol     = $0500 ; 32 bytes - temporary column to be flushed to the screen
temppal     = $0520 ; 8 bytes  - temporary palette column to be flushed to the screen
allocpals   = $0530 ; 16 bytes - logical to physical palette
palsallocd  = $0540 ; 16 bytes - physical to logical palette

temppalH1   = $0550 ; 8 bytes - temporary row in nametable 0
temppalH2   = $0558 ; 8 bytes - temporary row in nametable 1
temprow1    = $0560 ; 32 bytes - temporary row in nametable 0
temprow2    = $0580 ; 32 bytes - temporary row in nametable 1

loadedpals  = $05C0 ; 64 bytes - temporary storage for loaded palettes during vertical transitions


areaspace   = $6000 ; 2048 bytes -- 64 X 32 area, OR 32 X 64 in V mode
