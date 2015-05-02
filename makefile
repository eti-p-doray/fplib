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

DEVICE     = atmega8
CLOCK      = 32000000
PROGRAMMER = -c avrisp -b 19200 -F -P /dev/tty.usbserial-A700e6Td
OBJECTS    = main.o fplib/mulsf3x.o fplib/mulsf3.o fplib/addsf3x.o fplib/addsf3.o fplib/fp_inf.o fplib/fp_splinf.o fplib/fp_nan.o fplib/fp_zero.o fplib/fp_splzero.o fplib/fp_pack.o
FUSES      = -U efuse:w:0x05:m -U hfuse:w:0xDA:m -U lfuse:w:0xFF:m


# Tune the lines below only if you know what you are doing:

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
COMPILE = avr-gcc -std=c++11 -Os -fpack-struct -fshort-enums -ffunction-sections -fdata-sections -Wall -Wl,--relax,--gc-sections -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

# symbolic targets:
all: build flash fuse

build: clean main.hex

main.hex: main.elf
	rm -f main.hex
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex
	avr-size --format=avr --mcu=$(DEVICE) main.elf
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

# file targets:
main.elf: $(OBJECTS)
	$(COMPILE) -o main.elf $(OBJECTS)

%.o: %.cpp
	$(COMPILE) -o $@ -c $<

%.o: %.c
	$(COMPILE) -o $@ -c $<

%.o: %.S
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

%.o: %.s
	$(COMPILE) -S $< -o $@

# Targets for code debugging and analysis:
disasm:	main.elf
	avr-objdump -d main.elf > main.s

clean:
	rm -f main.hex main.elf $(OBJECTS)

