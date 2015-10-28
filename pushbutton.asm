.equ PB0_PIN = 0
.equ PB1_PIN = 1

.dseg
pb0_v:
    .byte 1
pb0_last_v:
    .byte 1
pb1_v:
    .byte 1
pb1_last_v:
    .byte 1
.cseg

pushbutton_init:
    push r16
    clr r16
    out DDRD, r16 ; set PORT D as input
    ser r16
    out PORTD, r16

    store8 pb0_v, 0
    store8 pb0_last_v, 0
    store8 pb1_v, 0
    store8 pb1_last_v, 0

    pop r16
    ret


pushbutton_0_down:
    push r16
    load8R r16, pb0_v
    cpi r16, 1
    pop r16

pushbutton_1_down:
    push r16
    load8R r16, pb1_v
    cpi r16, 1
    pop r16

.macro pushbutton_cmp_vals
    push r16
    load8R r16, @0
    cpi r16, 1
    brne pushbutton_cmp_vals_false
    load8R r16, @1
    cpi r16, 1
    breq pushbutton_cmp_vals_false

    sez
    rjmp pushbutton_cmp_vals_end

pushbutton_cmp_vals_false:
    clz
pushbutton_cmp_vals_end:
    pop r16
.endmacro


pushbutton_0_pressed:
    pushbutton_cmp_vals pb0_v, pb0_last_v
    ret

pushbutton_1_pressed:
    pushbutton_cmp_vals pb1_v, pb1_last_v
    ret

pushbutton_0_released:
    pushbutton_cmp_vals pb0_last_v, pb0_v
    ret

pushbutton_1_released:
    pushbutton_cmp_vals pb1_last_v, pb1_v
    ret

pushbutton_update:
    push r16
    
    load8R r16, pb0_v
    store8R pb0_last_v, r16
    load8R r16, pb1_v
    store8R pb1_last_v, r16
    
    store8 pb0_v, 0
    store8 pb1_v, 0

    sbis PIND, PB0_PIN
    rjmp pushbutton_update_pb0_down

pushbutton_update_pb1_test:
    sbis PIND, PB1_PIN
    rjmp pushbutton_update_pb1_down

pushbutton_update_end:
    pop r16
    ret

pushbutton_update_pb0_down:
    store8 pb0_v, 1
    rjmp pushbutton_update_pb1_test

pushbutton_update_pb1_down:
    store8 pb1_v, 1
    rjmp pushbutton_update_end
