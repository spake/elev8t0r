.include "m2560def.inc"

.dseg
Msec1:
    .byte 2

.cseg
.org 0
    jmp RESET
.org OC0Aaddr
    jmp timer0_handler
    jmp RESET

.include "macros.asm"
.include "lcd.asm"
.include "math.asm"
.include "sleep.asm"
.include "state.asm"
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
    dbgprintln "Starting up"

    ; set up other things
    rcall lcd_init
    rcall timer_init
    
    ; enable interrupts
    sei

    ; print demo strings to lcd
    loadZ CODE(welcome_str_1)
    rcall lcd_puts

    rcall lcd_set_line_2

    loadZ CODE(welcome_str_2)
    rcall lcd_puts

    ; initialise state
    store8 State, 0

    ; initialise current floor
    store8 CurrentFloor, 0

    dbgprintln "Entering state loop"

    rcall update_lcd

main_loop:
    rjmp main_loop

wait_loop:
    load16X Msec1
    cpi16X 1000
    brlt wait_loop

wait_ping:
    clear16 Msec1
    dbgprintln "ping"
    DBGREG(XH)
    DBGREG(XL)
    rjmp wait_loop

welcome_str_1: .db "    elev8t0r    ", 0
welcome_str_2: .db "   by Group F6  ", 0
