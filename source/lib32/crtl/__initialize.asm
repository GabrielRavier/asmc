; __INITIALIZE.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include crtl.inc

    .code

__initialize proc uses esi edi ebx offset_start:PVOID, offset_end:PVOID

    mov edx,offset_start
    mov eax,offset_end
    sub eax,edx

    .ifnz

        mov esi,edx ; start of segment
        lea edi,[edx+eax]

        .while  1

            xor eax,eax
            mov ecx,256
            mov ebx,esi
            mov edx,edi

            .while  edi != ebx

                .if [ebx] != eax && ecx >= [ebx+4]

                    mov ecx,[ebx+4]
                    mov edx,ebx
                .endif
                add ebx,8
            .endw

            .break .if edx == edi

            mov ebx,[edx]
            mov [edx],eax
            call ebx
        .endw
    .endif
    ret

__initialize endp

    END
