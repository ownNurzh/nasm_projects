extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

section .data 

    size_world equ 9 ; 9 symbols 9x9
    world_area equ size_world * size_world
    alive_point equ '1' ; alive point symbol
    dead_point equ '0' ; dead point symbol

    world TIMES world_area db dead_point

section .bss
    console_std_type resd 1 ; std type cons
    written resd 1 ; written buffer for win api
    message resb 10 ; one line message buffer

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
    push 10 ; register for len message
    push message ; register for message
    push dword [console_std_type]
    call _WriteFile@20
    ret


_start:

    call _init_std ; init for print function

    mov byte [message], '0'
    mov byte [message+1], '0'
    mov byte [message+2], '0'
    mov byte [message+3], '0' 
    mov byte [message+4], '0'
    mov byte [message+5], '0'
    mov byte [message+6], '0'
    mov byte [message+7], '0'
    mov byte [message+8], '0'
    mov byte [message+9], 0ah

    call _print
    call _print
    call _print

    jmp _end


_end:
    push 0 ; 1 arg for exitProcess
    call _ExitProcess@4