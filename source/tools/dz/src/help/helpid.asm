include io.inc
include fcntl.inc
include string.inc
include stdio.inc
include malloc.inc
include stdlib.inc

    .data

id_1	db 10,"<> Memory Requirements",0
id_2	db 10,"<> Compressed File Support",0
id_3	db 10,"<> Viewer Support",0
id_4	db 10,"<> Editor Support",0
id_5	db 10,"<> Internal Editor",0
id_6	db 10,"<> Extension and Filename Support",0
id_7	db 10,"<> Doszip Commander Environment Variables",0
id_8	db 10,"<> Installing Commander under Windows",0
id_9	db 10,"<> Creating a tools menu",0
id_A	db 10,"<> The File Search utility",0
id_B	db 10,"<> Create List File",0
id_C	db 10,"<> Operation Filter",0
id_D	db 10,"<> Shortcut keys",0
id_E	db 10,"<> Compare Directories",0
id_F	db 10,"<> Configuration Defaults",0
id_G	db 10,"<> Hex Editor",0

table	dd 0
	dd id_1,id_2,id_3,id_4,id_5,id_6,id_7
	dd id_8,id_9,id_A,id_B,id_C,id_D,id_E
	dd id_F,id_G

    .code

main proc c uses esi edi ebx

    .if _open("dz.txt", O_RDONLY or O_BINARY) != -1

	mov esi,eax
	mov ebx,filelength(esi)
	inc eax

	.if malloc(eax)

	    mov edi,eax
	    mov byte ptr [edi+ebx],0
	    _read(esi, eax, ebx)
	    _close(esi)

	    .if fopen("helpid.inc", "wt")

		mov ebx,eax
		fprintf(ebx, ".xlist\n")

		.for esi = 1 : esi < 17 : esi++

		    mov edx,table[esi*4]
		    .if strstr(edi, edx)

			sub eax,edi
			add eax,1
			add edx,1

			fprintf(ebx, "HELPID_%02d\tequ %04Xh\t; %s\n",
			    esi, eax, edx)
		    .endif
		.endf
		fprintf(ebx, ".list\n")
		fclose(ebx)
	    .endif
	    free(edi)
	.else
	    _close(esi)
	.endif
    .else
	perror("dz.txt")
    .endif
    xor eax,eax
    ret

main endp

    END
