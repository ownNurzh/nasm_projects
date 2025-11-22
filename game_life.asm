extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4
extern Sleep

section .data 
    ;=======================================
    size_world equ 11 ; world size (size_world x size_world)
    size_world_dec equ size_world - 1
    world_area equ size_world * size_world

    ;=======================================
    alive_point equ '1' ; alive point symbol
    dead_point equ '0' ; dead point symbol


    alive_rule_2 dd 2
    alive_rule_3 dd 3
    dead_rule_3 dd 3
    ;=======================================
    world TIMES world_area db dead_point
    ;=======================================
    clear db 27,"[2J" ; <ESC>[2J - for clear
    clear_len equ $-clear 

    move_cursor db 27 ,"[H"; <ESC>[H for move cursor in start
    move_cursor_len equ $-move_cursor
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
    count resd 1;
    ;==========================================
    base_clean_world resb world_area ; base clean world for logic

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

_pseudo_clear_term:
    ;move cursor
    push 0 
    push written
    push move_cursor; register for len message
    push move_cursor_len ; register for message
    push dword [console_std_type]
    call _WriteFile@20
    ret

_calc_row_col_index:
    ; input: ecx = row, ebx = column
    ; output: eax = index
    mov eax, ecx
    imul eax,size_world
    add eax,ebx
    ret

set_alive_cell:
    mov byte [base_clean_world + eax] , alive_point
    ret

set_dead_cell:
    mov byte [base_clean_world + eax] , dead_point
    ret

init_copy_world:
    push ecx
    lea esi, [world]  
    lea edi, [base_clean_world]         
    mov ecx, world_area
    rep movsb  
    pop ecx
    ret

rebase_world:
    push ecx
    lea esi, [base_clean_world]  
    lea edi, [world]         
    mov ecx, world_area
    rep movsb  
    pop ecx
    ret

_change_cell_state:
    ; input: ecx = row, ebx = column , eax = index
    ; table 8 neighbour cells
    ; =====
    ; [x,y]
    ; [0,-1], # top
    ; [1,-1], # top-right
    ; [1,0],  # right
    ; [1,1],  # bot-right
    ; [0,1],  # bot
    ; [-1,1], # bot-left
    ; [-1,0], # left
    ; [-1,-1],# top-left
    ; =====
    mov byte [count] , 0
    ;side cells
    cmp ecx , 0
    je skip_top_cell
    movzx edx, byte [world + eax - size_world]
    sub dl, '0'
    add byte [count] , dl
    skip_top_cell:
    cmp ecx , size_world_dec
    je skip_bot_cell
    movzx edx, byte [world + eax + size_world]
    sub dl, '0'
    add byte [count] , dl
    skip_bot_cell:
    cmp ebx , 0
    je skip_left_cell
    movzx edx, byte [world + eax - 1]
    sub dl, '0'
    add byte [count] , dl
    skip_left_cell:
    cmp ebx , size_world_dec
    je skip_right_cell
    movzx edx, byte [world + eax + 1]
    sub dl, '0'
    add byte [count] , dl
    skip_right_cell:
    ;diagonal cells
    cmp ecx , 0
    je skip_top_right_cell
    cmp ebx , size_world_dec
    je skip_top_right_cell
    movzx edx, byte [world + eax - size_world + 1]
    sub dl, '0'
    add byte [count] , dl
    skip_top_right_cell:
    cmp ecx , 0
    je skip_top_left_cell
    cmp ebx , 0
    je skip_top_left_cell
    movzx edx, byte [world + eax - size_world - 1]
    sub dl, '0'
    add byte [count] , dl
    skip_top_left_cell:
    cmp ecx , size_world_dec
    je skip_bot_right_cell
    cmp ebx , size_world_dec
    je skip_bot_right_cell
    movzx edx, byte [world + eax + size_world + 1]
    sub dl, '0'
    add byte [count] , dl
    skip_bot_right_cell:
    cmp ecx , size_world_dec
    je skip_bot_left_cell
    cmp ebx , 0
    je skip_bot_left_cell
    movzx edx, byte [world + eax + size_world - 1]
    sub dl, '0'
    add byte [count] , dl
    skip_bot_left_cell:
    ;check rules
    movzx edx, byte [world + eax]
    mov edi , [count]
    cmp dl , alive_point
    je check_alive_rules
    jmp check_dead_rules
    check_alive_rules:
        cmp edi , [alive_rule_2]
        je end_check_cell
        cmp edi , [alive_rule_3]
        je end_check_cell
        call set_dead_cell

        jmp end_check_cell
    check_dead_rules:
        cmp edi , [dead_rule_3]
        je alive_cell
        jmp end_check_cell
        alive_cell:
            call set_alive_cell
        jmp end_check_cell
    end_check_cell:
    ret


_game_loop_logic:

    call init_copy_world
    ;================
    mov ecx , 0 ; row 
    
    logic_row_loop:
        mov ebx , 0 ; column
        logic_column_loop:
            call _calc_row_col_index; eax = index = row * size_world + col
            call _change_cell_state
            inc ebx
            cmp ebx , size_world
            jl logic_column_loop
        inc ecx
        cmp ecx , size_world
        jl logic_row_loop
    call rebase_world
    ret

_render_game:
    ;================
    mov ecx , 0 ; row 
    
    row_loop:

        push ecx  
        mov ebx , 0

        column_loop:
            call _calc_row_col_index
            movzx edx,byte [world + eax]
            mov byte [message + ebx], dl
            inc ebx
            cmp ebx , size_world
            jl column_loop
        
        mov byte [message + size_world] , 0ah
        mov dword [message_len] , message_len_from_size_world
        call _print

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