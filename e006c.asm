format PE64 console

entry start

macro align size { rb (size-1)-($+size-1) mod size }

section '.text' readable executable code

limit = 100

align 16
start:
        sub     rsp, 5*8

        mov     ecx, limit
        xor     ebx, ebx
        xor     esi, esi
        @@:
                mov     eax, ecx
                mul     rcx
                add     rbx, rcx
                add     rdi, rax
                loop @b
        mov     rax, rbx
        mul     rbx
        sub     rax, rdi
        mov     rcx, rax

        lea     rdx, [_result - 1]
        call    print10base

        mov     rcx, -11
        call    [GetStdHandle]
        mov     rcx, rax
        lea     rdx, [rbx + 1]
        lea     r8,  [_result - 1]
        sub     r8,  rbx
        lea     r9,  [_chars_written]
        call    [WriteConsoleA]

        add     rsp, 5*8
        ret


align 16
print10base:           ;print10Base(rcx: unsigned number, rdx: ptr_back)

        mov rbx, rdx ; rbx: ptr
        mov rdi, rcx ; rdi: number

        .p10loop:
                mov rdx, 0xCCCCCCCCCCCCCCCD
                mov rax, rdi
                mul rdx
                mov rax, rdx
                shr rax, 3
                lea rdx, [rax+rax*4]
                add rdx, rdx
                sub rdi, rdx
                xor edx, edx
                add edi, '0'
                mov dl, dil
                mov rdi, rax

                mov [rbx], dl
                dec rbx
                cmp rdi, 0
                jne .p10loop
        ret


section '.idata' import data readable writable

        dd 0,0,0, RVA kernel_name, RVA kernel_table
        dd 5 dup 0

        kernel_table:
                GetStdHandle  dq RVA _GetStdHandle
                WriteConsoleA dq RVA _WriteConsoleA
                dq 0

        kernel_name db 'KERNEL32', 0

        _GetStdHandle  dw 0
                       db 'GetStdHandle', 0
        _WriteConsoleA dw 0
                       db 'WriteConsoleA', 0

buf_len = 20

        _message       rb buf_len
        _result        db 0
        _chars_written rw 1
