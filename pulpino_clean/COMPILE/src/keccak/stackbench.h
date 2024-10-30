#ifndef STACKBENCH_H
#define STACKBENCH_H

#define STACK_ADDR_START 0x00102000
#define STACK_WORDS 1024
#define CANARY 0xc01dc0fe

void write_stack();

uint32_t check_stack();

#endif
