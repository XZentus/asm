format PE64 GUI

entry start

section '.text' readable executable code

start:
        mov eax, 1
        mov ebx, 1
        xor ecx, ecx

loopiter:
                add ebx, eax
                add eax, ebx

                xor edx, edx
                xor r8d, r8d
                test eax, 1
                cmove edx, eax
                add ecx, edx

                test ebx, 1
                cmove r8d, ebx
                add ecx, r8d

                cmp eax, 4000000
                jb loopiter

        lea rdx, [_message_end - 1]
        call print10base


        sub rsp, 8*5


        mov     r9d, 0
        lea     r8,  [_caption]
        lea     rdx, [_message]
        mov     rcx, 0
        call    [MessageBoxA]

        mov     ecx,eax
        call    [ExitProcess]

print10base:           ;print10Base(rcx: unsigned number, rdx: ptr_back)

        mov rbx, rdx ; rbx: ptr
        mov rdi, rcx ; rdi: number

        p10loop:
                mov rdx, 0xCCCCCCCCCCCCCCCD ;-3689348814741910323
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

section '.idata' import data readable writable

  dd 0,0,0,RVA kernel_name,RVA kernel_table
  dd 0,0,0,RVA user_name,RVA user_table
  dd 0,0,0,0,0

  kernel_table:
    ExitProcess dq RVA _ExitProcess
    dq 0
  user_table:
    MessageBoxA dq RVA _MessageBoxA
    dq 0

  kernel_name db 'KERNEL32.DLL',0
  user_name db 'USER32.DLL',0

  _ExitProcess dw 0
    db 'ExitProcess',0
  _MessageBoxA dw 0
    db 'MessageBoxA',0

  msg_len = 20
  _caption        db 'Result', 0
  _message:       rept 30 { db ' ' }
  _message_end    db 0
