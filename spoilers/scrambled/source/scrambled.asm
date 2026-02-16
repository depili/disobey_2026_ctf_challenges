		CPU	Z180
		RELAXED	ON

BDOS		EQU	0005H
CONIN		EQU	1
CONOUT		EQU	2

TFT_CMD		EQU	0x54
TFT_DATA	EQU	0x55

TFT_COLS	EQU	320
TFT_ROWS	EQU	240

TFT_CMD_NOP	EQU	0x00			; No operation
TFT_SWRESET	EQU	0x01			; Software reset
TFT_RDDID	EQU	0x04			; Read ID, read 4 bytes after, first dummy, then 3 bytes of ID
TFT_RDDST	EQU	0x09			; Read display status, 5 bytes, including one dummy
TFT_RDDPM	EQU	0x0A			; Read display power mode, 2 bytes
TFT_RDDCOLMOD	EQU	0x0C			; Read display MADCTL
TFT_RDDIM	EQU	0x0D			; Read display image mode
TFT_RDDSM	EQU	0x0E			; Read display signal mode
TFT_RDDSDR	EQU	0x0F			; Read display self diagnostic result, 2 bytes
TFT_SLPIN	EQU	0x10			; Sleep in & booster off
TFT_SLPOUT	EQU	0x11			; Sleep out & booster on
TFT_PTLON	EQU	0x12			; Partial mode on
TFT_NORON	EQU	0x13			; Partial mode off, normal mode
TFT_INVOFF	EQU	0x20			; Invert off
TFT_INVON	EQU	0x21			; Invert on
TFT_GAMSET	EQU	0x26			; Gamma set, 1 byte
TFT_DISPOFF	EQU	0x28			; Display off
TFT_DISPON	EQU	0x29			; Display on
TFT_CASET	EQU	0x2A			; Column address set; X start high, X start low, X end high, X end low
TFT_RASET	EQU	0x2B			; Row address set; Y start high, Y start low, Y end high, Y end low
TFT_RAMWR	EQU	0x2C			; Memory write
TFT_RGBSET	EQU	0x2D			; LUT for 4k, 65k, 262k color display
TFT_RAMRD	EQU	0x2E			; Ram read, first one dummy byte, then data
TFT_PTLAR	EQU	0x30			; Partial start / end address set
TFT_SCRLAR	EQU	0x33			; Scroll area set
TFT_TEOFF	EQU	0x34			; Tearing effect line off
TFT_TEON	EQU	0x35			; Tearing effect line on, 1 byte
TFT_MADCTL	EQU	0x36			; Memory data access control (display rotation), 1 byte
TFT_VSCSAD	EQU	0x37			; Scroll start address of ram
TFT_IDMOFF	EQU	0x38			; Idle mode off
TFT_IDMON	EQU	0x39			; Idle mode on
TFT_COLMOD	EQU	0x3A			; Interface color mode, 1 byte
TFT_RDID1	EQU	0xDA			; Read ID 1
TFT_RDID2	EQU	0xDB			; Read ID 2
TFT_RDID3	EQU	0xDC			; Read ID 3

TFT_MADCTL_MH	EQU	0x04
TFT_MADCTL_RGB	EQU	0x08
TFT_MADCTL_ML	EQU	0x10
TFT_MADCTL_MV	EQU	0x20
TFT_MADCTL_MX	EQU	0x40
TFT_MADCTL_MY	EQU	0x80

TFT_565		EQU	0x55
TFT_888		EQU	0x66

TFT_MADCTL_VAL	EQU	TFT_MADCTL_MV + TFT_MADCTL_MX
TFT_GAMMA	EQU	0x01

z180_base	EQU	080H				; Z180 I/O Register Base Address (adjust as needed)

Z180_SAR0L	EQU	Z180_BASE + 20H		; dma0 source addr lo
Z180_SAR0H	EQU	Z180_BASE + 21H		; dma0 source addr hi
Z180_SAR0B	EQU	Z180_BASE + 22H		; dma0 source addr bank
Z180_DAR0L	EQU	Z180_BASE + 23H		; dma0 dest addr lo
Z180_DAR0H	EQU	Z180_BASE + 24H		; dma0 dest addr hi
Z180_DAR0B	EQU	Z180_BASE + 25H		; dma0 dest addr bank
Z180_BCR0L	EQU	Z180_BASE + 26H		; dma0 byte count lo
Z180_BCR0H	EQU	Z180_BASE + 27H		; dma0 byte count hi
Z180_MAR1L	EQU	Z180_BASE + 28H		; dma1 memory addr lo
Z180_MAR1H	EQU	Z180_BASE + 29H		; dma1 memory addr hi
Z180_MAR1B	EQU	Z180_BASE + 2AH		; dma1 memory addr bank
Z180_IAR1L	EQU	Z180_BASE + 2BH		; dma1 i/o addr lo
Z180_IAR1H	EQU	Z180_BASE + 2CH		; dma1 i/o addr hi
Z180_IAR1B	EQU	Z180_BASE + 2DH		; dma1 i/o addr bank (z8s180)
Z180_BCR1L	EQU	Z180_BASE + 2EH		; dma1 byte count lo
Z180_BCR1H	EQU	Z180_BASE + 2FH		; dma1 byte count hi
Z180_DSTAT	EQU	Z180_BASE + 30H		; dma status
Z180_DMODE	EQU	Z180_BASE + 31H		; dma mode
Z180_DCNTL	EQU	Z180_BASE + 32H		; dma/wait control


; Parameters for the transfer (must be defined elsewhere in your code)
DMA_SRC_ADDR	EQU	08000H		; Logical start address of the memory buffer (16-bit)
DMA_COUNT	EQU	0100H		; Number of bytes to transfer (up to 65535)
IO_PORT_ADDR	EQU	0C0H		; The 8-bit I/O Port address to write to
DMA_DEST_ADDR	EQU	09000H		; Logical start address of the memory buffer (16-bit)

		; CPM executable gets loaded at 0x0100
		PHASE	0100H
		JR	MAIN

MAIN:
		CALL	TFT_INIT
		CALL	TFT_CLEAR

		LD	A, 0
		CALL	TFT_SET_BG
		LD	B, 32
-		CALL	TFT_SCROLL
		INC	A
		CALL	TFT_SET_BG
		DJNZ	-

		LD	HL, FLAG
		LD	E, FLAG_LEN
		LD	D, 0
		LD	C, 20
-		LD	B, 0
-		LD	A, D
		CALL	TFT_SET_FG
		LD	A, (HL)
		CALL	TFT_PUTC		; A char, B, C position
		INC	HL
		DEC	E
		JR	NZ, +			; Still more text
		LD	HL, FLAG
		LD	E, FLAG_LEN
+		INC	D
		INC	B
		LD	A, B
		CP	TFT_COLS / 8
		JR	NZ, -			; Continue on row
		LD	B, 0
		INC	C
		LD	A, C
		CP	TFT_ROWS / 8
		JR	NZ, -			; Continue until filled


		XOR	A
		OUT0	(Z180_DSTAT), A
		RET

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
		CALL	DMA_IO_TO_MEM

;		LD	E, TFT_COLS / 4		; Loop reads 4 pixels at a time, this supports up to 1024 wide screens
;.read_loop:	REPT	3 * 4			; 3 bytes per pixel, 4 pixels
;		INI
;		ENDM
;		DEC	E
;		JR	NZ, .read_loop		; Cant use B as INI will mangle it

;		POP	DE			; Restore the write address
		CALL	TFT_SCROLL_RASET	; Set write row address
		LD	A, TFT_RAMWR		; TFT command for ram write
		OUT	(TFT_CMD), A
;		POP	HL			; Get stack buffer start
;		PUSH	HL
;		PUSH	DE			; Save row counter

		CALL	DMA_MEM_TO_IO


;		LD	E, TFT_COLS / 4		; Loop writes 4 pixels at a time, this supports up to 1024 wide screens
;.write_loop:	REPT	3 * 4			; 3 bytes per pixel, 4 pixels
;		OUTI
;		ENDM
;		DEC	E
;		JR	NZ, .write_loop



;		POP	DE			; Restore row address
;		POP	HL			; Restore stack buffer
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

TFT_STACK:	DS	2

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

TFT_BG:		DW	0x0000
TFT_FG:		DW	0xFFFF

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
		LD	A, TFT_INVON		; no invert
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



; --- DMA to IO, source HL, assume last 64k of memory space
DMA_MEM_TO_IO:
		PUSH	AF
		PUSH	HL
		DI
		; Disable the DMA
		XOR	A
		OUT0	(Z180_DSTAT), A
		OUT0	(Z180_DCNTL), A

		; Set Source Address (Memory)
		OUT0	(Z180_SAR0L), L
		OUT0	(Z180_SAR0H), H
		LD	A, 0Fh
		OUT0	(Z180_SAR0B), A

		; Set Destination Address (I/O Port)
		LD	A, TFT_DATA
		OUT0	(Z180_DAR0L), A
		XOR	A
		OUT0	(Z180_DAR0H), A
		; Need to clear the high bits, for transfer type flags
		OUT0	(Z180_DAR0B), A

		; Set Byte Count
		LD	HL, TFT_COLS * 3
		OUT0	(Z180_BCR0L), L
		OUT0	(Z180_BCR0H), H

		; DMODE
		; Bit 7 - unused
		; Bit 6 - unused
		; Bit 5 - DM1
		; Bit 4 - DM0 - 11 = IO destination
		; Bit 3 - SM1
		; Bit 2 - SM0 - 00 = Memory++
		; Bit 1 - MMOD
		; Bit 0 - unused

		LD	A, 00110010B		; Ch0 Mem++ -> IO
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

		EI
		POP	HL
		POP	AF
		RET
DMA_IO_TO_MEM:
		PUSH AF
		PUSH HL
		DI

		; Disable the DMA
		XOR	A
		OUT0	(Z180_DSTAT), A
		OUT0	(Z180_DCNTL), A

		; Set Destination Address (Memory)
		OUT0	(Z180_DAR0L), L
		OUT0	(Z180_DAR0H), H
		LD	A, 0Fh
		OUT0	(Z180_DAR0B), A

		; Set Source Address (I/O Port)
		LD	A, TFT_DATA
		OUT0	(Z180_SAR0L), A
		XOR	A
		OUT0	(Z180_SAR0H), A
		; Need to clear the high bits, for transfer type flags
		OUT0	(Z180_SAR0B), A

		; Set Byte Count
		LD	HL, TFT_COLS * 3
		OUT0	(Z180_BCR0L), L
		OUT0	(Z180_BCR0H), H

		; DMODE
		; Bit 7 - unused
		; Bit 6 - unused
		; Bit 5 - DM1
		; Bit 4 - DM0 - 00 = Memory++
		; Bit 3 - SM1
		; Bit 2 - SM0 - 11 = IO
		; Bit 1 - MMOD
		; Bit 0 - unused

		LD	A, 00001110B		; Ch0 IO -> Mem++
		OUT0	(Z180_DMODE), A

		; Start the DMA Transfer (DSTAT Register)
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

		EI				; Re-enable interrupts
		POP	HL
		POP	AF
		RET				; Return from the routine



FLAG:
		db	"DISOBEY[8Q.!6KJZ9%T1PAGVM:54N2RFHCWUL30X7&]"
FLAG_LEN	equ	$ - FLAG

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

		listing off
		include	"scrambled_font.asm"
		listing	on