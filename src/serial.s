.importzp inb, outb, stringp

.export serial_tx, serial_rx, delay_long, delay_short, qsdelay

.include "riot.s"

BAUDRATE=9600 ; Max 9600
BAUDSTEP=9600 / BAUDRATE - 1; Must be an integer

wait_getserial:
  lda #$02            ; Set bit 1 for serial TX (Output), clear bit 0 for serial RX (Input)
  sta DDRA            ; Store to configure port direction
wait_getserial2:
  lda DRA ; Check serial 3c
  and #$01 ; 2c
  bne wait_getserial2 ; 2c
  jsr serial_rx ; Get character
rts

qsdelay:
lda #244
sta WTD1KDI ; 244 * 1024 = 249856 ~= quarter second
waitqs:
lda READTDI
bne waitqs ; Loop until timer runs out
rts

; jsr = 6 cycles
; sta (zp) = 3 cycles
; (WTD8DI -1) * 8 cycles
; We can ignore branches while timer not 0
;lda (zp) = 3 cycles
; bne = 2 cycles (not taken since timer expired)
; rts = 6 cycles
; = 20 + ((WTD8DI - 1) * 8) cycles

delay_short:
sta WTD8DI ; Divide by 8 = A contains ticks to delay/8
shortwait:
nop; Sample every 8 cycles instead of every 6
lda READTDI
bne shortwait
rts

delay_long:
sta WTD1KDI
wait1k:
lda READTDI
bne wait1k ; Loop until timer runs out
rts

;Returns byte in A - assumes 9600 baud = ~104us/bit, 1 cycle = 1us (1 MHz)
;We should call this ASAP when RX pin goes low - let's assume it just happened (13 cycles ago)
serial_rx:
;Minimum 13 cycles before we get here
lda #(15+19*BAUDSTEP) ; 1.5 period-ish ; 2 cycles - 15 for 9600 baud, 34 for 4800
jsr delay_short ; 140c
ldx #8 ; 2 cycles
;149 cycles to get here
serial_rx_loop: ;103 cycles
lda DRA ; Read RX bit 0 ; 3 cycles
lsr ; Shift received bit into carry - in many cases might be safe to just lsr DRA ; 2 cycles
ror inb ; Rotate into MSB 5 cycles
lda #(9+13*BAUDSTEP) ; 2 cycles ;9 for 9600 baud, 22 for 4800 baud (add 104us == 104 / 8 = 13)
jsr delay_short ; Delay until middle of next bit - overhead; 84 cycles
nop ; 2c
dex ; 2c
bne serial_rx_loop ; 3 cycles
;Should already be in the middle of the stop bit
; We can ignore the actual stop bit and use the time for other things
; Received byte in inb
lda inb ; Put in A
rts

serial_tx:
sta outb
lda #$fd ; Inverse bit 1
and DRA
sta DRA ; Start bit
lda #(8+13*BAUDSTEP) ; 2c ; 9600 = 8, 4800 = 21
jsr delay_short ; 20 + (8-1)*8 = 76c ; Start bit total 104 cycles - 104 cycles measured
nop ; 2c
nop ; 2c
ldx #8 ; 2c
serial_tx_loop:
lsr outb ; 5c
lda DRA ; 3c
bcc tx0 ; 2/3c
ora #2 ; TX bit is bit 1 ; 2c
bcs bitset ; BRA 3c
tx0:
nop ; 2c
and #$fd ; 2c
bitset:
sta DRA ; 3c
; Delay one period - overhead ; 101c total ; 103c measured
lda #(8+13*BAUDSTEP) ; 2c ; 9600 8, 4800 21
jsr delay_short ; 20 + (8-1)*8 = 76c
nop; 2c fix
dex ; 2c
bne serial_tx_loop ; 3c
nop; 2c ; Last bit 98us counted, 100us measured
nop; 2c
nop; 2c
nop; 2c
lda DRA ;3c
ora #2 ; 2c
sta DRA ; Stop bit 3c
lda #(8+13*BAUDSTEP) ; 2c ; 9600 8, 4800 21
jsr delay_short
rts

serial_wstring:
ldy #0
txstringloop:
lda (stringp),y
beq stringtxd
jsr serial_tx
iny
bne txstringloop
stringtxd:
rts ; In case of overflow
