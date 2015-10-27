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

#define CODE(x) ((x) << 1)
