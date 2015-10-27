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

; writes a string to the UART, followed by a newline
; input: Z, addr of null-terminated string in code segment
uart_println:
    push r16

    rcall uart_puts

    ldi r16, '\r'
    rcall uart_putc
    ldi r16, '\n'
    rcall uart_putc

    pop r16
    ret
