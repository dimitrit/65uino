target = abn6507rom.bin

default: all

all: $(target)

%.bin: %.o
	ld65 -o $@ $< -C memmap.cfg

%.o: %.s
	ca65 -vvv --cpu 6502 -l $(basename $<).lst -o $@ $<

clean:
	@rm -f *.lst *.o *.bin

.PHONY: clean

.PRECIOUS: %.o