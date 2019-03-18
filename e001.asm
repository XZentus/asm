format PE64 GUI

entry start

section '.text' readable executable code

start:

        sub     rsp, 8*5
        mov     rdi, 3          ; num
        mov     rbx, 0          ; acc

        iterloop:
                call    isDiv3_5
                test    al, al
                jz      itercont
                add     rbx, rdi
        itercont:
                inc     rdi
                cmp     rdi, 1000
                jb      iterloop

        mov     rcx, rbx
        lea     rdx, [_result1 - 1]
        call    print10Base

        mov     r9,  0
        lea     r8,  [_caption1]
        lea     rdx, [_message]
        mov     rcx, 0
        call    [MessageBoxA]

        mov     rcx, rax
        call    [ExitProcess]


print10Base:
        mov     rdi, rcx
        mov     rsi, rdx
        mov     r8,  0xCCCCCCCCCCCCCCCD
        p10loop:
                mov     rax, rdi
                mul     r8
                shr     rdx, 3
                lea     eax, [rdx + rdx]
                lea     eax, [rax + 4*rax]
                mov     ecx, edi
                sub     ecx, eax
                or      cl, 48
                mov     [rsi], cl
;                add     rsi, -1
                dec     rsi
                cmp     rdi, 9
                mov     rdi, rdx
                ja      p10loop
        ret


isDiv3_5:
        mov     rcx, 0xAAAAAAAAAAAAAAAB
        mov     rax, rdi
        mul     rcx
        shr     rdx, 1
        lea     rax, [rdx + 2*rdx]
        cmp     rdi, rax
        je      .LBB0_1
        mov     rcx, 0xCCCCCCCCCCCCCCCD
        mov     rax, rdi
        mul     rcx
        shr     rdx, 2
        lea     rax, [rdx + 4*rdx]
        cmp     rdi, rax
        sete    al
        ret
.LBB0_1:
        mov     al, 1
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

        _caption1    db 'Result',0
        _caption2    db 'Result: analytic',0
        _message     db '                    '
_result1:
                     db 13, 10, '                    '
        _result2     db 0
