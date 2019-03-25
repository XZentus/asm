format PE64 console

entry start

section '.text' code readable executable

start:
        sub     rsp, 5*8

        mov     ecx, 100500
        lea     rdx, [_result - 1]
        call    print10base

        mov     ecx, -11
        call    [GetStdHandle]
        mov     rcx, rax
        lea     rdx, [rbx + 1]
        lea     r8,  [_result - 1]
        sub     r8,  rbx
        lea     r9,  [_chars_written]
        call    [WriteConsoleA]

        add     rsp, 5*8
        ret


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

section '.idata' import readable writable data

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

        _message       db buf_len dup '0'
        _result        db 0
        _chars_written dw ?
