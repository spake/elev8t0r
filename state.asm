.equ STATE_WAITING = 0
.equ STATE_MOVING_UP = 1
.equ STATE_MOVING_DOWN = 2
.equ STATE_DOOR_OPENING = 3
.equ STATE_DOOR_OPEN = 4
.equ STATE_DOOR_CLOSING = 5

.equ NUM_FLOORS = 10

.dseg
FloorRequest:
    .byte 10
.cseg

state_init:
    push r17
    push r18
    push XH
    push XL

    loadX FloorRequest

    ldi r18, 0
    ldi r17, NUM_FLOORS
    loadX FloorRequest
state_init_loop:
    cpi r17, 0
    breq state_init_end
    st X+, r18
    dec r17
    rjmp state_init_loop

state_init_end:
    pop XL
    pop XH
    pop r18
    pop r17
    ret

state_update_lcd:
    push r16
    push r17
    push r18

    ;rcall lcd_clear_display

    mov r16, Floor
    ldi r17, 5
    ldi r18, 0
    rcall lcd_load_intermediary_bigchar

    mov r16, Floor
    inc r16
    ldi r17, 5
    ldi r18, 4
    rcall lcd_load_intermediary_bigchar

    pop r18
    pop r17
    pop r16
    ret

state_update_requests:
    push r17
    push ZL
    push ZH

    ldi r16, KEY_0
    loadZ FloorRequest
state_update_requests_key_loop:
    rcall keypad_is_released
    brne state_update_requests_key_loop_next

    dbgprintln "got_request"
    DBGREG(r16)

    ldi r17, 1
    st Z, r17

state_update_requests_key_loop_next:
    cpi r16, KEY_9
    breq state_update_requests_end

    adiw ZH:ZL, 1
    inc r16
    rjmp state_update_requests_key_loop


state_update_requests_end:

;    rcall floors_requested
;    brne tt
;    dbgprintln "floors_requested!!"
;tt:
    pop ZH
    pop ZL
    pop r17
    ret

state_update:
    cpi State, STATE_WAITING
    breq_long do_state_waiting
    cpi State, STATE_MOVING_UP
    breq_long do_state_moving_up
    cpi State, STATE_MOVING_DOWN
    breq_long do_state_moving_down
    cpi State, STATE_DOOR_OPENING
    breq_long do_state_door_opening
    cpi State, STATE_DOOR_OPEN
    breq_long do_state_door_open
    cpi State, STATE_DOOR_CLOSING
    breq_long do_state_door_closing
    ret


run_move:
    cpi16 MoveTimer, 2000
    brlt run_move_end

    add Floor, r16

    rcall to_door_opening

run_move_end:
    ret

emergency_halt:
    ; TODO
    ret

; r16 = start floor
; r17 = end floor
floors_range_requested:
    push r18
    push r19
    push XH
    push XL

    mov r18, r16
    loadX FloorRequest

floors_range_requested_loop:
    cp r18, r17
    breq floors_range_requested_false

    ld r19, X+
    inc r18

    cpi r19, 1
    brne floors_range_requested_loop

    sez
    rjmp floors_range_requested_end

floors_range_requested_false:
    clz
floors_range_requested_end:
    pop XL
    pop XH
    pop r19
    pop r18
    ret



floors_requested:
    push r17
    ldi r16, 0
    ldi r17, NUM_FLOORS
    rcall floors_range_requested
    pop r17
    ret

floors_above_requested:
    push r17
    mov r16, Floor
    ldi r17, NUM_FLOORS
    rcall floors_range_requested
    pop r17
    ret

floors_below_requested:
    push r17
    ldi r16, 0
    mov r17, Floor
    rcall floors_range_requested
    pop r17
    ret

to_waiting:
    dbgprintln "-> STATE_WAITING"
    ldi State, STATE_WAITING
    ret

to_moving_down:
    dbgprintln "-> STATE_MOVING_DOWN"
    ldi State, STATE_MOVING_DOWN
    clear16 MoveTimer
    ret

to_moving_up:
    dbgprintln "-> STATE_MOVING_UP"
    ldi State, STATE_MOVING_UP
    clear16 MoveTimer
    ret

to_door_opening:
    dbgprintln "-> STATE_DOOR_OPENING"
    ldi State, STATE_DOOR_OPENING
    clear16 DoorOpeningTimer
    ret

to_door_open:
    dbgprintln "-> STATE_DOOR_OPEN"
    ldi State, STATE_DOOR_OPEN
    clear16 DoorOpenTimer
    ret

to_door_closing:
    dbgprintln "-> STATE_DOOR_CLOSING"
    ldi State, STATE_DOOR_CLOSING
    clear16 DoorClosingTimer
    ret

; STATE_WAITING
do_state_waiting:
    cpi Emergency, 1
    breq_long to_moving_down
    
    rcall floors_above_requested
    breq_long to_moving_up
    
    rcall floors_below_requested
    breq_long to_moving_down

    ret

; STATE_MOVING_UP
do_state_moving_up:
    cpi Emergency, 1
    breq_long to_moving_down

    rcall floors_requested
    brne_long to_waiting

    rcall floors_above_requested
    brne_long to_moving_down

    ldi r16, 1
    rcall run_move
    ret

; STATE_MOVING_DOWN
do_state_moving_down:
    cpi Emergency, 1
    breq do_state_moving_down_emergency

    rcall floors_requested
    brne_long to_waiting

    rcall floors_below_requested
    brne_long to_moving_down

do_state_moving_down_move:
    ldi r16, -1
    rcall run_move
    ret

do_state_moving_down_emergency:
    cpi Floor, 0
    breq_long to_door_opening
    rjmp do_state_moving_down_move



; STATE_DOOR_OPENING
do_state_door_opening:
    cpi Emergency, 1
    brne do_state_door_opening_check_open

    cpi Floor, 0
    breq do_state_door_opening_check_open

    rjmp to_door_closing

do_state_door_opening_check_open:
    cpi16 DoorOpeningTimer, 1000
    brlt do_state_door_opening_not_open

    cpi Emergency, 1
    breq_long emergency_halt

    rjmp to_door_open

do_state_door_opening_not_open:
    ret


; STATE_DOOR_OPEN
do_state_door_open:
    ; TODO: close button
    cpi16 DoorOpenTimer, 3000
    brge_long to_door_closing
    ret

; STATE_DOOR_CLOSING
do_state_door_closing:
    cpi16 DoorClosingTimer, 1000
    brge_long to_waiting
    ret





