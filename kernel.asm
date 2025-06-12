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

pusha
call clear_main_panel
popa
call clear_bottom_panel

main_loop:




mov si, input_buffer

;- - - - - - - - INPUT LOOP - - - - - - - -
read_input_loop:




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
cmp ax, 15
jae clear_input_buffer


jmp read_input_loop
;----------------------------------------Done input loop
done_input_loop:


mov di, help_command
call compear_strings
cmp al, 1
je help_

mov di, time_command
call compear_strings
cmp al, 1
je update_time_

mov di, clear_command
call compear_strings
cmp al, 1
je clear_main_panel_

mov di, reboot_command
call compear_strings
cmp al, 1
je reboot_

jmp clear_input_buffer



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


compear_strings:
push si
mov si, input_buffer
new_char_compear_strings:
mov al, [si]
mov bl, [di]
cmp al, bl
jne strings_not_equal

cmp al, 0
je strings_equal
inc si
inc di
jmp new_char_compear_strings

strings_not_equal:
xor al, al
pop si
ret

strings_equal:
mov al, 1
pop si
ret



;clear input buffer - - - - - - - - - - - - - -
clear_input_buffer:

.clear_loop:

cmp si, input_buffer
jbe .done_clear

dec si
mov byte [si], 0


mov al, 0x08
mov ah, 0x0E
int 0x10
mov al, 0x20
int 0x10
mov al, 0x08
int 0x10



jmp .clear_loop
.done_clear:
    jmp read_input_loop

jmp main_loop


;-----------------------------------------programs
help_:
pusha
call clear_main_panel
popa

push si
mov si, help_msg
mov di, 1920
mov cl, 0x1E
call print_video_memory
pop si

call clear_input_buffer

reboot_:
    cli
    mov al, 0xFE
    out 0x64, al
    hlt
    jmp $

update_time_:
pusha

xor ah, ah

mov ah, 0x02
int 0x1A

;HOURS
mov al, ch
call bcd_to_ascii
add al, 3
mov [time_buffer], ah
mov [time_buffer+1], al
mov byte [time_buffer+2], ':'

;MINUTES
mov al, cl
call bcd_to_ascii
mov [time_buffer+3], ah
mov [time_buffer+4], al
mov byte [time_buffer+5], ':'

;SECONDS
mov al, dh
call bcd_to_ascii
mov [time_buffer+6], ah
mov [time_buffer+7], al

mov byte [time_buffer+8], 0

popa
call clear_bottom_panel
pusha
 mov di, 3840  
 mov si, time_buffer
 mov cl, 0x1E
call print_video_memory
popa


jmp clear_input_buffer
bcd_to_ascii:
    mov ah, al
    and ah, 0F0h
    shr ah, 4
    or ah, '0'

    and al, 0Fh
    or al, '0'
    ret

clear_main_panel_:
pusha
call clear_main_panel
popa

jmp clear_input_buffer



;-------------------------------------------------



print_video_memory:
    pusha
    mov ax, 0xB800
    mov es, ax
        mov ah, cl
    mov cx, 0

.new_char:
  add cx, 2
    lodsb ;si++

    cmp al, 0Ah
    je .new_char

  

    cmp al, 0Dh
    je .new_string

    test al, al
    jz .done

    stosw ;di++
    jmp .new_char

.new_string:

mov bx, 164
sub bx, cx 

add di, bx

xor cx, cx
jmp .new_char

.done:
    popa
    ret


print_bottom_panel:
    pusha
    mov ax, 0xB800
    mov es, ax
    mov di, 3840  
    mov si, input_buffer
.new_char:
    lodsb
    test al, al
    jz .done
    mov ah, 0x1E 
    stosw
    jmp .new_char
.done:
    popa
    ret


clear_main_panel:
    pusha
    mov ax, 0xB800
    mov es, ax
    mov di, 1920
.new_char:
    mov al, 32

cmp di, 3360
je .done

    mov ah, 0x1E 
    stosw
    jmp .new_char
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
clear_command: db "clear", 0
reboot_command: db "reboot", 0
time_command: db "time", 0


;----------

;msg
help_msg: 
db 0Dh, 0Ah
db 0Dh, 0Ah
db "time - Update time", 0Dh, 0Ah
db "echo str - Show your text(dont work)", 0Dh, 0Ah
db "reboot - Reboot system", 0Dh, 0Ah
db "clear - Clear main panel", 0Dh, 0Ah
db 0


;--------------

username:
db "user/: ", 0

;clear_bottom_panel_text: db 0,0,0,0,0,0,0,0,0,0,0,0,0,0

ART:
db 0Dh, 0Ah
db " ######                    ###       #####    #####  |                         ", 0Dh, 0Ah
db "  ##  ##                  ## ##     ##   ##  ##   ## |                         ", 0Dh, 0Ah
db "  ##  ## ######  ####     #         ##   ##  #       |                         ", 0Dh, 0Ah
db "  #####   ##  ##    ##  ####        ##   ##   #####  | something will be here..", 0Dh, 0Ah
db "  ##  ##  ##     #####   ##         ##   ##       ## |                         ", 0Dh, 0Ah
db "  ##  ##  ##    ##  ##   ##         ##   ##  ##   ## | Kernel: 16-bit          ", 0Dh, 0Ah
db " ######  ####    #####  ####         #####    #####  | To see commands - help  ", 0Dh, 0Ah
db "                                                     |                         ",0Dh, 0Ah
db "                                                     |                         ", 0Dh, 0Ah
db 0

input_buffer db 16 dup(0)
time_buffer db 32 dup(0)


dw 0xAA55

