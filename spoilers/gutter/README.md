# Gutter Punch

Z180 pwn challenge with provided hardware. A buffer overflow in serial RX ISR leads to overwriting the interrupt vector table.

One flag is in plain sight, another is behind the MMU.

This challenge uses the same hardware as in the hacker puzzle. I have five copies of the physical challenge available.

## Description

A defector from Kouvostoliitto has provided us with some kouvosto telecom z180 gear and a test version of their super secret software. Our source tells us that there should be some secrets implanted at 0x0dead.

0x00000-0x7FFFF is rom, 0x80000-0xFFFFF is ram. Uart 57600-8-N-1. Both USB A and USB C connections are provided.

Please limit your testing sessions to ~15 minutes if there are people queuing for the hardware.

## Flag

* Easy one, at 0x07000h `DISOBEY[Consider trying harder for the second flag!]`
* Harder one, at 0x0DEADh (ish): `DISOBEY[Now you know how to map memory!]`

## Walkthrough

Simply outputting enough crap to the serial will lead to overwriting the ISR table. Care needs to be used, as the interrupts happen before the full 16 bits of address can be hijacked and the lsb gets overwritten first.

The first flag can be gotten with payload like:
```
LD HL, 7000h
CALL PUTS0
```

Second flag will require dealing with the MMU, easiest in my opinion is to just use the mem to io functionality and just ask the DMA controller to dump stuff into the uart. Second option is to do a mem-to-mem copy with DMA and then dump the secrets. Otherwise one needs to juggle the memory regions around.

When sending the payload over one needs to be careful about the speed, as the characters are also written to the tft. Sending at full uart speed will cause parts of the payload to get dropped. This should be quite obvious when looking at what actually gets printed.

The harder flag is part of a block of text:

```
		db	"Nyt ei kyllä pää kestä arvon henkilöstöpäälikkö Jorma Roposta ollenkaan. "
		db	"Tän homman piti olla helppo, yks insinöörikeikka noille kouvosto telecomin urpoille, "
		db	"mutta tää keikka on ihan tuskaa, ei näillä oo täällä kouvosto telecomilla minkäänlaista "
		db	"cadia tai ees kunnon tietokoneita. Nyt tähän kuukauden hommaan on mennyt jo pari vuotta ja "
		db	"menin sitten tyhmänä ottamaan urakkapalkan. Koska pännii niin tässä on niiden idioottejen "
		db	"uusin salasana kaikkiin järjestelmiin: "
		db	"DISOBEY[Now you know how to map memory!]",0
```

## Files

* challenge/gutter.hex - binary without secrets, 100% checked this time!
* source/ - source code for the challenge
* source/pwn.asm - example payload for the easy pwn
* source/pwn_2.asm - example payload for the harder pwn (DMA mem-to-mem)

## Contact info

Vesa-Pekka Palmu, vpalmu@depili.fi - +358 40 5278601