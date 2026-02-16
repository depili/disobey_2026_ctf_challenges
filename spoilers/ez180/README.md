# EZ180

A hopefully really simple z180 cp/m 2.2 crackme.

## Description

Lets get the CTF started, this one should be eazy.

Z180, CP/M 2.2, load address 0x100, entry point 0x100.

## Flag

`DISOBEY[eazy_flag_for_the_start!]`


## Walkthrough

Running the provided challenge executable in cp/m emulator will print `Yay!` with the correct flag. The binary uses simple xor obfuscation for the flag string.

## Files

* challenge/EZ180.COM - challenge binary
* source/ - source code for the challenge

## Contact info

Vesa-Pekka Palmu, vpalmu@depili.fi - +358 40 5278601