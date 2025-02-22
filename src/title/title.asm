; Copyright (C) 2024 iProgramInCpp

; ** SUBROUTINE: print_logo
; clobbers: a, x, y
; assumes:  video output disabled
print_logo:
	; write the actual logo, in 4 parts.
	lda #$20
	sta ppu_addr
	lda #$00
	sta ppu_addr
	lda #<tscr_canvas
	ldx #>tscr_canvas
	jsr nexxt_rle_decompress
	
	lda #$23
	sta ppu_addr
	lda #$C0
	sta ppu_addr
	ldx #<tscr_attrs
	ldy #>tscr_attrs
	lda #64
	jsr ppu_wrstring
	
	; write the "PRESS START" text
	lda #$22
	sta ppu_addr
	lda #$CB
	sta ppu_addr
	ldx #<logo_pressstart
	ldy #>logo_pressstart
	lda #9
	jsr ppu_wrstring
	
	; write iProgramInCpp's name
	lda #$23
	sta ppu_addr
	lda #$28
	sta ppu_addr
	ldx #<logo_iprogram
	ldy #>logo_iprogram
	lda #15
	jsr ppu_wrstring
	
	; write "(C)2018 EXOK"
	lda #$23
	sta ppu_addr
	lda #$4B
	sta ppu_addr
	ldx #<logo_exok
	ldy #>logo_exok
	lda #9
	jsr ppu_wrstring
	
	; write the "DEMO V1.XX" text.
	lda #$20
	sta ppu_addr
	lda #$62
	sta ppu_addr
	ldx #<logo_version
	ldy #>logo_version
	lda #7
	jmp ppu_wrstring
	
tl_owldswitch:
	lda #0
	sta fadeupdrt+1
	jsr fade_out
	
	lda #gm_overwld
	sta gamemode
	lda #0
	sta owldctrl
	
	jsr vblank_wait
	;lda #0
	sta ppu_mask        ; disable rendering
	rts

gamemode_title_init_FAR:
	lda #$00
	sta scroll_x     ; clear some fields
	sta scroll_y
	sta scroll_flags
	sta camera_x
	sta camera_y
	sta camera_x_pg
	sta camera_y_hi
	sta tl_cschctrl
	sta ppu_mask     ; disable rendering
	sta fadeupdrt+1
	
	jsr vblank_wait  ; wait for vblank
	
	; Set the title screen palette address, we'll fade in to it.
	lda #<title_palette
	sta paladdr
	lda #>title_palette
	sta paladdr+1
	
	lda #$20
	jsr clear_nt     ; clear the screen
	
	jsr print_logo   ; print the logo and the "PRESS BUTTON" text
	jsr tl_init_snow ; initialize snow
	
	lda titlectrl
	ora #ts_1stfr
	sta titlectrl
	
	jsr tl_select_banks
	
	jsr fade_in

gamemode_title_update_FAR:
	jsr tl_update_snow
	jsr tl_render_snow
	
	ldx #<s_update_title_aux
	ldy #>s_update_title_aux
	lda #prgb_ents
	jsr far_call2
	
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
	rts

gamemode_titletr:
	jsr tl_update_snow
	jsr tl_render_snow
	
	ldx tl_gametime
	dex
	beq tl_owldswitch
	stx tl_gametime
	rts

alt_colors:
	.byte $27, $29
	.byte $17, $19
	.byte $07, $09
