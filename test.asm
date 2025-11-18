extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

section .data 
    list db 3 , 2 , 5 , 6 ,7 ,2
    len_list equ 6
    message db 't' , 0ah


section .bss
    console_std_type resd 1 ; std type cons
    written resd 1 ; written buffer for win api

section .text
    global _start ; linker entry

_init_std:
    push -11 ; -11 for default output console
    call _GetStdHandle@4 ; return value in eax
    mov dword [console_std_type], eax ; save std type in cons
    ret 

_print:
    push 0 
    push written
    push eax ; register for len message
    push message ; register for message
    push dword [console_std_type]
    call _WriteFile@20
    ret

_start:

    call _init_std ; init for print function
    
    mov ecx, len_list
    mov edx , list
    lp:
        push ecx
        push edx

        mov eax , 2;
        movzx ebx , byte [edx]
        add bl , '0'

        mov byte [message],bl
        call _print

        pop edx
        pop ecx

        inc edx
        dec ecx
        jnz lp


    jmp _end

_end:
    push 0
    call _ExitProcess@4