.include "m2560def.inc"

.dseg
DoorOpeningTimer:
    .byte 2
DoorOpenTimer:
    .byte 2
DoorClosingTimer:
    .byte 2
MoveTimer:
    .byte 2
LedsTimer:
    .byte 2
StrobeTimer:
    .byte 2

.cseg
.org 0
    jmp RESET
.org OC0Aaddr
    jmp timer0_handler
    jmp RESET

.include "font.asm"
.include "macros.asm"
.include "math.asm"
.include "motor.asm"
.include "strobe.asm"
.include "timer.asm"
.include "uart.asm"
.include "keypad.asm"
.include "pushbutton.asm"
.include "leds.asm"
.include "lcd.asm"
.include "sleep.asm"

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
    call uart_init
    dbgprintln "Starting up"

    ; set up other things
    call lcd_init
    call timer_init
    call keypad_init
    call strobe_init
    call motor_init
    call leds_init
    call pushbutton_init
    call state_init

    ; enable interrupts
    sei

main:
    ldi State, STATE_WAITING
    ldi Floor, 0
    ldi Emergency, 0

    ; print welcome messages, hijack timer
    lcd_set_pos 0, 0
    lcdprint "    elev8t0r     "

welcome_loop1:
    cpi16 MoveTimer, 1000
    brlt welcome_loop1

    clear16 MoveTimer

    lcd_set_pos 1, 0
    lcdprint "   by Group F6   "

welcome_loop2:
    cpi16 MoveTimer, 1000
    brlt welcome_loop2

    clear16 MoveTimer

    ; set up LCD properly
    call state_fix_lcd
    dbgprintln "Entering state loop"

main_loop:
    call keypad_update
    call leds_update
    call pushbutton_update
    call state_update_lcd
    call state_update_requests
    call state_update
    call sleep_5ms

main_loop_end:
    rjmp main_loop
