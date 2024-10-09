; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: print_logo
; clobbers: a, x, y
; assumes:  video output disabled
print_logo_pal:
	ldx #<logo_pal
	ldy #>logo_pal
	lda #$4
	jsr ppu_wrstring
	rts
print_logo:
	; write the actual logo
	ldy #$21
	ldx #$4C
	jsr ppu_loadaddr
	ldx #<logo_row1
	ldy #>logo_row1
	lda #7
	jsr ppu_wrstring
	
	ldy #$21
	ldx #$6C
	jsr ppu_loadaddr
	ldx #<logo_row2
	ldy #>logo_row2
	lda #7
	jsr ppu_wrstring
	
	ldy #$21
	ldx #$8C
	jsr ppu_loadaddr
	ldx #<logo_row3
	ldy #>logo_row3
	lda #7
	jsr ppu_wrstring
	
	ldy #$21
	ldx #$AC
	jsr ppu_loadaddr
	ldx #<logo_row4
	ldy #>logo_row4
	lda #7
	jsr ppu_wrstring
	
	; write the "PRESS START" text
	ldy #$22
	ldx #$8A
	jsr ppu_loadaddr
	ldx #<logo_pressstart
	ldy #>logo_pressstart
	lda #11
	jsr ppu_wrstring
	
	; write iProgramInCpp's name
	ldy #$23
	ldx #$0C
	jsr ppu_loadaddr
	ldx #<logo_iprogram
	ldy #>logo_iprogram
	lda #7
	jsr ppu_wrstring
	
	; write the palette
	ldy #$23
	ldx #$D2
	jsr ppu_loadaddr
	jsr print_logo_pal
	jsr print_logo_pal
	jsr print_logo_pal
	rts

tl_gameswitch:
	lda #gm_game
	sta gamemode
	lda #0
	sta gamectrl
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
	jsr vblank_wait  ; wait for vblank
	lda #$20
	jsr clear_nt     ; clear the screen
	jsr print_logo   ; print the logo and the "PRESS BUTTON" text
	jsr tl_init_snow ; initialize snow
	jsr ppu_rstaddr  ; reset PPUADDR
	lda titlectrl
	ora #(ts_1stfr|ts_turnon)
	sta titlectrl
	lda #bank_title
	jsr mmc1_selcharbank ; load the title's character bank
	lda #bank_spr
	jsr mmc1_selsprbank
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

alt_colors: .byte $27, $29

gamemode_titletr:
	jsr tl_update_snow
	jsr tl_render_snow
	
	ldx tl_gametime
	dex
	beq tl_owldswitch
	stx tl_gametime
	
	jmp game_update_return
