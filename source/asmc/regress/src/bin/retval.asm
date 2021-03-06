;
; Return value adaptation:
;
; Nested function calls adapts to argument size.
; Assigned values adapts to target size if possible,
; else default is used ([R|E]AX).
;
    .x64
    .model flat, fastcall
    .code

id1  label byte
id2  label word
id4  label dword
id8  label qword
id16 label oword

foo proc
    ret
foo endp

    add     al,   foo()
    add     ax,   foo()
    add     eax,  foo()
    add     rax,  foo()
    addps   xmm2, foo()

    mov     id1,  foo()
    mov     id2,  foo()
    mov     id4,  foo()
    mov     id8,  foo()
    movups  id16, foo()

bar proc x:real4, y:real16
    ret
bar endp

    bar(bar(xmm0, xmm1), xmm1)

    end
