#include <stdint.h>
#include "SysTick.h"
#include "msp432p401r.h"
#include "SSEG.h"

#define A 0x3F  // Segment A  ON = 0011 1111
#define B 0x5F  // Segment B  ON = 0101 1111
#define C 0x6F  // Segment C  ON = 0110 1111
#define D 0x77  // Segment D  ON = 0111 0111
#define E 0x7B  // Segment E  ON = 0111 1011
#define F 0x7D  // Segment F  ON = 0111 1101
#define G 0x7E  // Segment G  ON = 0111 1110

#define  ONE    B & C
#define  TWO    A & B & D & E & G
#define  THREE  A & B & C & D & G
#define  FOUR   B & C & F & G
#define  FIVE   A & C & D & F & G
#define  SIX    A & C & D & E & F & G
#define  SEVEN  A & B & C
#define  EIGHT  A & B & C & D & E & F & G
#define  NINE   A & B & C & D & F & G
#define  ZERO   A & B & C & D & E & F

int bits[4];
int counter;
int difference = 0;

/*****************************************
 *          PRIVATE FUNCTIONS
 *****************************************/
void Button_Init(void){
    P6->SEL0 &= ~0x3;               // 0011 two buttons (extern, pos)
    P6->SEL1 &= ~0x3;
    P6->DIR  &= ~0x3;               // as input
}
uint32_t Button_In(void){           // private function
    return P6->IN & 0x3;            // extract those two bits
}

void SRCLKPulse(void){              // Pulse the Shift Register Clock
    P5OUT |=  0x1;                  // HIGH
    P5OUT &= ~0x1;                  // LOW
}

void RCLKPulse(void){               // Pulse the Latch Clock, inverse of SR Clock
    P5OUT |=  0x2;                  //HIGH
    P5OUT &= ~0x2;                  //LOW
}

/*
void SSEG_On(){
    P4->OUT = 0x0F;                 // All digits on
}
*/

void SSEG_Off(){
    P4->OUT = 0x00;                 // All digits off
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

    // For common cathode digit outputs:
    P4->SEL0 &= ~0x0F;              // 0000 1111
    P4->SEL1 &= ~0x0F;              // as GPIO
    P4->DIR  |=  0x0F;                // as OUTPUT
    // 0x1 = D1, 0x2 = D2, 0x4 = D3, 0x8 = D4

    SSEG_Off();

    // For Shift Register outputs:
    P5->SEL0 &= ~0x07;              // 0000 0111
    P5->SEL1 &= ~0x07;              // as GPIO
    P5->DIR  |=  0x07;                // as OUTPUT
    // 0x1 = SRCLK, 0x2 = RCLK, 0x4 = SER
}

/*
 * Port 6 ISR to debounce switches and inc/dec SSEG
 * Uses P6IV to solve critical section/race
 */
void PORT6_IRQHandler(int userinput) {
    while(1){                                   // loop here because counter had trouble updating its value
        if (Button_In() == 1){                  // 0001 for increment SSEG
            if (counter == 9999){
                userinput = 0;
                difference = 0;
            } else {
            counter++;
            difference++;
            }
            SysTick_Wait(1100000);              // debounce switches by about 366.7ms
        }
        else if (Button_In() == 2){             // 0010 for decrement SSEG
            if (counter == 0){
                userinput = 9999;
                difference = 0;
            } else {
            counter--;
            difference--;
            }
            SysTick_Wait(1200000);              // debounce switches by about 366.7ms
        } else {
            counter = userinput + difference;
            SSEG_Disp_Num(counter);
        }
    }
}

/*
 * SSEG_Disp_Num Function
 * Separate the input number into 4 single digit
 * Inputs: num between 0 and 9999
 * Outputs: none
 */
void SSEG_Disp_Num(int num){        // bits[] defined globally
    int num_temp = num;             // stores num divided by 10
    int digits = 0;                 // clear digits
    bits[0] = 0;                    // clear bits
    bits[1] = 0;
    bits[2] = 0;
    bits[3] = 0;
    while (num_temp > 0) {          // digit counter
        num_temp = num_temp/10;
        digits ++;
    }
    if (num == 0) digits = 1;       // the zero case
    int temp_n = num;               // stores num modulus 10
    int i;
    for(i = digits-1; i >= 0; i--) {
        temp_n = num %10;           // store modulus values backwards by decrementing
        bits[i] = temp_n;
        num /= 10;
    }
    counter = 0;                    // must be zero or else it will reuse previous counter value
    for (i = 0; i < digits; i++){
        counter = 10 * counter + bits[i]; // string to int conversion
    }
    SSEG_Out(digits);
}

/*
 * SSEG_Out Function
 * Output a 4-digit number to the display
 * Inputs: digits
 * Outputs: none
 */
void SSEG_Out(int digits) {
    int i;
    int digits_clone = digits;
    for (i = 0; i < digits; i++){
        switch(bits[i]) {
            case 1:
                SSEG_Shift_Out(ONE);
                break;
            case 2:
                SSEG_Shift_Out(TWO);
                break;
            case 3:
                SSEG_Shift_Out(THREE);
                break;
            case 4:
                SSEG_Shift_Out(FOUR);
                break;
            case 5:
                SSEG_Shift_Out(FIVE);
                break;
            case 6:
                SSEG_Shift_Out(SIX);
                break;
            case 7:
                SSEG_Shift_Out(SEVEN);
                break;
            case 8:
                SSEG_Shift_Out(EIGHT);
                break;
            case 9:
                SSEG_Shift_Out(NINE);
                break;
            case 0:
                SSEG_Shift_Out(ZERO);
                break;
            default:
                SSEG_Off();
                break;
        }//end switch
        if (digits_clone == 4){
                P4->OUT = 0x1;          // first digit
                SysTick_Wait(3000);      // .8333 ms
                }
        else if (digits_clone == 3){
                P4->OUT = 0x2;          // second digit
                SysTick_Wait(3000);      // .8333 ms
                }
        else if (digits_clone == 2){
                P4->OUT = 0x4;          // third digit
                SysTick_Wait(3000);      // .8333 ms
                }
        else if (digits_clone == 1){
                P4->OUT = 0x8;          // fourth digit
                SysTick_Wait(3000);      // .8333 ms
                }
        digits_clone--;
    }//end for
}//end func

/*
 * SSEG_Shift_Out Function
 * Shifts data out serially
 * Inputs: 8-bit data
 * Outputs: none
 */
void SSEG_Shift_Out(int data){      // input: 1 byte, ZERO through NINE.
    int i;
    for(i=0;i<8;i++){               // Output 8 bits to SER
        SRCLKPulse();               // Continuously pulse the SR Clock, must be low before data
        if((data & 0x01) == 0x01){  // if output high = LED seg on
            P5->OUT |= 0x4;
        }else{                      // output low = LED seg off
            P5->OUT &= ~0x4;
        }
        data=data>>1;               // Shift to next bit
    }
    RCLKPulse();                    // output latch after all 8 bits transfered, must be high after data
}
