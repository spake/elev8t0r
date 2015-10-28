.equ MOTOR_PIN = 1 ; PB2

motor_init:
    sbi DDRB, MOTOR_PIN
    ret

.macro motor_on
    sbi PORTB, MOTOR_PIN
.endmacro

.macro motor_off
    cbi PORTB, MOTOR_PIN
.endmacro
