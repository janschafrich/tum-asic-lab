#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "gpio.h"
#include "timer.h"
#include "uart.h"
#include "fips202.h"
#include "stackbench.h"

/* Declared globally such that variables are not on stack */
uint8_t input[32];
size_t inlen = 32;

uint8_t output[64];
size_t outlen = 64;

int t0, t1;

int main(void)
{

    reset_timer();
    start_timer();

    /* Used to initialize GPIOs */
    for (uint8_t i=0; i<8; i++) {
        set_gpio_pin_direction(i, DIR_OUT);
    }

    /* Initialize input for shake with counter values */
    for (uint8_t i=0; i<inlen; i++) {
        input[i] = i;
    }


    /* Measure time, stack and perform shake128 in software */
    write_stack();
    t0 = get_time();
    shake128(output, outlen, input, inlen);
    t1 = get_time();
    uint32_t stack_bytes = check_stack();

    /* Print output for comparison */
    for (uint8_t i=0; i<outlen; i++) {
        printf("%02x ", output[i]);
    }


    /* Print elapsed time and stack consumption */
    printf("\nElapsed cycles: %d\n", t1-t0);
    printf("Stack Bytes: %d\n", stack_bytes);


    /* Used to stop simulation */
    uart_wait_tx_done();
    for (uint8_t i=0; i<8; i++) {
        set_gpio_pin_value(i, 1);
    }
}
