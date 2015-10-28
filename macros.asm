.macro loadZ
    ldi ZH, HIGH(@0)
    ldi ZL, LOW(@0)
.endmacro

.macro loadX
    ldi XH, HIGH(@0)
    ldi XL, LOW(@0)
.endmacro

; sets X to the value pointed to by Z in dseg
.macro load16X
    push ZH
    push ZL

    loadZ @0
    ld XL, Z+
    ld XH, Z

    pop ZL
    pop ZH
.endmacro

; sets the value pointed to by Z in dseg to X
.macro store16X
    push ZH
    push ZL

    loadZ @0
    st Z+, XL
    st Z, XH

    pop ZL
    pop ZH
.endmacro

.macro store16
    push XH
    push XL

    loadX @1
    load16X @0

    pop XL
    pop XH
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
