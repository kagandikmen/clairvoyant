// Demo program for the super-resolution functionality of clairvoyant
// Created: 2024-08-21
// Modified: 2025-05-12 (status: tested, working)
// Author: Kagan Dikmen (kagan.dikmen@tum.de)

// Copyright (c) 2025, Kagan Dikmen
// See LICENSE for details

#include <stdint.h>
#include "platform.h"
#include "uart.h"

#define SOURCE_WIDTH 64
#define SOURCE_HEIGHT 64

#define CV          // comment if you want to run the base version

static struct uart uart0;

// sequence to initiate data transfer
uint8_t seq[4] = {0xAA, 0x55, 0xAA, 0x55};

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

    unsigned char enhanced_image_cropped [(SOURCE_WIDTH*2-1)*(SOURCE_HEIGHT*2-1)] = {};

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

    for(int i = 0; i < num_source_pixels; i++){
		while(uart_rx_fifo_empty(&uart0));
		*((volatile uint8_t*)(original_image + i)) = uart_rx(&uart0);
	}
    
#ifdef CV
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
    
    int index = 0;

    for(int i=0; i<(SOURCE_HEIGHT*2-1); i++)
    {
        for(int j=1; j<(SOURCE_WIDTH*2); j++)
        {
            enhanced_image_cropped[index] = enhanced_image[i*(SOURCE_WIDTH*2)+j];
            index++;
        }
    }
#else

    int index = 0;

    for(int i=0; i<2*SOURCE_HEIGHT-1; i++) {
        for(int j=0; j<2*SOURCE_WIDTH-1; j++) {
            if(i%2 == 0 && j%2 == 0) {
                enhanced_image_cropped[index] = (original_image[(i/2)*SOURCE_WIDTH+(j/2)] + original_image[(i/2)*SOURCE_WIDTH+(j/2)+SOURCE_WIDTH]) >> 1;
            } else {
                enhanced_image_cropped[index] = (original_image[(i/2)*SOURCE_WIDTH+(j/2)] + original_image[(i/2)*SOURCE_WIDTH+(j/2)+1] + original_image[(i/2)*SOURCE_WIDTH+(j/2)+SOURCE_WIDTH] + original_image[(i/2)*SOURCE_WIDTH+(j/2)+SOURCE_WIDTH+1]) >> 2;
            }
            index++;
        }
    }

#endif
    
    uart_tx_array(&uart0, enhanced_image_cropped, (SOURCE_WIDTH*2-1)*(SOURCE_HEIGHT*2-1));

    return 0;
}