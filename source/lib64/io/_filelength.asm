; _FILELENGTH.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include io.inc
include winbase.inc

    .code

_filelength PROC handle:SINT

  local FileSize:QWORD

    lea rax,_osfhnd
    mov rcx,[rax+rcx*8]
    .if GetFileSizeEx(rcx, &FileSize)

        mov rax,FileSize
    .else
        osmaperr()
        xor eax,eax
    .endif
    ret
_filelength ENDP

    END
