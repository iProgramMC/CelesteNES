; Copyright (C) 2025 iProgramInCpp

; This module implements the Postcard at the beginning of each stage.
.include "lettersfx.asm"
.include "lettergfx.asm"

postcard_palette_black:
	.byte $0f,$0f,$0f,$0f
postcard_palette_fade_step_1:
	.byte $0f,$00,$00,$05
postcard_palette_fade_step_2:
	.byte $0f,$10,$00,$05
postcard_palette:
	.byte $0f,$30,$10,$15

; ** SUBROUTINE: postcard_play_in_sound
; desc: Plays the sound that plays when the postcard scene fades in.
.proc postcard_play_in_sound
	ldy levelnumber
	lda postcard_sfx_in, y
	beq :+
	
	ldx #FAMISTUDIO_SFX_CH0
	jsr famistudio_sfx_play
:	rts
.endproc

; ** SUBROUTINE: postcard_setup_black
; ** SUBROUTINE: postcard_setup_fade_step_1
; ** SUBROUTINE: postcard_setup_fade_step_2
; ** SUBROUTINE: postcard_setup_fade_done
; desc: Creates a request for the steps of the fade.
postcard_setup_fade_step_1:
	lda #<postcard_palette_fade_step_1
	sta vmcsrc
	lda #>postcard_palette_fade_step_1
	sta vmcsrc+1
	jmp postcard_setup_palette_request

postcard_setup_fade_step_2:
	lda #<postcard_palette_fade_step_2
	sta vmcsrc
	lda #>postcard_palette_fade_step_2
	sta vmcsrc+1
	jmp postcard_setup_palette_request

postcard_setup_black:
	lda #<postcard_palette_black
	sta vmcsrc
	lda #>postcard_palette_black
	sta vmcsrc+1
	jmp postcard_setup_palette_request

postcard_setup_fade_done:
	lda #<postcard_palette
	sta vmcsrc
	lda #>postcard_palette
	sta vmcsrc+1
	;jmp postcard_setup_palette_request

postcard_setup_palette_request:
	lda #$00
	sta vmcaddr
	lda #$3F
	sta vmcaddr+1
	lda #4
	sta vmccount
	
	lda nmictrl2
	ora #nc2_vmemcpy
	sta nmictrl2
	rts

postcard_bitset:	.byte $FF, $01, $02, $04, $08, $10, $20, $40, $80

; ** SUBROUTINE: postcard
; desc: Initializes, shows the postcard screen, then fades out.  The game fadein will be handled by the caller.
; parameters:
;     levelnumber - The destination level number
.proc postcard
	;jmp level_end
	
	ldy levelnumber
	lda postcard_lo, y
	bne @continue
@returnEarly:
	rts
	
@continue:
	; have we already completed the level?
	ldy levelnumber
	lda postcard_bitset, y
	and sf_completed
	bne @returnEarly
	
	; well, there is a postcard defined here, and we didn't yet finish the level, so do it
	lda #$FF
	sta p1_cont
	sta p1_conto
	
	; fade to black TODO
	
	; disable rendering
	lda #0
	sta ppu_mask
	sta scroll_x
	sta scroll_y
	
	; since we might have interrupted rendering, wait for vblank to prevent tearing
	jsr vblank_wait
	
	; start loading screen data
	lda #$20
	sta ppu_addr
	lda #$00
	sta ppu_addr
	
	;ldy levelnumber
	lda postcard_hi, y
	tax
	lda postcard_lo, y
	
	jsr nexxt_rle_decompress
	
	; clear the attribute table bytes as it seems that the RLE data doesn't do that
	lda #$23
	sta ppu_addr
	lda #$C0
	sta ppu_addr
	
	ldy #64
	lda #0
:	sta ppu_data
	dey
	bne :-
	sty ow_slidetmr
	
	; also switch banks
	ldx #chrb_pcard
	stx bg0_bknum
	inx
	inx
	stx bg1_bknum
	
	; now prepare for (get this) another vblank wait.
	jsr com_clear_oam
	jsr soft_nmi_on
	
	; wait for vblank again
	jsr nmi_wait
	
	; now, we will want to program the palette
	; hopefully we are still in v-blank!  I know it's still safe to draw
	; since rendering is disabled but it'll show weird colors on the screen
	; if I push palettes while the screen is in the render area
	lda #$3F
	sta ppu_addr
	lda #$00
	sta ppu_addr
	
	ldy #32
	lda #$0F
:	sta ppu_data
	dey
	bne :-
	
	; enable rendering with the emphasis bits
	lda #(def_ppu_msk | %11100000)
	sta ppu_mask
	
	; ok, initialize the first step of the fade
	jsr postcard_setup_fade_step_1
	
	; finally, set up the scroll position
	lda #240-31
	sta scroll_y
	
	; ok, now do 36 frames with that step
	; on different index frames, do different things
@loopFadeIn:
	; then wait
	jsr nmi_wait

@framesPerStep = 12

@loopFadeInWaited:
	; adjust scroll
	inc ow_slidetmr
	lda #35
	sec
	sbc ow_slidetmr
	bcs :+
	lda #0
:	tax
	lda postcard_yp, x
	cmp #0
	beq :+
	lda #240
	sec
	sbc postcard_yp, x
:	sta scroll_y
	
	ldx ow_slidetmr
	
	cpx #(@framesPerStep / 2)
	beq @clearEmphasis
	cpx #(@framesPerStep / 2) + @framesPerStep
	beq @clearEmphasis
	cpx #@framesPerStep
	beq @step2
	cpx #@framesPerStep * 2
	beq @step3
	cpx #@framesPerStep * 3
	beq @step4
	bne @loopFadeIn

@clearEmphasis:
	lda #def_ppu_msk
	sta ppu_mask
	bne @loopFadeIn

@step2:
	jsr postcard_play_in_sound
	jsr postcard_setup_fade_step_2
	jsr nmi_wait
	lda #(def_ppu_msk | %11100000)
	sta ppu_mask
	jmp @loopFadeInWaited

@step3:
	jsr postcard_setup_fade_done
	jsr nmi_wait
	lda #(def_ppu_msk | %11100000)
	sta ppu_mask
	jmp @loopFadeInWaited

@step4:
	lda #def_ppu_msk
	sta ppu_mask

	lda #120
	sta ow_timer

@loop:
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	
	; check if the timer expired
	lda ow_timer
	beq @checkButtonPress
	
	dec ow_timer
	bne @loop
	
@checkButtonPress:
	; check if A or Start are pressed
	lda p1_conto
	and #(cont_a | cont_start)
	bne @loop
	lda p1_cont
	and #(cont_a | cont_start)
	beq @loop
	
	; ok, time to exit
	; first, play the outgoing sound
	lda #60
	sta ow_timer
	lda #0
	sta ow_slidetmr
	
	jsr soft_nmi_on
	
	ldy levelnumber
	lda postcard_sfx_out, y
	beq @loopFadeOut
	
	ldx #FAMISTUDIO_SFX_CH0
	jsr famistudio_sfx_play
	
	; ok, now do 36 frames with that step
	; on different index frames, do different things
@loopFadeOut:
	; then wait
	jsr nmi_wait

@loopFadeOutWaited:
	; adjust scroll
	inc ow_slidetmr
	ldx ow_slidetmr
	
	lda postcard_yp, x
	sta scroll_y
	
	cpx #(@framesPerStep / 2)
	beq @setEmphasis
	cpx #(@framesPerStep / 2) + @framesPerStep
	beq @setEmphasis
	cpx #@framesPerStep
	beq @step2o
	cpx #@framesPerStep * 2
	beq @step3o
	cpx #@framesPerStep * 3
	beq @step4o
	cpx #@framesPerStep * 4
	beq @step5o
	bne @loopFadeOut

@setEmphasis:
	jsr nmi_wait
	lda #(def_ppu_msk | %11100000)
	sta ppu_mask
	bne @loopFadeOut

@step2o:
	jsr postcard_setup_fade_step_2
	jsr nmi_wait
	lda #def_ppu_msk
	sta ppu_mask
	jmp @loopFadeOutWaited

@step3o:
	jsr postcard_setup_fade_step_1
	jsr nmi_wait
	lda #def_ppu_msk
	sta ppu_mask
	jmp @loopFadeOutWaited

@step4o:
	jsr postcard_setup_black
	jmp @loopFadeOut

@step5o:
	lda #0
	sta ppu_mask

@waitLoop:
	jsr soft_nmi_on
	jsr nmi_wait
	jsr soft_nmi_off
	
	dec ow_timer
	bne @waitLoop
	
@return:
	rts
.endproc

; NOTE: The Prologue doesn't use a postcard.
postcard_lo:		.byte 0, <postcard_ch1, <postcard_ch2
postcard_hi:		.byte 0, >postcard_ch1, >postcard_ch2
postcard_sfx_in:	.byte 0, 9, 11
postcard_sfx_out:	.byte 0, 10, 12
postcard_yp:		.byte 0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,2,3,4,4,5,6,7,8,9,10,12,13,15,16,18,20,22,24,26,29