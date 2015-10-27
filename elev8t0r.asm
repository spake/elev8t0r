.include "m2560def.inc"

.org 0
    jmp RESET

.include "sleep.asm"
.include "lcd.asm"

RESET:
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    rcall setup_lcd

    ldi ZH, HIGH(welcome_str_1 << 1)
    ldi ZL, LOW(welcome_str_1 << 1)
    rcall lcd_puts

    rcall lcd_set_line_2

    ldi ZH, HIGH(welcome_str_2 << 1)
    ldi ZL, LOW(welcome_str_2 << 1)
    rcall lcd_puts

halt:
    rjmp halt

welcome_str_1: .db "    elev8t0r    ", 0
welcome_str_2: .db "   by Group F6  ", 0
