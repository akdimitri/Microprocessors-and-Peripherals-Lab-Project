; DEV. BOARD: 	STK 500
; MCU:			ATMEGA16
; DESCRIPTION:	TOGGLE LED ON PORTB:0 USING TIM0_OVF INTERRUPT




.include "m16def.inc" 

.ORG 0x000
	JMP RESET 							; Reset Handler
.ORG 0x012
	JMP TIM0_OVF 						; Timer0 Overflow Handler

.ORG 0x02A 
RESET: 
	LDI R16,HIGH(RAMEND) 				; Main program start
	OUT SPH,R16 						; Set stack pointer to top of RAM
	LDI R16,LOW(RAMEND)
	OUT SPL,R16

	SBI DDRB, 0							; PORTB:0 OUTPUT
	SBI PORTB, 0						; TURN OFF LED0
	
	LDI R19, 0							; Temporary Counter

	LDI R16, 0							; Set COUNTER0 to 0
	OUT TCNT0, R16
	LDI R16, 0b00000001					; Enable TIM0_OVF Interrupt	
	IN R17, TIMSK
	OR R17, R16
	OUT TIMSK, R17
	LDI R16, 0b00000101					; Start COUNTER0, Normal Mode, Prescaler = clk/1024
	
	SEI									; Enable interrupts


;*** MAIN FUNCTION ***
MAIN:
	JMP MAIN							; Do Nothing


;*** TIM0_OVF ***
TIM0_OVF:
	IN R20, SREG						;SAVE STATUS REGISTER IN STACK
	PUSH R20	
	
	INC R19
	CPI R19, 61
	BRNE FINISH

REINITIALIZE_TEMPORARY_COUNTER:
	LDI R19, 0

TOGGLE_LED0:							;
	SBIC PORTB, 0						
	JMP TURN_ON_LED0
TURN_OFF_LED0:	
	SBI PORTB, 0
	JMP FINISH
TURN_ON_LED0:
	CBI PORTB, 0
	
FINISH:
	POP R20
	OUT SREG, R20
	RETI
