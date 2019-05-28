# Microprocessors-and-Peripherals-Lab-Project

Authors: 
         
         1.Dimitrios Antoniadis
         
         2.Vasileios Dimitriadis


****************************

| SUBJECT:	MICROCONTROLLERS AND PERIPHERALS	|

| UNIVERSITY:	ARISTOTLE UNIVERISTY OF THESSALONIKI	|

| SEMESTER:	8TH					|

| DATE:		26/5/2019				|
****************************

*Project: Silo*

*MCU: AVR atmetga16*

*DEV Board: STK500*




					
CLOCK SPEED: 4 MHz

1.--- DEFINITIONS SEGMENT ---

	COREA = CONTROL REGISTER A: [ B1| B2| B3| B4| A1| Y1| Y2| - ]
	
			BITS      : [ 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 ]
	
	COREB = CONTROL REGISTER B: [ M1| M2| - | - | - | B5| - | - ]
	
			BITS      : [ 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 ]


2.--- INTERRUPT VECTORS ---
	$0000 RESET
	$0008 TIM2_OVF 
	$0012 TIM0_OVF

3.--- RESET VECTOR ---
------------------------------------------
- This vector is executed first at power -
- on or whether RESET button or if RESET -
- is called is called during execution.  -
- This vector set ups the execution 	 -
- environment.		 		 -
------------------------------------------

	1. Set the stack pointer to top of RAM.
	2. Initialize COREA, COREB = 0.	
	3. Define PORTC:0(BUZZER) as OUTPUT and CLEAR it.
	4. Define PORTB as OUTPUT and TURN OFF LEDS.
	5. Dedine PORTD as INPUT and TURN ON PULL-UP Resistors.
	6. ENABLE ADC CONVERTER (ADCSRA:7 = ADEN = 1). (ADCSRA:5 = ADLAR = 1)
	   SET PRESCALER to 125 kHZ (ADCSRA:2,1,0 = 101)
	   ADCSRA = 10100101
	   
	   ACTIVATE PULL-UP Resistors of PORTA.
	   Needed for ADC conversion of PA0-PA4.
	   PORTA = 00011111
	7. Disable TIMER2, initialize TIM2_OVF times counter.
	8. SET COUNTER0 to 0. TCNT0 = 0
	   ENABLE TIMER0 OVERFLOW INTERRUPT. SET TIMSK:0 = TOIE = 1
	   TIMSK = 00000001
	   SET TIMER0 to NORMAL MODE and PRESCALER to CLK/1024.
	   TCCR0 = 00000101
	9. ENABLE Interrupts Globally.
	   
	   
4.--- MAIN FUNCTION ---
-------------------------------------------------
- This function is responsible for executing 	-
- the main program. It is the first function	-
- to be called after RESET vector		-
-------------------------------------------------

	1. WAIT UNTIL SW0 IS PRESSED.
	2. IF SW7 IS NOT PRESSED CONTINUE TO 3.
	   ELSE
		CALL ALARM FUNCTION
	3. IF( A1 == 0)
		ALARM
	4. IF( SW1 == 0 && B1 == 0 && B3 == 0)
	     ( Y1 is PRESSED AND SILO1 is EMPTY AND SILO2 is EMPTY)
		THEN Y1 = 1, Y2 = 0, LED5 = ON, LED3 = OFF
	   ELSE
		CONTINUE TO 5.
	5. IF( SW2 == 0 && B2 == 1)
	     ( Y2 is PRESSED AND SILO1 is FULL)
		THEN Y2 = 1, Y1 = 0, LED3 = ON, LED5 = OFF
	   ELSE
		CONTINUE TO 6.
	6. IF( Y1 == 1 && ( B2 == 0 || B4 == 0 ))
		IF( M2 == 0 )
			THEN LED4 = ON, M2 = 1
	   ELSE
		CONTINUE TO 7.
	7. IF( M2 == 1)
		IF( M1 == 0)
			LED6 = ON
			M1 = 1
			PAUSE 7 SECS
			B5 = 1
			LED2 = ON
	   ELSE
		CONTINUE TO 8.
	8. IF( SW4 == 0 || SW5 == 0)
	     ( Q1 is PRESSED OR Q2 is PRESSED) 
		CALL ALARM FUNCTION
	9. IF( B2 == 1 && B4 == 1)
		CALL ALARM.
	9. JUMP TO 2.


5.--- ALARM ---
------------------------------------------------------
- this function is called when both silos are filled -
- or when a missfunction occurs			     -
------------------------------------------------------
	1. DISABLE TIM0_OVF
	2. ENABLE TIM2_OVF
	2. START BUZZER
	3. WAIT ON SW6 TO BE PRESSED.
	4. JUMP RESET FUNCTION.


6.--- TIMER0 OVERFLOW INTERRUPT ---
----------------------------------------------------
- this function is executed every time an overflow -
- in TIMER0 occurs. It also reads the silo values  -
- every 64 usecs.				   -
----------------------------------------------------
	1. SAVE STATUS REGISTER IN STACK
	2. READ PA0, PA1, PA2, PA3, PA4
	3. SET/CLEAR B1, B2, B3, B4, A1 bits in COREA.


7.--- PAUSE ---
--------------------------------------
- this function is just waisting CPU -
- power for 7 seconds.		     -
--------------------------------------
	1. DISABLE INTERRUPTS
	2. WAIT 7 SECONDS
	3. ENABLE INTERRUPTS
	

8.--- TIMER2 OVERFLOW INTERRUPT ---
----------------------------------------------------
- this function is executed every time alarm funct -
- ion is called. It holds a counter. Each time an  -
- overflow happens, this counter is increased.     -
- When counter equals 7 (0.5 seconds), it toggles  -
- LED0. 					   -
----------------------------------------------------
	1. SAVE STATUS REGISTER IN STACK
	2. INCREASE COUNTER
	3. IF COUNTER EQUALS 7 TOGGLE LED0, SET COUNTER TO ZERO.
