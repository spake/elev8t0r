.macro do_lcd_command
    ldi r16, @0
    rcall lcd_command
    rcall lcd_wait
.endmacro
.macro do_lcd_data
    ldi r16, @0
    rcall lcd_data
    rcall lcd_wait
.endmacro

setup_lcd:
    ser r16
    out DDRF, r16
    out DDRA, r16
    clr r16
    out PORTF, r16
    out PORTA, r16

    do_lcd_command 0b00111000 ; 2x5x7
    rcall sleep_5ms
    do_lcd_command 0b00111000 ; 2x5x7
    rcall sleep_1ms
    do_lcd_command 0b00111000 ; 2x5x7
    do_lcd_command 0b00111000 ; 2x5x7
    do_lcd_command 0b00001000 ; display off?
    do_lcd_command 0b00000001 ; clear display
    do_lcd_command 0b00000110 ; increment, no display shift
    do_lcd_command 0b00001100 ; Cursor OFF, bar, no blink

    ret

; write string to LCD
; input: Z, addr of null-terminated string in program memory
lcd_puts:
    push r16
lcd_puts_loop:
    lpm r16, Z+
    cpi r16, 0
    breq lcd_puts_end

    rcall lcd_data
    rcall lcd_wait

    rjmp lcd_puts_loop
lcd_puts_end:
    pop r16
    ret

lcd_clear_display:
    do_lcd_command 0b00000001
    ret

lcd_set_line_2:
	do_lcd_command 0b11000000 ; move cursor to 2nd line
    ret

; draws an 8-bit number to the screen in decimal
; input: r16
lcd_draw_number:
	push r17
	push r18
	push r20

	ldi r18, 0 ; digit count
lcd_draw_number_loop:
	ldi r17, 10

    ; get r16 = (r16 / 10) and r17 = (r16 % 10)
	rcall divide

	ldi r20, '0'
	add r20, r17

    ; push digits (from least to most significant) onto the stack
	push r20
	inc r18

	cpi r16, 0
	breq lcd_draw_number_print
	rjmp lcd_draw_number_loop
lcd_draw_number_print:
	cpi r18, 0
	breq lcd_draw_number_finish

    ; pop digit from stack (from most to least significant) and print
	pop r20
    mov r16, r20
    rcall lcd_data
    rcall lcd_wait

	dec r18
	rjmp lcd_draw_number_print
lcd_draw_number_finish:
	pop r20
	pop r18
	pop r17
	ret

; draws a single digit
draw_digit:
	push r16
	mov r16, r20
	rcall lcd_data
	rcall lcd_wait
	pop r16
	ret

.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.macro lcd_set
    sbi PORTA, @0
.endmacro
.macro lcd_clr
    cbi PORTA, @0
.endmacro

;
; Send a command to the LCD (r16)
;

lcd_command:
    out PORTF, r16
    rcall sleep_1ms
    lcd_set LCD_E
    rcall sleep_1ms
    lcd_clr LCD_E
    rcall sleep_1ms
    ret

lcd_data:
    out PORTF, r16
    lcd_set LCD_RS
    rcall sleep_1ms
    lcd_set LCD_E
    rcall sleep_1ms
    lcd_clr LCD_E
    rcall sleep_1ms
    lcd_clr LCD_RS
    ret

lcd_wait:
    push r16
    clr r16
    out DDRF, r16
    out PORTF, r16
    lcd_set LCD_RW
lcd_wait_loop:
    rcall sleep_1ms
    lcd_set LCD_E
    rcall sleep_1ms
    in r16, PINF
    lcd_clr LCD_E
    sbrc r16, 7
    rjmp lcd_wait_loop
    lcd_clr LCD_RW
    ser r16
    out DDRF, r16
    pop r16
    ret
