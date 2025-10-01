
; increments 16-bit "thing" by 1
.macro increment_16 thing
.scope
	inc thing
	bne noCarry
	inc thing+1
noCarry:
.endscope
.endmacro

; adds an 8-bit value (constant or from memory) to 16-bit "thing"
.macro add_16 thing, value
.scope
	lda thing
	clc
	adc value
	sta thing
	bcc noCarry
	inc thing+1
noCarry:
.endscope
.endmacro

; subtracts an 8-bit value (constant or from memory) to 16-bit "thing"
.macro sub_16 thing, value
.scope
	lda thing
	sec
	sbc value
	sta thing
	bcs noCarry
	dec thing+1
noCarry:
.endscope
.endmacro

; adds a 16-bit value (constant) to 16-bit "thing"
.macro add_16_16 thing, constant
	lda #<(constant)
	clc
	adc thing
	sta thing
	lda #>(constant)
	adc thing+1
	sta thing+1
.endmacro

; adds the content of A to 16-bit "thing"
.macro add_16_a thing
.scope
	clc
	adc thing
	sta thing
	bcc noCarry
	inc thing+1
noCarry:
.endscope
.endmacro
