# Makefile for flashing-leds
#

TARGET=atmega8
HFUSE=0x91
LFUSE=0x04
CLOCK=8000000

ISP=usbasp
#PORT=/dev/usb/ttyUSB0


help:
	@echo "Usage: make                same as make help"
	@echo "       make help           same as make"
	@echo "       make led_blink.hex       create led_blink.hex"
	@echo "       make clean          remove redundant data"
	@echo "       make disasm         disasm led_blink"
	@echo "       make flash          upload led_blink.hex into flash"
	@echo "       make fuses          program fuses"
	@echo "       make avrdude        test avrdude"
	@echo "Current values:"
	@echo "       TARGET=${TARGET}"
	@echo "       LFUSE=${LFUSE}"
	@echo "       HFUSE=${HFUSE}"
	@echo "       CLOCK=${CLOCK}"
	@echo "       ISP=${ISP}"
	@echo "       PORT=${PORT}"


COMPILE = avr-gcc -Os -g -DF_CPU=$(CLOCK) -mmcu=$(TARGET) # -DDEBUG_LEVEL=2
#COMPILE = avr-gcc -Wall -O2 -DF_CPU=$(CLOCK) -Iusbdrv -I. -mmcu=$(TARGET) # -DDEBUG_LEVEL=2

OBJECTS = led_blink.o

.c.o:
	$(COMPILE) -c $< -o $@
#-Wa,-ahlms=$<.lst

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

.c.s:
	$(COMPILE) -S $< -o $@

clean:
	rm -f led_blink.hex led_blink.lst led_blink.obj led_blink.cof led_blink.list led_blink.map led_blink.eep.hex led_blink.bin *.o led_blink.s

# file targets:
led_blink.bin:	$(OBJECTS)
	$(COMPILE) -o led_blink.bin $(OBJECTS) -Wl,-Map,led_blink.map

led_blink.hex:	led_blink.bin
	rm -f led_blink.hex led_blink.eep.hex
	avr-objcopy -j .text -j .data -O ihex led_blink.bin led_blink.hex
#	./checksize led_blink.bin
# do the checksize script as our last action to allow successful compilation
# on Windows with WinAVR where the Unix commands will fail.

disasm:	led_blink.bin
	avr-objdump -d led_blink.bin

cpp:
	$(COMPILE) led_blink.c
#	$(COMPILE) -E led_blink.c

flash:
	avrdude -c ${ISP} -p ${TARGET} -U flash:w:led_blink.hex
#	avrdude -c ${ISP} -p ${TARGET} -P ${PORT} -U flash:w:led_blink.hex

fuses:
	avrdude -c ${ISP} -p ${TARGET} -u -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m
#	avrdude -c ${ISP} -p ${TARGET} -P ${PORT} -u -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

avrdude:
	avrdude -c ${ISP} -p ${TARGET} -v
#	avrdude -c ${ISP} -p ${TARGET} -P ${PORT} -v

# Fuse atmega8 high byte HFUSE:
# 0xc9 = 1 1 0 0   1 0 0 1 <-- BOOTRST (boot reset vector at 0x0000)
#        ^ ^ ^ ^   ^ ^ ^------ BOOTSZ0
#        | | | |   | +-------- BOOTSZ1
#        | | | |   + --------- EESAVE (don't preserve EEPROM over chip erase)
#        | | | +-------------- CKOPT (full output swing)
#        | | +---------------- SPIEN (allow serial programming)
#        | +------------------ WDTON (WDT not always on)
#        +-------------------- RSTDISBL (reset pin is enabled)
# Fuse atmega8 low byte LFUSE:
# 0x9f = 1 0 0 1   1 1 1 1
#        ^ ^ \ /   \--+--/
#        | |  |       +------- CKSEL 3..0 (external >8M crystal)
#        | |  +--------------- SUT 1..0 (crystal osc, BOD enabled)
#        | +------------------ BODEN (BrownOut Detector enabled)
#        +-------------------- BODLEVEL (2.7V)
#
# Fuse atmega48 high byte hfuse:
# 0xdf = 1 1 0 1   1 1 1 1     factory setting
#        ^ ^ ^ ^   ^ \-+-/
#        | | | |   |   +------ BODLEVEL (Brown out disabled)
#        | | | |   + --------- EESAVE (don't preserve EEPROM over chip erase)
#        | | | +-------------- WDTON (WDT not always on)
#        | | +---------------- SPIEN (allow serial programming)
#        | +------------------ DWEN (debug wire is disabled)
#        +-------------------- RSTDISBL (reset pin is enabled)
# 0xdd = ext.reset, no DW, SPI, no watchdog, no save eeprom, BOD 2.7V
# Fuse atmega48 low byte lfuse:
# 0x62 = 0 1 1 0   0 0 1 0     factory setting
#        ^ ^ \ /   \--+--/
#        | |  |       +------- CKSEL 3..0 (internal 8Mhz Oszillator)
#        | |  +--------------- SUT 1..0 (start-up time)
#        | +------------------ CKOUT (no clock output)
#        +-------------------- CKDIV8 (divide clock by 8)
# 0xdc = divide/1,no clock output,fast raising power,low Pw Oszil. 3..8 Mhz
# 0xe0 = divide/1,no clock output,fast raising power,external Oszil.
# 0xff = divide/1,no clock output,slow raising power,low Pw Oszil 8..  Mhz


SERIAL = `echo /dev/tty.USA19QI*`
UISP = uisp -dprog=$S -dserial=$(SERIAL) -dpart=auto
# The two lines above are for "uisp" and the AVR910 serial programmer connected
# to a Keyspan USB to serial converter to a Mac running Mac OS X.
# Choose your favorite programmer and interface.

uisp:	all
	$(UISP) --erase
	$(UISP) --upload --verify if=led_blink.hex

