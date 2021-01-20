/**************** Public Functions ****************/
/*
 * SSEG_Init Function
 * Initialize 7-segment display
 * Inputs: none
 * Outputs: none
 */
void SSEG_Init();

/*
 * Port 6 ISR to debounce switches and inc/dec SSEG
 * Uses P6IV to solve critical section/race
 */
void PORT6_IRQHandler(int userinput);

/*
 * SSEG_Disp_Num Function
 * Separate the input number into 4 single digit
 * Inputs: num between 0 and 9999
 * Outputs: none
 */
void SSEG_Disp_Num(int num);

/*
 * SSEG_Out Function
 * Output a 4-digit number to the display
 * Inputs: digits
 * Outputs: none
 */
void SSEG_Out(int digits);

/*
 * SSEG_Shift_Out Function
 * Shifts data out serially
 * Inputs: 8-bit data
 * Outputs: none
 */
void SSEG_Shift_Out(int data);
