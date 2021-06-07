; LAB 2: External switch with 250 ms delay toggles external LED
; James Samawi
; September 14, 2020

; Ports:
;   External negative logic LED connected to P4.0
;   External positive logic button connected to P5.0

; Pseudocode:
;	Initialize port 4.0 for external LED output
;   	Enable P4OUT so LED is initially on
;	Initialize port 5.0 for external switch input
;	Loop:
;		Branch to Delay to wait 250 ms
;		Branch to Switch Input to gather input data (0x0 or 0x1)
;		Compare and determine if press or no press
;			If P5IN == 0x1 (the switch is pressed), set P4.0 to toggle LED on and off repeatedly
;			If P5IN == 0x0 (the switch is not pressed), turn LED on by enabling P4OUT
;	Repeat loop

; ROM:
       .thumb             
   
       .text             
       .align  2       

; External, Negative logic LED:
P4OUT   .field 0x40004C23,32  ; Port 4 Output
P4DIR   .field 0x40004C25,32  ; Port 4 Direction
P4SEL0  .field 0x40004C2B,32  ; Port 4 Select 0
P4SEL1  .field 0x40004C2D,32  ; Port 4 Select 1
; External, Positive logic Switch:
P5IN    .field 0x40004C40,32  ; Port 5 Input
P5DIR   .field 0x40004C44,32  ; Port 5 Direction
P5REN   .field 0x40004C46,32  ; Port 5 Resistor Enable
P5SEL0  .field 0x40004C4A,32  ; Port 5 Select 0
P5SEL1  .field 0x40004C4C,32  ; Port 5 Select 1

      .global main    
      .thumbfunc main  
       
main: .asmfunc
	push {LR}
	BL Port4_Init
	BL Port5_Init
    BL Loop
	pop {LR}
	BX		LR
	.endasmfunc

Port4_Init: .asmfunc
    ; initialize P4.0 LED and make it output
    LDR  R1, P4SEL0
    LDRB R0, [R1]
    BIC  R0, R0, #0x01              ; configure LED pins as GPIO
    STRB R0, [R1]
    LDR  R1, P4SEL1
    LDRB R0, [R1]
    BIC  R0, R0, #0x01              ; configure LED pins as GPIO
    STRB R0, [R1]
    ; make LED pins out
    LDR  R1, P4DIR
    LDRB R0, [R1]
    ORR  R0, R0, #0x01              ; output direction
    STRB R0, [R1]
    LDR  R1, P4OUT
    LDRB R0, [R1]
    ORR  R0, R0, #0x01              ; LED high initially
    STRB R0, [R1]
    BX   LR
    .endasmfunc   

Port5_Init: .asmfunc
    ; configure P5.0 switch as GPIO input
    LDR  R1, P5SEL0
    LDRB R0, [R1]
    BIC  R0, R0, #0x01              ; configure P5.0 as GPIO
    STRB R0, [R1]
    LDR  R1, P5SEL1
    LDRB R0, [R1]
    BIC  R0, R0, #0x01              ; configure P5.0 as GPIO
    STRB R0, [R1]
    ; make P5.0 in
    LDR  R1, P5DIR
    LDRB R0, [R1]
    BIC  R0, R0, #0x01              ; input direction
    STRB R0, [R1]
    ; disable pull resistor on P5.0 (since external)
    LDR  R1, P5REN
    LDRB R0, [R1]
    BIC  R0, R0, #0x01              ; disable pull resistor
    STRB R0, [R1]
    BX   LR
    .endasmfunc

Loop: .asmfunc
	BL   Delay
	BL   Switch_Input               ; status = R0 = 0x00 or 0x01
continue
	CMP R0, #0x01
	BEQ pressed
	CMP R0, #0x00
	BEQ not_pressed
	BL  Loop
pressed								; LED toggles when button pressed
	BL	LED_Toggle
	BL  Loop
not_pressed							; LED on when button not pressed
	BL  LED_On
    BL  Loop
    .endasmfunc

Switch_Input: .asmfunc
	LDR  R1, P5IN
    LDRB R0, [R1]                   ; 8-bit contents of register
    AND  R0, R0, #0x01              ; get just P5.0
	BX   LR							; return 0x00 or 0x01
	.endasmfunc

Delay:  .asmfunc
	; delay by 250 ms (quarter second)
	MOV R0, #0x0D090
	ORR R0, R0, #0x30000
wait								; delays for 750,000 cycles
	SUBS R0, R0, #0x01
	BNE wait
	BX   LR
	.endasmfunc

LED_On: .asmfunc
    LDR  R1, P4OUT
    LDRB R0, [R1]
    ORR  R0, R0, #0x01              ; LED is high
    STRB R0, [R1]
    BX   LR
    .endasmfunc

LED_Toggle: .asmfunc
    LDR  R1, P4OUT
    LDRB R0, [R1]
    EOR  R0, R0, #0x01              ; toggles LED 1-> 0 or 0 -> 1
    STRB R0, [R1]
    BX   LR
    .endasmfunc

    .end           
