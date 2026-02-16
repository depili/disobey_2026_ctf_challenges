/*
 *  Compile with sccz80
 *  zcc +cpm -O3 simple.c -o simple.bin -create-app
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <cpm.h>
#include <string.h>
#include "ez180.h"
#pragma output noprotectmsdos

unsigned char pw[128];
unsigned char i = 0;
unsigned int j = 0;
unsigned char tmp = 0;
// DISOBEY[eazy_flag_for_the_start!] xor muumipeikko
// muumipeikkomuumipeikkomuumipeikko
unsigned char flag[] = {0x29,0x3c,0x26,0x22,0x2b,0x35,0x3c,0x32,0x0e,0x0a,0x15,0x14,0x2a,0x13,0x01,0x08,0x17,0x3a,0x0f,0x04,0x19,0x30,0x19,0x1d,0x10,0x32,0x1a,0x04,0x04,0x1b,0x1f,0x4a,0x32};
// muumipeikko xor 0xed
unsigned char key[] = {0x80,0x98,0x98,0x80,0x84,0x9d,0x88,0x84,0x86,0x86,0x82};
unsigned char pw_len;
unsigned char ok = 1;

int main(void) {
	printf("Easy Z180 crackme\r\n");
	printf("flag: ");
	int r = scanf("%63s", pw);
	printf("\r\n");
	if (r == 0) {
		printf("Uh?\r\n");
		return 1;
	}
	pw_len = strlen(pw);

	debug_print("PW len: %d key len: %d\n", pw_len, sizeof(key));

	debug_print("PW: <%s>\n", pw);

	for (j = 0; j < sizeof(flag); ) {
		for (i = 0; i < sizeof(key); i++) {
			tmp = key[i] ^ 0xed;
			tmp = flag[j] ^ tmp;
			if (pw[j] != tmp) {
				debug_print("Missmatch at %d\r\n", j);
				ok = 0;
			}
			j++;
		}
	}

	if (ok == 0 ) {
		printf("Nope\r\n");
		return 1;
	}

	printf("Yay!\r\n");
	return 0;
}
