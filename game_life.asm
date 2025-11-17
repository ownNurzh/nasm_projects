extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

section .data 
    name db 'nurzh ai', 0ah
    len equ $ - name

    size_world db 9 ; 9 symbols 9x9
    world TIMES  81  db  0 ; world map

section .bss
    console_std_type resd 1 ; std type cons
    written resd 1 ; written buffer after win api

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
    push ebx ; register for len message
    push esi ; register for message
    push dword [console_std_type]
    call _WriteFile@20
    ret

_init_world_map:
    ;init world 

_start:

    call _init_std ; init for print function

    ;test print function
    mov esi , name
    mov ebx , len
    call _print

    push 0 ; 1 arg for exitProcess
    call _ExitProcess@4