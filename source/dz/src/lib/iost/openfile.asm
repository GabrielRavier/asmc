include io.inc
include iost.inc
include dzlib.inc

    .code

openfile proc fname:LPSTR, mode, action

    .if osopen(fname, _A_NORMAL, mode, action) == -1

        eropen(fname)
    .endif
    ret

openfile endp

    END
