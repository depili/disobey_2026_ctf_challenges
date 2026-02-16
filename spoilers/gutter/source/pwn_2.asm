		cpu	z180
		RELAXED	ON
		org	0

		include z180.asm

		phase	0DE00h

puts0		equ	04c9h
puts_tft	equ	04d2h

		rept	128
		nop
		endm
		di

		; Disable the DMA
		XOR	A
		OUT0	(Z180_DSTAT), A
		OUT0	(Z180_DCNTL), A


		LD	HL, 0deadh
		; Set Source Address (Memory)
		OUT0	(Z180_SAR0L), L
		OUT0	(Z180_SAR0H), H
		XOR	A
		OUT0	(Z180_SAR0B), A

		; Set Destination Address (Memory)
		LD	HL, 9000h
		OUT0	(Z180_DAR0L), L
		OUT0	(Z180_DAR0H), H
		LD	A, D
		OUT0	(Z180_DAR0B), A

		; Set Byte Count
		LD	HL, 218h
		OUT0	(Z180_BCR0L), L
		OUT0	(Z180_BCR0H), H

		; DMODE
		; Bit 7 - unused
		; Bit 6 - unused
		; Bit 5 - DM1
		; Bit 4 - DM0 - 00 = Memory++
		; Bit 3 - SM1
		; Bit 2 - SM0 - 00 = Memory++
		; Bit 1 - MMOD
		; Bit 0 - unused

		LD	A, 00000010B		; Ch0 Mem++ -> Mem++
		OUT0	(Z180_DMODE), A

		; Bit 7: DE1 (Enable Channel 1)
		; Bit 6: DE0 (Enable Channel 0)
		; Bit 5: !DWE1 (Inverted write enable channel 1, set to 0 to write DE1)
		; Bit 4: !DWE0
		; Bit 3: DIE1 (DMA interrupt enable channel 1)
		; Bit 2: DIE0
		; Bit 1: unused
		; Bit 0: DME (DMA master enable)
		LD	A, 01000001B
		OUT0	(Z180_DSTAT), A
		LD	HL, 9000h
		CALL	puts0
		JP	0




		align 2
		rept	80
		dw	0DE41h
		endm
