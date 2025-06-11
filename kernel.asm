[BITS 16]
org 0x8000

start:

mov ah, 0x00
mov al, 0x03 
int 0x10


mov cl, 0x0C
mov si, ART
call print_string_color

jmp $

print_string:
    pusha
.next_char:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .next_char
.done:
    popa
    ret





times 510 - ($ - $$) db 0

ART:
db 0Dh, 0Ah
db " ____                      ___", 0Dh, 0Ah
db "|  _ \\                   / _||", 0Dh, 0Ah
db "| ||) ||  _ ___   __ __  | ||_     ___   ___", 0Dh, 0Ah
db "|  _ <<  | '__|| / _` || |  _||   / _ \\/ __||", 0Dh, 0Ah
db "| ||) || | ||   | ((| || | ||    | (() |\__ \\", 0Dh, 0Ah
db "|____//  |_||    \__,_|| |_||     \___//|___//", 0Dh, 0Ah
db 0

buffer db 100 dup(0)


dw 0xAA55
