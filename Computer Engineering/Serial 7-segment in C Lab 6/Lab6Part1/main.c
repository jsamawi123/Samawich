#include "msp432p401r.h"
#include "SysTick.h"
#include "SSEG.h"

void main() {
    SysTick_Init();
    SSEG_Init();
    SSEG_Out(0);
    while(1){
        PORT6_IRQHandler();
    }
}
