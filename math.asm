
divide:
    ; takes two numbers r16 and r17
    ; sets r16 := r16 / r17, r17 := r16 % r17

    push r18
    ldi r18, 0 ; stores r16 / r17

divide_loop:
    cp r16, r17
    brlo divide_finish
    inc r18
    sub r16, r17
    rjmp divide_loop

divide_finish:
    mov r17, r16 ; r16 % r17
    mov r16, r18 ; r16 / r17

    pop r18
    ret


.include "avr200.asm"

divide16:
    push drem16uL
    push drem16uH
    push dres16uL
    push dres16uH
    push dd16uL  
    push dd16uH  
    push dv16uL  
    push dv16uH  
    push dcnt16u

    mov dd16uH, ZH
    mov dd16uL, ZL
    mov dv16uH, YH
    mov dv16uL, YL

    rcall div16u

    mov ZH, dres16uH
    mov ZL, dres16uL

    pop dcnt16u
    pop dv16uH  
    pop dv16uL  
    pop dd16uH  
    pop dd16uL  
    pop dres16uH
    pop dres16uL
    pop drem16uH
    pop drem16uL
    ret
