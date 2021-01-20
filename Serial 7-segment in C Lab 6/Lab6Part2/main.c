// LAB 6 By James Samawi 12/18/2020
#include "msp432p401r.h"
#include "SysTick.h"
#include "SSEG.h"
#include <stdio.h> //printf, scanf

void main() {
    int userinput = 0;
    SysTick_Init();
    SSEG_Init();
    printf("\nEnter an integer between 0 and 9999: ");
    scanf("%d", &userinput);
    if (userinput < 0 || userinput > 9999){
        printf("Error: Entered value does not lie between 0 and 9999. Try again.\n");
        scanf("%d", &userinput);
    }
    else {
        PORT6_IRQHandler(userinput);
    }
}
