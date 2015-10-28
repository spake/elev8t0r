.equ STATE_WAITING = 0
.equ STATE_MOVING_UP = 1
.equ STATE_MOVING_DOWN = 2
.equ STATE_DOOR_OPENING = 3
.equ STATE_DOOR_OPEN = 4
.equ STATE_DOOR_CLOSING = 5

update_lcd:
    rcall lcd_clear_display

    lcdprint "Floor: "

    mov r16, Floor
    rcall lcd_draw_number

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


run_move:
    ; TODO
    ret

emergency_halt:
    ; TODO
    ret

floors_requested:
    ; TODO
    sez
    ret

floors_requested_above:
    ; TODO
    clz
    ret

floors_requested_below:
    ; TODO
    clz
    ret

to_waiting:
    ldi State, STATE_WAITING
    ret

to_moving_down:
    ldi State, STATE_MOVING_DOWN
    ret

to_moving_up:
    ldi State, STATE_MOVING_UP
    ret

to_door_opening:
    ldi State, STATE_DOOR_OPENING
    clear16 DoorOpeningTimer
    ret

to_door_open:
    ldi State, STATE_DOOR_OPEN
    clear16 DoorOpenTimer
    ret

to_door_closing:
    ldi State, STATE_DOOR_CLOSING
    clear16 DoorClosingTimer
    ret

; STATE_WAITING
do_state_waiting:
    cpi Emergency, 1
    breq to_moving_down
    
    rcall floors_requested_above
    breq to_moving_up
    
    rcall floors_requested_below
    breq to_moving_down

    ret

; STATE_MOVING_UP
do_state_moving_up:
    cpi Emergency, 1
    breq to_moving_down

    rcall floors_requested
    brne_long to_waiting

    rcall floors_requested_above
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

    rcall floors_requested_below
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





