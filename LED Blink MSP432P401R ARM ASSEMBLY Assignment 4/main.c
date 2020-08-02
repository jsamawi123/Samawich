#include <stdint.h>
#include <stdio.h>
#include "msp432p401r.h"

extern void asm_main();
extern void Port1_ISR();

// Port 1 ISR
void PORT1_IRQHandler() {
    Port1_ISR();        // Call assembly Port 1 ISR
}

void main() {
    asm_main();
}
