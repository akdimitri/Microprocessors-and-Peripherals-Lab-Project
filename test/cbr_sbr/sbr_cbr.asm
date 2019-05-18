.include "m16def.inc" 


.ORG 0x000
	jmp RESET


RESET:
	ldi r20, 0x0F
	sbr r20, 0b10000000

MAIN:
	jmp main
