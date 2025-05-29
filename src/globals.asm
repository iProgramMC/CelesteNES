; Copyright (C) 2024-2025 iProgramInCpp

; Notes about some variables:
;
; (1) -- If dialogsplit is non zero, it is applied instead of scrollsplit, and then scrollsplit
;        is only used to calculate the camera offset in game.
;
; (2) -- The irqcounter represents the current phase of the dialog raster trick.
;        Once it reaches three, normal game is rendered.
;
; (3) -- The camera Y is split into "multiples of 8" and "non multiple of 8" because I suck. There
;        are loads of edge cases in the horizontal level design that I'm not willing to completely
;        reupholster.

.segment "ZEROPAGE"

nmi_disable : .res 1 ; HARD NMI disable - used when resetting the game. Must be zero to run NMIs.
farcalladdr : .res 2 ; FAR CALL address (can be used as temporary)
irqaddr     : .res 2 ; IRQ handler address
temp1       : .res 1
temp2       : .res 1
temp3       : .res 1
temp4       : .res 1
temp5       : .res 1
temp6       : .res 1
temp7       : .res 1
temp8       : .res 1
temp9       : .res 1
temp10      : .res 1
temp11      : .res 1
temp12      : .res 1

; temporaries specific to the IRQ (touching them WILL result in a
; race condition if the IRQ is active!)
;
; note: for the death wipe, the NMI will take care of updating these!
irqtmp      : .res 10
	irqtmp1 = irqtmp+0
	irqtmp2 = irqtmp+1
	irqtmp3 = irqtmp+2
	irqtmp4 = irqtmp+3
	irqtmp5 = irqtmp+4
	irqtmp6 = irqtmp+5
	irqtmp7 = irqtmp+6
	irqtmp8 = irqtmp+7
	irqtmp9 = irqtmp+8
	irqtmp10= irqtmp+9

; if the IRQ controls a death wipe. this is equal to:
; - $00 if the death wipe is disabled
; - the PPU mask for the first half of the wipe.
deathwipe   : .res 1

; This is the value to set the PPUMASK to for the second half of the wipe.
deathwipe2  : .res 1

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

nmictrl     : .res 1 ; nc_*
nmictrl2    : .res 1 ; nc2_*

splgapaddr  : .res 2

mmc3_shadow : .res 1
currA000bank: .res 1 ; current bank index loaded at $A000-$BFFF.
oam_wrhead  : .res 1 ; OAM buffer write head
wr_str_temp : .res 2 ; address of current character of string
x_crd_temp  : .res 1 ; used by oam_putsprite and h_get_tile, MUST be x before y!
y_crd_temp  : .res 1 ; used by oam_putsprite
scroll_x    : .res 1
scroll_y    : .res 1
scroll_flags: .res 1 ; the FLAGS for the scroll split part of PPUCTRL
tempmaskover: .res 1 ; with the nc_turnon flag, this is the thing that's ORed onto the default PPU mask
fade_active : .res 1 ; is a fade active

; dialog stuff in the zeropage
scrollsplit : .res 1 ; Y position of the scroll split
dialogsplit : .res 1 ; Y position of the dialog split (1)
miscsplit   : .res 1 ; Y position of the misc split (used by death wipe etc)
irqcounter  : .res 1 ; (2)
dlg_updates : .res 1 ; row update bitmask
dlg_entity  : .res 1 ; entity engaged with in a cutscene
dlg_cutsptr : .res 2 ; pointer to the current cutscene script command
dlg_textptr : .res 2 ; the pointer to the current character
dlg_porttbl : .res 2 ; the pointer to the portrait table

rng_state   : .res 2
p1_cont     : .res 2
p1_conto    : .res 2
game_cont   : .res 2
game_conto  : .res 2
ctrlscheme  : .res 1 ; active control scheme
paladdr     : .res 2 ; currently loaded palette address.

player_x    : .res 1 ; offset by the camera's position!
player_y    : .res 1
camera_y_bs : .res 1 ; base camera Y
camera_y_ho : .res 1 ; camera Y high OLD
vertoffshack: .res 1 ; offset when fetching tiles using coordinates.  This is a hack
camera_y_min: .res 1
camera_y_max: .res 1
tl_timer    : .res 1 ; used for weather

; merged from individual variables between Prologue, Title and Overworld.
; note: these may be used as extra temporaries for the Game mode too!
pot_merged  : .res 10

; title
tl_gametime := pot_merged + 0
tl_cschctrl := pot_merged + 1
; overworld
ow_lvlopen  := pot_merged + 0 ; is the level drawer open
ow_berries1 := pot_merged + 1
ow_berries2 := pot_merged + 2
ow_timer2   := pot_merged + 3
ow_splity   := pot_merged + 4
ow_timer    := pot_merged + 5
ow_sellvl   := pot_merged + 6 ; selected level
ow_iconoff  := pot_merged + 7
ow_slidetmr := pot_merged + 8
; Prologue specific addresses
pl_state    := pot_merged + 0 ; 0 - load text, 1 - writing text, 2 - waiting, 3 - fadeout
pl_ppuaddr  := pot_merged + 1
pl_ppudata  := pot_merged + 3
p_textaddr  := pot_merged + 4 ; current address in text string
p_textlen   := pot_merged + 6 ; length of current text string
p_textnum   := pot_merged + 7
p_textoffs  := pot_merged + 8
p_texttimer := pot_merged + 9

; Game specific addresses
lvlptrlo    := pot_merged + 0 ; : .res 1 ; level pointer
lvlptrhi    := pot_merged + 1 ; : .res 1
roomptrlo   := pot_merged + 2 ; : .res 1 ; room pointer
roomptrhi   := pot_merged + 3 ; : .res 1
arrdheadlo  := pot_merged + 4 ; : .res 1 ; area read head
arrdheadhi  := pot_merged + 5 ; : .res 1
entrdheadlo := pot_merged + 6 ; : .res 1 ; entity read head
entrdheadhi := pot_merged + 7 ; : .res 1
lvladdr     := pot_merged + 8 ; : .res 1 ; temporaries used by h_get_tile and h_set_tile
lvladdrhi   := pot_merged + 9 ; : .res 1

lvlbktbl    : .res 2 ; pointer to list of banks occupied by which rooms
lvldatabank : .res 1 ; mobile level data is active in this bank
lvldatabank2: .res 1 ; fixed (DPCM-sample) level data is active in this bank
musicbank   : .res 1 ; music data is active in this bank
anfrptrlo   : .res 1 ; animation frame pointer low
anfrptrhi   : .res 1 ; animation frame pointer high
gamectrl2   : .res 1 ; second game control flags
gamectrl3   : .res 1 ; third game control flags
camera_x_pg : .res 1
entdelay    : .res 1 ; entity row delay (vertical scrolling)
vmcsrc      : .res 2 ; Source of bytes to copy to
player_yo   : .res 1 ; player Y old. used for spike collision
player_xo   : .res 1 ; player X old. used for horizontal spike collision
ptscount    : .res 1 ; last points count given
ptstimer    : .res 1 ; time the ptscount is valid in frames
palrdheadlo : .res 1 ; palette read head
palrdheadhi : .res 1
lvlyoff     : .res 1 ; level Y offset when writing name table data
trarwrhead  : .res 1
transtimer  : .res 1
camera_rev  : .res 1 ; revealed pixels - if it goes above 8, request a column to be generated
plr_spr_l   : .res 1 ; player sprite left
plr_spr_r   : .res 1 ; player sprite right
plh_spr_l   : .res 1 ; player hair sprite left
plh_spr_r   : .res 1 ; player hair sprite right
ntrowhead   : .res 1
ntrowhead2  : .res 1
wrcountHP1  : .res 1 ; write count for HP1
wrcountHP2  : .res 1 ; write count for HP2
ppuaddrHP1  : .res 2 ; ppuaddr to write palH1 to
ppuaddrHP2  : .res 2 ; ppuaddr to write palH2 to
ppuaddrHR1  : .res 2 ; ppuaddr to write row1 to
ppuaddrHR2  : .res 2 ; ppuaddr to write row2 to
ppuaddrHR3  : .res 2 ; ppuaddr to write row3 to
wrcountHR1  : .res 1 ; write count for HR1
wrcountHR2  : .res 1 ; write count for HR2
wrcountHR3  : .res 1 ; write count for HR3
jcountdown  : .res 1 ; jump countdown
forcemovext : .res 1
forcemovex  : .res 1
quaketimer  : .res 1
quakeflags  : .res 1 ; directions are the same as controller flags
l0crshidx   : .res 1
entground   : .res 1 ; entity ID the player is interacting with (standing on or climbing)
defsprbank  : .res 1 ; the default level specific sprite bank
musictable  : .res 2 ; currently active table of songs
musicdiff   : .res 1 ; should the music be re-initialized?
clearpalo   : .res 1 ; enqueued name table clear, ppu address low
clearpahi   : .res 1 ; enqueued name table clear, ppu address high
clearsizex  : .res 1 ; enqueued name table clear, size X
clearsizey  : .res 1 ; enqueued name table clear, size Y
setdataaddr : .res 2 ; enqueued name table set, data source.
roomnumber  : .res 1 ; incremented every time a room transition happens
climbbutton : .res 1 ; the state of the CLIMB button. Any non zero value works.
deathangle  : .res 1 ; death particles angle

prevplrctrl : .res 1 ; last player control flags
respawntmr  : .res 1 ; respawn timer
chopentity  : .res 1 ; reference to the climb hop solid
choplastX   : .res 1
choplastY   : .res 1

scrchklo    : .res 1 ; temporaries used for scroll checking
scrchkhi    : .res 1
trantmp1    : .res 1 ; temporaries used for transitioning
trantmp2    : .res 1
trantmp3    : .res 1
trantmp4    : .res 1
trantmp5    : .res 1
plattemp1   : .res 1
plattemp2   : .res 1
plattemp3   : .res 1

tmpRoomTran : .res 9 ; temporaries used by leaveroomU, 
	camdst_x    := tmpRoomTran + 0
	camdst_x_pg := tmpRoomTran + 1
	camoff_H    := tmpRoomTran + 2
	camoff_M    := tmpRoomTran + 3
	camoff_L    := tmpRoomTran + 4
	camoff_sub  := tmpRoomTran + 5
	camoff2_M   := tmpRoomTran + 6
	camoff2_L   := tmpRoomTran + 7
	camoff2_H   := tmpRoomTran + 8

; NEW level format
roomwidth   : .res 1
roomheight  : .res 1
roomreadidx : .res 2 ; read index in first name table row
roomcurrcol : .res 1 ; current column index in first name table row

; this is the warp header is copied, when a room warp is processed
roomloffs   : .res 1 ; used for stub rooms.  The amount of tiles the room is shifted left.
startpx     : .res 1 ; starting player X position
startpy     : .res 1 ; starting player Y position

warpflags   : .res 1 ; extracted from roomloffs on load

camera_y_hi : .res 1
fadeupdrt   : .res 2

; these spots are always zeroed out on respawn
zero_on_respawn_zp_begin:

gamectrl4   : .res 1 ; fourth game control flags
gamectrl5   : .res 1 ; fifth game control flags
playerctrl  : .res 1
playerctrl2 : .res 1

player_sp_x : .res 1 ; subpixel memory X
player_sp_y : .res 1 ; subpixel memory Y

player_vl_x : .res 1 ; velocity X, pixels
player_vs_x : .res 1 ; velocity X, subpixels
player_vl_y : .res 1 ; velocity Y, pixels
player_vs_y : .res 1 ; velocity Y, subpixels

camera_x    : .res 1
camera_y    : .res 1
camera_y_sub: .res 1 ; sub-tile camera Y (0-7) (3)
camera_x_lo : .res 1 ; for smoother scrolling
camera_y_lo : .res 1
camlimit    : .res 1
camlimithi  : .res 1
camleftlo   : .res 1
camlefthi   : .res 1

roombeglo   : .res 1 ; beginning of room in pixels.  Used for entity placement
roombeghi   : .res 1
roombeglo2  : .res 1 ; beginning of room in the 2 loaded nametables.

transoff    : .res 1
tr_scrnpos  : .res 1 ; active screen position
ntwrhead    : .res 1 ; name table write head (up to 64 columns)
arwrhead    : .res 1 ; area space write head (up to 32 columns)
dashtime    : .res 1
dashcount   : .res 1 ; times player has dashed
dashdir     : .res 1 ; dash direction X (controller inputs at time of dash SHIFTED LEFT by 2)
jumpbuff    : .res 1 ; jump buff time
jumpcoyote  : .res 1 ; jump coyote time, if not zero, player may jump
wjumpcoyote : .res 1 ; wall jump coyote time
liftboosttm : .res 1 ; lift boost time
liftboostX  : .res 1
liftboostY  : .res 1
lastlboostX : .res 1 ; last lift boost velocity
lastlboostY : .res 1
currlboostX : .res 1 ; lift boost calculation in progress
currlboostY : .res 1
player_x_d  : .res 1
hopcdown    : .res 1 ; hop countdown HACK
cjwindow    : .res 1 ; climb jump window -- if you push the opposite direction while jumping, stamina will be refunded and a wall jump will happen
cjwalldir   : .res 1 ; climb jump wall direction
climbcdown  : .res 1 ; climb cooldown (when transitioning rooms)
plrtrahd    : .res 1 ; plr trace head
plrstrawbs  : .res 1 ; strawberries following this player
deathtimer  : .res 1
stamflashtm : .res 1 ; stamina flash timer
paused      : .res 1 ; is the game paused right now?
dredeatmr   : .res 1 ; dream death counter
dreinvtmr   : .res 1 ; dream dash invincibility timer
rununimport : .res 1 ; set this to 0 to allow running of unimportant stuff such as background effects
tswitches   : .res 1 ; amount of touch switches that have not been touched (platforms activate when this hits 0)
cassrhythm  : .res 1 ; used to control the solidity of cassette blocks

zero_on_respawn_zp_end:

.segment "OAMBUF"
oam_buf     : .res $100

.segment "ENTITIES"
sprspace    : .res $100

.segment "PLTRACES"
plr_trace_x : .res $40
plr_trace_y : .res $40

.segment "DRAWTEMP"
temprowtot  : .res $40
tempcol     = temprowtot+$00  ; 32 bytes - temporary column to be flushed to the screen
temppal     = temprowtot+$20  ; 8 bytes  - temp palette column to be flushed to the screen
temppalH1   = temprowtot+$28  ; 8 bytes  - temporary row in nametable 0 (DO NOT REARRANGE THESE)
temppalH2   = temprowtot+$30  ; 8 bytes  - temporary row in nametable 1
; 8 bytes here
temprow1    : .res $20  ; 32 bytes - temporary row in nametable 0 (DO NOT REARRANGE THESE)
temprow2    : .res $20  ; 32 bytes - temporary row in nametable 1
temprow3    : .res $20  ; 32 bytes - temporary row in nametable 0 again
lastcolumn  : .res $20  ; 30 bytes - temporary storage for last column, used during decompression
ntattrdata  : .res $80  ; 128 bytes- loaded attribute data
spritepals  : .res 9    ; 9 bytes  - loaded sprite palettes
spritepalso : .res 9    ; 9 bytes  - previous frame's loaded sprite palettes
sprpalcount : .res 1    ; 1 byte   - amount of palettes written
sprpaltemp  : .res 1    ; 1 byte   - just a temporary variable
palidxs     : .res pal_max; pal_max bytes - the indices of each loaded palette

.segment "MORERAM"

; Current Session
strawberries: .res 4 ; 32 bit bitset of strawberries collected.  Note that The Summit actually has 49 strawberries.
abovescreen : .res 1 ; if the player is above the screen
groundtimer : .res 1 ; how long the player is on the ground, max of 9 frames
deaths      : .res 2
colsloaded  : .res 1 ; column count loaded

pauseoption : .res 1 ; selected pause option
pauseanim   : .res 1 ; selected option animation
levelnumber : .res 1 ; level number

; Loaded from savefile
sstrawberries: .res 4 ; 32 bit bitset of strawberries collected before the current session.

; Loaded sprite banks
spr0_bknum  : .res 1
spr1_bknum  : .res 1
spr2_bknum  : .res 1
spr3_bknum  : .res 1
bg0_bknum   : .res 1
bg1_bknum   : .res 1

spr0_bkspl  : .res 1
spr1_bkspl  : .res 1
spr2_bkspl  : .res 1
spr3_bkspl  : .res 1
bg0_bkspl   : .res 1
bg1_bkspl   : .res 1

lvlbasebank : .res 1 ; base bank from which alt banks are offset

; this is where the room header is copied, when a room is loaded.
roomsize    : .res 1 ; room size in tiles. 0 if the room is long/1-directional.
roomflags   : .res 1 ; room flags
; destination warp numbers
warp_u      : .res 1
warp_d      : .res 1
warp_l      : .res 1
warp_r      : .res 1
; room offsets when transitioning in that direction
warp_u_x    : .res 1
warp_d_x    : .res 1
warp_l_y    : .res 1
warp_r_y    : .res 1
; palette offset
rm_paloffs  : .res 1
; X/Y coordinates below which the alternate warp will activate
warp_ualt_x : .res 1
warp_dalt_x : .res 1
warp_lalt_y : .res 1
warp_ralt_y : .res 1
; alternate warp destination
warp_ualt   : .res 1
warp_dalt   : .res 1
warp_lalt   : .res 1
warp_ralt   : .res 1
; alternate warp destination room offsets
warp_ualt_xo: .res 1
warp_dalt_xo: .res 1
warp_lalt_yo: .res 1
warp_ralt_yo: .res 1

warp_t_no   : .res 1 ; temporary warp number
old_lvlyoff : .res 1 ; temporary for transitions
old_roomflgs: .res 1 ; temporary for transitions

roomflags2  : .res 1 ; derived from paloffs

roomhdrfirst = roomsize
roomhdrlast  = rm_paloffs + 1

roomaltwarpsfirst = warp_ualt_x + 1
roomaltwarpslast  = warp_ralt_yo + 1

; pause menu stuff
spr0_paubk  : .res 1
spr1_paubk  : .res 1
spr2_paubk  : .res 1
spr3_paubk  : .res 1

currroom    : .res 1 ; current room
respawnroom : .res 1 ; room to respawn to when the player dies

; video memory copy NMI operation (not used by level loading / transition routines)
vmccount    : .res 1 ; Amount of bytes to copy
vmcaddr     : .res 2 ; Destination to copy to

; player sprite modes
plh_attrs   : .res 1 ; player hair attributes
amodeforce  : .res 1 ; animation mode force (set to non zero to activate)
animmode    : .res 1 ; current animation mode
animtimer   : .res 1 ; current animation timer. It has a subunitary component because
animtimersb : .res 1 ; the upper component is directly used as the frame index.
animflags   : .res 1 ; animation flags copied from anim data
spryoff     : .res 1 ; hair sprite Y offset
sprxoff     : .res 1 ; hair sprite X offset
spryoffbase : .res 1 ; hair sprite Y offset base (used for af_oddryth)
plh_forcepal: .res 1 ; forced hair palette if non-zero

; chapter 2 control
dbenable    : .res 1 ; 1+ = dream blocks are enabled, 2+ = Badeline initted, 3+ = in "awake" stage
dbouttimer  : .res 1 ; cooldown for the player exiting a dream block

advtracesw  : .res 1 ; if advanced trace is enabled (YOU MUST NOT show a dialog during this phase!)
advtracehd  : .res 1 ; advanced trace head
chasercdown : .res 1 ; countdown until the next chaser can pop into existence

starsbgctl  : .res 1 ; star background control

game_cont_force : .res 2
exitmaptimer: .res 1

ow_deathsU  : .res 1 ; deaths units digit
ow_deathsT  : .res 1 ; deaths tens digit
ow_deathsH  : .res 1 ; deaths hundreds digit
ow_deathsO  : .res 1 ; deaths thousands digit
ow_deathsE  : .res 1 ; deaths tens-of-thousands digit

player_dx   : .res 1 ; player death X
player_dy   : .res 1 ; player death Y

stamina     : .res 2 ; stamina amount (16-bit integer)

.segment "LASTRAM"

retain_vl_x : .res 1 ; retained velocity X
retain_vs_x : .res 1
retain_timer: .res 1 ; wall speed retention timer
wallhboxybot: .res 1 ; wall hit box Y bottom
dshatktime  : .res 1 ; dash attack time
dshold_vl_x : .res 1 ; dash old speed X high
dshold_vs_x : .res 1 ; dash old speed X low
dustrhythm  : .res 1 ; used to control the synchronization of dust bunnies
scrollsplitb: .res 1 ; scroll split backup for pause
dialogsplitb: .res 1 ; dialog split backup for pause
dlgentoldst : .res 1 ; dialog entity old state
dlgmusicpaus: .res 1 ; should pause the music when game is paused?

.segment "AREASPC"      ; $6000 - Cartridge WRAM
areaspace   : .res $800

.segment "AREAXTRA"     ; $6800 - Cartridge WRAM
areaextra   : .res 960 * 4 ; 4 screens worth of extra data

; AreaExtra composed of:
; [ 960 bytes ] - Screen 1
; [ 960 bytes ] - Screen 2
; [ 960 bytes ] - Screen 3
; [ 960 bytes ] - Screen 4

.segment "AREAPAL"

areapal8X2  : .res $40  * 4 ; 4 X 16 X 4 (4 screens' worth of attribute table data)
; (note: this one is laid out horizontally in 8X2 tile strips)
; (note: this data is laid out row-wise)

areapal4X4  : .res $40  * 4 ; 8 X 8  X 4 (4 screens' worth of attribute table data)
; (note: this one is laid out in 4X4 tile blocks)
; (note: this data is laid out column-wise)

.segment "SAVEFILE"
save_file_begin:

save_file_checksum: .res 3

save_file_0:
	sf_berries:   .res 22    ; bitset for 176 total strawberries
	sf_name:      .res 12    ; player's name (default is "Madeline")
	sf_completed: .res 1     ; chapters completed
	sf_times:     .res 3*8   ; times for each chapter (in frames. Up to 77 hours / 16.7 million frames)
	sf_totaltime: .res 4     ; total time spent in-game (up to 2 years / 4 billion frames)
	sf_deaths:    .res 2*8   ; total deaths (max. 65K)
	sf_cassettes: .res 1     ; cassettes (B-sides) unlocked (note: probably won't actually have B-sides!)
	sf_hearts:    .res 1     ; crystal hearts obtained
	sf_unused:    .res 2

save_file_size = * - save_file_0

; TODO: use the other files
save_file_1:      .res save_file_size
save_file_2:      .res save_file_size

save_file_options:		.res 3

save_file_final_bit:	.res 1 ; it's just gonna be $A5 always

; The advanced trace is enabled by the "advtracesw" global. By default, it's not enabled, as it overlaps
; with the dialog temporary area.

; It contains 8 components: X, X Page, Y, Sprite Left, Sprite Right, Hair Left, Hair Right, Sprite Bank << 1 | Facing.
.segment "ADVTRACE"

; History Size: 64 frames
; NOTE: Must be a power of 2
adv_trace_hist_size = 64

adv_trace_x:	.res adv_trace_hist_size
adv_trace_x_pg:	.res adv_trace_hist_size
adv_trace_y:	.res adv_trace_hist_size
adv_trace_y_hi:	.res adv_trace_hist_size
adv_trace_sl:	.res adv_trace_hist_size
adv_trace_sr:	.res adv_trace_hist_size
adv_trace_hl:	.res adv_trace_hist_size
adv_trace_hr:	.res adv_trace_hist_size
adv_trace_pc:	.res adv_trace_hist_size

.segment "BGFXRAM"

; Background Effect RAM
max_stars   = 16

stars_x     : .res 16
stars_y     : .res 16
stars_state : .res 16

tl_snow_y   := stars_x
tl_snow_x   := stars_y

bgcurroffs  := stars_x ; current column relative to the screen, for background rendering in Ch3
