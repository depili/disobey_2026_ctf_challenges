;
; Initialize Z180 ASCI
;
uart_init:
		;
		; Program the ASCI0 port
		;
		; CNTLB is programmed to achieve a divisor of CPU clock / 480.  For
		; a CPU with an 18.432 MHz clock running at half speed as programmed
		; above, this will be 9216000 / 480 = 19200 baud.
		;
		ld	a, 0
		out0	(z180_stat0), a		; disable interrupts, ch0
		out0	(z180_stat1), a		; disable interrupts, ch1

		ld	a, 64h			; xmit enable, rcv enable, 8 data bits, no parity
		out0	(z180_cntla1), a
		out0	(z180_cntla0), a

		ld	a, 0h			; Set both as 57600-8-N-1
		out0	(z180_cntlb0), a
		out0	(z180_cntlb1), a
		ld	a,

		ld	a, 60h			; dcd0 disable, cts0 disable
		out0	(z180_asext0), a
		ld	a, 0h
		out0	(z180_asext1), a

		ret

;
; Routine to print a string at HL to chan1
;
puts1:		ld	a, (hl)
		or	a
		ret	z
		call	putc1
		inc	hl
		jr	puts1

puts0:		ld	a, (hl)
		or	a
		ret	z
		call	putc0
		inc	hl
		jr	puts0


puts_tft:	ld	a, (hl)
		or	a
		ret	z
		call	tft_print
		inc	hl
		jr	puts_tft


puts1_im:	pop	hl
		call	puts1
		inc	hl
		jp	(hl)

puts0_im:	pop	hl
		call	puts0
		inc	hl
		jp	(hl)


putc0:		push	af
.loop:		in0	a, (z180_stat0)
		and	02h
		jr	z, .loop
		pop	af
		out0	(z180_tdr0), a
		ret

putc1:		push	af
.loop:		in0	a, (z180_stat1)
		and	02h
		jr	z, .loop
		pop	af
		out0	(z180_tdr1), a
		ret


getc0:		in0	A, (z180_stat0)
		bit	7, A
		jr	z, getc0
		in0	a, (z180_rdr0)
		ret


getc1:		in0	A, (z180_stat1)
		bit	7, A
		jr	z, getc0
		in0	a, (z180_rdr1)
		ret


print_word:
		push	af
		ld	a, h
		call	print_byte
		ld	a, l
		call	print_byte
		pop	af
		ret


print_byte:
		push	af
		rra
		rra
		rra
		rra
		call	.conv
		pop	af
.conv:		and	0Fh
		add	a, 90h
		daa
		adc	a, 40h
		daa
		call	tft_print
		ret

;
; HL - src, DE - dest
; Returns size in BC
;
copy_line:
	ld	bc, 0
-	ld	a, (hl)
	cp	"\n"
	ld	(de), a
	ret	z
	inc	l
	inc	de
	inc	bc
	jr	-


;
; hl - source to compare
; de - dest
; sets carry on equal
;
strcmp:
	ld	a, (de)
	ld	b, a
	ld	a, (hl)
	and	a		; test (hl) for zero
	jr	z, .ok
	cp	b
	jr	nz, .fail
	inc	hl
	inc	de
	jr	strcmp
.ok:	scf
	ret
.fail:	and	a
	ret


