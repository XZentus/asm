format PE64 console

entry start

section '.text' code readable executable

limit = 20
macro align value { rb (value-1)-($+value-1) mod value }

align 16
start:
        sub     rsp, 5*8

        lea     rsi, [_divisors]
        mov     edi, 1
        .get_divisors:
                inc     rdi
                call    update_divisors
                cmp     rdi, limit
                jbe     .get_divisors


        mov     ecx, limit
        .product_divisors:
                mov     bl, [_divisors + rcx]
                test    bl, bl
                jz      @f
                mov     rdi, rax
                xor     eax, eax
                inc     al
                .power:
                        mul     rcx
                        dec     bl
                        jnz     .power

                mul     rdi
                @@:
                loop    .product_divisors

        mov     rcx, rax
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

align 16
update_divisors:        ;rdi: Num rsi: ptr
        xor     edx, edx
        xor     r9b, r9b
        mov     rax, rdi
        .loop_2_d:
                cmp    rax, 1
                je     .end_2_power
                test   rax, 1
                jnz    .loop_2_dend
                inc    r9b
                shr    rax, 1
                jmp    .loop_2_d

        .loop_2_dend:

        cmp     r9b, [rsi + 2]
        jbe     @f
        mov     [rsi + 2], r9b
        @@:
        mov     ecx, 3
        mov     r8,  rax
        xor     r9d, r9d

        .loop_n_d:
                cmp    rax, 1
                je     .end_n
                xor    edx, edx
                div    rcx
                test   rdx, rdx
                jz     .loop_n_d_0rem
                cmp    r9b, [rsi + rcx]
                jbe    @f
                mov    [rsi + rcx], r9b
                @@:
                add    ecx, 2
                xor    r9d, r9d
                mov    rax, r8
                jmp    .loop_n_d
                .loop_n_d_0rem:
                inc    r9d
                mov    r8,  rax
                jmp    .loop_n_d

        .end_2_power:
        mov     ecx, 2
        .end_n:
        cmp     r9b, [rsi + rcx]
        jbe     @f
        mov     byte [rsi + rcx], r9b
        @@:
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

        _message       rb buf_len
        _result        db 0
        _chars_written rw 1
        _divisors      db limit dup 0
