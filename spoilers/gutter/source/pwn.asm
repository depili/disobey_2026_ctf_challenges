		cpu	z180
		org	0
		phase	0DE00h

puts0		equ	04c9h
puts_tft	equ	04d2h

		rept	128
		nop
		endm
		di
-		ld	hl, 7000h
		call	puts_tft
		jr	-

		align 2
		rept	80
		dw	0DE41h
		endm
