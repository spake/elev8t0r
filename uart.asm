.equ BAUD = 9600
.equ MYUBRR = (F_CPU/8/BAUD-1)

; initialises the chip's UART
uart_init:
    push r16

    ; set baud rate
    ldi r16, HIGH(MYUBRR)
    sts UBRR0H, r16

    ldi r16, LOW(MYUBRR)
    sts UBRR0L, r16

    ldi r16, (1 << U2X0)
    sts UCSR0A, r16

    ; transmit only
    ldi r16, (1 << TXEN0)
    sts UCSR0B, r16

    ; 8 data bits, 1 stop bit
    ldi r16, (3 << UCSZ00)
    sts UCSR0C, r16

    pop r16
    ret

; writes a single character to the UART
; input: r16, the character
uart_putc:
    push r17

uart_putc_loop:
    ; loop until ready to transmit
    lds r17, UCSR0A
    sbrs r17, UDRE0
    rjmp uart_putc_loop

    ; send char
    sts UDR0, r16

    pop r17
    ret

; writes a string to the UART
; input: Z, addr of null-terminated string in code segment
uart_puts:
    push r16

uart_puts_loop:
    lpm r16, Z+
    cpi r16, 0
    breq uart_puts_end

    ; write char
    rcall uart_putc
    rjmp uart_puts_loop

uart_puts_end:
    pop r16
    ret

uart_newline:
    push r16

    ldi r16, '\r'
    rcall uart_putc
    ldi r16, '\n'
    rcall uart_putc

    pop r16
    ret

; writes a string to the UART, followed by a newline
; input: Z, addr of null-terminated string in code segment
uart_println:
    push r16

    rcall uart_puts
    rcall uart_newline

    pop r16
    ret

; draws an 8-bit number to the screen in decimal
; input: r16
uart_print_number:
    push r17
    push r18
    push r20

    ldi r18, 0 ; digit count
uart_print_number_loop:
    ldi r17, 10

    ; get r16 = (r16 / 10) and r17 = (r16 % 10)
    rcall divide

    ldi r20, '0'
    add r20, r17

    ; push digits (from least to most significant) onto the stack
    push r20
    inc r18

    cpi r16, 0
    breq uart_print_number_print
    rjmp uart_print_number_loop
uart_print_number_print:
    cpi r18, 0
    breq uart_print_number_finish

    ; pop digit from stack (from most to least significant) and print
    pop r20
    mov r16, r20
    rcall uart_putc

    dec r18
    rjmp uart_print_number_print
uart_print_number_finish:
    pop r20
    pop r18
    pop r17
    ret
