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
#define ACCEL_DATA_BASE     ((volatile uint8_t*) (accel_base + data_offset))

#define RATE_BYTES          (1344/8)
#define N_MEM_WORDS         (RATE_BYTES/4)

#define ENABLE_DEBUG        0

/* Declared globally such that variables are not on stack */
uint32_t *accel_data = ACCEL_DATA_BASE;      // a pointer to a 8bit value

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

    /* Initialize memory with input and padding */
    for (uint8_t i = 0; i < N_MEM_WORDS; i++)
    {
        switch (i) {
            // input
            case 0:                 accel_data[i] = (uint32_t) 0x55555555; break;
            // padding
            case 1:                 accel_data[i] = (uint32_t) 1; break;            
            case (N_MEM_WORDS-1):   accel_data[i] = (uint32_t) 0x80000000; break;
            default:                accel_data[i] = (uint32_t) 0; break;
        }
    }

    // verify successful write
    for (int i = 0; i < N_MEM_WORDS; i++)
    {
        printf("0x%x accel_data[%d] = %d \n",&accel_data[i], i, accel_data[i] );
    }

    printf("Idle:\n");
    printf("Accel: Status Address 0x%x=%d \n",  STATUS_REG,  *START_REG & 0x0F);
    printf("Accel: Error  Address 0x%x=%d \n",   STATUS_REG, (*START_REG & 0xF0) >> 4);

    write_stack();
    
    printf("Before Write 0x%x START_REG = %d\n", START_REG, *START_REG);
    t0 = get_time();
    *START_REG = (uint8_t) 1;
    printf("After Write  0x%x START_REG = %d\n", START_REG, *START_REG);

    // busy wait until Accelerator is done and resets the start bit
    printf("Accel: Addr 0x%x  Status=%d     Error=%d \n",  STATUS_REG,  *STATUS_REG & 0x0F, (*STATUS_REG & 0xF0) >> 4);

    while (*START_REG == 1);
    t1 = get_time();
    printf("Accel: Addr 0x%x  Status=%d     Error=%d \n",  STATUS_REG,  *STATUS_REG & 0x0F, (*STATUS_REG & 0xF0) >> 4);
    

    uint32_t stack_bytes = check_stack();

    for (int i = 0; i < N_MEM_WORDS; i++)
    {
        printf("test_data[%d] = %d\n", i, accel_data[i]);
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
