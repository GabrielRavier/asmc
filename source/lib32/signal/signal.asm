; SIGNAL.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include stdio.inc
include stdlib.inc
include signal.inc
include crtl.inc

EH_STACK_INVALID    equ 08h
EH_NONCONTINUABLE   equ 01h
EH_UNWINDING        equ 02h
EH_EXIT_UNWIND      equ 04h
EH_NESTED_CALL      equ 10h

    .data

pCurrentException   PEXCEPTION_POINTERS 0
pExceptionReg       PEXCEPTION_REGISTRATION 0
sig_table           dd NSIG dup(0)

    .code

ExceptionHandler proc C private,
    ExceptionRecord:    ptr EXCEPTION_RECORD,
    EstablisherFrame:   ptr dword,
    ContextRecord:      ptr EXCEPTION_CONTEXT,
    DispatcherContext:  ptr dword

local CurrentException: EXCEPTION_POINTERS

    mov ecx,ExceptionRecord
    mov edx,ContextRecord

    mov CurrentException.ExceptionRecord,ecx
    mov CurrentException.ContextRecord,edx
    lea eax,CurrentException
    mov pCurrentException,eax

    mov eax,[ecx].EXCEPTION_RECORD.ExceptionFlags

    .repeat

        .switch
          .case eax & EH_UNWINDING
          .case eax & EH_EXIT_UNWIND
            raise(SIGTERM)
            .break
          .case eax & EH_STACK_INVALID
          .case eax & EH_NONCONTINUABLE
            raise(SIGSEGV)
            .break
          .case eax & EH_NESTED_CALL
            exit(1)
        .endsw

        mov eax,[ecx].EXCEPTION_RECORD.ExceptionCode
        .switch eax

          .case EXCEPTION_ACCESS_VIOLATION
          .case EXCEPTION_ARRAY_BOUNDS_EXCEEDED
          .case EXCEPTION_DATATYPE_MISALIGNMENT
          .case EXCEPTION_STACK_OVERFLOW
          .case EXCEPTION_IN_PAGE_ERROR
          .case EXCEPTION_INVALID_DISPOSITION
          .case EXCEPTION_NONCONTINUABLE_EXCEPTION
            raise(SIGSEGV)
            .endc

          .case EXCEPTION_SINGLE_STEP
          .case EXCEPTION_BREAKPOINT
            raise(SIGINT)
            .endc

          .case EXCEPTION_FLT_DENORMAL_OPERAND
          .case EXCEPTION_FLT_DIVIDE_BY_ZERO
          .case EXCEPTION_FLT_INEXACT_RESULT
          .case EXCEPTION_FLT_INVALID_OPERATION
          .case EXCEPTION_FLT_OVERFLOW
          .case EXCEPTION_FLT_STACK_CHECK
          .case EXCEPTION_FLT_UNDERFLOW
            raise(SIGFPE)
            .endc

          .case EXCEPTION_ILLEGAL_INSTRUCTION
          .case EXCEPTION_INT_DIVIDE_BY_ZERO
          .case EXCEPTION_INT_OVERFLOW
          .case EXCEPTION_PRIV_INSTRUCTION
            raise(SIGILL)
            .endc

        .endsw
    .until 1
    mov eax,ExceptionContinueSearch
    ret

ExceptionHandler endp

signal proc index:dword, func:PVOID
    mov edx,index
    mov ecx,func
    mov eax,sig_table[edx*4]
    mov sig_table[edx*4],ecx
    ret
signal endp

raise proc index:dword
    mov ecx,index
    mov eax,sig_table[ecx*4]
    .if eax
        push ecx
        call eax
        add  esp,4
    .endif
    ret
raise endp


ExcInstall:
;
; allocate 8 bytes on the stack for EXCEPTION_REGISTRATION
;
    sub     esp,8
    mov     edx,edi
    mov     eax,esi
    mov     edi,esp
    lea     esi,[edi+8]
    mov     ecx,7
    rep     movsd
    mov     pExceptionReg,edi
    xchg    esi,eax
    xchg    edi,edx
    assume  FS:nothing
    mov     eax,FS:[0]
    mov     [edx].EXCEPTION_REGISTRATION.prev,eax
    mov     [edx].EXCEPTION_REGISTRATION.handler,ExceptionHandler
    mov     FS:[0],edx
    assume  FS:ERROR
    ret

ExcRemove:
    mov     eax,pExceptionReg
    mov     eax,[eax].EXCEPTION_REGISTRATION.prev
    assume  FS:nothing
    mov     FS:[0],eax
    assume  FS:ERROR
    ret

.pragma(init(ExcInstall, 1))
.pragma(exit(ExcRemove, 200))

    END
