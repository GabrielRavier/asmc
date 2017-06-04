include consx.inc
include winuser.inc

	.code

SetKeyState PROC USES esi edi eax
	mov	edi,keyshift
	mov	esi,[edi]
	and	esi,not 01FF030Fh

	GetKeyState(VK_LSHIFT)
	.if	ah & 80h
		or esi,SHIFT_LEFT or SHIFT_KEYSPRESSED
	.endif
	GetKeyState(VK_RSHIFT)
	.if	ah & 80h
		or esi,SHIFT_RIGHT or SHIFT_KEYSPRESSED
	.endif
	GetKeyState(VK_LCONTROL)
	.if	ah & 80h
		or esi,SHIFT_CTRLLEFT
	.endif
	GetKeyState(VK_RCONTROL)
	.if	ah & 80h
		or esi,SHIFT_CTRL
	.endif
	mov	[edi],esi
	ret
SetKeyState ENDP

	END
