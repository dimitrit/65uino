; Zero Page definitions

.exportzp i2caddr, inb, outb, xtmp, stringp, mode, rxcnt, txcnt, runpnt, cursor, scroll, tflags, serialbuf

.segment "ZEROPAGE"

.org $0

i2caddr:   .res 1 ; Reserve 1 byte for I2CADDR
inb:       .res 1 ; Reserve 1 byte for inb - Used for Serial and I2C
outb:      .res 1 ; Reserve 1 byte for outb - Used for Serial and I2C
xtmp:      .res 1 ; Reserve 1 byte for xtmp
stringp:   .res 2 ; Reserve 2 bytes for stringp (stringp + 1)
;Stringp +1 free for temp.
mode:      .res 1 ; Reserve 1 byte for mode
rxcnt:     .res 1 ; Reserve 1 byte for rxcnt
txcnt:     .res 1 ; Reserve 1 byte for txcnt
runpnt:    .res 2 ; Reserve 2 bytes for runpnt
cursor:    .res 1 ; Reserve 1 byte for cursor ; SSD1306
scroll:    .res 1 ; Reserve 1 byte for scroll ; SSD1306
tflags:    .res 1 ; Reserve 1 byte for tflags ; SSD1306
serialbuf: .res 0 ; Reserve 1 byte for serialbuf - Used for text display and userland program storage
