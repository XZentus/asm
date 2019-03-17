extern  MessageBoxA
extern  ExitProcess

section .text USE64 ; write
    
start:
    ; and     rsp, 0FFFFFFFFFFFFFFF0h
    ; sub     rsp, 8*4
    sub     rsp, 5*8
    
    mov     rax, 1
    mov     rbx, 1
    xor     rcx, rcx
    
    loopiter:
        add     rbx, rax
        add     rax, rbx
        xor     rdx, rdx
        xor     r8,  r8
        test    rax, 1
        cmove   rdx, rax
        add     rcx, rdx
        test    rbx, 1
        cmove   r8,  rbx
        add     rcx, r8
        cmp     rax, 4000000
        jb      loopiter

    lea     rdx, [_msg + _msglen - 2]
    call    print10base
    
    xor     rcx, rcx
    lea     rdx, [_msg]
    lea     r8,  [_title]
    xor     r9,  r9
    call    MessageBoxA
    
    xor     rcx, rcx
    call    ExitProcess

    
print10base:
    mov     rbx, rdx
    mov     rax, rcx
    mov     r10, 10
    p10loop:
        xor     rdx, rdx
        div     r10
        add     dl, '0'
        mov     [rbx], dl
        dec     rbx
        test    rax, rax
        jnz     p10loop
    ret
    
    
section .data

    _title  db 'Result', 0
    _msg    db '                    ', 0
    _msglen equ $-1 - _msg
