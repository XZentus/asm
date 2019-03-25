format PE64 console

entry start

section '.text' readable executable code

start:

        sub     rsp, 5*8
        call    solve

        mov     rcx, rax
        lea     rdx, [_result - 1]
        call    print10base

        mov     ecx, -11 ;STD_OUTPUT_HANDLE
        call    [GetStdHandle]
        mov     rcx, rax
        lea     rdx, [rbx + 1]
        mov     r8,  _result - _message
        lea     r9,  [_chars_written]
        call    [WriteConsoleA]

        xor     ecx, ecx
        add     rsp, 5*8
        ret

solve:
        mov     r10d, 100
        xor     r13d, r13d

        .loop10:
                inc     r10d
                cmp     r10d, 999
                jg      .end
                mov     r11d, r10d
                .loop11:
                        mov     eax, r10d
                        mul     r11d
                        mov     r12d, eax
                        mov     rdi, rax
                        call    to_binary_decimal_controlled
                        test    rax, rax
                        jz      .loop11inc
                        mov     rdi, rax
                        call    is_6_digit_palindrome
                        test    al, al
                        jz     .loop11cont
                        cmp     r12d, r13d
                        jbe     .loop11cont
                        mov     r13d, r12d
                        .loop11cont:
                        cmp     r12d, 999999
                        jg      .loop10
                        cmp     r11d, 999
                        jg      .loop10
                        .loop11inc:
                        inc     r11d
                        jmp     .loop11

        .end:
        mov     eax, r13d
        ret



is_6_digit_palindrome:            ;rdi: number
        mov     rax, rdi

        mov     rbx, rdi
        shr     rbx, 8*5
        cmp     al,  bl
        jne     .not_pal

        shr     rax, 8
        mov     rbx, rdi
        shr     rbx, 8*4
        cmp     al,  bl
        jne     .not_pal

        shr     rax, 8
        mov     rbx, rdi
        shr     rbx, 8*3
        cmp     al,  bl
        jne     .not_pal
        xor     eax, eax
        inc     eax
        ret
        .not_pal:
        xor     eax, eax
        ret


to_binary_decimal_controlled:     ;rdi: number
        lea     rax, [rdi - 100001]
        xor     r9d, r9d
        cmp     rax, 899998
        ja      .end
        mov     rsi, rdi
        test    rdi, rdi
        je      .end
        xor     ecx, ecx
        mov     r8,  0xCCCCCCCCCCCCCCCD
        xor     r9d, r9d
        .loop:
                mov     rax, rsi
                mul     r8
                shr     rdx, 3
                lea     rax, [rdx + rdx]
                lea     rax, [rax + 4*rax]
                mov     rdi, rsi
                sub     rdi, rax
                shl     rdi, cl
                or      r9,  rdi
                add     rcx, 8
                cmp     rsi, 9
                mov     rsi, rdx
                ja      .loop
        .end:
        mov     rax, r9
        ret


print10base:           ;print10Base(rcx: unsigned number, rdx: ptr_back)

        mov rbx, rdx ; rbx: ptr
        mov rdi, rcx ; rdi: number

        p10loop:
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
                jne p10loop
        ret

section '.idata' readable writable import data

        dd 0,0,0, RVA kernel_name, RVA kernel_table
        dd 5 dup 0

        kernel_table:
                GetStdHandle dq RVA _GetStdHandle
                WriteConsoleA dq RVA _WriteConsoleA
                dq 0

        kernel_name db 'KERNEL32.DLL', 0

        _GetStdHandle dw 0
                      db 'GetStdHandle', 0
        _WriteConsoleA dw 0
                      db 'WriteConsoleA', 0
buf_len = 20

        _message     db buf_len dup ' '
        _result      db 0
        _chars_written  dw ?
