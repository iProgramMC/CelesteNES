
level0_r1_e:
	.byte $FF
level0_r1_t:
	.byte $02, $01       ; ground change to $01 (dirt)
	.byte $00, $5A       ; 5X horizontal ground at X=0,Y=10
	.byte $56, $1A, $07  ; 1X horizontal ground at X=5,Y=10,id=$07 (snow corner inner U+L)
	.byte $56, $19, $03  ; 1X horizontal ground at X=5,Y=9, id=$03 (snow corner UL)
	.byte $66, $19, $02  ; 1X horizontal ground at X=6,Y=9, id=$02 (snow)
	.byte $66, $1A, $0C  ; 1X horizontal ground at X=6,Y=9, id=$0C (snow corner inner D+R)
	.byte $67, $4B, $09  ; 4X vertical ground at X=6,Y=11,id=$09 (snow r wall)
	.byte $76, $19, $04  ; 1X horizontal ground at X=7,Y=9, id=$04 (snow corner UR)
	.byte $76, $1A, $06  ; 1X horizontal ground at X=7,Y=10,id=$06 (snow corner DR)
	.byte $B6, $1A, $19  ; 1X horizontal ground at X=11,Y=10,id=$19(dirt lower half left corner)
	.byte $B7, $4B, $15  ; 4X vertical ground at X=11,Y=11,id=$15 (dirt l wall)
	.byte $C6, $1A, $18  ; 1X horizontal ground at X=12,Y=10,id=$1A(dirt lower half)
	.byte $FF            ; terminator
	; old prototype level:
	.byte $00, $0E  ; 16X horizontal ground, at Y=14
	.byte $22, $03  ; ground change to $03 at X=2
	.byte $20, $45  ; 4X horizontal ground at X=2, Y=5
	.byte $72, $02  ; ground change to $02
	.byte $71, $52  ; 5X  vertical ground stripe, at X=7,Y=2
	.byte $82, $02  ; ground change to $03
	.byte $80, $CA  ; 12X horizontal ground at X=8,Y=10
	.byte $A2, $03  ; ground change to $03
	.byte $A1, $53  ; 5X  vertical ground stripe, at X=10,Y=3
	.byte $B2, $01  ; ground change to $01
	.byte $FE
	.byte $00, $0D
	.byte $00, $0E
	.byte $10, $E7  ; 14X ground at X=1, Y=7
	.byte $22, $06  ; ground change to $06 (spikes)
	.byte $20, $4C  ; 4X row at X=2 Y=12
	.byte $80, $2A  ; 2X row at X=8 Y=10
	.byte $A0, $2B  ; 2X row at X=10 Y=11
	.byte $A2, $01  ; ground change to $01 (snow) at X=10
	.byte $FE
	.byte $00, $0C
	.byte $36, $4A, $07  ; 4X row at X=3, Y=10
	.byte $76, $4B, $07  ; 4X row at X=7, Y=11
	.byte $FE
	.byte $00, $0D
	.byte $00, $0E
	.byte $36, $4A, $09  ; 4X row at X=3, Y=10
	.byte $76, $4B, $09  ; 4X row at X=7, Y=11
	.byte $FE
	.byte $00, $0E
	.byte $36, $4B, $08  ; 4X row at X=3, Y=11
	.byte $76, $4D, $08  ; 4X row at X=7, Y=13
	.byte $FF       ; terminator

level0_r1:
	.byte 1, 0, 12
	.byte 1, 0       ; starting ground, background
	.byte 0, 0, 0, 0 ; warp room numbers
	.byte 0, 0, 0, 0 ; warp room coords
	.byte 0          ; spare
	.word level0_r1_t
	.word level0_r1_e

level0:
	.byte $00    ; normal environment
	.byte $01    ; room count
	.word level0_r1
