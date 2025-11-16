extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

section .data
    msg db 'Hello, world!', 0Ah
    len equ $ - msg

section .bss
    written resd 1

section .text
    global _start

_start:
    push -11 ; -11 for default output console
    call _GetStdHandle@4 ; return value in eax
    push 0
    push written
    push len
    push msg
    push eax
    call _WriteFile@20

    push 0
    call _ExitProcess@4
