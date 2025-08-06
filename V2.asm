
.286
;-------------------------------------------------------------------------

STACKSG SEGMENT

	PILA DW 0FFFH DUP(0)

STACKSG ENDS

;-------------------------------------------------------------------------

DATASG SEGMENT

;Variables

MAS_SLA 	DB	0;MASTER=0, SLAVE=1
;POSICIONES
PELX		DB	40
PELY		DB	12
MASY		DB	12
SLAY		DB	12
FILA		DB	0
COL			DB	0
SCRMAS		DB	0
SCRSLV		DB	0
;VARIOS
ESTADO		DB	0
DIR			DB	1
CONT		DB	0
PUNTM		DB	48
PUNTS		DB	48
GAMEO	DB	0
;CHAR
CAR			DB	0
ASC			DB	0
C_PEL		DB	7
C_JUG1		DB	176
C_JUG2		DB	178
C_BORR		DB	0
TECLA		DB	0
DATO		DB	0

FileName  	DB 	"obsta.txt",0
FileHandle 	DW 	0
Buffer    	DB  81	DUP(0)
BytesRead 	DW  	0




FileSize  	DD  	0
OFF			DW	0

;STRING
PUNT		DB	' MAS 0 - SLV 0 $'
MSG1		DB	'MASTER$'
MSG2		DB	'SLAVE$'
MSG3		DB	' --GAME OVER!-- $'
MSG4		DB	'GANO  $'
MSG5		DB	'ERROR AL CARGAR EL ARCHIVO! $'
DATASG ENDS

;-------------------------------------------------------------------

CODESG	SEGMENT

BEGIN PROC

	ASSUME SS:STACKSG,DS:DATASG,CS:CODESG
	MOV AX,DATASG ;Obtiene dirección de segmento de datos
	MOV DS,AX ;Se lo carga en DS
	MOV AX,0B800H
	MOV ES,AX ;SEGMENTO PANTALLA
	MOV DI,0

INICIO:
	CALL 	CLRSCR
	CALL	OBSTA

SALIR:
	CALL	GETKEY
	CMP		ASC,'q'
	JNE		SALIR
	MOV 	AX,4C00H
	INT 	21H
	BEGIN ENDP

;-------------------------------------------------------------------

OBSTA 	PROC
	
	PUSHA
	
	MOV		AX,3D00H	;READ ONLY
	MOV     DX,offset FileName
	INT	    21H
	MOV     [FileHandle],AX
	JC		FINOBSTAERR	;ERROR
	MOV		FILA,0
	MOV		COL,0
	CALL	SETCUR
LEO:
	MOV		AX,[BytesRead]
	mov     bx,[FileHandle]
    mov     dx,offset buffer
	mov     ah,3Fh
    mov     cx,80
    int     21h
	
	MOV 	SI,80
	MOV		AL,'$'
    LEA 	BX,buffer     
    MOV 	BX[SI],AL   ;EN AL TENGO EL ELEMENTO SI
	
	LEA		DX,BUFFER
	MOV		AH,9H
	INT		21H
	INC		FILA
	CMP		FILA,25
	JNE		LEO
	JC		FINOBSTAERR	;ERROR
	
FINLEO:
	MOV     BX,[FileHandle]
    MOV     AH,3EH
    INT     21H
	JC		FINOBSTAERR	;ERROR
	JMP		FINOBSTA
	
FINOBSTAERR:
	LEA		DX,MSG5
	MOV		AH,9H
	INT		21H
	
FINOBSTA:
	MOV		FILA,0
	MOV		COL,0
	CALL	SETCUR
	POPA
	RET

OBSTA 	ENDP


;-------------------------------------------------------------------
;PROCEDURES
;SETCUR POSICIONA EL CURSOR DE PANTALLA EN DH = FILA, DL = COLUMNA

SETCUR PROC
	
	PUSHA
	MOV AH,02H
	MOV BH,0
	MOV DH,FILA
	MOV DL,COL
	INT 10H
	POPA
	RET

SETCUR ENDP

;-------------------------------------------------------------------
;WRITE ESCRIBE CARACTER EN PANTALLA AL = character to display.

WRITE PROC

	PUSHA
	MOV AH,0AH
	MOV BH,0
	MOV AL,CAR
	MOV CX,1
	INT 10H
	POPA
	RET
	

WRITE ENDP
;-------------------------------------------------------------------
;WRITE ESCRIBE CARACTER EN PANTALLA AL = character to display.

BORRAR PROC

	PUSHA
	MOV AH,0AH
	MOV BH,0
	MOV AL,' '
	MOV CX,1
	INT 10H
	POPA
	RET
	
BORRAR ENDP

;-------------------------------------------------------------------

;GETKEY TOMA UNA TECLA AH = BIOS scan code, AL = ASCII character
;BORRA BUFFER.

GETKEY PROC

	PUSHA
	MOV 	AH,1
	INT 	16H
	JNZ		FINGETKEY
	MOV 	AH,0
	INT 	16H
	MOV 	TECLA,AH
	MOV 	ASC,AL
FINGETKEY:
	POPA
	RET	

GETKEY ENDP
;-------------------------------------------------------------------
WAITKEY PROC
	PUSHA
	MOV 	AH,0
	INT 	16H
	MOV 	TECLA,AH
	MOV 	ASC,AL
FINWAITKEY:
	POPA
	RET	

WAITKEY ENDP
;-------------------------------------------------------------------
DELAY PROC
	MOV		BX,01FFH
B1:
	MOV		AX,0FFFFH
B2:
	DEC		AX
	JNZ		B2
B3:
	DEC		BX
	JNZ		B1
	RET
DELAY ENDP
;--------------------------------------------------------------------

CLRSCR PROC

	MOV	FILA,0
	MOV	COL,0
	MOV	CAR,' '
BORR:
	MOV	DH,FILA
	MOV	DL,COL
	CALL	SETCUR
	CALL	WRITE
	INC	COL
	CMP	COL,80
	JL	BORR
	MOV	COL,0
	INC	FILA
	CMP	FILA,24
	JL	BORR
	MOV	FILA,0
	MOV	COL,0
	CALL	SETCUR
	RET

CLRSCR ENDP	 
;-------------------------------------------------------------------

GUI PROC
	MOV	COL,0
	MOV	FILA,0
MARCOSUP:
	MOV	CAR,205
	CALL	SETCUR
	CALL	WRITE
	INC	COL
	CMP	COL,80
	JNE	MARCOSUP
CENTRO:
	MOV	COL,35
	MOV	FILA,0
	CALL	SETCUR	
	LEA	DX,PUNT
	MOV	AH,9H
	INT	21H
	RET

GUI ENDP      
;-------------------------------------------------------------------

PRINTMAS PROC
	
	PUSHA
	MOV	COL,0
	MOV	AH,MASY
	DEC	AH
	MOV	FILA,AH
	MOV	CAR,176;CARACTER DEL J1
	CALL	SETCUR
	CALL	WRITE
	INC	FILA
	CALL	SETCUR
	CALL	WRITE
	INC	FILA
	CALL	SETCUR
	CALL	WRITE
	POPA
	RET

PRINTMAS ENDP

;-------------------------------------------------------------------

PRINTSLV PROC
	
	PUSHA
	MOV	COL,79
	MOV	AH,SLAY
	DEC	AH
	MOV	FILA,AH
	MOV	CAR,178;CARACTER DEL J1
	CALL	SETCUR
	CALL	WRITE
	INC	FILA
	CALL	SETCUR
	CALL	WRITE
	INC	FILA
	CALL	SETCUR
	CALL	WRITE
	POPA
	RET

PRINTSLV ENDP
;-------------------------------------------------------------------
CODESG ENDS

END BEGIN
