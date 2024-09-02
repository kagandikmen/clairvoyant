// Demo program for the super-resolution functionality of clairvoyant
// Created: 2024-08-21
// Modified: 2024-09-01 (status: tested, working)
// Author: Kagan Dikmen (kagan.dikmen@tum.de)

// Copyright (c) 2024, Kagan Dikmen
// See LICENSE for details

#include <stdint.h>
#include "platform.h"
#include "uart.h"

static struct uart uart0;

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
	// Do nothing
}

int main() 
{
    
    uart_initialize(&uart0, (volatile void *) PLATFORM_UART0_BASE);
	uart_set_divisor(&uart0, uart_baud2divisor(115200, PLATFORM_SYSCLK_FREQ));
    
    unsigned char original_image [4096] = {};

    unsigned char enhanced_image [16384] = {};

    for(int i = 0; i < 64 * 64; i++){
		while(uart_rx_fifo_empty(&uart0));
		*((volatile uint8_t*)(original_image + i)) = uart_rx(&uart0);
	}
    
    asm volatile("add x28, x0, %[a]"::[a] "r" (original_image):);
    asm volatile("add x29, x0, %[a]"::[a] "r" (enhanced_image):);
    
    
    for(int i=0; i<64; i++){
        for(int j=0; j<16; j++) {
            asm volatile(
                        "lw x30, 0(x28)\n\t"
                        "lw x31, 64(x28)\n\t"
                        "enh x30, x31\n\t"
                        "lf0 0(x29)\n\t"
                        "lf1 4(x29)"
                        );
            if(i != 63) // Corner case: last row
            {
                asm volatile(
                            "lf2 128(x29)\n\t"
                            "lf3 132(x29)"
                            );
            }
            asm volatile(
                        "addi x28, x28, 0x4\n\t"
                        "addi x29, x29, 0x8"
                        );
            
        }
        asm volatile("addi x29, x29, 0x80");
    }

    uart_tx_array(&uart0, enhanced_image, 16384);
    
    return 0;
}