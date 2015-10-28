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

main:
    ; initialise state
    ldi State, 0

    ; initialise current floor
    ldi CurrentFloor, 0

    ; do initial LCD update
    rcall update_lcd

    dbgprintln "Entering state loop"

main_loop:

    ; check if moving
    sbrs State, STATE_MOVING
    rjmp main_loop_moving_done
main_loop_moving:
    ; check if 2 seconds has elapsed
    load16X FloorTimer
    cpi16X 2000
    brlt main_loop

    ; reset floor timer
    clear16 FloorTimer

    ; time to move
    inc CurrentFloor

    ; set not moving any more
    cbr State, (1 << STATE_MOVING)

    rcall update_lcd
main_loop_moving_done:


main_loop_end:
    rjmp main_loop

welcome_str_1: .db "    elev8t0r    ", 0
welcome_str_2: .db "   by Group F6  ", 0
