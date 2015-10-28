.include "m2560def.inc"

.dseg
Msec1:
    .byte 2
FloorTimer:
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
.include "motor.asm"
.include "sleep.asm"
.include "strobe.asm"
.include "timer.asm"
.include "uart.asm"
.include "keypad.asm"

.def State = r19
.def Floor = r20
.def Emergency = r21

.include "state.asm"

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
    rcall keypad_init
    rcall strobe_init
    rcall motor_init

    ; enable interrupts
    sei

main:
    ldi State, 0
    ldi Floor, 0
    ldi Emergency, 0

    ; do initial LCD update
    rcall update_lcd

    dbgprintln "Entering state loop"

main_loop:
    rcall keypad_update

main_loop_end:
    rjmp main_loop

welcome_str_1: .db "    elev8t0r    ", 0
welcome_str_2: .db "   by Group F6  ", 0
