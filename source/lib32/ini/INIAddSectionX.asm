; INIADDSECTIONX.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include ini.inc
include stdio.inc

    .code

INIAddSectionX proc c ini:LPINI, format:LPSTR, argptr:VARARG


    .if ftobufin(format, &argptr)

        INIAddSection(ini, edx)
    .endif

    ret

INIAddSectionX endp

    END
