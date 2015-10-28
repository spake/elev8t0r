.include "m2560def.inc"

.dseg
Msec1:
    .byte 2

.cseg
.org 0
    jmp RESET
.org OC0Aaddr
    jmp timer0OC
    jmp RESET

.include "macros.asm"
.include "lcd.asm"
.include "math.asm"
.include "sleep.asm"
.include "timer.asm"
.include "uart.asm"

RESET:
    ; initialise stack
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    ; initialise uart for debugging
    rcall uart_init
    debugstr "Starting up"

    ; set up other things
    rcall setup_lcd
    rcall setup_timer
    
    ; enable interrupts
    sei

    ; print demo strings to lcd
    loadZ CODE(welcome_str_1)
    rcall lcd_puts

    rcall lcd_set_line_2

    loadZ CODE(welcome_str_2)
    rcall lcd_puts

    debugstr "Waiting for Msec1 to be non-zero"
loop:
    load16 Msec1

    cpi XH, 4
    brge loop_print

    rjmp loop
loop_print:
    debugstr "ping"

    clr XL
    clr XH
    store16 Msec1

    rjmp loop

halt:
    rjmp halt

welcome_str_1: .db "    elev8t0r    ", 0
welcome_str_2: .db "   by Group F6  ", 0
