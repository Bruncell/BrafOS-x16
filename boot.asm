[bits 16]
[org 0x7C00]

xor ax, ax
mov ds, ax
mov es, ax


    mov ah, 0x02
    mov al, 8 ;sectors     
    mov ch, 0
    mov cl, 2 
    mov dh, 0
    mov dl, 0x00 
    mov bx, 0x8000 
    int 0x13
    jc disk_error 

mov si, SUCCESS_BOOT_MSG
call print_string

mov si, JUMP_KERNEL_MSG
call print_string
 
    jmp 0x8000 

disk_error:
    mov si, DISK_ERROR_MSG
    call print_string
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
    
    
START_BOOT_MSG db "Bootloader starting..", 0
SUCCESS_BOOT_MSG db "Successful kernel boot!", 0
JUMP_KERNEL_MSG db "Jumping to kernel..", 0
DISK_ERROR_MSG db "Disk read error!", 0

times 510 - ($ - $$) db 0
dw 0xAA55

