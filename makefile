# Name: Makefile
# Author: <insert your name here>
# Copyright: <insert your copyright message here>
# License: <insert your license reference here>

# This is a prototype Makefile. Modify it according to your needs.
# You should at least check the settings for
# DEVICE ....... The AVR device you compile for
# CLOCK ........ Target AVR clock rate in Hertz
# OBJECTS ...... The object files created from your source files. This list is
#                usually the same as the list of source files with suffix ".o".
# PROGRAMMER ... Options to avrdude which define the hardware you use for
#                uploading to the AVR and the interface where this hardware
#                is connected. We recommend that you leave it undefined and
#                add settings like this to your ~/.avrduderc file:
#                   default_programmer = "stk500v2"
#                   default_serial = "avrdoper"
# FUSES ........ Parameters for avrdude to flash the fuses appropriately.

DEVICE     = atmega328
CLOCK      = 8000000
PROGRAMMER = -c avrisp -b 19200 -F -P /dev/tty.usbserial-A700e6Td
FPLIBOBJECTS    = fplib/mulsf3x.o fplib/mulsf3.o fplib/addsf3x.o fplib/addsf3.o fplib/fp_inf.o fplib/fp_splinf.o fplib/fp_nan.o fplib/fp_zero.o fplib/fp_splzero.o fplib/fp_pack.o
FUSES      = -U efuse:w:0x05:m -U hfuse:w:0xDA:m -U lfuse:w:0xFF:m


# Tune the lines below only if you know what you are doing:

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
AVRCOMPILE = avr-gcc -std=c++11 -Os -fpack-struct -fshort-enums -ffunction-sections -fdata-sections -Wall -Wl,--relax,--gc-sections -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

build: 

test: build

testmulsf3: testmulsf3/main.hex operandsgenerate
	simulavr -d $(DEVICE)

%/operandsgenerate: %/operandsgenerate.cpp
	$(COMPILE) $< -o $@
	./$@



%.hex: %.elf
	rm -f $@
	avr-objcopy -j .text -j .data -O ihex $< $@
	avr-size --format=avr --mcu=$(DEVICE) $<
	avr-objdump -d $@ > $*.s

# file targets:
%.elf: %.o $(FPLIBOBJECTS)
	$(AVRCOMPILE) $? -o $@

%.o: %.cpp
%.o: %.c
%.o: %.S
%.o: %.s
	$(AVRCOMPILE) -o $@ -c $<

clean:
	rm -f main.hex main.elf $(OBJECTS)

