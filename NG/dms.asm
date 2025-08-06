.286

CODIGO SEGMENT
        ASSUME cs:CODIGO,ds:CODIGO,ss:CODIGO
	
	org 100h        
begin:
	
	jmp start

Victor     dw 2
Cont    dw 1 dup (364)          ;Son 20 Seg.
Pila 	db 40 dup ('PILA')
PilaEnd db 1

start:
	
        mov ax,offset PilaEnd
	mov sp,ax
	call SetVector	
pipi:   jmp pipi

;	mov ax,4c00h
;	int 21h

proc	SetVector
	
	mov ah,35h
	mov al,08h
	int 21h
        mov Victor,bx
        mov Victor+2,es

        mov ax,SEG RutInt
        mov ds,ax
        mov dx,OFFSET RutInt
	mov ah,25h
	mov al,08h

	int 21h
	ret

endp	SetVector

proc RutInt
     pusha
    
     dec Cont
     jnz fin
     mov ah,0ah
     mov al,30h
     mov cx,01h         
     mov bx,0h
     int 10h
     ;mov Cont,364

fin:
     popa
     jmp Victor
     
endp RutInt

CODIGO ENDS
end begin

