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


// User Configuration Parameters:
#define INPUT_LEN_BYTE      8      // HW: max 64
#define OUTPUT_LEN_BYTE    16      // HW: max 64

#define ENABLE_DEBUG        0
       

/* Declared globally such that variables are not on stack */


uint8_t input[INPUT_LEN_BYTE];
const size_t inlen = INPUT_LEN_BYTE;

uint8_t output_sw[OUTPUT_LEN_BYTE];
uint8_t output_hw[OUTPUT_LEN_BYTE];
const size_t outlen = OUTPUT_LEN_BYTE;

int t0, t1;
int count = 0;

void shake128_hw(uint8_t *output_hw, size_t outlen, const uint8_t *input, size_t inlen)
{
    uint8_t *accel_data = ACCEL_DATA_BASE;

#if ENABLE_DEBUG
    printf("\nBefore Write 0x%x OUTPUT_LEN_BYTE_REG = %d", OUTPUT_LEN_BYTE_REG, *OUTPUT_LEN_BYTE_REG);
#endif

    *OUTPUT_LEN_BYTE_REG = (uint8_t) (outlen - 1); // 6 bit register

#if ENABLE_DEBUG
    printf("\nAfter Write  0x%x OUTPUT_LEN_BYTE_REG = %d", OUTPUT_LEN_BYTE_REG, *OUTPUT_LEN_BYTE_REG);
#endif

    for (uint8_t i = 0; i < RATE_BYTES; i++)
    {
        if (i < inlen)
        {
            accel_data[i] = input[i];     // input data
        } // padding     
        else if (i == inlen)            accel_data[i] = (uint8_t) 0x1F;
        else if (i == RATE_BYTES - 1)   accel_data[i] = (uint8_t) 0x80;
        else                            accel_data[i] = (uint8_t) 0x00;
    }

#if ENABLE_DEBUG
    printf("\n      d=%d Byte Input: 0x", inlen);
    for (uint8_t i = 0; i < inlen; i++)
    {
        printf("%x", accel_data[i]);
    }

    // check memory for succesfull write
    for (int i = 0; i < RATE_BYTES; i++)
    {
        printf("\n0x%x accel_input[%d] = %d ",&accel_data[i], i, accel_data[i] );
    }

    printf("\nAccel: Status Address 0x%x=%d ",  STATUS_REG,  *START_REG & 0x0F);
    printf("\nAccel: Error  Address 0x%x=%d ",   STATUS_REG, (*START_REG & 0xF0) >> 4);
#endif

#if ENABLE_DEBUG
    printf("\nBefore Write 0x%x START_REG = %d", START_REG, *START_REG);
#endif

    *START_REG = (uint8_t) 1;

#if ENABLE_DEBUG
    printf("\nAfter Write  0x%x START_REG = %d", START_REG, *START_REG);

    printf("\nAccel: Addr 0x%x  Status=%d     Error=%d",  STATUS_REG,  *STATUS_REG & 0x0F, (*STATUS_REG & 0xF0) >> 4);
#endif

    // busy wait for accelerator 
    while (*DONE_REG == 0);

    // read results back
    for (uint8_t i = 0; i < outlen; i++)
    {
            output_hw[i] = accel_data[i];
    }

}


int main(void)
{

    reset_timer();
    start_timer();

    /* Used to initialize GPIOs */
    for (uint8_t i = 0; i<8; i++)
    {
        set_gpio_pin_direction(i, DIR_OUT);
    }

    /* Initialize memory with input and padding */
    printf("Input Data = ");
    for (uint8_t i = 0; i < inlen; i++)
    {
        input[i]      = (uint8_t) 0xFF;     // input data
        printf("%02x ", input[i]);
    }  


    write_stack();

    t0 = get_time();

    shake128_hw(output_hw, outlen, input, inlen);

    t1 = get_time();

    uint32_t stack_bytes = check_stack();

    shake128(output_sw, outlen, input, inlen);

    //     shake128(output, outlen, input, inlen);
    // t1 = get_time();
    // uint32_t stack_bytes = check_stack();

      
    

#if ENABLE_DEBUG
    for (int i = 0; i < outlen; i++)
    {
        if (output_sw[i] == output_hw[i]) printf("\nCORRECT");
        else                            printf("\nERROR  ");
        printf(" SW hash[%d] \t= %x \tAccel hash[%d] \t= %x ",i, output_sw[i], i, output_hw[i]);
    }
#endif

    printf("\nHW d=%d Byte Hash: 0x", outlen);
    for (uint8_t i = 0; i < outlen; i++)
    {
        printf("%02x", output_hw[i]);
    }

    printf("\nSW d=%d Byte Hash: 0x", outlen);
    for (uint8_t i = 0; i < outlen; i++)
    {
        printf("%02x", output_sw[i]);
        // printf("%d   ", i);
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
