.macro loadZ
    ldi ZH, HIGH(@0)
    ldi ZL, LOW(@0)
.endmacro

; The macro clear16s a word (2 bytes) in a memory
; the parameter @0 is the memory address for that word
.macro clear16
    loadZ @0
    clr temp
    st Y+, temp ; clear16 the two bytes at @0 in SRAM
    st Y, temp
.endmacro

; sets X to the value pointed to by Z in dseg
.macro load16
    push ZH
    push ZL

    loadZ @0
    ld XL, Z+
    ld XH, Z

    pop ZL
    pop ZH
.endmacro

; sets the value pointed to by Z in dseg to X
.macro store16
    push ZH
    push ZL

    loadZ @0
    st Z+, XL
    st Z, XH

    pop ZL
    pop ZH
.endmacro

#define CODE(x) ((x) << 1)

.macro debugstr
    ; jump over the string
    rjmp SKIP

    ; write string in memory
    .set STR_ADDR = PC
    .db @0, 0

    ; print line to UART for debugging
SKIP:
    push ZH
    push ZL

    loadZ CODE(STR_ADDR)
    rcall uart_println

    pop ZL
    pop ZH
.endmacro
