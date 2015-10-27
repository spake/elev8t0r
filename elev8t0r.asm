.include "m2560def.inc"

.org 0
    jmp RESET

.include "macros.asm"
.include "lcd.asm"
.include "math.asm"
.include "sleep.asm"
.include "uart.asm"

RESET:
    ; initialise stack
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    ; set up things
    rcall setup_lcd
    rcall uart_init

    ; print demo strings to lcd
    loadZ CODE(welcome_str_1)
    rcall lcd_puts

    rcall lcd_set_line_2

    loadZ CODE(welcome_str_2)
    rcall lcd_puts

    debugstr "Welcome..."
    debugstr "...to the world of tomorrow!"

halt:
    rjmp halt

welcome_str_1: .db "    elev8t0r    ", 0
welcome_str_2: .db "   by Group F6  ", 0
