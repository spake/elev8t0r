timer_init:
    push r16

    ldi r16, 0
    out TCCR0A, r16

    ; tick every 0.004ms
    ; i.e. 250 ticks = 1ms
    ldi r16, 0b00000011
    out TCCR0B, r16

    ldi r16, 250
    out OCR0A, r16

    ldi r16, 1 << OCIE0A
    sts TIMSK0, r16

    pop r16
    ret

timer0_handler:
    ; save regs
    push r16

    ; save SREG
    in r16, SREG
    push r16

    inc16 LedsTimer

    ; restore SREG
    pop r16
    out SREG, r16

    ; restore regs
    pop r16
    reti
