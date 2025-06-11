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

;- - - - - - - - INPUT LOOP - - - - - - - -
read_input_loop:

call clear_bottom_panel

call print_bottom_panel

mov ah, 00h
int 0x16

cmp al, 0x08
je backspace

cmp al, 0Dh
je done_input_loop

mov [si], al
inc si


mov ah, 0x0E
int 0x10

mov ax, si
sub ax, input_buffer
cmp ax, 16
jae clear_input_buffer


jmp read_input_loop

;backspace - - - - - - - - - - - - - - - - - - -
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

done_input_loop:
jmp $

;clear input buffer - - - - - - - - - - - - - -
clear_input_buffer:
cmp si, input_buffer
jbe done_clear_buffer

mov al, 0x08
mov ah, 0x0E
int 0x10
mov al, 0x20
int 0x10
mov al, 0x08
int 0x10

dec si
mov byte [si], 0



jmp clear_input_buffer
done_clear_buffer:
jmp read_input_loop



;- - - - - - - - - - - - - - - - - - - - - - -


jmp main_loop

;- - - - - - - - - - - - - - - - - - - - - - -
print_bottom_panel:

    pusha
    mov ax, 0xB800
    mov es, ax
    mov di, 3840  
    mov si, input_buffer
new_char_bottom_panel:
    lodsb
    test al, al
    jz .done
    mov ah, 0x1E 
    stosw
    jmp new_char_bottom_panel
.done:
    popa
    ret
 
clear_bottom_panel:
    pusha
    mov ax, 0xB800
    mov es, ax
    mov di, 3840
    mov cx, 80
.clear_loop:
    mov ax, 0x0720 
    mov ah, 0x1E
    stosw
    loop .clear_loop
    popa
    ret


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

;Commands
help_command: db "help", 0


;----------

username: db "user/: ", 0
clear_bottom_panel_text: db 0,0,0,0,0,0,0,0,0,0,0,0,0,0

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

input_buffer db 16 dup(0)


dw 0xAA55

