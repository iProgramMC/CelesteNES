
; ** SUBROUTINE: rand
; arguments: none
; clobbers:  a
; returns:   a - the pseudorandom number
; desc:      generates a pseudo random number
; credits:   https://www.nesdev.org/wiki/Random_number_generator#Overlapped
.proc rand
seed := rng_state
	lda temp11
	pha
	
	lda seed+1
	sta temp11 ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0 ; recombine with original low byte
	sta seed+1
	; compute seed+0 ($39 = %111001)
	lda temp11 ; original high byte
	sta seed+0
	asl
	eor seed+0
	asl
	eor seed+0
	asl
	asl
	asl
	eor seed+0
	sta seed+0
	
	pla
	sta temp11
	
	lda seed+0
	rts
.endproc

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

; ** SUBROUTINE: far_call2
; desc: Does a far call in a slightly slower, but slimmer way
; parameters:
;     X - The low byte of the address
;     Y - The high byte of the address
;     A - The bank to load
far_call2:
	stx farcalladdr
	sty farcalladdr+1
	tay
	jmp far_call

; ** SUBROUTINE: oam_putsprite
; arguments:
;   a - attributes
;   y - tile number
;   [x_crd_temp] - y position of sprite
;   [y_crd_temp] - y position of sprite
; clobbers:  a, y
; desc:      inserts a sprite into OAM memory
oam_putsprite:
	pha             ; preserve the attributes
	tya
	pha             ; preserve the tile number
	ldy oam_wrhead  ; load the write head into Y
	lda y_crd_temp  ; store the Y coordinate into OAM
	sta oam_buf, y
	iny             ; move on to the tile number byte
	pla
	; flip bit 1 because I am lazy and don't want to make every tile index be odd...
	eor #$01
	sta oam_buf, y  ; store the tile number into OAM
	iny
	pla
	sta oam_buf, y  ; store the attributes into OAM
	iny
	lda x_crd_temp
	sta oam_buf, y  ; store the X coordinate into OAM
	iny
	sty oam_wrhead
	rts

; ** SUBROUTINE: fade_once_color
; desc: Fades a color once.
.proc fade_once_color
	cmp #$10
	bcc justBlack
	
	cmp #$1D
	beq justBlack  ; special exception as we'd end up in $0D
	
	sec
	sbc #$10
	rts

justBlack:
	lda #$0F
	rts
.endproc

; ** SUBROUTINE: fade_twice_if_high
; desc: Fades twice if >= $30, fades once otherwise
.proc fade_twice_if_high
	cmp #$30
	bcc fadeOnce
	
	jsr fade_once_color
fadeOnce:
	jmp fade_once_color
.endproc

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
