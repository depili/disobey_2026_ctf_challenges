# Garbage bin

A really heavily obfuscated go binary that asks for a password, then extracts the flag from an embedded zip file. The intended solution is to use binwalk to extract the embedded file with the flag.

## Description

Go garbage hunting.

## Flag

`DISOBEY[Hope you used binwalk...]`


## Walkthrough

`binwalk -e garbage`

## Files

* challenge/
* source/ - source code for the challenge

## Contact info

Vesa-Pekka Palmu, vpalmu@depili.fi - +358 40 5278601