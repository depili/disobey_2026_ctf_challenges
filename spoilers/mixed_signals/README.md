# Mixed signals

Basic logic analyzer capture with UART and SPI flags.

## Description

We were able to obtain a capture from some unknown Kouvosto Telecom communications with our state-of-the-art logic analyzer. Can you extract the secrets? Sigrok/pulseview

## Flag

* `DISOBEY[UART is present almost everywhere]`
* `DISOBEY[SPI or shift registers are also common]`

Probably best to give out the first character of each flag on the challenge pages so that people know which flag to enter on which field.

## Walkthrough

Add UART decoder on the channels 0 and 1, baud rate 31250 (you can use the guess baudrate decoder to detect it) and you get the uart flag

Add SPI decoder with clock = 4, MISO = 6, CS = 2 and you will have your second flag as bytes, opening a binary decoder view window will give you the ascii flag.

## Files

* challenge/mixed_signals.sr - sigrok format logic capture
* challenge/mixed_signals.csv.zip - same data in CSV format for the desperate

## Contact info

Vesa-Pekka Palmu, vpalmu@depili.fi - +358 40 5278601