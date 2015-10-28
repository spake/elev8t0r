.macro loadZ
    ldi ZH, HIGH(@0)
    ldi ZL, LOW(@0)
.endmacro

.macro loadX
    ldi XH, HIGH(@0)
    ldi XL, LOW(@0)
.endmacro

; sets X to the value pointed to by @0 in dseg
.macro load16X
    push ZH
    push ZL

    loadZ @0
    ld XL, Z+
    ld XH, Z

    pop ZL
    pop ZH
.endmacro

; sets XL to the value pointed to by @0 in dseg
.macro load8X
    push ZH
    push ZL

    loadZ @0
    ld XL, Z

    pop ZL
    pop ZH
.endmacro

; sets the value pointed to by @0 in dseg to X
.macro store16X
    push ZH
    push ZL

    loadZ @0
    st Z+, XL
    st Z, XH

    pop ZL
    pop ZH
.endmacro

; sets the value pointed to by @0 in dseg to XL
.macro store8X
    push ZH
    push ZL

    loadZ @0
    st Z, XL

    pop ZL
    pop ZH
.endmacro

; sets the value pointed to by @0 in dseg to @1
.macro store16
    push XH
    push XL

    loadX @1
    store16X @0

    pop XL
    pop XH
.endmacro

; sets the value pointed to by @0 in dseg to @1
.macro store8
    push XL

    ldi XL, @1
    store8X @0

    pop XL
.endmacro

; clears value pointed to by @0
.macro clear16
    store16 @0, 0
.endmacro

; clears value pointed to by @0
.macro clear8
    store8 @0, 0
.endmacro

; compare X with @0
.macro cpi16X
    push YH
    push YL

    ldi YH, HIGH(@0)
    ldi YL, LOW(@0)

    ; do comparison
    cp XL, YL
    cpc XH, YH

    pop YL
    pop YH
.endmacro

.macro cpi16
    push XH
    push XL

    load16X @0
    cpi16X @1

    pop XL
    pop XH
.endmacro

; loads @1th value of array pointed to by @0 into XL
.macro arrayLoadX
    push ZH
    push ZL

    loadZ @0
    ld XL, Z+@1

    pop ZL
    pop ZH
.endmacro

; stores XL into @1th value of array pointed to by @0
.macro arrayStoreX
    push ZH
    push ZL

    loadZ @0
    st Z+@1, XL

    pop ZL
    pop ZH
.endmacro

#define CODE(x) ((x) << 1)

.macro lcdprint
    ; jump over the string
    rjmp SKIP

    ; write string in memory
    .set STR_ADDR = PC
    .db @0, 0

    ; print line to LCD
SKIP:
    push ZH
    push ZL

    loadZ CODE(STR_ADDR)
    rcall lcd_puts

    pop ZL
    pop ZH
.endmacro

.macro dbgprint
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
    rcall uart_puts

    pop ZL
    pop ZH
.endmacro

.macro dbgprintln
    dbgprint @0
    rcall uart_newline
.endmacro

.macro dbgreg_
    dbgprint @0
    push r16
    mov r16, @1
    rcall uart_print_number
    rcall uart_newline
    pop r16
.endmacro

#define DBGREG(reg) dbgreg_ #reg ": ", reg

.macro breq_long
    brne SKIP
    rjmp @0
SKIP:
.endmacro

.macro brne_long
    breq SKIP
    rjmp @0
SKIP:
.endmacro

.macro brge_long
    brlt SKIP
    rjmp @0
SKIP:
.endmacro
