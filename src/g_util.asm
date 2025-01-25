
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

; ** IRQ Handler: Idle
; desc: Blocks unimportant stuff from running
irq_idle:
	inc rununimport
	sta mmc3_irqdi
	rti

; these tables are 25 frames in size
death_irq_table_1:	.byte 1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17,17,17,17,17,17,17
death_irq_table_2:	.byte 1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17,17,17,17,17,17,17
death_irq_table_3:	.byte 1,1,1,1,1,1,2,3,4,5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,17,17,17
death_irq_table_4:	.byte 1,1,1,1,1,1,2,3,4,5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,17,17,17

; ** SUBROUTINE: memorial_get_position
; desc: To avoid code repetition while also avoiding use of position dependent code,
;       offload some processing here
; parameters:
;       A - the index of the character
; returns:
;       Y - the Y position of the char
;       A - the X position of the char (also in temp11)
.proc memorial_get_position
@dialogWidth = 26
	cmp #@dialogWidth
	bcc @firstRow
	cmp #@dialogWidth*2
	bcc @secondRow
	; third row
	sbc #@dialogWidth*2
	ldy #9
	bne @donePickingY
@secondRow:
	sbc #(@dialogWidth-1)
	ldy #7
	bne @donePickingY
@firstRow:
	ldy #4
@donePickingY:
	clc
	adc temp11
	and #$3F
	rts
.endproc

; ** SUBROUTINE: rand_m1_p1
; desc: Gets a random number, either -1, 0, or 1.
.proc rand_m1_p1
	jsr rand
	bpl :+
	lda #$FF
	rts
:	and #1
	rts
.endproc

; ** SUBROUTINE: calc_approach
; desc: Approaches an 8-bit value towards another 8-bit value.
;
; parameters:
;     X - The index into the zero page of the value to update
;     Y - The value to add
;     A - The approached value
;
; note:
;     clobbers temp1, temp2, A, X
.if 0
calc_approach:
@end = temp1
@add = temp2
	sta @end
	sty @add
	
	lda 0, x
	cmp @end
	bcs @startBiggerThanEnd
	
	; start < end
	; clc
	adc @add
	bcc :+
	lda @end   ; it overflew! so, just end
:	cmp @end
	bcc :+
	lda @end   ; start now >= end, load end
:	sta 0, x
	rts
	
@startBiggerThanEnd:
	; start >= end
	; sec
	sbc @add
	bcs :+
	lda @end   ; it underflew! so, just end
:	cmp @end
	bcs :+
	lda @end   ; start now < end, load end
:	sta 0, x
	rts
.endif

; ** SUBROUTINE: invert_oam_order
; desc: Inverts the order of sprites in OAM.
; arguments:
;     X - Old OAM Head
;     Y - New OAM Head
; clobbers: temp11
; note: X&3 == Y&3 == 0!!
.proc invert_oam_order
	; if list is empty
	sty temp11
	cpx temp11
	beq @break
	
	; if list is 1 byte in size
	; also gets the last item in the list of items to shuffle
	dey
	dey
	dey
	dey
	
	sty temp11
	cpx temp11
	beq @break
@loop:

.repeat 4, i
	lda oam_buf+i, x
	sta temp11
	
	lda oam_buf+i, y
	sta oam_buf+i, x
	
	lda temp11
	sta oam_buf+i, y
.endrepeat
	
	; increment X four times, if it matches Y then break
	inx
	inx
	inx
	inx
	sty temp11
	cpx temp11
	beq @break
	
	; decrement Y four times and see if it matches X
	dey
	dey
	dey
	dey
	sty temp11
	cpx temp11
	bne @loop

@break:
	rts
.endproc

; These belong in PRG_TTLE, but I don't have enough space for them! :(
logo_pressstart:	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78
logo_iprogram:		.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E
logo_exok:			.byte $60,$61,$79,$7A,$00,$7B,$7C,$7D,$7E
logo_version:		.byte $20,$21,$22,$23,$24,$25,$26
