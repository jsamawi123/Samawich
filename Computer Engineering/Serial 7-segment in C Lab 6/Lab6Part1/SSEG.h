/**************** Public Functions ****************/
/*
 * SSEG_Init Function
 * Initialize 7-segment display
 * Inputs: none
 * Outputs: none
 */
void SSEG_Init();

/*
 * SSEG_Out Function
 * Output a number to a single digit of the 7-segment display
 * Inputs: a number between 0 and 15
 * Outputs: none
 */
void SSEG_Out(uint8_t num);

/*
 * Port 6 ISR to debounce switches and inc/dec SSEG
 * Uses P6IV to solve critical section/race
 */
void PORT6_IRQHandler();
