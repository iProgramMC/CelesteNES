; Copyright (C) 2024 iProgramInCpp

.segment "ZEROPAGE"

temp1       : .res 1
temp2       : .res 1
temp3       : .res 1
temp4       : .res 1
temp5       : .res 1
temp6       : .res 1
temp7       : .res 1
temp8       : .res 1
temp9       : .res 1
temp10      : .res 1 ; NEW

gamemode    : .res 1 ; active game mode
framectr    : .res 1 ; continuously increasing frame counter
nmicount    : .res 1
nmienable   : .res 1
ctl_flags   : .res 1 ; copied into ppuctrl
gamestate   : .res 1 ; reused by every game mode
	titlectrl = gamestate
	gamectrl  = gamestate
	owldctrl  = gamestate
	prolctrl  = gamestate

mmc3_shadow : .res 1
oam_offset  : .res 1
oam_wrhead  : .res 1 ; OAM buffer write head
wr_str_temp : .res 2 ; address of current character of string
x_crd_temp  : .res 1 ; used by oam_putsprite and h_get_tile, MUST be x before y!
y_crd_temp  : .res 1 ; used by oam_putsprite

tr_bufidx   : .res 1 ; alias to y_crd_temp
rng_state   : .res 1
p1_cont     : .res 1
p1_conto    : .res 1

player_x    : .res 1 ; offset by the camera's position!
player_y    : .res 1
player_sp_x : .res 1 ; subpixel memory X
player_sp_y : .res 1 ; subpixel memory Y
camera_x    : .res 1
camera_y    : .res 1
camera_x_hi : .res 1
camera_y_hi : .res 1

; TODO: Merge These Into Each Other
; title
tl_timer    : .res 1
tl_gametime : .res 1

; overworld
ow_temp1    : .res 1
ow_temp2    : .res 1
ow_temp3    : .res 1
ow_temp4    : .res 1
ow_temp5    : .res 1
ow_temp6    : .res 1
ow_timer    : .res 1
ow_sellvl   : .res 1 ; selected level
ow_iconoff  : .res 1
ow_slidetmr : .res 1

; Prologue specific addresses
pl_state    : .res 1 ; 0 - load text, 1 - writing text, 2 - waiting, 3 - fadeout
pl_ppuaddr  : .res 2
pl_ppudata  : .res 1
p_textaddr  : .res 2 ; current address in text string
p_textlen   : .res 1 ; length of current text string
p_textnum   : .res 1
p_textoffs  : .res 1
p_texttimer : .res 1

; Game specific addresses
ntwrhead    : .res 1 ; name table write head (up to 64 columns)
arwrhead    : .res 1 ; area space write head (up to 32 columns)
camera_x_pg : .res 1
lvlptrlo    : .res 1 ; level pointer
lvlptrhi    : .res 1
roomptrlo   : .res 1 ; room pointer
roomptrhi   : .res 1
arrdheadlo  : .res 1 ; area read head
arrdheadhi  : .res 1
entrdheadlo : .res 1 ; entity read head
entrdheadhi : .res 1
tr_regsto   : .res 1
lvladdr     : .res 1 ; temporaries used by h_get_tile and h_set_tile
lvladdrhi   : .res 1
tr_scrnpos  : .res 1 ; active screen position
playerctrl  : .res 1
player_vl_x : .res 1 ; velocity X, pixels
player_vs_x : .res 1 ; velocity X, subpixels
player_vl_y : .res 1 ; velocity Y, pixels
player_vs_y : .res 1 ; velocity Y, subpixels
plh_attrs   : .res 1 ; player hair attributes
dashtime    : .res 1
dashcount   : .res 1 ; times player has dashed
dashdir     : .res 1 ; dash direction X (controller inputs at time of dash SHIFTED LEFT by 2)
currroom    : .res 1 ; current room
spryoff     : .res 1 ; hair sprite Y offset
animmode    : .res 1 ; current animation mode
animtimer   : .res 1 ; current animation timer. It has a subunitary component because
animtimersb : .res 1 ; the upper component is directly used as the frame index.
animflags   : .res 1 ; animation flags copied from anim data
anfrptrlo   : .res 1 ; animation frame pointer low
anfrptrhi   : .res 1 ; animation frame pointer high
sprxoff     : .res 1 ; hair sprite X offset
spryoffbase : .res 1 ; hair sprite Y offset base (used for af_oddryth)
jumpbuff    : .res 1 ; jump buff time
jumpcoyote  : .res 1 ; jump coyote time, if not zero, player may jump
wjumpcoyote : .res 1 ; wall jump coyote time
player_yo   : .res 1 ; player Y old. used for spike collision
player_xo   : .res 1 ; player Y old. used for horizontal spike collision
transoff    : .res 1
ptscount    : .res 1 ; last points count given
ptstimer    : .res 1 ; time the ptscount is valid in frames
palrdheadlo : .res 1 ; palette read head
palrdheadhi : .res 1
camlimit    : .res 1
camlimithi  : .res 1
transtimer  : .res 1
trantmp3    : .res 1
trarwrhead  : .res 1
scrchklo    : .res 1 ; temporaries used for scroll checking
scrchkhi    : .res 1
lvlyoff     : .res 1 ; level Y offset when writing name table data
trantmp1    : .res 1 ; temporaries used for transitioning
trantmp2    : .res 1
camera_rev  : .res 1 ; revealed pixels - if it goes above 8, request a column to be generated
plr_spr_l   : .res 1 ; player sprite left
plr_spr_r   : .res 1 ; player sprite right
plh_spr_l   : .res 1 ; player hair sprite left
plh_spr_r   : .res 1 ; player hair sprite right
gamectrl2   : .res 1 ; second game control flags
deathtimer  : .res 1
tmp_sprx    : .res 1 ; used by gm_draw_entities to calculate the X and Y
tmp_spry    : .res 1
palallochd  : .res 1
roombeglo   : .res 1 ; beginning of room in pixels.  Used for entity placement
roombeghi   : .res 1
roombeglo2  : .res 1 ; beginning of room in tiles.
plrtrahd    : .res 1 ; plr trace head
plrstrawbs  : .res 1 ; strawberries following this player
ntrowhead   : .res 1
ntrowhead2  : .res 1
camdst_x    : .res 1 ; temporary used by gm_leaveroomU
camdst_x_pg : .res 1 ; temporary used by gm_leaveroomU
paloffs     : .res 1 ; temporary used by gm_leaveroomU
wrcountHP1  : .res 1 ; write count for HP1
ppuaddrHP1  : .res 2 ; ppuaddr to write palH1 to
ppuaddrHP2  : .res 2 ; ppuaddr to write palH2 to
ppuaddrHR1  : .res 2 ; ppuaddr to write row1 to
ppuaddrHR2  : .res 2 ; ppuaddr to write row2 to
wrcountHP2  : .res 1 ; write count for HP2
wrcountHR1  : .res 1 ; write count for HR1
wrcountHR2  : .res 1 ; write count for HR2
camoff_H    : .res 1 ; temporaries used by gm_leaveroomU
camoff_M    : .res 1
camoff_L    : .res 1
camoff_sub  : .res 1
player_x_d  : .res 1
camoff2_M   : .res 1
camoff2_L   : .res 1
jcountdown  : .res 1 ; jump countdown
forcemovext : .res 1
forcemovex  : .res 1
quaketimer  : .res 1
quakeflags  : .res 1 ; directions are the same as controller flags
l0crshidx   : .res 1
plattemp1   : .res 1 ; TODO: replace with a regular temp
plattemp2   : .res 1 ; TODO: replace with a regular temp
entground   : .res 1 ; entity ID the player is standing on
musicbank   : .res 1 ; music is active in this bank
musicbank2  : .res 1
musictable  : .res 2 ; currently active table of songs
musicdiff   : .res 1 ; should the music be re-initialized?
clearpalo   : .res 1 ; enqueued name table clear, ppu address low
clearpahi   : .res 1 ; enqueued name table clear, ppu address high
clearsizex  : .res 1 ; enqueued name table clear, size X
clearsizey  : .res 1 ; enqueued name table clear, size Y

; this is where the room header is copied, when a room is loaded.
roomsize    : .res 1 ; room size in tiles. 0 if the room is long/1-directional.
roomspare2  : .res 1 ; spare bytes
roomspare3  : .res 1 ; spare bytes
startpx     : .res 1 ; starting player X position
startpy     : .res 1 ; starting player Y position
warp_u      : .res 1 ; destination warp numbers
warp_d      : .res 1
warp_l      : .res 1
warp_r      : .res 1
warp_u_x    : .res 1 ; destination X or Y coordinates depending on warp side
warp_d_x    : .res 1
warp_l_y    : .res 1
warp_r_y    : .res 1
rm_paloffs  : .res 1

roomhdrfirst = roomsize
roomhdrlast  = rm_paloffs + 1

tl_snow_y   : .res 16
tl_snow_x   : .res 16
debug       : .res 1
debug2      : .res 1

.segment "OAMBUF"
oam_buf     : .res $100

.segment "ENTITIES"
sprspace    : .res $100

.segment "PLTRACES"
plr_trace_x : .res $40
plr_trace_y : .res $40

.segment "DRAWTEMP"
tempcol     : .res $20  ; 32 bytes - temporary column to be flushed to the screen
allocpals   : .res $10  ; 16 bytes - logical to physical palette TODO
palsallocd  : .res $10  ; 16 bytes - physical to logical palette TODO
temppal     : .res $8   ; 8 bytes  - temp palette column to be flushed to the screen
temppalH1   : .res $8   ; 8 bytes  - temporary row in nametable 8
temppalH2   : .res $8   ; 8 bytes  - temporary row in nametable 1
spare8bytes : .res $8   ; 8 bytes  - SPARE SPARE
temprow1    : .res $20  ; 32 bytes - temporary row in nametable 0
temprow2    : .res $20  ; 32 bytes - temporary row in nametable 1
lastcolumn  : .res $20  ; 30 bytes - temporary storage for last column, used during decompression
loadedpals  : .res $40  ; 64 bytes - temporary storage for loaded palettes during vertical transitions

.segment "CARTWRAM" ; $6000 - Cartridge WRAM
areaspace   : .res $800
