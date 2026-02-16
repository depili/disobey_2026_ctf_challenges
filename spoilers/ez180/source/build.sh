#!/bin/sh

docker run  -v .:/src/ -it z88dk/z88dk:20250630 zcc +cpm -compiler=sdcc -O3 -create-app ez180.c  -oez180.bin