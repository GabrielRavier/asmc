system.exe:
    asmc -q -pe $*.asm
    echo PE-WIN32A:
    $@
    pause
    del $@
    asmc -q -pe -D_WIN64 $*.asm
    echo PE-WIN64A:
    $@
    pause
    del $@

