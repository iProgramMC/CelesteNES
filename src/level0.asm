level0_r1_e:
	.byte $FF
level0_r1_t:
	.byte $02,$01			; initial ground change
	.byte $00,$5A			; 5X horz ground at X=$00,Y=$0A
	.byte $56,$19,$03		; 1X horz ground at X=$05,Y=$09,ID=$03
	.byte $56,$1A,$07		; 1X horz ground at X=$05,Y=$0A,ID=$07
	.byte $66,$19,$02		; 1X horz ground at X=$06,Y=$09,ID=$02
	.byte $66,$1A,$0C		; 1X horz ground at X=$06,Y=$0A,ID=$0C
	.byte $67,$4B,$09		; 4X vert ground at X=$06,Y=$0B,ID=$09
	.byte $76,$19,$04		; 1X horz ground at X=$07,Y=$09,ID=$04
	.byte $76,$1A,$06		; 1X horz ground at X=$07,Y=$0A,ID=$06
	.byte $B7,$15,$24		; 1X vert ground at X=$0B,Y=$05,ID=$24
	.byte $B6,$1A,$19		; 1X horz ground at X=$0B,Y=$0A,ID=$19
	.byte $B7,$4B,$15		; 4X vert ground at X=$0B,Y=$0B,ID=$15
	.byte $C7,$15,$25		; 1X vert ground at X=$0C,Y=$05,ID=$25
	.byte $C6,$1A,$18		; 1X horz ground at X=$0C,Y=$0A,ID=$18
	.byte $D7,$19,$1F		; 1X vert ground at X=$0D,Y=$09,ID=$1F
	.byte $D7,$1A,$1E		; 1X vert ground at X=$0D,Y=$0A,ID=$1E
	.byte $D7,$4B,$14		; 4X vert ground at X=$0D,Y=$0B,ID=$14
	.byte $FE
	.byte $02,$15			; ground change
	.byte $07,$1A,$19		; 1X vert ground at X=$00,Y=$0A,ID=$19
	.byte $01,$4B			; 4X vert ground at X=$00,Y=$0B
	.byte $17,$1A,$18		; 1X vert ground at X=$01,Y=$0A,ID=$18
	.byte $27,$1A,$1A		; 1X vert ground at X=$02,Y=$0A,ID=$1A
	.byte $27,$4B,$14		; 4X vert ground at X=$02,Y=$0B,ID=$14
	.byte $FF
level0_r1:
	.byte 1, 0, 12
	.byte 1, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0
	.word level0_r1_t
	.word level0_r1_e
level0:
	.byte $00	; environment type
	.byte $01	; room count
	.word level0_r1
