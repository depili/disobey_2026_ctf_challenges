# Scrambled eggs

A simple Z180 CP/M 2.2 binary that prints the flag on a display with a scrambled font. The code has been written for a slightly different TFT module than what is present on the physical target hardware, so that one can't solve it by just running it.


## Description

This is some serious crypto stuff. It utilizes the latest Kouvosto Telecom crypto module ST7789 at IO 0x54 and 0x55 on their custom Z180 CP/M system. Load address 0x100, entry point 0x100.


## Flag

`DISOBEY[this crypto module supports colors]`


## Walkthrough

Running the binary on the actual hardware prints the flag on the screen.

The string `DISOBEY[8Q.!6KJZ9%T1PAGVM:54N2RFHCWUL30X7&]` is present on the binary. Locating the screen putc function and getting the 8x8 bitmap font from there allows one to render the glyphs used and unscramble the flag.


## Files

* challenge/SCRAMBLED.COM
* source/ - source code for the challenge

## Contact info

Vesa-Pekka Palmu, vpalmu@depili.fi - +358 40 5278601