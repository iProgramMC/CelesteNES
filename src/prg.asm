
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

; Constants
blank_tile  = $00
apu_irq_off = $40
oam_buf_hi  = $07   ; matches the upper bytes of the address of oam_buf
leveldata   = $E000
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
gs_1stfr    = $01   ; first frame of game screen
gs_vertical = $02   ; is the level vertical?
gs_gentiles = $04   ; need to generate metatiles
gs_gencols  = $08   ; need to generate visual columns
lf_vertical = $01   ; level flag: is this level vertical
tilesahead  = 36    ; tiles ahead of camera X
camspeed    = 2     ; pixels advanced per frame by camera

; Variables (RAM: 0x0000 - 0x0800)
oam_buf     = $0700 ; OAM buffer, flushed every vblank to PPU OAM
oam_offset  = $0000
oam_wrhead  = $0001 ; OAM buffer write head
wr_str_temp = $0002 ; and $0003
x_crd_temp  = $0004 ; used by oam_putsprite and h_get_tile, MUST be x before y!
y_crd_temp  = $0005 ; used by oam_putsprite
rng_state   = $0006
p1_cont     = $0007
p1_conto    = $0008

player_x    = $0010
player_y    = $0011
player_sp_x = $0012 ; subpixel memory X
player_sp_y = $0013 ; subpixel memory Y
camera_x    = $0014
camera_y    = $0015
ctl_flags   = $0016 ; copied into ppuctrl
gamemode    = $0017 ; active game mode
titlectrl   = $0018 ; title control
camera_x_hi = $0019

; NOTE: these addresses can and should be repurposed for in-game
tl_snow_y   = $0020 ; Y coordinates of the 16 snow particles
tl_snow_x   = $0030 ; X coordinates of the 16 snow particles
tl_timer    = $0040
tl_gametime = $0041 ; time until the transition to gm_game happens

gamectrl    = $0020 ; game control
ntwrhead    = $0021 ; name table write head (up to 64 columns)
arwrhead    = $0022 ; area space write head (up to 32 columns)
; $0023 spare
lvlptrlo    = $0024 ; level pointer
lvlptrhi    = $0025
roomptrlo   = $0026 ; room pointer
roomptrhi   = $0027
arrdheadlo  = $0028 ; area read head
arrdheadhi  = $0029
entrdheadlo = $002A ; entity read head
entrdheadhi = $002B

; large areas reserved by the game
tilecounts  = $0300 ; 32 bytes - 16 X 2.  Format: [Metatile ID, Count]
areaspace   = $0400 ; 512 bytes -- 32 X 16 area, OR 16 X 32 in V mode
sprspace    = $0600 ; 256 bytes

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

.res lastpage - *, $FF
init_palette:
	.byte $0f,$20,$10,$00 ; grey tiles
	.byte $0f,$37,$16,$06 ; brown tiles
	.byte $0f,$20,$21,$11 ; blue tiles
	.byte $0f,$39,$29,$19 ; green tiles
	.byte $0f,$15,$37,$21 ; player sprite colors
	.byte $0f,$15,$25,$36 ; red/strawberry sprite
	.byte $0f,$30,$29,$09 ; green/refill sprite
	.byte $0f,$20,$10,$00 ; unused sprite 3

; logo data
logo_row1: .byte $20,$20,$20,$c0,$20,$20,$20
logo_row2: .byte $c6,$c5,$c1,$c5,$c3,$c4,$c5
logo_row3: .byte $c7,$c8,$ca,$c9,$cb,$cc,$c9
logo_row4: .byte $cd,$20,$20,$20,$20,$ce,$cf
logo_pal:  .byte $aa,$aa,$aa,$aa
logo_pressstart: .byte "PRESS START"

.res $FFFA - *, $FF
	.word nmi
	.word reset
	.word $fff0   ; unused
