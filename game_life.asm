extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4
extern Sleep

section .data 
    ;=======================================
    size_world equ 11 ; world size (size_world x size_world)
    world_area equ size_world * size_world
    ;=======================================
    alive_point equ '1' ; alive point symbol
    dead_point equ '0' ; dead point symbol
    ;=======================================
    world TIMES world_area db dead_point
    ;=======================================
    clear db 27,"[2J" ; <ESC>[2J
    clear_len equ $-clear 
    ;=======================================
    sleep_time equ 300;main loop sleep time
    ;=======================================
    message_len_from_size_world equ size_world + 1
    ;=======================================

section .bss
    ;==========================================
    ;win api params
    console_std_type resd 1 ; std type cons
    written resd 1 ; written buffer for win api
    ;==========================================
    ;print function default params
    message resb message_len_from_size_world ; 
    message_len resd 1;
    ;==========================================

section .text
    ;===========================
    global _start ; linker entry

_init_std:
    push -11 ; -11 for default output console
    call _GetStdHandle@4 ; return value in eax
    mov dword [console_std_type], eax ; save std type in cons
    ret


_clear_registers:
    xor ecx,ecx
    xor ebx,ebx
    xor edx,edx
    xor eax,eax
    ret

_print:
    push 0 
    push written
    push [message_len]; register for len message
    push message ; register for message
    push dword [console_std_type]
    call _WriteFile@20
    ret

_time_sleep:
    push ebp
    mov ebp, esp
    push sleep_time
    call Sleep
    mov esp, ebp
    pop ebp
    ret

_clear_term:
    push 0 
    push written
    push clear_len; register for len message
    push clear ; register for message
    push dword [console_std_type]
    call _WriteFile@20
    ret

_game_loop_logic:
    ;================

_render_game:
    ;================
    mov ecx , 0 ; row 
    
    row_loop:
        ;стекка лақтырамыз а то винда функциясынан кейн значение жоғалп кетп жатр утечка
        push ecx  
        mov ebx , 0
        column_loop:
            ; крч тут рассчитываем клетку по такой формуле row * 9 + col
            mov eax, ecx
            imul eax,size_world
            add eax,ebx
            ; 
            ; movzx чтобы брать только байт и остальное заполнить нулями с обычным mov траблы
            movzx edx,byte [world + eax]
            ; добавляем полученную клетку в сообщение который будет выводится после этого цикла
            mov byte [message + ebx], dl
            ; ну тут просто дефолт ,увеличиваем цикл и проверяем
            inc ebx
            cmp ebx , size_world
            jl column_loop
        ; добавляем \n в конец ,я спецом для этого оставил один лишний байт
        mov byte [message + size_world] , 0ah
        mov dword [message_len] , message_len_from_size_world
        call _print

        ;берем из стека өйткені винда функциясын шақырған соң регистр почему то очищается
        pop ecx
        inc ecx
        cmp ecx , size_world
        jl row_loop
    ret

_init_glider_in_world:
    ;=======================================
    ; glider
    ; 0 1 0
    ; 0 0 1
    ; 1 1 1
    ;=======================================
    mov byte [world + 0 * size_world + 1], alive_point
    mov byte [world + 1 * size_world + 2], alive_point
    mov byte [world + 2 * size_world ], alive_point
    mov byte [world + 2 * size_world + 1], alive_point
    mov byte [world + 2 * size_world + 2], alive_point
    ret

_start:
    ;=======================================
    call _init_std ; init for print function
    call _clear_term ; clear terminal
    ;=======================================

    call _init_glider_in_world

    main_loop:
        ;=================================================================
        ; просто так очистил 'Такие люди, как я, делают меня мизантропом.'
        call _clear_registers
        ;=================================================================

        ;================
        call _render_game
        ;----------------
        call _clear_registers
        ;----------------
        call _game_loop_logic
        ;================
        call _time_sleep
        
        call _clear_term
        ;================

    ;while true
    jmp main_loop
    
    jmp _end


_end:
    push 0 ; 1 arg for exitProcess
    call _ExitProcess@4