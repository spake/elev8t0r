.equ STROBE_PIN = 1 ; PA3

strobe_init:
    sbi DDRA, STROBE_PIN
    ret

.macro strobe_on
    sbi PORTA, STROBE_PIN
.endmacro

.macro strobe_off
    cbi PORTA, STROBE_PIN
.endmacro
