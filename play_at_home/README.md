# Play at home versions of the challenges

## EZ180
```
Lets get the CTF started, this one should be eazy.

Z180, CP/M 2.2, load address 0x100, entry point 0x100.
```

Files: EZ180.COM

## Garbage

```
Go garbage hunting.
```

Files: garbage

## Gutter

This one had a hardware component to pwn, so unfortunately you cannot play it at home properly, maybe if I feel like it I will provide an emulator solution later...

The code should work with emulators, you will just be missing the TFT display output, which will make the challenge harder to understand.

True players will build their own from https://gitlab.com/Depili/z180

```
A defector from Kouvostoliitto has provided us with some kouvosto telecom z180 gear and a test version of their super secret software. Our source tells us that there should be some secrets implanted at 0x0dead.

0x00000-0x7FFFF is rom, 0x80000-0xFFFFF is ram. Uart 57600-8-N-1. Both USB A and USB C connections are provided.

Please limit your testing sessions to ~15 minutes if there are people queuing for the hardware.
```

Files: gutter.hex