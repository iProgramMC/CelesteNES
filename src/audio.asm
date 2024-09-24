
; ** SUBROUTINE: aud_read
; desc: Read a byte of audio data.
aud_read:
	ldy audrdhead
	lda audiodata, y
	iny
	cpy #(audiodatamax - audiodata)
	bne :+
	ldy #0
:	sty audrdhead
	rts

frequency = 113

; ** SUBROUTINE: aud_run
; desc: Run a 1/60 tick of the audio engine.
aud_run:
	jsr aud_read
	cmp #$FF                 ; #$FF means wait til next frame
	beq :+
	sta audaddrhi
	jsr aud_read
	sta audaddrlo
	jsr aud_read
	ldy #0
	sta (audaddrlo),y        ; write the data!
:	rts

audiodata:
	.byte $40,$00,%00000000
	.byte $40,$01,%00000000
	.byte $40,$02,112
	.byte $40,$03,%00100000
	.byte $40,$15,%00000001
	.byte $FF              ; wait for next frame
	
	.byte $40,$00,%00000000
	.byte $40,$01,%00000000
	.byte $40,$02,120
	.byte $40,$03,%00100000
	.byte $40,$15,%00000001
	.byte $FF              ; wait for next frame
audiodatamax: