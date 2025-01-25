; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: gm_calc_camera_nosplit
; desc: Calculate the quake scroll offsets, and adds them to cameraX/cameraY.
;       Then calculates the cameraX/cameraY and prepares it for upload to the PPU.
; note: Does not handle scroll splits.
gm_calc_camera_nosplit:
	; scroll X
	lda camera_x
	sta scroll_x
	
	; scroll Y
	lda camera_y
	clc
	adc camera_y_sub
	cmp #240
	bcc :+
	adc #15     ; adds 16 because carry is set
:	sta scroll_y
	
	jmp gm_calc_camera_shake_and_hi

; ** SUBROUTINE: gm_calc_camera
; desc: Calculates the cameraX/cameraY and prepares it for upload to the PPU.
; note: Does not calculate quake offsets.
gm_calc_camera_split:
	; scroll X
	lda camera_x
	sta scroll_x
	
	; scroll Y
	lda camera_y
	clc
	adc camera_y_sub
	cmp #240
	bcc :+
	adc #15
:	sta scroll_y
	
	; add the scroll split offset if needed.
	lda scrollsplit
	beq @doneAdding
	
	sec
	adc scroll_y
	sta scroll_y
	bcs @carryIsSet
	
	; carry clear, just check if >$F0
	cmp #$F0
	bcc @doneAdding
	
	sec
	sbc #$F0
	sta scroll_y
	
@flipHighBitAndDone:
	lda temp2
	eor #1
	sta temp2

@doneAdding:
	jmp gm_calc_camera_shake_and_hi
	
@carryIsSet:
	; carry was set
	adc #$0F   ; add +$10
	sta scroll_y
	; TODO: carry might be set again. I don't think it matters right now
	; but if you set scrolllimit to > like 80, then look here first.
	jmp @flipHighBitAndDone

; ** SUBROUTINE: gm_calc_camera_shake_and_hi
; desc: Shakes the camera according to quakeflags, and calculates the high bits of scroll.
.proc gm_calc_camera_shake_and_hi
	; scroll X/Y high
	lda camera_x_pg
	and #1
	sta temp1
	lda camera_y_hi
	sta temp2
	
	lda #0
	sta temp11
	
	lda quaketimer
	beq noQuake
	
	dec quaketimer
	
	lda #cont_up
	bit quakeflags
	beq notUp
	
	jsr rand_m2_to_p1
	sta temp11
	
notUp:
	lda #cont_down
	bit quakeflags
	beq notDown
	
	jsr rand_m1_to_p2
	clc
	adc temp11
	sta temp11
	
notDown:
	lda #cont_left
	bit quakeflags
	beq notLeft
	
	jsr rand_m2_to_p1
	clc
	adc scroll_x
	sta scroll_x
	lda temp1
	adc temp5
	and #1
	sta temp1
	
notLeft:
	lda #cont_right
	bit quakeflags
	beq notRight
	
	jsr rand_m1_to_p2
	clc
	adc scroll_x
	sta scroll_x
	lda temp1
	adc temp5
	and #1
	sta temp1
	
notRight:
	lda temp11
	bmi shakeNegative
	
	; shake positive
	clc
	adc scroll_y
	cmp #240
	bcc :+
	adc #15
:	sta scroll_y
	jmp noQuake

shakeNegative:
	clc
	adc scroll_y
	cmp #240
	bcc :+
	sbc #16
:	sta scroll_y
	
noQuake:
	lda #0
	ldx temp1
	beq :+
	ora #pctl_highx
	
:	ldx temp2
	beq :+
	ora #pctl_highy
	
:	sta scroll_flags
	rts
.endproc
