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

        nop

        lea eax, [array]
        mov edx, 0

loop2:
        cmp [eax], edx
        cmova edx, [eax]
        add eax, 4
        cmp eax, stop
        jb loop2

        nop

        sub rsp, 8*5         ; reserve stack for API use and make stack dqword aligned

        mov     r9d,0
        lea     r8,[_caption]
        lea     rdx,[_message]
        mov     rcx, 0
        call    [MessageBoxA]

        mov     ecx,eax
        call    [ExitProcess]


section '.data' data readable writable

array dd 12, 32, 1, 0, 17
stop  dd ?

_caption        db 'Result', 0
_message        db 0,0,0,0,0,0,0,0,0,0,0
_label          db ?

section '.idata' import data readable writeable

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
