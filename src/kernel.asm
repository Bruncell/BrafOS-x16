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

call update_time_

mov si, input_buffer

;main loop
main_loop:

mov ah, 00h
int 0x16

cmp al, 0x08
je backspace

cmp al, 0Dh
je .done

mov [si], al
inc si


mov ah, 0x0E
int 0x10

mov ax, si
sub ax, input_buffer

cmp ax, 31
jae clear_input_buffer

jmp main_loop

.done:

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

mov di, echo_prefix
call compear_prefix
cmp al, 1
je echo_

mov di, read_prefix
call compear_prefix
cmp al, 1
je read_sector_

mov di, sum_prefix
call compear_prefix
cmp al, 1
je sum_

mov di, sub_prefix
call compear_prefix
cmp al, 1
je sub_

mov al, 0

jmp clear_input_buffer

backspace:
cmp si, input_buffer
jbe main_loop

dec si
mov byte [si], 0

mov ah, 0x0E
int 0x10
mov al, 0x20
int 0x10
mov al, 0x08
int 0x10
jmp main_loop

compear_prefix:
push si
mov si, input_buffer
.new_char:
mov al, [si]
mov bl, [di]

cmp bl, 0
je .equal

cmp al, 0
je .not_equal

cmp al, bl
jne .not_equal

inc si
inc di
jmp .new_char
.equal:
mov al, 1
jmp .done

.not_equal:
mov al, 0
jmp .done
.done:
pop si
ret

compear_strings:
push si
mov si, input_buffer
.new_char:
mov al, [si]
mov bl, [di]
cmp al, bl
jne strings_not_equal

cmp al, 0
je strings_equal
inc si
inc di
jmp .new_char

strings_not_equal:
xor al, al
pop si
ret

strings_equal:
mov al, 1
pop si
ret

clear_input_buffer:

mov si, input_buffer

.find_end:
    cmp byte [si], 0
    je .start_clearing
    inc si
    jmp .find_end

.start_clearing:

    cmp si, input_buffer
    je .done_clear

.clear_loop:
    dec si
    mov byte [si], 0

    mov al, 0x08
    mov ah, 0x0E
    int 0x10
    mov al, 0x20
    int 0x10
    mov al, 0x08
    int 0x10

    cmp si, input_buffer
    jne .clear_loop
.done_clear:
jmp main_loop



;-----------------------------------------programs
    
read_sector_:



      pusha

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ah, 0x00
    mov dl, 0x00
    int 0x13
    jc .error




mov cx, 5
mov si, input_buffer
call get_first_number

call get_second_number_sum

    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, dl

    mov dh, 0
    mov dl, 0x00
    mov ax, bx
    mov es, ax
    xor bx, bx
    int 0x13
    jc .error

    mov ax, es
    mov si, ax
    mov di, 1920
    mov cl, 0xF0
    call print_video_memory_sector

    popa
    call clear_input_buffer

.error:
    
   push si
mov si, error_disk_read_msg
mov di, 3910
mov cl, 0xF0
call print_video_memory
pop si

call clear_input_buffer

error_disk_read_msg db "DISK READ FAIL :(", 0
jmp $


sub_:
xor ax, ax
xor cx, cx
xor bx, bx
xor dx, dx

mov cx, 4
mov si, input_buffer
call get_first_number
call get_second_number_sum

pusha
cmp dx, 32767
je .skip1
.skip2:

pusha
cmp bx, 32767
je .skip1
.skip1:

pusha
sub dx, bx
js .negative
popa
sub dx, bx



mov ax, dx

pusha
mov di, help_buffer
call num_to_str
popa

pusha
mov ax, 0xB800
mov es, ax
mov di, 1920
mov ah, 0xF0

.new_char1:

mov al, 32
stosw ;di++
cmp di, 1984
jna .new_char1
popa


pusha
mov si, help_buffer
mov di, 1920
mov cl, 0xF0
call print_video_memory
popa

xor ax, ax
xor cx, cx
xor bx, bx
xor dx, dx

jmp clear_input_buffer

.negative:
popa
sub bx, dx

mov ax, bx

pusha
mov di, help_buffer
call num_to_str
popa

pusha
mov ax, 0xB800
mov es, ax
mov di, 1920
mov ah, 0xF0

.new_char2:

mov al, 32
stosw ;di++
cmp di, 1984
jna .new_char2
popa

pusha
mov si, minus
mov di, 1920
mov cl, 0xF0
call print_video_memory
popa

pusha
mov si, help_buffer
mov di, 1922
mov cl, 0xF0
call print_video_memory
popa

xor ax, ax
xor cx, cx
xor bx, bx
xor dx, dx

call clear_input_buffer


sum_:
xor ax, ax
xor cx, cx
xor bx, bx
xor dx, dx

mov cx, 4
mov si, input_buffer
call get_first_number

call get_second_number_sum

cmp dx, 32767
jae clear_input_buffer

cmp bx, 32767
jae clear_input_buffer

add dx, bx

mov ax, dx

pusha
mov di, help_buffer
call num_to_str
popa

pusha
mov ax, 0xB800
mov es, ax
mov di, 1920
mov ah, 0xF0

.new_char:

mov al, 32
stosw ;di++
cmp di, 1984
jna .new_char
popa


pusha
mov si, help_buffer
mov di, 1920
mov cl, 0xF0
call print_video_memory
popa

jmp clear_input_buffer


get_first_number:
push ax
push bx
push cx



add si, cx

xor ax, ax
xor cx, cx
xor bx, bx
xor dx, dx


.next_char1:

lodsb

cmp al, 32 
je .done

sub al, '0'
cmp al, 9
ja .bad_done

cmp dl, 0
je .skip

push ax
mov ax, dx
mov cx, 10
mul cx
mov dx, ax
pop ax

add dx, ax
mov ax, dx

.skip:
mov dx, ax

xor ax, ax

jmp .next_char1

.done:
pop ax
pop bx
pop cx
ret

.bad_done:


pop ax
pop bx
pop cx

jmp clear_input_buffer



get_second_number_sum:
push ax
push dx
push cx

xor ax, ax

.next_char:


lodsb


cmp al, 0 
je .done

sub al, '0'
cmp al, 9
ja .bad_done

cmp bx, 0
je .skip2



push ax
mov ax, bx
mov cx, 10
mul cx
mov bx, ax
pop ax

add bx, ax
mov ax, bx

.skip2:
mov bx, ax

xor ax, ax

jmp .next_char

.done:
pop ax
pop dx
pop cx
ret

.bad_done:

pop ax
pop dx
pop cx
sub si, 1
jmp clear_input_buffer




   
num_to_str:

    mov cx, 0
    mov bx, 10
.repeat:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .repeat
.print_digits:
    pop ax
    mov [di], al
    inc di
    loop .print_digits
    mov byte [di], 0

    ret



echo_:

push si
mov si, input_buffer
add si, 5
cmp si, 0
je .done_echo
pop si


pusha
mov ax, 0xB800
mov es, ax
mov di, 1920
mov ah, 0xF0

.new_char:

mov al, 32
stosw ;di++
cmp di, 1984
jna .new_char
popa
    


push si
mov si, input_buffer
add si, 5
mov di, 1920
mov cl, 0xF0
call print_video_memory
pop si

.done_echo:


call clear_input_buffer

help_:


push si
mov si, help_msg
mov di, 1920
mov cl, 0xF0
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
add al, 0
call .bcd_to_ascii
mov [time_buffer], ah
mov [time_buffer+1], al
mov byte [time_buffer+2], ':'

;MINUTES
mov al, cl
call .bcd_to_ascii
mov [time_buffer+3], ah
mov [time_buffer+4], al
mov byte [time_buffer+5], ':'

;SECONDS
mov al, dh
call .bcd_to_ascii
mov [time_buffer+6], ah
mov [time_buffer+7], al

mov byte [time_buffer+8], 0

popa
call clear_bottom_panel
pusha
 mov di, 3840  
 mov si, time_buffer
 mov cl, 0xF0
call print_video_memory
popa


jmp clear_input_buffer

.bcd_to_ascii:
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

print_video_memory_sector:
    pusha
    mov ax, 0xB800
    mov es, ax
    mov ah, cl
    mov cx, 0

.new_char:



inc cx
cmp cx, 512
je .done

    lodsb ;si++



    stosw ;di++
    jmp .new_char

.done:
    popa
    ret
;=============================================================================
eror_print:

pusha
push si
mov si, error_code_text
mov di, 3858
mov cl, 0xF0
call print_video_memory
pop si

cmp bx, 1
je .buffer_overflow

cmp bx, 2
je .invalid_syntax

popa
jmp clear_input_buffer

.buffer_overflow:

push si
mov si, buffer_overflow_code
mov di, 3880
mov cl, 0xF0
call print_video_memory
pop si

popa
call clear_input_buffer

.invalid_syntax:

push si
mov si, invalid_syntax_code
mov di, 3880
mov cl, 0xF0
call print_video_memory
pop si

popa
ret


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
    mov ah, 0xF0 
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

    mov ah, 0xF0 
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
    mov ah, 0xF0
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

;times 510 - ($ - $$) db 0

;Commands
help_command: db "help", 0
clear_command: db "clear", 0
reboot_command: db "reboot", 0
time_command: db "time", 0
echo_prefix: db "echo ", 0
read_prefix: db "read ", 0 ;Don't work
sum_prefix: db "sum ", 0
sub_prefix: db "sub ", 0



;----------


;msg
help_msg: 
db 0Dh, 0Ah
db 0Dh, 0Ah
db "time - Update time           sum num num - sums numbers             ", 0Dh, 0Ah
db "echo str - Show your text    sub num num - subtracts numbers        ", 0Dh, 0Ah
db "reboot - Reboot system       read sector adress - read sector       ", 0Dh, 0Ah
db "clear - Clear main panel                                            ", 0Dh, 0Ah
db 0


;--------------


;-----error messanges-----
error_code_text: db "Error code:",0

buffer_overflow: db "The buffer you are using is full",0
buffer_overflow_code: db "E0",0

invalid_syntax: db "The command syntax is incorrect",0
invalid_syntax_code: db "E1",0

minus: db "-", 0

username: db "user/: ", 0
zero_char: db 0
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

read_buffer: times 512 db 0


help_buffer db 32 dup(0)
input_buffer db 32 dup(0)
time_buffer db 32 dup(0)


dw 0xAA55


