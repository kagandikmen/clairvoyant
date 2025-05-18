// Demo program for the super-resolution functionality of clairvoyant
// Created: 2024-08-21
// Modified: 2025-05-18 (status: tested, working)
// Author: Kagan Dikmen (kagan.dikmen@tum.de)

// Copyright (c) 2025, Kagan Dikmen
// See LICENSE for details

#include <stddef.h>
#include <stdint.h>
#include "platform.h"
#include "uart.h"

#define SOURCE_WIDTH 64
#define SOURCE_HEIGHT 64

#define CV          // comment if you want to run the base version
// #define EVAL     // uncomment if you want to receive the cycle count at the end

static struct uart uart0;

// sequence to initiate data transfer
static const unsigned char seq[4] = {0xAA, 0x55, 0xAA, 0x55};

// converts integer to string, used in evaluation
static void int2str(int, char[]);

static unsigned char original_image [SOURCE_WIDTH * SOURCE_HEIGHT] = {};

static volatile unsigned char enhanced_image [(2*SOURCE_WIDTH) * (2*SOURCE_HEIGHT)] = {};

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
	// Do nothing
}

int main() 
{
    
    uart_initialize(&uart0, (volatile void *) PLATFORM_UART0_BASE);
	uart_set_divisor(&uart0, uart_baud2divisor(115200, PLATFORM_SYSCLK_FREQ));

    uint8_t key;

    while(1) {
        while(uart_rx_fifo_empty(&uart0));
        key = uart_rx(&uart0);
        if(key != seq[0]) continue;

        while(uart_rx_fifo_empty(&uart0));
        key = uart_rx(&uart0);
        if(key != seq[1]) continue;

        while(uart_rx_fifo_empty(&uart0));
        key = uart_rx(&uart0);
        if(key != seq[2]) continue;

        while(uart_rx_fifo_empty(&uart0));
        key = uart_rx(&uart0);
        if(key != seq[3]) continue;
        
        break;
    }

    for(size_t i = 0; i < SOURCE_WIDTH * SOURCE_HEIGHT; i++){
		while(uart_rx_fifo_empty(&uart0));
		*((volatile uint8_t*)(original_image + i)) = uart_rx(&uart0);
	}

    uint32_t hi1, lo, hi2;
    do {
        asm volatile("csrr %0, cycleh" : "=r"(hi1));
        asm volatile("csrr %0, cycle"  : "=r"(lo));
        asm volatile("csrr %0, cycleh" : "=r"(hi2));
    } while (hi1 != hi2);

    uint64_t start_cycle = ((uint64_t)hi1 << 32) | lo;
    
#ifdef CV
    asm volatile("add x28, x0, %[a]"::[a] "r" (&original_image[SOURCE_WIDTH-4]):);
    asm volatile("add x29, x0, %[a]"::[a] "r" (&enhanced_image[(2*SOURCE_WIDTH)-8]):);
    
    for(size_t i=0; i<SOURCE_HEIGHT; i++){
        asm volatile("ctrst");
        for(size_t j=0; j<(SOURCE_WIDTH>>2); j++) {
            asm volatile("lw x30, 0(x28)\n\t"
                        "add x31, x28, %[a]\n\t"
                        "lw x31, 0(x31)\n\t"
                        "enh x30, x31\n\t"
                        "lf0 0(x29)\n\t"
                        "lf1 4(x29)\n\t"
                        "add x30, x29, %[b]\n\t"
                            "lf2 0(x30)\n\t"
                        "lf3 4(x30)"
                        ::
                        [a] "r" (SOURCE_WIDTH),
                        [b] "r" (2*SOURCE_WIDTH)
                        :); 
            if(i==SOURCE_HEIGHT-1) {
                asm volatile("lf0 0(x30)\n\t"
                            "lf1 4(x30)");
            }
            asm volatile("addi x28, x28, -4\n\t"
                        "addi x29, x29, -8");
        }
        asm volatile("add x28, x28, %[a]"::[a] "r" (2*SOURCE_WIDTH));
        asm volatile("add x29, x29, %[a]"::[a] "r" (6*SOURCE_WIDTH));
    }
    
    int index = 0;

#else

    int index = 0;

    for(size_t i=0; i<2*SOURCE_HEIGHT-1; i++) {
        for(size_t j=0; j<2*SOURCE_WIDTH-1; j++) {

            int pos = (i/2)*SOURCE_WIDTH+(j/2);

            while(!uart_tx_fifo_empty(&uart0));

            if(i%2 == 0 && j%2 == 0) {
                enhanced_image[index] = original_image[pos];
            } else if(i%2 == 0 && j%2 != 0) {
                enhanced_image[index] = (original_image[pos] + original_image[pos+1]) >> 1;
            } else if(i%2 != 0 && j%2 == 0) {
                enhanced_image[index] = (original_image[pos] + original_image[pos+SOURCE_WIDTH]) >> 1;
            } else {
                enhanced_image[index] = (original_image[pos] + original_image[pos+1] + original_image[pos+SOURCE_WIDTH] + original_image[pos+SOURCE_WIDTH+1]) >> 2;
            }

            if(j==2*SOURCE_WIDTH-1)
                enhanced_image[index] = enhanced_image[index-1];

            if(i==2*SOURCE_HEIGHT-1)
                enhanced_image[index] = enhanced_image[index-2*SOURCE_WIDTH];

            index++;
        }
    }

#endif

    do {
        asm volatile("csrr %0, cycleh" : "=r"(hi1));
        asm volatile("csrr %0, cycle"  : "=r"(lo));
        asm volatile("csrr %0, cycleh" : "=r"(hi2));
    } while (hi1 != hi2);

    uint64_t end_cycle = ((uint64_t)hi1 << 32) | lo;

    uint64_t elapsed = end_cycle - start_cycle;

    index = 0;

    // send the enhanced image through UART
    for(size_t i=0; i<(2*SOURCE_HEIGHT); i++) {
        for(size_t j=0; j<(2*SOURCE_WIDTH); j++) {
            while(!uart_tx_fifo_empty(&uart0));
            uart_tx(&uart0, enhanced_image[index]);
            index++;
        }
    }

#ifdef EVAL
    char duration[10];

    int2str(elapsed, duration);

    uart_tx_string(&uart0, "\n\n\rCYCLE COUNT: ");
    uart_tx_string(&uart0, duration);
    uart_tx_string(&uart0, "\n\r");
#endif

    return 0;
}

static void int2str(int num, char str[])
{
    if (num == 0) {
        str[0] = '0';
        str[1] = '\0';
        return;
    }

    int rem, len = 0, n;
 
    n = num;

    while (n != 0) {
        len++;
        n /= 10;
    }

    for (size_t i = 0; i < len; i++) {
        rem = num % 10;
        num = num / 10;
        str[len - (i + 1)] = rem + '0';
    }
    
    str[len] = '\0';
}