#include <stdint.h>
#include "SysTick.h"
#include "msp432p401r.h"
#include "SSEG.h"

#define G 0x3F // Segment g  ON = 0011 1111
#define F 0x5F // Segment f  ON = 0101 1111
#define E 0x6F // Segment e  ON = 0110 1111
#define D 0x77 // Segment d  ON = 0111 0111
#define C 0x7B // Segment c  ON = 0111 1011
#define B 0x7D // Segment b  ON = 0111 1101
#define A 0x7E // Segment a  ON = 0111 1110
#define ONE B & C
#define TWO A & B & D & E & G
#define THREE A & B & C & D & G
#define FOUR B & C & F & G
#define FIVE A & C & D & F & G
#define SIX A & C & D & E & F & G
#define SEVEN A & B & C
#define EIGHT A & B & C & D & E & F & G
#define NINE A & B & C & D & F & G
#define ZERO A & B & C & D & E & F

uint32_t counter = 0;

void DisableInterrupts();			// Disable interrupts
void EnableInterrupts();			// Enable interrupts
long StartCritical ();				// previous I bit, disable interrupts
void EndCritical(long sr);			// restore I bit to previous value
void WaitForInterrupt();			// low power mode

/*****************************************
 *          PRIVATE FUNCTIONS
 *****************************************/
void Button_Init(void){
    P6->SEL0 &= ~0x3;               // 0011 two buttons (extern, pos)
    P6->SEL1 &= ~0x3;
    P6->DIR &= ~0x3;                // as input
}
uint32_t Button_In(void){           // private function
    return P6->IN & 0x3;            // extract those two bits
}

/*****************************************
 *          PUBLIC FUNCTIONS
 *****************************************/
/*
 * SSEG_Init Function
 * Initialize 7-segment display
 * Inputs: none
 * Outputs: none
 */
void SSEG_Init() {
    Button_Init();
    P4->SEL0 &= ~0x7F;              // 0111 1111
    P4->SEL1 &= ~0x7F;              // as GPIO
    P4->DIR |= 0x7F;                // as Out
}

/*
 * SSEG_Out Function
 * Output a number to a single digit of the 7-segment display
 * Inputs: a number between 0 and 9
 * Outputs: none
 */
void SSEG_Out(uint8_t num) {
    switch(num) {
        case 1:
            P4->OUT = ONE;
            break;
        case 2:
            P4->OUT = TWO;
            break;
        case 3:
            P4->OUT = THREE;
            break;
        case 4:
            P4->OUT = FOUR;
            break;
        case 5:
            P4->OUT = FIVE;
            break;
        case 6:
            P4->OUT = SIX;
            break;
        case 7:
            P4->OUT = SEVEN;
            break;
        case 8:
            P4->OUT = EIGHT;
            break;
        case 9:
            P4->OUT = NINE;
            break;
        case 0:
            P4->OUT = ZERO;
            break;
        default:
            P4->OUT = 0x7F;         // LED off
            break;
    }
}

/*
 * Port 6 ISR to debounce switches and inc/dec SSEG
 * Uses P6IV to solve critical section/race
 */
void PORT6_IRQHandler() {
    if (Button_In() == 1){          // 0001 for increment SSEG
        if (counter == 10){
            counter = 0;
            SSEG_Out(counter);
        } else {
        counter++;
        SSEG_Out(counter);
        }
        /*
        switch(P4->OUT) {
            case ZERO:
                P4->OUT = ONE;
                break;
            case ONE:
                P4->OUT = TWO;
                break;
            case TWO:
                P4->OUT = THREE;
                break;
            case THREE:
                P4->OUT = FOUR;
                break;
            case FOUR:
                P4->OUT = FIVE;
                break;
            case FIVE:
                P4->OUT = SIX;
                break;
            case SIX:
                P4->OUT = SEVEN;
                break;
            case SEVEN:
                P4->OUT = EIGHT;
                break;
            case EIGHT:
                P4->OUT = NINE;
                break;
            case NINE:
                P4->OUT = ZERO;
                break;
            default:
                P4->OUT = 0x7F;         // LED off
                break;
        }*/

    }
    else if (Button_In() == 2){     // 0010 for decrement SSEG
        if (counter == 0){
            counter = 9;
            SSEG_Out(counter);
        } else {
        counter--;
        SSEG_Out(counter);
        }
        /*
        switch(P4->OUT) {
            case ZERO:
                P4->OUT = NINE;
                break;
            case ONE:
                P4->OUT = ZERO;
                break;
            case TWO:
                P4->OUT = ONE;
                break;
            case THREE:
                P4->OUT = TWO;
                break;
            case FOUR:
                P4->OUT = THREE;
                break;
            case FIVE:
                P4->OUT = FOUR;
                break;
            case SIX:
                P4->OUT = FIVE;
                break;
            case SEVEN:
                P4->OUT = SIX;
                break;
            case EIGHT:
                P4->OUT = SEVEN;
                break;
            case NINE:
                P4->OUT = EIGHT;
                break;
            default:
                P4->OUT = 0x7F;         // LED off
                break;
        }*/
    }
    SysTick_Wait(1100000);            // debounce switches by about 366.7ms
}
