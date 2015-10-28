.dseg
State:
    .byte 1
CurrentFloor:
    .byte 1


.cseg

; Elevator direction (1: up, 0: down)
.equ STATE_DIRECTION = 0
; Whether elevator is moving (1: moving, 0: stopped)
.equ STATE_MOVING = 1
; Door status (1: open, 0: closed)
.equ STATE_DOOROPEN = 2
; Whether door is currently opening/closing (1: moving, 0: not moving)
.equ STATE_DOORMOVING = 3
; Emergency mode (1: emergency mode, 0: normal)
.equ STATE_EMERGENCY = 4

update_lcd:
    rcall lcd_clear_display

    lcdprint "Floor: "

    load8X CurrentFloor
    mov r16, XL
    rcall lcd_draw_number

    ret