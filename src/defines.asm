; Copyright (C) 2024 iProgramInCpp

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
sp_flags    = (sp_max * 1)   ; flags
sp_x        = (sp_max * 2)   ; X coordinate within a page
sp_x_lo     = (sp_max * 3)   ; X coordinate subpixels (used for things like crystal hearts for smooth bounceback)
sp_y        = (sp_max * 4)   ; Y coordinate
sp_y_lo     = (sp_max * 5)   ; Y coordinate subpixels
sp_x_pg     = (sp_max * 6)   ; X coordinate in pages
sp_wid      = (sp_max * 7)   ; sprite hit box width / entity specific
sp_hei      = (sp_max * 8)   ; sprite hit box height / entity specific
sp_vel_x    = (sp_max * 9)   ; sprite velocity X / entity specific (used by gm_ent_move_x)
sp_vel_y    = (sp_max *10)   ; sprite velocity Y / entity specific (used by gm_ent_move_y)
sp_vel_x_lo = (sp_max *11)   ; sprite velocity X low / entity specific (used by gm_ent_move_x)
sp_vel_y_lo = (sp_max *12)   ; sprite velocity X low / entity specific (used by gm_ent_move_y)
sp_entspec1 = (sp_max *13)   ; entity specific 1
sp_entspec2 = (sp_max *14)   ; entity specific 2
sp_entspec3 = (sp_max *15)   ; entity specific 3

; synonyms for entspec fields
sp_oscill_timer = sp_entspec1
sp_refill_flags = sp_entspec2
sp_refill_oldos = sp_entspec3
sp_strawb_flags = sp_entspec2
sp_strawb_colid = sp_entspec3
sp_points_count = sp_entspec1
sp_points_timer = sp_entspec2

sp_part_entty = sp_entspec1
sp_part_vel_x = sp_vel_x
sp_part_vel_y = sp_vel_y
sp_part_timer = sp_entspec2
sp_part_chrti = sp_wid
sp_part_chrat = sp_hei

sp_l0ic_state = sp_entspec1  ; 0 - hanging, 1 - falling, 2 - fallen
sp_l0ic_timer = sp_entspec2
sp_l0ic_vel_y = sp_vel_y
sp_l0ic_vsu_y = sp_vel_y_lo

; entity flags
ef_collidable = $01

; Entity Types
; NOTE(iProgram): Keep this up to date with LEVELEDITOR\Entity.cs (public enum eEntityType)
;                 and LEVELEDITOR\MainGame.cs (GetByteFromString)
e_none      = $00
e_strawb    = $01
e_refill    = $02
e_spring    = $03
e_key       = $04
e_particle  = $05 ; INTERNAL: shatter particle
e_refillhd  = $06 ; INTERNAL: place holder for refill
e_points    = $07 ; INTERNAL: points when a strawberry is collected
e_l0introcr = $08 ; level 0 intro crusher
e_box       = $09 ; box with collision against the player

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
;
; notes:
;   plrsp0 and plrsp1 belong at $0000
;   anisp0.....anisp3 belong at $0C00
;   gensp1 and gensp2 belong at $0800 and $0400 respectively.

chrb_plrsp0 = $00   ; player sprite banks  \.
chrb_plrsp1 = $01   ;                      |  PART OF "sp_player.chr"
chrb_anisp0 = $02   ; animated sprites     |
chrb_anisp1 = $03   ;                      /
chrb_anisp2 = $04   ;                      \.
chrb_anisp3 = $05   ;                      |  PART OF "sprites.chr"
chrb_gensp1 = $06   ;                      |
chrb_gensp2 = $07   ;                      /

; don't know when these will be used.
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
;chrb_lvl6   = $34   ; graphics bank for level 6 "Reflection"
;chrb_lvl7   = $38   ; graphics bank for level 7 "The Summit"
;chrb_lvl8   = $3C   ; graphics bank for level 8 "Core"
chrb_dmade  = $34   ; graphics bank for dialog with Madeline
chrb_dtheo  = $38   ; graphics bank for dialog with Theo
chrb_dgran  = $3C   ; graphics bank for dialog with Granny
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
def_mmc3_bn = %01000000 ; default mmc3 bank config.
                        ; two 2K banks at $0000-$0FFF, four 1K banks at $1000-$1FFF
                        ; PRG ROM fixed at $8000-$9FFF and $E000-$FFFF
blank_tile  = $00
apu_irq_off = $40
obj_fliphz  = $40   ; flip horizontally
obj_flipvt  = $80   ; flip vertically
obj_backgd  = $20   ; behind background
miscdata    = $E000
palettepage = $FF00
pctl_nmi_on = %10000000
pctl_adv32  = %00000100
pctl_sprsz  = %00100000
pctl_bgpat  = %00010000
pctl_sppat  = %00001000
pctl_highx  = %00000001 ; +256 to screen scroll
pctl_highy  = %00000010 ; +240 to screen scroll
def_ppu_msk = %00011110
gm_game     = $00   ; Game Modes
gm_title    = $01
gm_titletra = $02   ; title transition
gm_overwld  = $03   ; overworld
gm_prologue = $04
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
ps_1stfr    = $01   ; first frame of prologue screen
ps_turnon   = $02   ; need to program the PPU mask to turn on rendering
ps_clear    = $04   ; clear 32 bytes of pl_ppuaddr
ps_dofade   = $08   ; reupload palette to faded version
pls_ldtext  = $00   ; prologue: load text state
pls_wrtext  = $01   ; prologue: write text state
pls_fade    = $02   ; prologue: wait state
pls_wait    = $03   ; prologue: fade state
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
g2_noclrall = $08   ; don't clear everything
g2_clearcol = $10   ; clear two columns at ntwrhead with blank.
g2_clrcru   = $20   ; clear the intro crusher's tiles to blank (entity index in l0crshidx)
g2_setcru   = $40   ; set the intro crusher's tiles (entity index in l0crshidx)
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
gravity     = $40   ; Celeste uses a value of 900 px/s^2, converted it would be about 0.25 spx/fr^2 for us
lograthresh = $C0   ; if Math.Abs(Speed.Y) <= lograthresh (40f in Celeste), and holding C, then apply half the gravity
ctrpull     = $18   ; acceleration imposed by player pressing buttons
scrolllimit = $78   ; around halfway to the screen
jumpsustain = $0C   ; sustain the max jump velocity for at most twelve frames
accel       = $47   ; acceleration. equivalent of RunAccel in Celeste
accelred    = $1C   ; reduced accel. equivalent of RunReduce in Celeste
accelair    = $2E   ; acceleration in mid-air. multiplied by ~0.65
accelredair = $12   ; reduced accel in mid-air. multiplied by ~0.65
jumpvel     = $01C0 ; jump velocity
walljump    = $022A ; wall jump velocity
maxwalk     = $0180 ; max walk speed in pixels
maxfall     = $02AA ; max fall speed
plrwidth    = $08   ; player hitbox width - 8 pixels wide
plrheight   = $0A   ; player hitbox height - 10 pixels wide
maxdashes   = 1     ; TODO: change to 2
defdashtime = 12    ; time to perform a dash
dashchrgtm  = 2     ; time to charge the dash (after this, the dash direction is checked)
dashgrndtm  = 6     ; time to wait until the grounded check should be performed
maxwalkad   = $40   ; maximum walk approach delta in subpixels
dragamount  = $47   ; drag amount per frame (around 17 px/fr^2 in Celeste)
superjmphhi = $04   ; super jump boost pixel part
superjmphlo = $55   ; super jump boost subpixel part
wjfxtval    = $0A   ; wall jump force X timer value. in Celeste this is 0.16f which is about ten frames.
animspd     = $10   ; 256/animspd is the amount of frames per animation up-tick (for 32, it's 8 fr)
maxslidespd = $80   ; maximum slide speed in subpixels
defjmpbuff  = $04   ; 4 frames of buffering a jump
defjmpcoyot = $06   ; 6 frames of coyote time
defwjmpcoyo = $03   ; 3 frames of wall coyote time
jmphboost   = 170   ; boost applied to the player's jump when running
wjgrace     = 3     ; walls are checked this many pixels away from the hitbox for a wall jump. Celeste uses 3 here
ct_none     = $00   ; no collision
ct_full     = $01   ; the entire tile has collision
ct_deadly   = $02   ; the tile is UP spike shaped
ct_jumpthru = $03   ; the tile is a jump through
ow_maxlvl   = $07   ; maximum level number
jtheight    = 3     ; height of jump through blocks
swjgrace    = 5     ; grace time for a super wall jump TODO

maxfallHI   = (maxfall >> 8)
maxfallLO   = (maxfall & $FF)

maxwalkHI   = (maxwalk >> 8)
maxwalkLO   = (maxwalk & $FF)
maxwalkNHI  = (((-maxwalk) >> 8) & $FF)
maxwalkNLO  = ((-maxwalk) & $FF)

walljumpHI  = (walljump >> 8)
walljumpLO  = (walljump & $FF)
walljumpNHI = (((-walljump) >> 8) & $FF)
walljumpNLO = ((-walljump) & $FF)

jumpvelHI   = (((-jumpvel) >> 8) & $FF)
jumpvelLO   = ((-jumpvel) & $FF)
sjumpvelHI  = (((-(jumpvel / 2)) >> 8) & $FF)
sjumpvelLO  = ((-(jumpvel / 2)) & $FF)

; player proportions
plr_y_bot      = 16
plr_y_bot_wall = 14 ; for wall checking
plr_y_top      = (plr_y_bot - plrheight)
plr_y_mid      = (plr_y_bot_wall - plrheight / 2)
plr_x_left     = (8 - plrwidth / 2)
plr_x_right    = (15 - plrwidth / 2)
plr_x_wj_left  = (plr_x_left  - wjgrace)
plr_x_wj_right = (plr_x_right + wjgrace)
plr_x_mid      = 8

FAMISTUDIO_CFG_C_BINDINGS = 0
