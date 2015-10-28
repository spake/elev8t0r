.dseg
LedPrevState:
    .byte 1
LedCounter:
    .byte 1

.cseg

.equ LED_STATE_UP = 1
.equ LED_STATE_DOWN = 2
.equ LED_STATE_OPEN = 3
.equ LED_STATE_CLOSE = 4

leds_init:
    push r16

    ser r16
    out DDRC, r16
    clr r16
    out PORTC, r16

    pop r16
    ret

leds_update:
    push r16
    push r17
    push r18

    cpi16 LedsTimer, 167
    brlt_long leds_update_done ; not yet due for an update

    clear16 LedsTimer ; reset timer

    load8R r17, LedPrevState

    cpi State, STATE_MOVING_UP
    breq leds_update_state_moving_up
    cpi State, STATE_MOVING_DOWN
    breq leds_update_state_moving_down
    cpi State, STATE_DOOR_OPENING
    breq leds_update_state_door_open
    cpi State, STATE_DOOR_OPEN
    breq leds_update_state_door_open
    cpi State, STATE_DOOR_CLOSING
    breq leds_update_state_door_close
    cpi State, STATE_WAITING
    breq leds_update_state_door_close

    ; bad state
    rjmp leds_update_done

leds_update_state_moving_up:
    ldi r16, LED_STATE_UP
    rjmp leds_update_state_check
leds_update_state_moving_down:
    ldi r16, LED_STATE_DOWN
    rjmp leds_update_state_check
leds_update_state_door_open:
    ldi r16, LED_STATE_OPEN
    rjmp leds_update_state_check
leds_update_state_door_close:
    ldi r16, LED_STATE_CLOSE

leds_update_state_check:
    cpi r16, LED_STATE_UP
    breq leds_update_moving
    cpi r16, LED_STATE_DOWN
    breq leds_update_moving
    cpi r16, LED_STATE_OPEN
    breq leds_update_door
    cpi r16, LED_STATE_CLOSE
    breq leds_update_door

leds_update_moving:
    cp r16, r17
    brne leds_update_moving_setup

    ; r18 holds LedCounter value
    load8R r18, LedCounter
    rjmp leds_update_moving_do

leds_update_moving_setup:
    ldi r18, 0
    store8R LedPrevState, r16

leds_update_moving_do:
    ; update counter
    inc r18
    cpi r18, 8
    brlt leds_update_moving_write

    ; wrap around counter
    ldi r18, 0

leds_update_moving_write:
    ; update counter in memory
    store8R LedCounter, r18

    ; flip things around if we're moving down
    cpi r16, LED_STATE_DOWN
    brne leds_update_moving_write2

    ; r18 := 7 - r18
    com r18
    ldi r17, 8
    add r18, r17

leds_update_moving_write2:
    mov r16, r18
    rcall rotate
    out PORTC, r16

    rjmp leds_update_done

leds_update_door:
    cp r16, r17
    brne leds_update_door_setup

    ; r18 holds LedCounter value
    load8R r18, LedCounter
    rjmp leds_update_door_do

leds_update_door_setup:
    ldi r18, 0
    store8R LedPrevState, r16
    rjmp leds_update_door_write

leds_update_door_do:
    ; check counter, increment if we haven't hit 3 yet
    cpi r18, 3
    breq leds_update_door_write
    inc r18

leds_update_door_write:
    ; update counter in memory
    store8R LedCounter, r18

    ; flip things around if we're opening
    cpi r16, LED_STATE_OPEN
    brne leds_update_door_write2

    ; r18 := 3 - r18
    com r18
    ldi r17, 4
    add r18, r17

leds_update_door_write2:
    ; set appropriate pattern in r16
    cpi r18, 0
    breq leds_update_door_pattern0
    cpi r18, 1
    breq leds_update_door_pattern1
    cpi r18, 2
    breq leds_update_door_pattern2

leds_update_door_pattern3:
    ldi r16, 0b11111111
    rjmp leds_update_door_write3
leds_update_door_pattern2:
    ldi r16, 0b11100111
    rjmp leds_update_door_write3
leds_update_door_pattern1:
    ldi r16, 0b11000011
    rjmp leds_update_door_write3
leds_update_door_pattern0:
    ldi r16, 0b10000001

leds_update_door_write3:
    out PORTC, r16

leds_update_done:
    pop r18
    pop r17
    pop r16
    ret

; input: number n, 0 <= n <= 7, in r16
; output: (1 << n), in r16
rotate:
    push r17

    ldi r17, 1
rotate_loop:
    cpi r16, 0
    breq rotate_done

    lsl r17
    dec r16
    rjmp rotate_loop

rotate_done:
    mov r16, r17
    pop r17
    ret

