format PE64 GUI

entry start

section '.text' readable executable code

start:
        sub     rsp, 5*8

        mov     rcx, 600851475143

; even? ->
        mov     ebx, 2
.div2:
        test    cl,  1
        jnz     .cont1
        shr     rcx, 1
        jmp     .div2
; <- even?
.cont1:
        cmp     rcx, 1
        cmove   rcx, rbx
        je      .done
        mov     rdi, 3
        .loop:
                lea     rsi, [rdi * 2]
                cmp     rsi, rcx
                jge     .done

                mov     rax, rcx
                xor     edx, edx
                div     rdi
                test    rdx, rdx
                cmovz   rcx, rax
                jz      .loop
                add     rdi, 2
                jmp     .loop

.done:
        lea     rdx, [_result-1]
        call    print10Base

        xor     r9d, r9d
        lea     r8,  [_caption]
        lea     rdx, [_message]
        xor     rcx, rcx
        call    [MessageBoxA]
        call    [ExitProcess]


print10Base:
        mov     rdi, rcx
        mov     rsi, rdx
        mov     r8,  0xCCCCCCCCCCCCCCCD
        .p10loop:
                mov     rax, rdi
                mul     r8
                shr     rdx, 3
                lea     eax, [rdx + rdx]
                lea     eax, [rax + 4*rax]
                mov     ecx, edi
                sub     ecx, eax
                or      cl, 48
                mov     [rsi], cl
                dec     rsi
                cmp     rdi, 9
                mov     rdi, rdx
                ja      .p10loop
        ret

section '.idata' import data readable writable

        dd      0,0,0, RVA kernel_name, RVA kernel_table
        dd      0,0,0, RVA user_name,   RVA user_table
        dd      0,0,0,0,0

        kernel_table:
                ExitProcess dq RVA _ExitProcess
                dq 0
        user_table:
                MessageBoxA dq RVA _MessageBoxA
                dq 0

        kernel_name db 'KERNEL32.DLL', 0
        user_name   db 'USER32.DLL',   0

        _ExitProcess dw 0
                     db 'ExitProcess', 0
        _MessageBoxA dw 0
                     db 'MessageBoxA', 0

buf_len = 20

        _caption     db 'Result', 0
        _message     db buf_len dup ' '
        _result      db 0
