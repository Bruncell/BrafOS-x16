[BITS 16]
org 0x8000

start:

mov ah, 0x00
mov al, 0x03 
int 0x10

mov si, ART
call print_string

mov si, username
call print_string

main_loop:

mov si, input_buffer

read_input_loop:

mov ah, 00h
int 0x16

cmp al, 0x08
je backspace

cmp al, 0x13
je backspace

mov [si], al
inc si


mov ah, 0x0E
int 0x10

jmp read_input_loop

backspace:
cmp si, input_buffer
jbe read_input_loop

dec si
mov byte [si], 0

mov ah, 0x0E
int 0x10
mov al, 0x20
int 0x10
mov al, 0x08
int 0x10
jmp read_input_loop

done_read_input:


jmp main_loop

; - - - - - - - - - - - - - - - - - - - 

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

username: db "user/: ", 0

ART:
db 0Dh, 0Ah
db " ____                      ___", 0Dh, 0Ah
db "|  _ \\                   / _||", 0Dh, 0Ah
db "| ||) ||  _ ___   __ __  | ||_     ___   ___", 0Dh, 0Ah
db "|  _ <<  | '__|| / _` || |  _||   / _ \\/ __||", 0Dh, 0Ah
db "| ||) || | ||   | ((| || | ||    | (() |\__ \\", 0Dh, 0Ah
db "|____//  |_||    \__,_|| |_||     \___//|___//", 0Dh, 0Ah
db 0Dh, 0Ah
db "-------------------------------------------------------------------------------", 0Dh, 0Ah
db 0

input_buffer db 32 dup(0)


dw 0xAA55

