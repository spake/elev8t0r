
.equ KEY_0 = 0
.equ KEY_1 = 1
.equ KEY_2 = 2
.equ KEY_3 = 3
.equ KEY_4 = 4
.equ KEY_5 = 5
.equ KEY_6 = 6
.equ KEY_7 = 7
.equ KEY_8 = 8
.equ KEY_9 = 9
.equ KEY_A = 10
.equ KEY_B = 11
.equ KEY_C = 12
.equ KEY_D = 13
.equ KEY_STAR = 14
.equ KEY_HASH = 15
.equ KEY_LEN = 16
.equ KEY_NONE = 255

.def row = r16              ; current row number
.def col = r17              ; current column number
.def rmask = r18            ; mask for current row during scan
.def cmask = r19            ; mask for current column during scan
.def temp1 = r20 
.def temp2 = r21

.equ PORTLDIR = 0xF0        ; PH7-4: output, PH3-0, input
.equ INITCOLMASK = 0xEF     ; scan from the rightmost column,
.equ INITROWMASK = 0x01     ; scan from the top row
.equ ROWMASK = 0x0F         ; for obtaining input from Port L

.dseg
keypad_v:
    .byte 1
keypad_last_v:
    .byte 1
.cseg

keypad_init:
    push r16

    ldi r16, PORTLDIR   ; PB7:4/PB3:0, out/in
    sts DDRL, r16

    ser r16
    out DDRC, r16
    out PORTC, r16

    store8 keypad_v, KEY_NONE

    pop r16
    ret

keypad_is_released:
    push XL

    load8X keypad_last_v
    cp XL, r16
    brne keypad_is_released_false

    load8X keypad_v
    cp XL, r16
    breq keypad_is_released_false

    sez
    rjmp keypad_is_released_end

keypad_is_released_false:
    clz
keypad_is_released_end:
    pop XL
    ret

keypad_update:
    push row
    push col
    push rmask
    push cmask
    push temp2
    push temp1
    push XL

    load8X keypad_v
    store8X keypad_last_v
    store8 keypad_v, KEY_NONE

keypad_update_swap_loop_done:

    ldi cmask, INITCOLMASK      ; initial column mask
    clr col                     ; initial column

keypad_update_colloop:
    cpi col, 4
    brne keypad_update_scan_column

    rjmp keypad_update_end      ; If all keys are scanned, exit

keypad_update_scan_column:
    sts PORTL, cmask            ; Otherwise, scan a column.
  
    ldi temp1, 0xFF             ; Slow down the scan operation.

keypad_update_delay:
    dec temp1
    brne keypad_update_delay    ; until temp1 is zero? - delay

    lds temp1, PINL             ; Read PORTL
    andi temp1, ROWMASK         ; Get the keypad output value
    cpi temp1, 0xF              ; Check if any row is low
    breq keypad_update_nextcol  ; if not - switch to next column

                                ; If yes, find which row is low
    ldi rmask, INITROWMASK      ; initialize for row check
    clr row

; and going into the row loop
keypad_update_rowloop:
    cpi row, 4                  ; is row already 4?
    breq keypad_update_nextcol  ; the row scan is over - next column
    mov temp2, temp1
    and temp2, rmask            ; check un-masked bit
    breq keypad_update_convert  ; if bit is clear, the key is pressed
    inc row                     ; else move to the next row
    lsl rmask
    jmp keypad_update_rowloop
    
keypad_update_nextcol:          ; if row scan is over
     lsl cmask
     inc col                    ; increase col value
     jmp keypad_update_colloop  ; go to the next column
     
keypad_update_convert:
    cpi col, 3                  ; If the pressed key is in col 3
    breq keypad_update_letters  ; we have letter
    
                                ; If the key is not in col 3 and
    cpi row, 3                  ; if the key is in row 3,
    breq keypad_update_symbols  ; we have a symbol or 0
    
    mov temp1, row              ; otherwise we have a number 1-9
    lsl temp1
    add temp1, row
    add temp1, col
    inc temp1                   ; temp1 = row*3 + col + 1
    jmp keypad_update_convert_end
    
keypad_update_letters:
    ldi temp1, KEY_A
    add temp1, row              ; Get the value for the key
    jmp keypad_update_convert_end

keypad_update_symbols:
    cpi col, 0                  ; Check if we have a star
    breq keypad_update_star
    cpi col, 1                  ; or if we have zero
    breq keypad_update_zero
    ldi temp1, KEY_HASH         ; if not we have hash
    jmp keypad_update_convert_end
keypad_update_star:
    ldi temp1, KEY_STAR         ; set to star
    jmp keypad_update_convert_end
keypad_update_zero:
    ldi temp1, 0                ; set to zero

keypad_update_convert_end:
    ; dbgprintln "keypad press"
    ; DBGREG(temp1)
    mov XL, temp1
    store8X keypad_v

keypad_update_end:
    pop XL
    pop temp1
    pop temp2
    pop cmask
    pop rmask
    pop col
    pop row
    ret



.undef row
.undef col
.undef rmask
.undef cmask
.undef temp1 
.undef temp2
