.include "m2560def.inc"

.org 0
    jmp RESET

.include "lcd.asm"

RESET:
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    rcall setup_lcd

    do_lcd_data 'e'
    do_lcd_data 'l'
    do_lcd_data 'e'
    do_lcd_data 'v'
    do_lcd_data '8'
    do_lcd_data 't'
    do_lcd_data '0'
    do_lcd_data 'r'
    
    do_lcd_command 0b11000000 ; move cursor to 2nd line

    do_lcd_data 'b'
    do_lcd_data 'y'
    do_lcd_data ' '
    do_lcd_data 'G'
    do_lcd_data 'r'
    do_lcd_data 'o'
    do_lcd_data 'u'
    do_lcd_data 'p'
    do_lcd_data ' '
    do_lcd_data 'F'
    do_lcd_data '6'

halt:
    rjmp halt
