				.thumb					; BY JAMES SAMAWI
										; A special thanks to the SysTick slide for 6/10 of the subroutines

				.data
Delay			.byte	6				; CALCULATION: 1/3MHZ = 333NS, for 10ms interrupts: 10MS/333NS = 30000 ... nope...
										; CALCULATION: 1/3MHZ = 333NS, max reset val (2^24-1)(333NS) = 5.5924s
										; 5.5924 will be useful later, but i will not use this variable in my code

				.text					; Puts code in ROM
Delay_ptr		.word	Delay
;STEP			.byte	XXXX

P1IN			.word	0x40004C00		; Port 1 Input
P1OUT			.word	0x40004C02		; Port 1 Output
P1DIR			.word	0x40004C04		; Port 1 Direction
P1REN			.word	0x40004C06		; Port 1 Resistor Enable
P1SEL0			.word	0x40004C0A		; Port 1 Select 0
P1SEL1			.word	0x40004C0C		; Port 1 Select 1
;P1IV			.word	0x40004C0E		; NOT USED...Port 1 interrupt vector register
P1IES			.word	0x40004C18		; Port 1 interrupt edge select
P1IE			.word	0x40004C1A		; Port 1 interrupt enable
P1IFG			.word	0x40004C1C		; Port 1 interrupt flag

SYSTICK_STCSR   .word	0xE000E010		; SysTick Control and Status Register
SYSTICK_STRVR   .word	0xE000E014		; SysTick Reload Value Register
SYSTICK_STCVR   .word	0xE000E018		; SysTick Current Value Register
N0x2DC6C0       .word	0x2DC6C0		; 3 million

NVIC_IPR8		.word	0xE000E420		; NVIC interrupt priority 8
NVIC_ISER1		.word	0xE000E104		; NVIC enable register 1

				.global asm_main
				.thumbfunc asm_main

				.global Port1_ISR
				.thumbfunc Port1_ISR

asm_main:		.asmfunc		; main
	; TODO: Complete this SR

	push {LR}		; Only jump to .asmfunc subroutines
	BL Port1_Init
	BL NVIC_Init
	BL Port1_ISR
    BL SysTick_Init

	pop {LR}
	bx		lr
				.endasmfunc


NVIC_Init:		.asmfunc		; NVIC_Init
	; TODO: Complete this SR

	ldr r1, NVIC_IPR8
	AND R0, #0xFF000000
	mov r0, #0x40000000			; 8 pri
	str r0, [r1]

	ldr r1, NVIC_ISER1
	mov r0, #8					; ENABLE
	str r0, [r1]

	cpsie i

	bx		lr
	        	.endasmfunc

Port1_Init:		.asmfunc		; Port 1 Init
	; TODO: Complete this SR

	cpsid i

	LDR R2, P1SEL0
	LDRB R1, [R2]
	BICB R1, R1, #1
	STRB R1, [R2]

	LDR R2, P1SEL1
	LDRB R1, [R2]
	BICB R1, R1, #1
	STRB R1, [R2]

	LDR R2, P1DIR
	LDRB R1, [R2]
	ORRB R1, R1, #1 	; P1DIR = P1.0 = OUTPUT
	STRB R1, [R2]

	LDR R2, P1REN		; for switches (right button bit 1, left is bit 4)
	LDR R1, [R2]
	ORR R1, R1, #0x12	; 10010b == 12h
	STR R1, [R2]

	LDR R2, P1IN
	LDRB R1, [R2]
	ORRB R1, R1, #0x12
	STRB R1, [R2]


	bx		lr
	        	.endasmfunc

Port1_ISR:	.asmfunc
	; TODO: Complete this SR

	LDR R1, P1IFG
	BIC R0, #1		; Acknowledgment: Clear P1
	STRB R0, [R1]

	nop	; ???
	bx		lr
	        .endasmfunc


;------------SysTick_Init------------
; Initialize SysTick with busy wait running at bus clock
; Input: none
; Output: none
; Modifies: R0, R1
SysTick_Init:	.asmfunc
	; Disable systick during setup
	LDR R1, SYSTICK_STCSR
	MOV R0, #0				; CLEARS ENABLE BIT == 0
	STR R0, [R1]

	; Maximum reload value
	LDR R1, SYSTICK_STRVR
	LDR R0, N0x2DC6C0		; MAX RELOAD VAL == 2^24 - 1 / 5.5924s = 3 million. Should toggle by 1 second when reaches max value
							; Refer to calculation on line 6
	STR R0, [R1]

	; Any write to current clears it
	LDR R1, SYSTICK_STCVR
	MOV R0, #0				; CLEAR CURRENT VAL == 0
	STR R0, [R1]

	; Enable systick with no interrupts
	LDR R1, SYSTICK_STCSR
	MOV R0, #0x5			; 5d = 101b therefore ENABLE = CLK_SRC = 1
	STR R0, [R1]

	        .endasmfunc

;------------SysTick_Wait------------
; Time delay using busy wait
; Input: r0 delay parameter in units of the core clock (units of 333 nsec for 3 mhz clock)
; Output: none
; Modifies: r0, r1, r2, r3
SysTick_Wait:

  	LDR R1, SYSTICK_STRVR	; reload value = 3 million
  	LDR R1, SYSTICK_STCSR


SysTick_Wait_Loop:

	LDR R7, P1IN
    LDRB R8, [R7]
    AND R8, R8, #0x12
    cmp R8, #0x02
    BEQ left
    cmp R8, #0x10
    BEQ right

    LDR R3, [R1]			; R3 == STCSR
    ANDS R3, R3, #0x10000	; 10000h = 65536d
    BEQ SysTick_Wait_Loop	; Loop from current value reg == 3 million to 0 such that the time elapsed = 1 second.

LED_Toggle:				; Toggles red LED
	; TODO: Complete this SR ... Turn off as 1 second elapses

	LDR R2, P1OUT
	LDRB R1, [R2]
	EOR R1, R1, #1		; EOR does the toggling
	STRB R1, [R2]

	BL SysTick_Init		; REITERATE LOOP

	bx		lr





; +10 ms
right:

	LDR R1, SYSTICK_STRVR
	ADD R1, R1, #0xFFF
	STR R1, [R1]

	LDR R1, SYSTICK_STCSR
	MOV R0, #0				; CLEARS ENABLE BIT == 0
	STR R0, [R1]

	LDR R1, SYSTICK_STCVR
	MOV R0, #0				; CLEAR CURRENT VAL == 0
	STR R0, [R1]

	; Enable systick with no interrupts
	LDR R1, SYSTICK_STCSR
	MOV R0, #0x5			; 5d = 101b therefore ENABLE = CLK_SRC = 1
	STR R0, [R1]

	LDR R1, SYSTICK_STRVR	; reload value = 3 million
  	LDR R1, SYSTICK_STCSR

 	B SysTick_Wait_Loop


; -10 ms
left:

	LDR R1, SYSTICK_STRVR
	SUB R1, R1, #0xFFF
	STR R1, [R1]

 	LDR R1, SYSTICK_STCSR
	MOV R0, #0				; CLEARS ENABLE BIT == 0
	STR R0, [R1]

	LDR R1, SYSTICK_STCVR
	MOV R0, #0				; CLEAR CURRENT VAL == 0
	STR R0, [R1]

	; Enable systick with no interrupts
	LDR R1, SYSTICK_STCSR
	MOV R0, #0x5			; 5d = 101b therefore ENABLE = CLK_SRC = 1
	STR R0, [R1]

	LDR R1, SYSTICK_STRVR	; reload value = 3 million
  	LDR R1, SYSTICK_STCSR

	B SysTick_Wait_Loop






;------------SysTick_Wait10ms------------
; Time delay using busy wait.  this assumes 3 mhz system clock
; Input: r0 number of times to wait 10 ms before returning
; Output: none
; Modifies: r0

delay10ms	.word	30000			; Clock cycles in 10 ms (assumes 3 mhz clock!!!!!!)

SysTick_Wait10ms: .asmfunc
    PUSH {R4, LR}					; SAVE R4 & LR
    MOVS R4, R0						; R4 == R0 ?
    BEQ SysTick_Wait10ms_Done		; jump to done iff R4 == 0

    ;bx		lr

SysTick_Wait10ms_Loop:
    LDR R0, delay10ms
    BL SysTick_Wait					; wait 10ms
    SUBS R4, R4, #1					; R4 - 1
    BHI SysTick_Wait10ms_Loop		; if R4 > 0, wait +10ms


    ;bx		lr

SysTick_Wait10ms_Done:
    POP		{R4, LR}				; Restore previous value of r4, lr
									; Slides said POP ..PC} Probably not needed.

    bx		lr						; return
    .endasmfunc

	        .end
