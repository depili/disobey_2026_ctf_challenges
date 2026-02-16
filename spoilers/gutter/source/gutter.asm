		CPU	Z180
		RELAXED	ON

		include "z180.asm"

secrets		EQU	1

; Parameters for the transfer (must be defined elsewhere in your code)
DMA_SRC_ADDR	EQU	08000H		; Logical start address of the memory buffer (16-bit)
DMA_COUNT	EQU	0100H		; Number of bytes to transfer (up to 65535)
IO_PORT_ADDR	EQU	0C0H		; The 8-bit I/O Port address to write to
DMA_DEST_ADDR	EQU	09000H		; Logical start address of the memory buffer (16-bit)


mem_start	equ	08000h
fp_led_io	equ	00h


CPUOSC		.SET	18432000	; CPU OSC FREQ IN MHZ
INTMODE		.SET	2		; INTERRUPTS: 0=NONE, 1=MODE 1, 2=MODE 2, 3=MODE 3 (Z280)
;
RAMSIZE		.SET	512		; SIZE OF RAM IN KB (MUST MATCH YOUR HARDWARE!!!)
ROMSIZE		.SET	512		; SIZE OF ROM IN KB (MUST MATCH YOUR HARDWARE!!!)
APP_BNKS	.SET	$FF		; BANKS TO RESERVE FOR APP USE ($FF FOR AUTO SIZING)
RAMBIAS		.SET	ROMSIZE		; OFFSET OF START OF RAM IN PHYSICAL ADDRESS SPACE
MPGSEL_0	.SET	$78		; Z2 MEM MGR BANK 0 PAGE SELECT REG (WRITE ONLY)
MPGSEL_1	.SET	$79		; Z2 MEM MGR BANK 1 PAGE SELECT REG (WRITE ONLY)
MPGSEL_2	.SET	$7A		; Z2 MEM MGR BANK 2 PAGE SELECT REG (WRITE ONLY)
MPGSEL_3	.SET	$7B		; Z2 MEM MGR BANK 3 PAGE SELECT REG (WRITE ONLY)
MPGENA		.SET	$7C		; Z2 MEM MGR PAGING ENABLE REGISTER (BIT 0, WRITE ONLY)
;
Z180_CLKDIV	.SET	0		; Z180: CHK DIV: 0=OSC/2, 1=OSC, 2=OSC*2
Z180_MEMWAIT	.SET	0		; Z180: MEMORY WAIT STATES (0-3)
Z180_IOWAIT	.SET	1		; Z180: I/O WAIT STATES TO ADD ABOVE 1 W/S BUILT-IN (0-3)
Z180_CNTR_DEF	.EQU	$06		; DEFAULT VALUE FOR Z180 CSIO CONFIG


ASCI_DEF_CNTLA	.EQU	$64
ASCI_DEF_CNTLB	.EQU	$20
ASCI_DEF_ASEXT	.EQU	$60
;
ASCI_BUFSZ	.EQU	32		; RECEIVE RING BUFFER SIZE
;
ASCI_NONE	.EQU	0		; NOT PRESENT
ASCI_ASCI	.EQU	1		; ORIGINAL ASCI (Z8S180 REV. K)
ASCI_ASCIB	.EQU	2		; REVISED ASCI W/ BRG & FIFO (Z8S180 REV. N)
;
ASCI0_BASE	.EQU	Z180_BASE	; RELATIVE TO Z180 INTERNAL IO PORTS
ASCI1_BASE	.EQU	Z180_BASE + 1	; RELATIVE TO Z180 INTERNAL IO PORTS
;
ASCI_RTS	.EQU	%00010000	; ~RTS BIT OF CNTLA REG

stack		equ	0DD00h

		; Memory, stack will be bellow this
		ORG	stack

asci0_tx_buf	ds	256
asci0_rx_buf	ds	256		; FIXME 512 byte buffers to comply with irc?
		align	0100h
isr_page:	ds	256
asci0_rx_rd:	ds	1		; RX read pointer
asci0_rx_wr:	ds	1		; RX write pointer
asci0_tx_rd:	ds	1		; TX read pointer
asci0_tx_wr:	ds	1		; TX write pointer
tft_row:	ds	1
tft_col:	ds	1
led_state:	ds	1
led_timer:	ds	1
TFT_STACK:	DS	2
TFT_BG:		Ds	2
TFT_FG:		Ds	2



		ORG	0000H
		JR	MAIN

MAIN:
		DI
		IM	2
		ld	a, 1h
		out	(fp_led_io), a

		LD	A,Z180_BASE
		OUT0	($3F),A		; AT RESET, ICR IS AT $3F

		XOR	A
		OUT0	(Z180_RCR),A

		; MASK OFF TIMER INTERRUPTS
		XOR	A
		OUT0	(Z180_TCR),A
		OUT0	(Z180_ITC),A

		; SET DEFAULT CPU CLOCK MULTIPLIERS (XTAL / 2)
		;
		; BILL MCMULLEN REPORTED THAT CMR NEEDS TO BE SET PRIOR TO CCR
		; WHEN USING A CPU FREQUENCY (PHI) THAT IS XTAL * 2.
		; HERE WE ARE SETTING CPU FREQUENCY TO XTAL / 2, BUT JUST
		; FOR GOOD MEASURE, CMR IS SET PRIOR TO CCR BELOW.
		; https://www.retrobrewcomputers.org/forum/index.php?t=msg&th=316&goto=5045&#msg_5045
		XOR	A
		OUT0	(Z180_CMR),A
		OUT0	(Z180_CCR),A


		; SET DEFAULT WAIT STATES
		LD	A,$F0
		OUT0	(Z180_DCNTL),A

		; Z180 MMU SETUP
		LD	A,$80
		OUT0	(Z180_CBAR),A		; SETUP FOR 32K/32K BANK CONFIG

		LD	A,(RAMSIZE + RAMBIAS - 64) >> 2
		OUT0	(Z180_CBR),A		; COMMON BASE = LAST (TOP) BANK

		; SET DEFAULT CSIO SPEED (INTERNAL CLOCK, SLOW AS POSSIBLE)
		LD	A,Z180_CNTR_DEF		; DIV 1280, 14KHZ @ 18MHZ CLK
		OUT0	(Z180_CNTR),A


		ld	hl, mem_start
		ld	de, mem_start + 1
		ld	bc, 0ffffh - mem_start
		ld	(hl), 00h
		xor	a
		ldir
		ld	sp, stack

		ld	a, 02h
		out	(fp_led_io), a
		ld	(led_state), a
		ld	a, 50
		ld	(led_timer), a

		call	uart_init
		ld	hl, banner
		call	puts0


		call	isr_init

		LD	A, 0
		CALL	TFT_SET_BG
		LD	A, 10
		CALL	TFT_SET_FG

		CALL	TFT_INIT
		CALL	TFT_CLEAR

		LD	HL, banner
		CALL	puts_tft


		LD	A, (tft_row)
		INC	A
		LD	(tft_row), A

		ld	hl, PROMPT
		CALL	puts_tft

		ld	HL, asci0_rx_buf
		ld	(asci0_rx_wr), HL

-
		call	getc0
		ld	(HL), A
		inc	HL
		; call	print_word0
		call	TFT_PRINT
		cp	"\r"
		jr	z, .fake_process
		jr	-
.fake_process	ld	ix, asci0_rx_buf
		ld	hl, newline
		call	puts_tft
		ld	a, (ix+2)
		ld	b, (ix+3)
		sub	"0"
		add	a, b
		sub	"0"
		call	print_byte
		ld	hl, PRICE
		call	puts_tft
-		call	getc0
		cp	"\r"
		jr	nz, -
		jp	0


newline:
		db	"\r\n",0

z180_isr_table:
.int1		dw	ei_reti
.int2		dw	ei_reti
.prt0		dw	prt_isr
.prt1		dw	prt_isr
.dma0		dw	ei_reti
.dma1		dw	ei_reti
.csi		dw	ei_reti
.asci0		dw	asci_isr
.asci1		dw	asci_isr

ei_reti:
		ei
		reti

		align	100h	; Make exploiting slightly easier
		ds	41h
		; 50Hz timer interrupt
prt_isr:
		di
		ex	af, af'
		exx
		in0	a,(z180_tcr)		; Ack interrupt
		in0	a,(z180_tmdr0l)
		in0	a,(z180_tmdr1l)

		ld	a, (led_timer)
		dec	a
		jr	z, +
		ld	(led_timer), a
		jr	.end
+		ld	a, 50
		ld	(led_timer), a
		ld	a, (led_state)
		xor	80h
		out	(fp_led_io), a
		ld	(led_state), a

.end		exx
		ex	af, af'
		ei
		reti

asci_isr:
		di
		ex	af, af'
		exx

		in0	a, (z180_stat1)
		bit	7, a
		; call	nz, asci1_rx_available

		in0	a, (z180_stat1)
		bit	1, a
		; call	nz, asci1_tx_empty

		; Reset error flags
		in0	a, (z180_cntla1)
		res	3, a
		out0	(z180_cntla1), a

		exx
		ex	af, af'
		ei
		reti


isr_init:
		ld	a, isr_page >> 8
		ld	i, a
		ld	hl, z180_isr_table
		ld	de, isr_page
		ld	bc, ei_reti - z180_isr_table
		ldir

		; z180 prescales the counter by 20 so,
		; rldr = cpu clk / 20 / tickfreq
		; if we assume tickfreq = 50, we can simplify to
		; rldr = cpu clk / 1000
		; if we divide both sides by 1000, we can use
		; cpukhz value and simplify to
		; rldr = cpukhz
		xor	a			; all bits zero
		out0	(z180_tcr),a		; ... inhibits timer operation
		out0	(z180_itc), a		; disable external interrupts
						; Enable trap vectoring to 0 for illegal instruction
		ld	hl, 02400h		; 50hz = 18432000 / 20 / 50 / x, so x = cpu khz
		out0	(z180_tmdr1l),l		; initialize timer 0 data register
		out0	(z180_tmdr1h),h
		dec	hl			; reload occurs *after* zero
		out0	(z180_rldr1l),l		; initialize timer 0 reload register
		out0	(z180_rldr1h),h
		ld	a, 022h			; enable timer0 int and down counting
		out0	(z180_tcr),a
		im	2
		ei


;
; Fill the screen with background color
;
TFT_CLEAR:	PUSH	AF
		PUSH	BC
		PUSH	DE
		PUSH	HL
		LD	A, TFT_CASET		; Column address set
		OUT	(TFT_CMD), A
		LD 	A, 0
		OUT	(TFT_DATA), A
		OUT	(TFT_DATA), A
		LD	A, (TFT_COLS - 1) >> 8
		OUT	(TFT_DATA), A
		LD	A, (TFT_COLS - 1) & 0xFF
		OUT	(TFT_DATA), A

		LD	A, TFT_RASET		; Row address set
		OUT	(TFT_CMD), A
		LD	A, 0
		OUT	(TFT_DATA), A
		OUT	(TFT_DATA), A
		LD	A, TFT_ROWS - 1 >> 8
		OUT	(TFT_DATA), A
		LD	A, TFT_ROWS - 1 & 0xFF
		OUT	(TFT_DATA), A
		LD	A, TFT_RAMWR		; Write data
		OUT	(TFT_CMD), A
		LD	DE, (TFT_BG)
		LD	C, TFT_DATA
		LD	HL, TFT_ROWS * TFT_COLS / 8
.loop:		REPT	8			; Write 8 pixels per loop
		OUT	(C), D
		OUT	(C), E
		ENDM
		DEC	HL
		LD	A, H
		OR	L
		JR	NZ, .loop
		xor	a
		ld	(tft_row), a
		ld	(tft_col), a
		POP	HL
		POP	DE
		POP	BC
		POP	AF
		RET

;
; Scroll down by one line
;
TFT_SCROLL:	PUSH	AF
		PUSH	BC
		PUSH	DE
		PUSH	HL
		LD	(TFT_STACK), SP		; Allocate TFT_ROWS x 3 bytes on the stack
		LD	HL, (TFT_STACK)
		LD	DE, TFT_COLS * 3
		OR	A
		SBC	HL, DE
		LD	SP, HL
		LD	A, TFT_COLMOD		; Set the TFT to 888 color mode
		OUT	(TFT_CMD), A
		LD	A, TFT_888
		OUT	(TFT_DATA), A
		LD	A, TFT_CASET		; Set column address for whole row
		OUT	(TFT_CMD), A
		XOR	A
		OUT	(TFT_DATA), A
		OUT	(TFT_DATA), A
		LD	A, (TFT_COLS - 1) >> 8
		OUT	(TFT_DATA), A
		LD	A, (TFT_COLS - 1) & 0xFF
		OUT	(TFT_DATA), A
		LD	C, TFT_DATA		; Use C for TFT_DATA port address pointer
		LD	DE, 0			; DE contains target row
.loop:		PUSH	HL			; Stack buffer start...
		PUSH	DE			; Save the target row
		LD	A, E
		ADD	A, 8
		LD	E, A
		JR	NC, +
		INC	D			; DE contains start row + 8, the source row
+		CALL	TFT_SCROLL_RASET	; Set read row address
+		LD	A, TFT_RAMRD		; TFT command for ram read
		OUT	(TFT_CMD), A
		IN	A, (TFT_DATA)		; Dummy read, for TFT internal setup

		POP	DE
		POP	HL
;		CALL	DMA_IO_TO_MEM

		LD	E, TFT_COLS / 4		; Loop reads 4 pixels at a time, this supports up to 1024 wide screens
.read_loop:	REPT	3 * 4			; 3 bytes per pixel, 4 pixels
		INI
		ENDM
		DEC	E
		JR	NZ, .read_loop		; Cant use B as INI will mangle it

		POP	DE			; Restore the write address
		CALL	TFT_SCROLL_RASET	; Set write row address
		LD	A, TFT_RAMWR		; TFT command for ram write
		OUT	(TFT_CMD), A
		POP	HL			; Get stack buffer start
		PUSH	HL
		PUSH	DE			; Save row counter

;		CALL	DMA_MEM_TO_IO


		LD	E, TFT_COLS / 4		; Loop writes 4 pixels at a time, this supports up to 1024 wide screens
.write_loop:	REPT	3 * 4			; 3 bytes per pixel, 4 pixels
		OUTI
		ENDM
		DEC	E
		JR	NZ, .write_loop

		POP	DE			; Restore row address
		POP	HL			; Restore stack buffer
		INC	DE			; Next row
		LD	A, D			; Check for TFT_ROWS - 8
		CP	(TFT_ROWS - 8) >> 8
		JR	NZ, .loop
		LD	A, E
		CP	(TFT_ROWS - 8) & 0xFF
		JR	NZ, .loop
		LD	SP, (TFT_STACK)		; End of scroll loop, restore stack
		LD	A, TFT_RASET		; Set write area to last 8 rows
		OUT	(TFT_CMD), A
		LD	A, TFT_ROWS - 8 >> 8
		OUT	(TFT_DATA), A
		LD	A, TFT_ROWS - 8 & 0xFF
		OUT	(TFT_DATA), A
		LD	A, TFT_ROWS - 1 >> 8
		OUT	(TFT_DATA), A
		LD	A, TFT_ROWS - 1 & 0xFF
		OUT	(TFT_DATA), A
		LD	A, TFT_COLMOD		; Restore the color mode
		OUT	(TFT_CMD), A
		LD	A, TFT_565
		OUT	(TFT_DATA), A
		LD	A, TFT_RAMWR
		OUT	(TFT_CMD), A
		LD	HL, TFT_COLS		; Fill the last 8 rows with BG color
		LD	C, TFT_DATA
		LD	DE, (TFT_BG)
.fill_loop:	REPT	8			; Output 8 pixels per loop iteration
		OUT	(C), D
		OUT	(C), E
		ENDM
		DEC	HL
		LD	A, H
		OR	L
		JR	NZ, .fill_loop
		POP	HL
		POP	DE
		POP	BC
		POP	AF
		RET


TFT_SCROLL_RASET:
		LD	A, TFT_RASET
		OUT	(TFT_CMD), A
		OUT	(C), D
		OUT	(C), E
		OUT	(C), D
		OUT	(C), E
		RET

TFT_SET_FG:	PUSH	AF
		PUSH	BC
		PUSH	HL
		LD	HL, TFT_PALETTE
		AND	0x0F
		SLA	A
		ADD	A, L
		LD	L, A
		LD	C, (HL)
		INC	HL
		LD	B, (HL)
		LD	HL, TFT_FG
		LD	(HL), C
		INC	HL
		LD	(HL), B
		POP	HL
		POP	BC
		POP	AF
		RET

TFT_SET_BG:	PUSH	AF
		PUSH	BC
		PUSH	HL
		LD	HL, TFT_PALETTE
		AND	0x0F
		SLA	A
		ADD	A, L
		LD	L, A
		LD	C, (HL)
		INC	HL
		LD	B, (HL)
		LD	HL, TFT_BG
		LD	(HL), C
		INC	HL
		LD	(HL), B
		POP	HL
		POP	BC
		POP	AF
		RET


TFT_PRINT:
		push	bc
		push 	af
		cp	"\r"
		jr	z, .cr
		cp	"\n"
		jr	z, .nl
		ld	a, (tft_col)
		ld	b, a
		ld	a, (tft_row)
		ld	c, a
		pop	af
		call	TFT_PUTC
		push	af
		inc	b
		ld 	a, b
		cp	TFT_COLS / 8
		jr	nz, .next_col	; just increment column
.nl		xor	a
		ld	(tft_col), a
		ld	a, (tft_row)
		inc	a
		cp	TFT_ROWS / 8
		jr	nz, .next_row
		xor	a
		ld	(tft_row), a
		jr	.end
.next_row
		ld	(tft_row), a
		jr	.end

.next_col	ld	(tft_col), a
.end		pop	af
		pop	bc
		ret
.cr		xor	a
		jr	.next_col

		; B = col, C = row
		; A = character
TFT_PUTC:	PUSH	AF
		PUSH	BC
		PUSH	DE
		PUSH	HL
		CALL	TFT_SET_POS
		CALL	TFT_GETGLYPH
		LD	A, TFT_RAMWR
		OUT	(TFT_CMD), A
		LD	C, TFT_DATA
		LD	B, 8
		LD	DE, (TFT_BG)
.loop:		LD	A, (HL)
		INC	HL
		PUSH	HL
		LD	HL, (TFT_FG)
		REPT	8
		RLCA			; Rotate A left to carry fast
		JR	C, +
		OUT	(C), D		; DE contains the background color
		OUT	(C), E
		JR	++
+		OUT	(C), H		; HL contains the foreground color
		OUT	(C), L
+
		ENDM
		POP	HL
		DEC	B
		JR	Z, .end
		JP	.loop
.end:		POP	HL
		POP	DE
		POP	BC
		POP	AF
		RET

TFT_DRAW_FG:	LD	A, 0
		OUT	(TFT_DATA), A
		OUT	(TFT_DATA), A
		RET

TFT_DRAW_BG:	LD	A, 0
		OUT	(TFT_DATA), A
		OUT	(TFT_DATA), A
		RET


;
; Set write area to given glyph
; B colums, C rows
;
TFT_SET_POS:	PUSH	AF
		PUSH	DE
		LD	D, 0
		LD	E, B
		LD	A, TFT_CASET
		OUT	(TFT_CMD), A
		CALL	TFT_SET_REGION
		LD	D, 0
		LD	E, C
		LD	A, TFT_RASET
		OUT	(TFT_CMD), A
		CALL	TFT_SET_REGION
		POP	DE
		POP	AF
		RET


TFT_SET_REGION:	SLA	E			; Multiply by 8
		RL	D
		SLA	E
		RL	D
		SLA	E
		RL	D
		LD	A, D
		OUT	(TFT_DATA), A
		LD	A, E
		OUT	(TFT_DATA), A
		LD	A, 7
		ADD	A, E
		JR	NC, +
		INC	D
+		LD	E, A
		LD	A, D
		OUT	(TFT_DATA), A
		LD	A, E
		OUT	(TFT_DATA), A
		RET


;
; Get pointer to font glyph
; A - character
; Returns the pointer in HL
;
TFT_GETGLYPH:	PUSH	BC
		LD	B, 0
		LD	C, A
		SLA	C			; Multiply by 8
		RL	B
		SLA	C
		RL	B
		SLA	C
		RL	B
		LD	HL, FONT8x8U
		ADD	HL, BC
		POP	BC
		RET

		; TODO: SW reset with 120 msec delay...
TFT_INIT:	LD	A, TFT_COLMOD		; data format
		OUT	(TFT_CMD), A
		LD	A, TFT_565		; 5-6-5
		OUT	(TFT_DATA), A
		LD	A, TFT_MADCTL		; Screen rotation
		OUT	(TFT_CMD), A
		LD	A, TFT_MADCTL_VAL
		OUT	(TFT_DATA), A
		LD	A, TFT_INVOFF		; no invert
		OUT	(TFT_CMD), A
		LD	A, TFT_GAMSET		; Gamma
		OUT	(TFT_CMD), A
		LD	A, TFT_GAMMA
		OUT	(TFT_DATA), A
		LD	A, TFT_SLPOUT		; Sleep out
		OUT	(TFT_CMD), A

		LD	A, TFT_DISPON		; Display on
		OUT	(TFT_CMD), A

		RET


		include "io.asm"

BANNER:
		db	"Kouvosto Telecom Rain Gutter Calculator V0.1rc1beta2\r\n"
		db	"Unauthorized use forbidden.\r\n",0

PROMPT:
		db	"Rain gutter code:", 0

PRICE:
		db	" kouvosto bucks per furlong.\r\n",0

;
; CGA colors, 2 bytes per color, 5-6-5 format
;
		ALIGN	0x0020
TFT_PALETTE:
		dw	0x0000		; 0 - Black
		dw	0x0015		; 1 - Blue
		dw	0x0540		; 2 - Green
		dw	0x0555		; 3 - Teal
		dw	0xA800		; 4 - Red
		dw	0xA815		; 5 - Pink
		dw	0xAAA0		; 6 - Brown
		dw	0xAD55		; 7 - Light grey
		dw	0x52AA		; 8 - Dark grey
		dw	0x52BF		; 9 - Light blue
		dw	0x57EA		; 10 - Light green
		dw	0x57FF		; 11 - Light teal
		dw	0xFAAA		; 12 - Light red
		dw	0xFABF		; 13 - Light pink
		dw	0xFFEA		; 14 - Yellow
		dw	0xFFFF		; 15 - White

		ORG	7000h
flag1:
		ifdef	secrets
		db	"DISOBEY[Consider trying harder for the second flag!]",0
		elseif
		db	"DISOBEY[                                           ]",0
		endif

		listing off
		include	"font8x8u.asm"
		listing	on

		; This area will not be directly accessible, as it is not mapped with the MMU
		ORG	0deadh
		ifdef	secrets
FLAG:		db	"Nyt ei kyllä pää kestä arvon henkilöstöpäälikkö Jorma Roposta ollenkaan. "
		db	"Tän homman piti olla helppo, yks insinöörikeikka noille kouvosto telecomin urpoille, "
		db	"mutta tää keikka on ihan tuskaa, ei näillä oo täällä kouvosto telecomilla minkäänlaista "
		db	"cadia tai ees kunnon tietokoneita. Nyt tähän kuukauden hommaan on mennyt jo pari vuotta ja "
		db	"menin sitten tyhmänä ottamaan urakkapalkan. Koska pännii niin tässä on niiden idioottejen "
		db	"uusin salasana kaikkiin järjestelmiin: "

		db	"DISOBEY[Now you know how to map memory!]",0
FLAG_LEN	equ	$ - FLAG
		endif