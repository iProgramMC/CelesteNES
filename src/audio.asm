
au_wait   = $00
au_pulse1 = $01

au_waitfr = $FF

note_f5  = 77
note_fS5 = 78
note_g5  = 79
note_gS5 = 80
note_a5  = 81
note_bF5 = 82
note_b5  = 83
note_c6  = 84
note_cS6 = 85
note_d6  = 86
note_eF6 = 87
note_e6  = 88
note_f6  = 89
note_fS6 = 90


; note frequencies


; ** SUBROUTINE: aud_read
; desc: Read a byte of audio data.
aud_read:
	ldx #0
	lda (audrdlo,x)
	inc audrdlo
	bne :+
	inc audrdhi
:	ldx audrdlo
	cpx #<audiodatamax
	bne :+
	ldx audrdhi
	cpx #>audiodatamax
	bne :+
	jsr aud_rewind   ; if reached the end, then rewind
:	rts

aud_init:
	lda #%00001111   ; enable square 1 and 2, triangle, and noise channels
	sta apu_status
	
aud_rewind:
	ldx #<audiodata
	stx audrdlo
	ldx #>audiodata
	stx audrdhi
	rts

aud_handle_wait:
	jsr aud_read
	sta audlock
	jmp aud_run

aud_handle_pulse1:
	jsr aud_read       ; read envelope, duty & volume info
	sta apu_pulse1
	jsr aud_read       ; load note number
	tax
	lda ntsc_period_low,x
	sta apu_pulse1+2
	lda ntsc_period_high,x
	sta audtemp1
	jsr aud_read       ; load note length
	asl
	asl
	asl
	ora audtemp1       ; and the high part of the timer
	sta apu_pulse1+3
	jmp aud_run        ; jump back to the beginning of aud_run to read the next command

; ** SUBROUTINE: aud_run
; desc: Run a 1/60 tick of the audio engine.
aud_run:
	lda audlock
	beq :+
	dec audlock        ; if audio is locked, take 1 from the timer and return
	rts
:	jsr aud_read
	cmp #au_wait
	beq aud_handle_wait
	cmp #au_pulse1
	beq aud_handle_pulse1
	rts

delay = 10
notelen = %11100

audiodata:
	.byte au_pulse1, $00, note_a5,  notelen
	.byte au_wait, delay*3
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_f6,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_gS5, notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_e6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_d6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_f5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_a5,  notelen
	.byte au_wait, delay
	; split
	.byte au_pulse1, $00, note_gS5, notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_d6,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_e6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_d6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_a5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_gS5, notelen
	.byte au_wait, delay
	; split
	.byte au_pulse1, $00, note_f5,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_d6,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_a5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_gS5, notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_a5,  notelen
	.byte au_wait, delay*2
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay
	; split
	.byte au_pulse1, $00, note_d6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_e6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_f6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_gS5, notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_d6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_e6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_a5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_b5,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_c6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_d6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_f6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_e6,  notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_eF6, notelen
	.byte au_wait, delay
	.byte au_pulse1, $00, note_e6,  notelen
	.byte au_wait, delay*2
audiodatamax:


ntsc_period_low:
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  .byte $ff, $f1, $7f, $13, $ad, $4d, $f3, $9d
  .byte $4c, $00, $b8, $74, $34, $f8, $bf, $89
  .byte $56, $26, $f9, $ce, $a6, $80, $5c, $3a
  .byte $1a, $fb, $df, $c4, $ab, $93, $7c, $67
  .byte $52, $3f, $2d, $1c, $0c, $fd, $ef, $e1
  .byte $d5, $c9, $bd, $b3, $a9, $9f, $96, $8e
  .byte $86, $7e, $77, $70, $6a, $64, $5e, $59
  .byte $54, $4f, $4b, $46, $42, $3f, $3b, $38
  .byte $34, $31, $2f, $2c, $29, $27, $25, $23
  .byte $21, $1f, $1d, $1b, $1a, $18, $17, $15
  .byte $14, $13, $12, $11, $10, $0f, $0e, $0d
  .byte $0c, $0c, $0b, $0a, $0a, $09, $08, $08

ntsc_period_high:
  .byte $07, $07, $07, $07, $07, $07, $07, $07
  .byte $07, $07, $07, $07, $07, $07, $07, $07
  .byte $07, $07, $07, $07, $07, $07, $07, $07
  .byte $07, $07, $07, $07, $07, $07, $07, $07
  .byte $07, $07, $07, $07, $06, $06, $05, $05
  .byte $05, $05, $04, $04, $04, $03, $03, $03
  .byte $03, $03, $02, $02, $02, $02, $02, $02
  .byte $02, $01, $01, $01, $01, $01, $01, $01
  .byte $01, $01, $01, $01, $01, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00