; Copyright (C) 2024 iProgramInCpp

;  This code belongs in the PRG_DIAL segment

dialog_data:
	.incbin "data.bin"

dlg_update_d:
	rts

dlg_test_d:
	jsr vblank_wait
	lda #0
	sta ppu_mask
	
	lda #chrb_dcntr
	sta bg0_bkspl
	lda #chrb_dcntr+2
	sta bg1_bkspl
	
	lda scrollsplit
	eor #64
	sta scrollsplit
	
	lda dialogsplit
	eor #12
	sta dialogsplit
	
	; NOTE: hardcoded
	beq @dontDoAnything
	
	lda #$24
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldy #$00
:	lda dialog_data, y
	sta ppu_data
	iny
	bne :-
	
	lda #$25
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldy #$00
:	lda dialog_data+$100, y
	sta ppu_data
	iny
	bne :-
	
	lda #$26
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldy #$00
:	lda dialog_data+$200, y
	sta ppu_data
	iny
	bne :-
	
	lda #$27
	sta ppu_addr
	lda #$00
	sta ppu_addr
	ldy #$00
:	lda dialog_data+$300, y
	sta ppu_data
	iny
	bne :-
	
@dontDoAnything:
	
	lda nmictrl
	ora #nc_turnon
	sta nmictrl
	
	jsr vblank_wait
	
	rts
