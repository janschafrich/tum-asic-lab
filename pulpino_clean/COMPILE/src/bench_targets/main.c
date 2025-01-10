#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "gpio.h"
#include "timer.h"
#include "uart.h"
#include "fips202.h"
#include "stackbench.h"

#define accel_base     (0x20000000u)
#define control_offset (0x0u        )
#define status_offest  (0x10u       )
#define data_offset    (0x80000u    )

#define START_REG           ((volatile uint8_t*) (accel_base + control_offset))
#define OUTPUT_LEN_BYTE_REG ((volatile uint8_t*) (accel_base + control_offset + 1))
#define STATUS_REG          ((volatile uint8_t*) (accel_base + status_offest))
#define DONE_REG            ((volatile uint8_t*) (accel_base + status_offest + 1))
#define ACCEL_DATA_BASE     ((volatile uint8_t*) (accel_base + data_offset))

#define RATE_BYTES          (1344/8)
#define N_MEM_WORDS         (RATE_BYTES/4)

#define ENABLE_DEBUG        0

/* Declared globally such that variables are not on stack */
uint8_t *accel_data = ACCEL_DATA_BASE;   

uint8_t input[64];
size_t inlen = 64;

uint8_t output[64];
size_t outlen = 64;

int t0, t1;
int count = 0;

enum acc_state {ST_IDLE, ST_RUNNING};
enum acc_error {ER_OKAY, ER_INVALID_CFG, ER_OTHERS};

int main(void)
{

    reset_timer();
    start_timer();

    /* Used to initialize GPIOs */
    for (uint8_t i=0; i<8; i++) {
        set_gpio_pin_direction(i, DIR_OUT);
    }

    printf("Before Write 0x%x OUTPUT_LEN_BYTEREG = %d\n", OUTPUT_LEN_BYTE_REG, *OUTPUT_LEN_BYTE_REG);
    *OUTPUT_LEN_BYTE_REG = (uint8_t) (outlen - 1); // 6 bit register
    printf("After Write  0x%x OUTPUT_LEN_BYTE_REG = %d\n", OUTPUT_LEN_BYTE_REG, *OUTPUT_LEN_BYTE_REG);

    /* Initialize memory with input and padding */
    for (uint8_t i = 0; i < RATE_BYTES; i++)
    {
        if (i < outlen)
        {
            accel_data[i] = (uint8_t) 0xFF;
            input[i]      = (uint8_t)  0xFF;
        }      
        else if (i == outlen)           accel_data[i] = (uint8_t) 0x1F;
        else if (i == RATE_BYTES - 1)   accel_data[i] = (uint8_t) 0x80;
        else                            accel_data[i] = (uint8_t) 0x00;
    }

    // print written values
    for (int i = 0; i < RATE_BYTES; i++)
    {
        printf("0x%x accel_data[%d] = %d \n",&accel_data[i], i, accel_data[i] );
    }

    printf("Idle:\n");
    printf("Accel: Status Address 0x%x=%d \n",  STATUS_REG,  *START_REG & 0x0F);
    printf("Accel: Error  Address 0x%x=%d \n",   STATUS_REG, (*START_REG & 0xF0) >> 4);

    write_stack();

    shake128(output, outlen, input, inlen);
   
    printf("Before Write 0x%x START_REG = %d\n", START_REG, *START_REG);
    t0 = get_time();
    *START_REG = (uint8_t) 1;
    printf("After Write  0x%x START_REG = %d\n", START_REG, *START_REG);

    printf("Accel: Addr 0x%x  Status=%d     Error=%d \n",  STATUS_REG,  *STATUS_REG & 0x0F, (*STATUS_REG & 0xF0) >> 4);
    // busy wait for accelerator 
    while (*DONE_REG == 0);
    t1 = get_time();
    printf("Accel: Addr 0x%x  Status=%d     Error=%d \n",  STATUS_REG,  *STATUS_REG & 0x0F, (*STATUS_REG & 0xF0) >> 4);
    

    uint32_t stack_bytes = check_stack();

    for (int i = 0; i < outlen; i++)
    {
        if (output[i] == accel_data[i])
        {
            printf("CORRECT");
        }
        else printf("ERROR ");
        printf(" SW output[%d] = %d ; Accel output[%d] = %d \n",i, output[i], i, accel_data[i]);
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
