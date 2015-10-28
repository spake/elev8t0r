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

lcd_init:
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

    ; enable backlight (PE5)
    sbi DDRE, 3
    sbi PORTE, 3

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

lcd_set_line_1:
    do_lcd_command 0b10000000 ; move cursor to 1st line
    ret

lcd_set_line_2:
	do_lcd_command 0b11000000 ; move cursor to 2nd line
    ret

; sets it to line @0, col @1
.macro lcd_set_pos
    do_lcd_command (0b10000000 | (@0 * 0x40) | (@1 & 0x3F))
.endmacro

; input: Z, addr of bigchar in program memory
;        r16, offset for chars in CGRAM (should be 0 or 4)
;        r17, border setting for bigchar (1 for left, 2 for right, 0 for none)
lcd_load_bigchar:
    push r18
    push r19
    push r20

    mov r20, r16 ; save offset

    ldi r18, 0 ; count the 4 bigchar segments
lcd_load_bigchar_outer:
    cpi r18, 4
    breq lcd_load_bigchar_end

    ; r16 := 0x40 | ((r18 + r20) << 3)
    mov r16, r18
    add r16, r20 ; add offset
    lsl r16
    lsl r16
    lsl r16
    ori r16, 0x40

    rcall lcd_command
    rcall lcd_wait

    ldi r19, 0 ; count the 8 parts of each normal char
lcd_load_bigchar_inner:
    cpi r19, 8
    breq lcd_load_bigchar_inner_end

    lpm r16, Z+

    cpi r17, 1
    breq lcd_load_bigchar_inner_leftborder
    cpi r17, 2
    breq lcd_load_bigchar_inner_rightborder

    rjmp lcd_load_bigchar_inner_draw

lcd_load_bigchar_inner_leftborder:
    cpi r18, 0
    breq lcd_load_bigchar_inner_leftborder_tl
    cpi r18, 2
    breq lcd_load_bigchar_inner_leftborder_bl
    rjmp lcd_load_bigchar_inner_draw

lcd_load_bigchar_inner_leftborder_tl:
lcd_load_bigchar_inner_leftborder_bl:
    ori r16, 0b10000
    rjmp lcd_load_bigchar_inner_draw

lcd_load_bigchar_inner_rightborder:
    cpi r18, 1
    breq lcd_load_bigchar_inner_rightborder_tr
    cpi r18, 3
    breq lcd_load_bigchar_inner_rightborder_br
    rjmp lcd_load_bigchar_inner_draw

lcd_load_bigchar_inner_rightborder_tr:
lcd_load_bigchar_inner_rightborder_br:
    ori r16, 0b00001

lcd_load_bigchar_inner_draw:
    rcall lcd_data
    rcall lcd_wait

    inc r19
    rjmp lcd_load_bigchar_inner

lcd_load_bigchar_inner_end:
    inc r18
    rjmp lcd_load_bigchar_outer

lcd_load_bigchar_end:
    pop r20
    pop r19
    pop r18
    ret

; input: r16, digit to display
;        r17, how far through it should be (0-9, where 5 is centred)
;        r18, offset to pass to lcd_load_bigchar
;        r19, border setting to pass to lcd_load_bigchar
lcd_load_intermediary_bigchar:
    push r16
    push r17
    push r18
    push r19
    push r20
    push ZL
    push ZH

    mov r20, r19 ; save border setting in here

    loadZ CODE(Bigchar_Start)

    ; each bigchar is 32 bytes
    ; 10 intermediary states each: 0 for completely visible, 9 for one col remaining
    ; so each set of intermediary states for a digit takes up 320 bytes

    ldi r19, 0

    ; Z += 320*r16
lcd_load_intermediary_bigchar_loop1:
    cp r19, r16
    breq lcd_load_intermediary_bigchar_loop1_end

    inc ZH      ; Z += 256
    adiw Z, 32  ; Z += 32
    adiw Z, 32  ; Z += 32

    inc r19
    rjmp lcd_load_intermediary_bigchar_loop1
lcd_load_intermediary_bigchar_loop1_end:

    ldi r19, 0

    ; Z += 32*r17
lcd_load_intermediary_bigchar_loop2:
    cp r19, r17
    breq lcd_load_intermediary_bigchar_loop2_end

    adiw Z, 32

    inc r19
    rjmp lcd_load_intermediary_bigchar_loop2
lcd_load_intermediary_bigchar_loop2_end:

    ; finally, load bigchar

    mov r16, r18
    mov r17, r20
    rcall lcd_load_bigchar

    pop ZL
    pop ZH
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
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
    rcall sleep_100us
    lcd_set LCD_E
    rcall sleep_100us
    lcd_clr LCD_E
    rcall sleep_100us
    ret

lcd_data:
    out PORTF, r16
    lcd_set LCD_RS
    rcall sleep_100us
    lcd_set LCD_E
    rcall sleep_100us
    lcd_clr LCD_E
    rcall sleep_100us
    lcd_clr LCD_RS
    ret

lcd_wait:
    push r16
    clr r16
    out DDRF, r16
    out PORTF, r16
    lcd_set LCD_RW
lcd_wait_loop:
    rcall sleep_100us
    lcd_set LCD_E
    rcall sleep_100us
    in r16, PINF
    lcd_clr LCD_E
    sbrc r16, 7
    rjmp lcd_wait_loop
    lcd_clr LCD_RW
    ser r16
    out DDRF, r16
    pop r16
    ret
