; ISXDIGIT.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include ctype.inc

    .code

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

isxdigit proc char:SINT
    lea rax,_ctype
    mov al,[rax+rcx*2+2]
    and eax,_HEX
    ret
isxdigit endp

    end

