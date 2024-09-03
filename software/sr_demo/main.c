// Demo program for the super-resolution functionality of clairvoyant
// Created: 2024-08-21
// Modified: 2024-09-01 (status: tested, working)
// Author: Kagan Dikmen (kagan.dikmen@tum.de)

// Copyright (c) 2024, Kagan Dikmen
// See LICENSE for details

#include <stdint.h>
#include "platform.h"
#include "uart.h"

#define SOURCE_WIDTH 32
#define SOURCE_HEIGHT 32

static struct uart uart0;

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
	// Do nothing
}

int main() 
{
    
    uart_initialize(&uart0, (volatile void *) PLATFORM_UART0_BASE);
	uart_set_divisor(&uart0, uart_baud2divisor(115200, PLATFORM_SYSCLK_FREQ));
    
    int num_source_pixels = SOURCE_WIDTH * SOURCE_HEIGHT;

    unsigned char original_image [num_source_pixels] = {};

    unsigned char enhanced_image [num_source_pixels*4] = {};

    for(int i = 0; i < num_source_pixels; i++){
		while(uart_rx_fifo_empty(&uart0));
		*((volatile uint8_t*)(original_image + i)) = uart_rx(&uart0);
	}
    
    asm volatile("add x28, x0, %[a]"::[a] "r" (original_image):);
    asm volatile("add x29, x0, %[a]"::[a] "r" (enhanced_image):);
    
    
    for(int i=0; i<SOURCE_HEIGHT; i++){
        asm volatile("ctrst");
        for(int j=0; j<(SOURCE_WIDTH>>2); j++) {
            asm volatile("lw x30, 0(x28)");
            asm volatile("add x31, x28, %[a]"::[a] "r" (SOURCE_WIDTH):);
            asm volatile(
                        "lw x31, 0(x31)\n\t"
                        "enh x30, x31\n\t"
                        "lf0 0(x29)\n\t"
                        "lf1 4(x29)"
                        );
            if(i != SOURCE_HEIGHT-1)    // Corner case: last row
            {
                asm volatile("add x30, x29, %[a]"::[a] "r" (SOURCE_WIDTH*2):);
                asm volatile(
                            "lf2 0(x30)\n\t"
                            "lf3 4(x30)"
                            );
            }
            asm volatile(
                        "addi x28, x28, 0x4\n\t"
                        "addi x29, x29, 0x8"
                        );
            
        }
        asm volatile("add x29, x29, %[a]"::[a] "r" (SOURCE_WIDTH*2));
    }

    uart_tx_array(&uart0, enhanced_image, num_source_pixels*4);
    
    return 0;
}