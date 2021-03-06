; STRFN.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
; char *strfn(char *path);
;
; EXIT: file part of path if /\ is found, else path
;
include string.inc
include strlib.inc

	.code

	option stackbase:esp

strfn	proc uses edi ecx path:LPSTR
	mov	edi,path
	strlen( edi )
	lea	eax,[edi+eax-1]
@@:
	cmp	byte ptr [eax],'\'
	je	@F
	cmp	byte ptr [eax],'/'
	je	@F
	dec	eax
	cmp	eax,edi
	ja	@B
	lea	eax,[edi-1]
@@:
	inc	eax
	ret
strfn	ENDP

	END
