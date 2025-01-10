AS = ca65
LD = ld65

LDCONFIG = memmap.cfg

default: full

full: abn6507rom.bin



abn6507rom.bin: zerop.o i2c.o ssd1306.o serial.o abn6507rom.o

%.bin: %.o
	$(LD) -o $@ $^ -C $(LDCONFIG) -Ln $(basename $@).map

%.o: %.s
	$(AS) -vvv --cpu 6502 -l $(basename $<).lst -o $@ $<

clean:
	@rm -f *.lst *.map *.o *.bin

.PHONY: clean

.PRECIOUS: %.o