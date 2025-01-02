AS = ca65
LD = ld65

rom = abn6507rom.bin
rom_objects = zerop.o i2c.o ssd1306.o serial.o abn6507rom.o

default: $(rom)

$(rom): $(rom_objects)
	$(LD) -o $@ $(rom_objects) -C memmap.cfg -Ln $(basename $@).map

%.o: %.s
	$(AS) -vvv --cpu 6502 -l $(basename $<).lst -o $@ $<

clean:
	@rm -f *.lst *.map *.o *.bin

.PHONY: clean

.PRECIOUS: %.o