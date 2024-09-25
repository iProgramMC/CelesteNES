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

; ** SUBROUTINE: tl_adjust_y
; arguments: a - the Y coordinate to adjust
; returns:   a - the adjusted Y coordinate
; clobbers:  x
; desc:      adjusts a Y coordinate to fit in a [0, 224] range
tl_adjust_y:
	tax
	cpx #$E0
	bcc tl_adjusret
	sbc #$E0
	asl
	asl
	asl
	asl
	and #%11011111
tl_adjusret:
	rts

; ** SUBROUTINE: tl_init_snow
tl_init_snow:
	ldy #$00           ; initialize Y coordinates
tl_initloop1:
	jsr rand
	sta tl_snow_y, y
	iny
	cpy #$10
	bne tl_initloop1
	
	ldy #$00           ; initialize X coordinates
tl_initloop2:
	jsr rand
	sta tl_snow_x, y
	iny
	cpy #$10
	bne tl_initloop2

	rts

osciltable:
	.byte $FF,$FF,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$FF,$FF

; ** SUBROUTINE: tl_update_snow
tl_update_snow:
	inc tl_timer
	ldy #$00
	
	; update Y coordinate to oscillate
tl_updaupdloop:
	tya
	adc tl_timer
	and #$07
	bne tl_updadontosci
	tya
	adc tl_timer
	lsr
	lsr
	lsr
	and #$0F
	tax
	lda tl_snow_y, y
	clc
	adc osciltable, x
	sta tl_snow_y, y
tl_updadontosci:
	
	; update X coordinate to go left
	ldx tl_snow_x, y
	dex
	beq tl_updatrespawn
	tya
	and #$01
	bne tl_updadontdecr
	dex
	beq tl_updatrespawn
tl_updadontdecr:
	stx tl_snow_x, y
tl_updacontinue:
	
	; move on to the next particle
	iny
	cpy #$10
	bne tl_updaupdloop
	rts
tl_updatrespawn:         ; respawn this particle
	lda #$FF
	sta tl_snow_x, y
	jsr rand
	jsr tl_adjust_y
	sta tl_snow_y, y
	jmp tl_updacontinue

snow_sprites: .byte $16, $18

; ** SUBROUTINE: tl_render_snow
tl_render_snow:
	ldy #$00
tl_render_loop:
	lda tl_snow_y, y
	sta y_crd_temp
	lda tl_snow_x, y
	sta x_crd_temp
	tya
	pha
	and #$01
	tay
	lda snow_sprites, y
	tay
	lda #3
	jsr oam_putsprite
	pla
	tay
	iny
	cpy #$10
	bne tl_render_loop
	rts

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
	ora #ts_1stfr
	ora #ts_turnon
	sta titlectrl
	lda #bank_title
	jsr mmc1_selcharbank ; load the title's character bank
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
	beq tl_gameswitch
	stx tl_gametime
	
	jmp game_update_return
	
tl_gameswitch:
	lda #gm_game
	sta gamemode
	lda #0
	sta gamectrl
	jmp game_update_return
