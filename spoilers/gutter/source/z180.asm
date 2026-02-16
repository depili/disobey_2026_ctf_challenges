		listing off
z180_base	equ	080h
z180_cntla0	equ	z180_base + 00H		; asci0 control a
z180_cntla1	equ	z180_base + 01H		; asci1 control a
z180_cntlb0	equ	z180_base + 02H		; asci0 control b
z180_cntlb1	equ	z180_base + 03H		; asci1 control b
z180_stat0	equ	z180_base + 04H		; asci0 status
z180_stat1	equ	z180_base + 05H		; asci1 status
z180_tdr0	equ	z180_base + 06H		; asci0 transmit
z180_tdr1	equ	z180_base + 07H		; asci1 transmit
z180_rdr0	equ	z180_base + 08H		; asci0 receive
z180_rdr1	equ	z180_base + 09H		; asci1 receive
z180_cntr	equ	z180_base + 0aH		; csi/o control				;<----- For SD Card
z180_trdr	equ	z180_base + 0bH		; csi/o transmit/receive		;<----- For SD card
z180_tmdr0l	equ	z180_base + 0cH		; timer 0 data lo
z180_tmdr0h	equ	z180_base + 0dH		; timer 0 data hi
z180_rldr0l	equ	z180_base + 0eH		; timer 0 reload lo
z180_rldr0h	equ	z180_base + 0fH		; timer 0 reload hi
z180_tcr	equ	z180_base + 10H		; timer control
;
z180_asext0	equ	z180_base + 12H		; asci0 extension control (z8s180)
z180_asext1	equ	z180_base + 13H		; asci1 extension control (z8s180)
;
z180_tmdr1l	equ	z180_base + 14H		; timer 1 data lo
z180_tmdr1h	equ	z180_base + 15H		; timer 1 data hi
z180_rldr1l	equ	z180_base + 16H		; timer 1 reload lo
z180_rldr1h	equ	z180_base + 17H		; timer 1 reload hi
z180_frc	equ	z180_base + 18H		; free running counter

z180_astc0l	equ	z180_base + 1aH		; asci0 time constant lo (z8s180)
z180_astc0h	equ	z180_base + 1bH		; asci0 time constant hi (z8s180)
z180_astc1l	equ	z180_base + 1cH		; asci1 time constant lo (z8s180)
z180_astc1h	equ	z180_base + 1dH		; asci1 time constant hi (z8s180)
z180_cmr	equ	z180_base + 1eH		; clock multiplier (latest z8s180)
z180_ccr	equ	z180_base + 1fH		; cpu control (z8s180)
;
z180_sar0l	equ	z180_base + 20H		; dma0 source addr lo
z180_sar0h	equ	z180_base + 21H		; dma0 source addr hi
z180_sar0b	equ	z180_base + 22H		; dma0 source addr bank
z180_dar0l	equ	z180_base + 23H		; dma0 dest addr lo
z180_dar0h	equ	z180_base + 24H		; dma0 dest addr hi
z180_dar0b	equ	z180_base + 25H		; dma0 dest addr bank
z180_bcr0l	equ	z180_base + 26H		; dma0 byte count lo
z180_bcr0h	equ	z180_base + 27H		; dma0 byte count hi
z180_mar1l	equ	z180_base + 28H		; dma1 memory addr lo
z180_mar1h	equ	z180_base + 29H		; dma1 memory addr hi
z180_mar1b	equ	z180_base + 2aH		; dma1 memory addr bank
z180_iar1l	equ	z180_base + 2bH		; dma1 i/o addr lo
z180_iar1h	equ	z180_base + 2cH		; dma1 i/o addr hi
z180_iar1b	equ	z180_base + 2dH		; dma1 i/o addr bank (z8s180)
z180_bcr1l	equ	z180_base + 2eH		; dma1 byte count lo
z180_bcr1h	equ	z180_base + 2fH		; dma1 byte count hi
z180_dstat	equ	z180_base + 30H		; dma status
z180_dmode	equ	z180_base + 31H		; dma mode
z180_dcntl	equ	z180_base + 32H		; dma/wait control
z180_il		equ	z180_base + 33H		; interrupt vector load
z180_itc	equ	z180_base + 34H		; int/trap control
;
z180_rcr	equ	z180_base + 36H		; refresh control
;
z180_cbr	equ	z180_base + 38H		; mmu common base register
z180_bbr	equ	z180_base + 39H		; mmu bank base register
z180_cbar	equ	z180_base + 3aH		; mmu common/bank area register
;
z180_omcr	equ	z180_base + 3eH		; operation mode control
z180_icr	equ	z180_base + 3fH		; i/o control register


BDOS		EQU	0005H
CONIN		EQU	1
CONOUT		EQU	2

TFT_CMD		EQU	0x54
TFT_DATA	EQU	0x55

TFT_COLS	EQU	160
TFT_ROWS	EQU	128

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

TFT_MADCTL_VAL	EQU	TFT_MADCTL_MV + TFT_MADCTL_MY + TFT_MADCTL_RGB
TFT_GAMMA	EQU	0x02

		listing on
