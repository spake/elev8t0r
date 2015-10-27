.include "m2560def.inc"

.org 0
    jmp RESET

.include "lcd.asm"
.include "macros.asm"
.include "math.asm"
.include "sleep.asm"

RESET:
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    rcall setup_lcd

    loadZCode welcome_str_1
    rcall lcd_puts

    rcall lcd_set_line_2

    loadZCode welcome_str_2
    rcall lcd_puts

halt:
    rjmp halt

welcome_str_1: .db "    elev8t0r    ", 0
welcome_str_2: .db "   by Group F6  ", 0
