# Makefile for PYNQ-Z1 tests
# Created: 2024-08-30
# Modified: 2024-08-20 (status: tested, working)

# Copyright (c) 2024 Kagan Dikmen
# See LICENSE for details

.PHONY: all clean
include ../common.mk

TARGET_LDFLAGS += -Wl,-T../potato.ld -Wl,--Map,sru_test.map

OBJECTS := main.o start.o

PORT ?= /dev/ttyUSB0

all: sru_test.elf sru_test.bin sru_test.coe

sru_test.elf: $(OBJECTS)
	$(TARGET_LD) -o sru_test.elf $(TARGET_LDFLAGS) $(OBJECTS)
	$(TARGET_SIZE) sru_test.elf

clean:
	-$(RM) $(OBJECTS)
	-$(RM) sru_test.elf sru_test.bin sru_test.coe

# Object file rules:

main.o: main.c ../../potato.h
	$(TARGET_CC) -c -o $@ $(TARGET_CFLAGS) $<

start.o: ../start.S
	$(TARGET_CC) -c -o $@ $(TARGET_CFLAGS) $<

sendover:
	cat sru_test.bin /dev/zero | head -c128k | pv -s 128k -L 14400 > $(PORT)


###########################################
## OLD VERSION
###########################################

# TOOLCHAIN_PREFIX ?= riscv32-unknown-elf

# SOURCE := main

# PORT := /dev/ttyUSB0

# .PHONY: all buildbin clean 

# all: buildbin sendover

# buildbin:
# 	$(TOOLCHAIN_PREFIX)-gcc -c $(SOURCE).c -o $(SOURCE).o -I ../../ -I ../../libsoc
# 	$(TOOLCHAIN_PREFIX)-gcc $(SOURCE).o -o $(SOURCE)
# 	$(TOOLCHAIN_PREFIX)-objcopy -O binary $(SOURCE) $(SOURCE).bin

# sendover: buildbin
# 	cat $(SOURCE).bin /dev/zero | head -c128k | pv -s 128k -L 14400 > $(PORT)

# clean:
# 	-$(RM) $(SOURCE) $(SOURCE).o $(SOURCE).bin