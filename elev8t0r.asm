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
    rcall uart_init
    dbgprintln "Starting up"

    ; set up other things
    rcall lcd_init
    rcall timer_init
    rcall keypad_init
    rcall strobe_init
    rcall motor_init
    rcall leds_init
    rcall pushbutton_init
    rcall state_init

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
    rcall state_fix_lcd
    dbgprintln "Entering state loop"

main_loop:
    rcall keypad_update
    rcall leds_update
    rcall pushbutton_update
    rcall state_update_lcd
    rcall state_update_requests
    rcall state_update
    rcall sleep_5ms

main_loop_end:
    rjmp main_loop
