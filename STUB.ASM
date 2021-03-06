
; ��� void three extender ��� (c) 2k-1 by franky@scene.at ���

	.586p
	.SEQ

        MEM_POOL  =     16 SHL 20	;16 MB memory pool

	ASSUME		CS:HYBRID, DS:HYBRID
        HYBRID  GROUP   CODE_16, CODE_32, DATA, ZDATA

	CODE_16		SEGMENT BYTE USE16
	CODE_16		ENDS

	CODE_32 	SEGMENT BYTE USE32
	CODE_32		ENDS

	DATA		SEGMENT BYTE USE16
	DATA		ENDS

        ZDATA           SEGMENT DWORD USE16
        ZDATA		ENDS

	SCREEN		SEGMENT AT 0a000h
	SCREEN		ENDS

;   �����������������������������������������������

	CODE_16		SEGMENT

        ORG     100h                    ;����� program entry �����

rm_main:
        lea     di, ZERO_START		;��� clear zero data ���
	mov	ch, 55000 SHR 8
	rep	stosb

        mov     ax, 1687h               ;��� DPMI installed? ���
	int     2fh
	inc	ax
	and	bx, ax			;32-bit host ?
        jnz     @@dpmi

        lea     dx, no_dpmi		;error, exit
        mov     ah, 9h
	int     21h
	ret

no_dpmi db      "no DPMI host found! please start in w95/w98 dosbox!$"

@@dpmi:
	push	es di

        mov     ax, cs                  ;��� get linear address ���
        imul    eax, -16
	push	eax

	CODE_16		ENDS

include franky.rm			;franky: RM code
include shiva.rm			;shiva : RM code

        CODE_16         SEGMENT

	pop	ebp			;ebp = linear address

        mov     bx, ds			;��� 16-bit PM switch ���
        add	bh, 10h
        mov     es, bx
        xor     ax, ax
        inc     ax
        call    dword ptr [ esp ]
pm_16:
	mov	al, 0ah			;��� get alias ���
	mov	bx, cs
	int	31h
	xchg	bx, ax

	mov	al, 08h			;��� set limit ���
	stc
	sbb	cx, cx
	sbb	dx, dx
	int	31h

	inc	ax			;��� set rights ���
	mov	cx, 1101111111111011b
	int	31h

        push    bx                      ;��� 32-bit PM switch ���
	push	OFFSET pm_32
        retf
pm_32:
	CODE_16 	ENDS

	CODE_32		SEGMENT
					;��� 32-bit PM entry ���
        inc     eax
	int	31h
	push	eax
	pop	ds			;set up DS, ES, SS
	push	eax
	pop	es
	push	eax
	pop	ss

	mov	ax, 0501h		;��� create memory pool ���
	xor	ecx, ecx
	mov	bx, MEM_POOL SHR 16
	int	31h
	shl	ebx, 16
	add	ebp, ebx
	add	ebp, ecx		;[ebp] -> memory pool

        xor     eax, eax
        mov     ecx, MEM_POOL - 1       ;��� clear mem-pool ���
	mov	edi, ebp
	rep	stosb

	CODE_32		ENDS

include shiva.mac
include	franky.pm
include shiva.pm

        END	rm_main


