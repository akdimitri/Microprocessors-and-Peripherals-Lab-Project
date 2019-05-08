;******************************************
;* AUTHORS: 	1. ANTONIADIS DIMITRIOS	  *
;*			   	2. DIMITRIADIS VASILEIOS  *
;* DATE:		MAY 2019				  *
;******************************************

.include "m16def.inc" 

.DEF COREA = R30							;CONTROL REGISTER A: [B1|B2|B3|B4|A1|Y1|Y2|RUN]
.DEF COREB = R31							;CONTROL REGISTER B: [M1|M2|Q1|Q2|H1|B5|  | - ]


.ORG 0x000
	JMP RESET
.ORG 0x012
	JMP TIMER0_OVF
.ORG 0x008
	JMP TIMER2_OVF


.ORG 0x02A
RESET:
	LDI R16, LOW(RAMEND)					;INITIALIZE THE STACK
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

	LDI COREA, 0b00000000					;CONTROL REGISTER A: [B1 = 0|B2 = 0|B3 = 0|B4 = 0|A1 = 0|Y1 = 0|Y2 = 0|RUN = 0]			
	LDI COREB, 0b00110000					;CONTROL REGISTER B: [K1 = 0|K2 = 0|Q1 = 1|Q2 = 1|H1 = 0|   -  |   -  |	  -   ]

	LDI R16, 0b00000000						;PORTD INPUT
	OUT DDRD, R16
	LDI R16, 0b11111111
	OUT PORTB, R16

	LDI R16, 0b11111111						;PORTB OUTPUT
	OUT DDRB, R16
	LDI R16, 0b00000000
	OUT PORTB, R16
	
	LDI R16, 0x00							;SET COUNTER2 TO 0
	OUT TCNT2, R16
	IN R16, TIMSK
	ORI R16, 0b01000000						;ENABLE INTERRUPT TIMER2 OVERFLOW
	OUT TIMSK, R16
	LDI R16, 0b00000001						;SET COUNTER2 PRESCALING TO CLK/1
	OUT TCCR2, R16

	LDI R16, 0b10000010						;ENABLE ADC, PRESCALER = 2
	OUT ADCSRA, R16	



	CLI

;********************
;*** MAIN ROUTINE ***
;********************
MAIN:
WAIT_ON_START_BUTTON:
	SBIS PIND, 0							;START WHEN SW0 IS PRESSED
	JMP WAIT_ON_START_BUTTON				;
CHECK_IF_SILO0_IS_EMPTY:
	SBRS COREA, 3							;IF SW0 IS PRESSED AND A1 = 0
	JMP ALARM								;THEN ALARM ELSE CONTINUE		
	
	SEI										;TURN ON INTERRUPTS
	SBI PORTB, 7							;IF SW0 == 1 TURN ON LED 7

	
EXECUTION:
CHECK_IF_STOP_PRESSED:
	SBIC PIND, 7							;IF SW7 IS PRESSED JUMP ON ALARM
	JMP ALARM

CHECK_IF_SW1_PRESSED:
	SBIS PIND, 1							;IF SW1 IS PRESSED
	JMP CHECK_IF_SW2_PRESSED				;
	SBRC COREA, 7							;	AND B1 == 0
	JMP CHECK_IF_SW2_PRESSED				;
	SBRC COREA, 5							;	AND B3 == 0
	JMP CHECK_IF_SW2_PRESSED				;THEN
SET_Y1:
	SBR COREA, 2							;COREA:21 = 10
	CBR COREA, 1
	SBI PORTB, 5							;TURN ON LED 5
	CBI PORTB, 3							;TURN OFF LED 3

CHECK_IF_SW2_PRESSED:
	SBIS PIND, 2							;IF SW2 IS PRESSED
	JMP CHECK_ON_M2							;
	SBRS COREA, 6							;	AND B2 == 1			
	JMP CHECK_ON_M2							;
SET_Y2:										;THEN
	SBR COREA, 1							;COREA:21 = 01
	CBR COREA, 2	
	CBI PORTB, 5							;TURN OFF LED 5
	SBI PORTB, 3							;TURN ON LED 3

CHECK_ON_M2:
	SBRS COREA, 2							;IF Y1 = 1
	JMP CHECK_ON_M1							;
	SBRS COREA, 6							;	AND( B2 == 0 OR B4 == 0)
	JMP CHECK_Q2							;
	SBRC COREA, 4							;
	JMP CHECK_ON_M1							;
CHECK_Q2:									;
	SBRS COREB, 4							;	AND( Q2 == 1)
	JMP ALARM 		;IF Q2 = 0 JMP TO ALARM							;
	SBRC COREB, 3							;	AND( H1 == 0)
	JMP CHECK_ON_M1							;THEN
START_M2:									;	
	SBR COREB, 6							;	COREB:6 = 1
	SBI PORTB, 4							;	TURN ON LED 4	

CHECK_ON_M1:								
	SBRS COREB, 6							;IF M2 == 1
	JMP CHECK_FOR_ERRORS					;
CHECK_Q1:								;
	SBRS COREB, 5							;	AND( Q1 == 1)
	JMP ALARM		;IF Q1 = 0 JMP TO ALARM				;
	SBRC COREB, 3							;	AND( H1 == 0)
	JMP CHECK_FOR_ERRORS					;
START_M1:									;THEN
	SBRC COREB, 2							;	IF M1 == 0
	JMP CHECK_FOR_ERRORS					;
	CALL PAUSE_7_SECS						;		WAIT 7 SECS
	SBR COREB, 7							;		COREB:7 = 1
	SBI PORTB, 6							;		TURN ON LED 6 

CHECK_FOR_ERRORS:
	SBRC COREB, 3							;IF H1 == 1
	JMP ALARM								;JMP TO ALARM
	JMP EXECUTION


;*********************	
;*** ALARM HANDLER ***	
;*********************
ALARM:
	CLI
	;TODO
	;1. BUZZER

	SBI PORTB, 0							;TURN ON LED 0

WAIT_ON_ACKNOWLEDGEMENT:	
	SBIS PIND, 6							;WAIT ACKNOWLEDGEMENT BUTTON SW6 TO BE PRESSED
	JMP WAIT_ON_ACKNOWLEDGEMENT
	
	;2. STOP BUZZER
	JMP RESET

;*******************************
;*** PAUSE 7 SECONDS ROUTINE ***
;*******************************
PAUSE_7_SECS:
	LDI R19, 0								;R19 TEMPORARY COUNTER
	LDI R18, 0								;INITIALIZE TCNT0 
	OUT TCNT0, R18							;TO 0
	IN R18, TIMSK							;ENABLE TIMER 0 OVERFLOW INTERRUPT
	ORI R18, 0b00000001						;
	OUT TIMSK, R18							;
	LDI R17, 0b00000101						;SET COUNTER0 TO
	OUT TCCR0, R17							;NORMAL MODE, PRESCALER: CLK/1024

LOOP:
	CPI R19, 256	;!!! WRONG 427 IS THE RIGHT FOR 7 SECS
	BRLO LOOP
		
	IN R18, TIMSK
	ANDI R18, 0b11111110
	OUT TIMSK, R18
	LDI R17, 0x00							;STOP COUNTER
	OUT TCCR0, R17							

	RET
	


;******************************************
;*** TIMER 0 OVERFLOW INTERRUPT ROUTINE	***
;******************************************
TIMER0_OVF:
	IN R20, SREG							;SAVE STATUS REGISTER IN STACK
	PUSH R20
	
	INC R19
	
	POP R20
	OUT SREG, R20
	RETI		


;******************************************
;*** TIMER 2 OVERFLOW INTERRUPT ROUTINE ***
;******************************************
TIMER2_OVF:
	IN R20, SREG							;SAVE STATUS REGISTER IN STACK
	PUSH R20
	;TODO POLLING
	;1. READ B1
READ_B1:									;B1 IS Pot2: PA1 PIN
	LDI R23, 0b11100001						
	OUT ADMUX, R23
	
	SBI ADCSRA, 6							;START CONVERSION
B1_CONVERSION:
	IN R24, ADCSRA
	SBRC R24, 6								;WHEN ADCSRA bit 6 is 0 conversion is DONE.
	JMP B1_CONVERSION
B1_CONVERSION_DONE:
	IN R25, ADCH							;ADLAR = 1 SO ADCH STORES THE RESULT

	CPI R25, 0x0F							;IF R25 > 0x0F THEN B1 = 0
	BRSH CLEAR_B1							;			   ELSE B1 = 1
SET_B1:
	SBR COREA, 7
	JMP READ_B2
CLEAR_B1:
	CBR COREA, 7

	;2. READ B2
READ_B2:
	LDI R23, 0b11100010						;B2 IS Pot3: PA2 PIN					
	OUT ADMUX, R23

	SBI ADCSRA, 6							;START CONVERSION
B2_CONVERSION:
	IN R24, ADCSRA
	SBRC R24, 6
	JMP B2_CONVERSION						;IF ADCSRA:6 == 0 THEN CONVERSION IS DONE
B2_CONVERSION_DONE:
	IN R25, ADCH

	CPI R25, 0x0F
	BRSH CLEAR_B2
SET_B2:
	SBR COREA, 6
	JMP READ_B3
CLEAR_B2:
	SBR COREA, 6

	;3. READ B3
READ_B3:
	LDI R23,0b11100011						;B3 IS Pot:4 PA3 PIN
	OUT ADMUX, R23
	
	SBI ADCSRA, 6
B3_CONVERSION:
	IN R24, ADCSRA
	SBRC R24, 6
	JMP B3_CONVERSION
B3_CONVERSION_DONE:
	IN R25, ADCH
	
	CPI R25, 0x0F
	BRSH CLEAR_B3
SET_B3:
	SBR COREA, 5
	JMP READ_B4
CLEAR_B3:
	CBR COREA, 4
						
	;4. READ B4
READ_B4:
	LDI R23, 0b11100100						;B4 IS Pot5: PA4 PIN 
	OUT ADMUX, R23
	
	SBI ADCSRA, 6
B4_CONVERSION:
	IN R24, ADCSRA
	SBRC R24, 6
	JMP B4_CONVERSION
B4_CONVERSION_DONE:
	IN R25, ADCH
	
	CPI R25, 0x0F
	BRSH CLEAR_B4
SET_B4:
	SBR COREA, 4
	JMP READ_A1
CLEAR_B4:
	CBR COREA, 4
	
	;5. READ A1
READ_A1:
	LDI R23, 0b11100000						;A1 IS Pot1: PA0 PIN
	OUT ADMUX, R23
	
	SBI ADCSRA, 6
A1_CONVERSION:
	IN R24, ADCSRA
	SBRC R24, 6
	JMP A1_CONVERSION
A1_CONVERSION_DONE:
	IN R25, ADCH
	
	CPI R25, 0x0F
	BRSH CLEAR_A1
SET_A1:
	SBR COREA, 3
	JMP END_OF_TIMER2_OVF
CLEAR_A1:
	CBR COREA, 3

;TODO READ Q1, Q2

END_OF_TIMER2_OVF:
	POP R20
	OUT SREG, R20						
	RETI
