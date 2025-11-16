extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

section .data 
    name db 'nurzh ai', 0ah
    len equ $ - name

section .bss
    console_std_type resd 1
    written resd 1

section .text
    global _start ; linker entry

_init_std:
    push -11 ; -11 for default output console
    call _GetStdHandle@4 ; return value in eax
    mov dword [console_std_type], eax
    ret 

_print:
    push 0
    push written
    push ebx ; register for len message
    push esi ; register for message
    push dword [console_std_type]
    call _WriteFile@20
    ret

_start:

    call _init_std ; init for print function

    ;test print function
    mov esi , name
    mov ebx , len
    call _print

    push 0 ; 1 arg for exitProcess
    call _ExitProcess@4