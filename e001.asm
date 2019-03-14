format PE64 GUI

entry start

section '.text' readable executable code

start:

        sub     rsp, 8*5
        ;test
        mov     rcx, 7
        mov     rdx, 3
        call    next_div
        mov     rcx, 7
        mov     rdx, 3
        call    prev_div
        ;~test
        mov     rcx, 3          ; num
        mov     rbx, 0          ; acc

        iterloop:
                call    isDiv3_5
                test    al, al
                jz      itercont
                add     rbx, rcx
        itercont:
                inc     rcx
                cmp     rcx, 1000
                jb      iterloop

        mov     rcx, rbx
        lea     rdx, [_label-2]
        call    print10Base

        mov     r9,  0
        lea     r8,  [_caption1]
        lea     rdx, [_message]
        mov     rcx, 0
        call    [MessageBoxA]

        mov     rcx, rax
        call    [ExitProcess]


print10Base:
        mov     r10, 10
printNBase:
        mov     rbx, rdx
        mov     rax, rcx
        p10loop:
                xor     rdx, rdx
                div     r10
                add     dl, '0'
                mov     [rbx], dl
                dec     rbx
                test    rax, rax
                jnz     p10loop
        ret


isDiv3_5:                       ; eax edx r9d
        mov     rax, rcx
        xor     rdx, rdx
        mov     r9,  3
        div     r9
        test    dl, dl
        jz      d3_5
        mov     rax, rcx
        xor     rdx, rdx
        mov     r9,  5
        div     r9
        test    dl, dl
        jz      d3_5
        xor     rax, rax
        ret
d3_5:
        mov     rax, 1
        ret

next_div:
        mov     rax, rcx
        mov     r9,  rdx
        xor     rdx, rdx
        div     r9
        test    rdx, rdx
        mov     rax, rcx
        jz      nd_divisor
        add     rax, r9
        sub     rax, rdx
nd_divisor:
        ret

prev_div:
        mov     rax, rcx
        mov     r9,  rdx
        xor     rdx, rdx
        div     r9
        mov     rax, rcx
        sub     rax, rdx
        ret


section '.idata' import data readable writable

        dd 0,0,0, RVA kernel_name, RVA kernel_table
        dd 0,0,0, RVA user_name, RVA user_table
        dd 0,0,0,0,0

        kernel_table:
                ExitProcess dq RVA _ExitProcess
                dq 0
        user_table:
                MessageBoxA dq RVA _MessageBoxA
                dq 0

        kernel_name db 'KERNEL32.DLL',0
        user_name   db 'USER32.DLL',0

        _ExitProcess dw 0
                     db 'ExitProcess',0
        _MessageBoxA dw 0
                     db 'MessageBoxA',0

        _caption1    db 'Result: iteration',0
        _caption2    db 'Result: analytic',0
        _message     db '                    ', 0
        _label       db ?
