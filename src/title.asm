; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: print_logo
; clobbers: a, x, y
; assumes:  video output disabled
print_logo:
	; write the actual logo, in 4 parts.
	ldy #$20
	ldx #$00
	jsr ppu_loadaddr
	ldx #<(tscr_canvas + $0000)
	ldy #>(tscr_canvas + $0000)
	lda #0
	jsr ppu_wrstring
	
	ldx #<(tscr_canvas + $0100)
	ldy #>(tscr_canvas + $0100)
	lda #0
	jsr ppu_wrstring
	
	ldx #<(tscr_canvas + $0200)
	ldy #>(tscr_canvas + $0200)
	lda #0
	jsr ppu_wrstring
	
	ldx #<(tscr_canvas + $0300)
	ldy #>(tscr_canvas + $0300)
	lda #0
	jsr ppu_wrstring
	
	; write the "PRESS START" text
	ldy #$22
	ldx #$EA
	jsr ppu_loadaddr
	ldx #<logo_pressstart
	ldy #>logo_pressstart
	lda #11
	jsr ppu_wrstring
	
	; write iProgramInCpp's name
	ldy #$23
	ldx #$4C
	jsr ppu_loadaddr
	ldx #<logo_iprogram
	ldy #>logo_iprogram
	lda #7
	jsr ppu_wrstring
	rts

tl_gameswitch:
	lda #gm_game
	sta gamemode
	lda #0
	sta gamectrl
	sta musictable
	sta musictable+1
	jsr gm_set_level
	jmp game_update_return

tl_prolswitch:
	lda #gm_prologue
	sta gamemode
	lda #0
	sta prolctrl
	jmp game_update_return
	
tl_owldswitch:
	lda #gm_overwld
	sta gamemode
	lda #0
	sta owldctrl
	
	jsr vblank_wait
	lda #0
	sta ppu_mask        ; disable rendering
	
	jmp game_update_return

; ** GAMEMODE: gamemode_title
gamemode_title:
	lda #ts_1stfr
	bit titlectrl    ; might need to update the screen buffer
	bne gamemode_title_update 
	
	lda #$00
	sta camera_x     ; clear some fields
	sta camera_x_hi
	sta ppu_mask     ; disable rendering
	
	; have to reset audio data because DPCM samples are loaded in at $C000
	; and we want to use that bank for title screen and overworld data.
	; We have 8K at our disposal.
	jsr aud_reset
	
	; Load said bank.
	lda #mmc3bk_prg0
	ldy #prgb_ttle
	jsr mmc3_set_bank
	
	jsr vblank_wait  ; wait for vblank
	
	; Also load the title screen palette.
	lda #<title_palette
	sta paladdr
	lda #>title_palette
	sta paladdr+1
	jsr load_palette
	
	lda #$20
	jsr clear_nt     ; clear the screen
	
	jsr print_logo   ; print the logo and the "PRESS BUTTON" text
	jsr tl_init_snow ; initialize snow
	jsr ppu_rstaddr  ; reset PPUADDR
	
	lda titlectrl
	ora #ts_1stfr
	sta titlectrl
	lda nmictrl
	ora #nc_turnon
	sta nmictrl
	
	jsr tl_select_banks
	jsr vblank_wait
	
gamemode_title_update:
	jsr tl_update_snow
	jsr tl_render_snow
	
	lda #cont_start
	bit p1_cont
	beq tl_no_transition
	lda #gm_titletra
	sta gamemode
	lda #8
	sta tl_timer
	lda #tm_gametra
	sta tl_gametime
tl_no_transition:
	
	jmp game_update_return

gamemode_titletr:
	jsr tl_update_snow
	jsr tl_render_snow
	
	ldx tl_gametime
	dex
	beq tl_owldswitch
	stx tl_gametime
	
	jmp game_update_return

alt_colors:
	.byte $27, $29
	.byte $17, $19
	.byte $07, $09

; TODO: PLACEHOLDER
gamemode_title_:
	beq gamemode_title