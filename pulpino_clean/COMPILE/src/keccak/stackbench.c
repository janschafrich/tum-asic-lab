#include <stdint.h>

#include "stackbench.h"


void write_stack() {
    uint32_t *ptr = (uint32_t *) STACK_ADDR_START;

    /* Fill stack with canary */
    for (uint32_t i=0; i<STACK_WORDS; i++) {
        *ptr = CANARY;
        ptr--;
    }
}

uint32_t check_stack() {
    uint32_t *ptr   = (uint32_t *) STACK_ADDR_START;
    uint32_t cnt    = 0;

    /* Check stack for canary */
    for (uint32_t i=0; i<STACK_WORDS; i++) {
        if (*ptr != CANARY) {
            cnt += 4;
        }
        ptr--;
    }
    return cnt;
}
