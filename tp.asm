;Dado un archivo que contiene n números en BPF c/signo de 8 bits (n <= 30) se pide codificar en
;assembler Intel 80x86 un programa que imprima por pantalla que movimiento se realiza (por ejemplo
;“Iniciando el ciclo de i menor a la longitud del vector”) y contenido de dicho archivo ordenado en forma
;ascendente o descendente de acuerdo a lo que elija el usuario, usando un algoritmo de ordenamiento
;basado en el método de inserción.
;procedure insercion (int[] vector)
;   i ← 1
;   while i < length(vector)
;       j ← i
;           while j > 0 and vector[j-1] > vector[j]
;               swap vector[j] and vector[j-1]
;               j ← j - 1
;           end while
;       i ← i + 1
;   end while
;end procedure
;El método de ordenamiento por inserción es una manera muy natural de ordenar para un ser humano.
;Inicialmente se tiene un solo elemento, que obviamente es un conjunto ordenado. Después, cuando
;hay k elementos ordenados de menor a mayor, se toma el elemento k+1 y se compara con todos los
;elementos ya ordenados, deteniéndose cuando se encuentra un elemento menor (todos los elementos
;mayores han sido desplazados una posición a la derecha) o cuando ya no se encuentran elementos
;(todos los elementos fueron desplazados y este es el más pequeño). En este punto se inserta el
;elemento k+1 debiendo desplazarse los demás elementos
;Nota: no es correcto generar el archivo con un editor de textos de forma tal que cada registro sea una tira de 16
;caracteres 1 y 0. Se aconseja el uso de un editor hexadecimal.

global main
extern 		printf
extern 		fopen
extern 		fclose
extern 		fread
extern 		gets
extern 		sscanf
extern  	puts

section  .data
	nombreArchivo                       db 'numeros_2.dat',0
    modoArchivo                         db "rb+",0
    msjErrorArchivo                     db 'Error al abrir el archivo',10,0

    msjBienvenida                       db 'Bienvenido usted tiene los siguientes numeros: ', 0
    msjPedirOpcion                      db 'Ingrese 1 si desea ordenarlos de mayor a menor o 2 si desea ordenarlos de menor a mayor',10, 0
    formatoIngresado                    db 'hhi',0

    msjErrIngreso                       db 'Error de ingreso numero ingresado no valido',10,0

    msjVectorOrdenado                   db 10,'    »Los numeros quedaron ordenados de la siguiente forma: ',0

    msjIniciadoCiclo                    db 10,'    »Iniciando el ciclo de i = %hhi menor a la longitud del vector.....',10,10,0

    msjNuevoOrd                         db 'Nuevo orden: ',10,0

    msjTope								db	"El top es: %hhi",10,0
    msjNumeroIngresado                  db	"Numero ingresado = %hhi",10,0
    msjI							    db	"i = %hhi",10,0
    msjJ								db	"j =  %hhi",10,0
    msjVec								db	"| %hhi ",0
    msjVecJ_1							db	" Vec[%hhi] = %hhi",10,0
    msjVecJ							    db	" Vec[%hhi] = %hhi",10,0
    msjSalto							db	'| ',10,0

    msjDatoValido                       db	"Dato Valido es: %c",10,0

    tope                                db  0
    i                                   db  1
    j                                   db  1

    registro            times 0         db ''
        dato            times 1         db 0
    numeroFormato						db	'%hi',0


section  .bss
    handleArchivo               resq    1
    numIngStr                   resb    1
    numIng                      resb    1
    datoValido                  resb    1
    vector          times 30    resb    1
    vectorJ_1                   resb    1
    vectorJ                     resb    1
    aux                         resb    1
    datoIngresado				resb	10
	numero      				resw 	1
	plusRsp						resq	1

section .text
main:
    sub     rsp,8

    call    abrirArchivo

    call    leerArchivo

    call    imprimirMsjBienvenida

    call    pedirTipoOrd

    call    ordenarVector         

    jmp     finPrograma
errorAperturaArchivo:
    mov     rdi, msjErrorArchivo
    call    printf
finPrograma:
    mov		rdi,msjVectorOrdenado
    sub		rax,rax
	call	printf
    call    imprimirVector

    add     rsp,8
    ret
;------------------------------------------------------
;   ABRIR EL ARCHIVO
;------------------------------------------------------
abrirArchivo:
    mov     rdi, nombreArchivo
    mov     rsi, modoArchivo
    call    fopen
    mov     qword[handleArchivo], rax
    cmp		qword[handleArchivo],0
    je		errorAperturaArchivo
    ret
;------------------------------------------------------
;   Leer archivo y cargar en la matriz
;------------------------------------------------------
leerArchivo:
leerVector:
    mov     rdi, registro
    mov     rsi, 1
    mov     rdx, 1
    mov     rcx, qword[handleArchivo]
    call    fread
    cmp		rax,0				
	jle	    finArchivo

    inc     byte[tope]

    mov     cl,byte[tope]

    mov     rax, 0
    mov     rbx, 0

    dec     cl
    ;mov	    ebx,ecx
    mov     al, [dato]
    mov		byte[vector + ecx], al

    cmp     byte[tope],30
    
    jle     leerVector

finArchivo:
    mov		rdi, [handleArchivo]
	call	fclose
    ret
;------------------------------------------------------
;   Pedir opcion
;------------------------------------------------------
pedirTipoOrd:
    mov     rdi, msjPedirOpcion
    sub     rax, rax
    call    printf

    mov		rdi,datoIngresado
	call	gets

	mov 	rdi,datoIngresado
	mov		rsi,numeroFormato
	mov 	rdx,numero
    call	checkAlign
	sub		rsp,[plusRsp]
	call	sscanf
	add		rsp,[plusRsp]

    call    validarIngreso
    cmp     byte[datoValido], 'N'

    je      errorIngreso

    ret
errorIngreso:
    mov		rdi,msjErrIngreso
    sub		rax,rax
	call	printf

    call     pedirTipoOrd
validarIngreso:
    mov     byte[datoValido], 'N'

    cmp     word[numero], 1
    jl      finValidacionIngreso

    cmp     word[numero], 2
    jg      finValidacionIngreso

    mov     byte[datoValido], 'S'
finValidacionIngreso:
    ret



ordenarVector:
    mov     al, 0
    mov     al, byte[tope]
    sub     al, byte[i]

    cmp     al, 0
    jg      ordenar
    
    ret

ordenar:
    call    imprimirIniciadoCiclo
    call    imprimirVector

    mov     al, 0
    mov     al, byte[i]
    mov     byte[j], al

verficarMayoroMenor:
    mov     cl,byte[j]

    mov     rax, 0
    mov     rbx, 0

    dec     cl
    ;mov	    ebx,ecx
    mov		al, byte[vector + ecx]
    mov     byte[vectorJ_1], al

    mov     cl,byte[j]

    mov     rax, 0
    mov     rbx, 0

    ;mov	    ebx,ecx
    mov		al, byte[vector + ecx]
    mov     byte[vectorJ], al

    call    tipoOrdenamiento

desincrementarJ:
    dec     byte[j]

    cmp     byte[j],0
    jg      verficarMayoroMenor

    inc     byte[i]

    jmp    ordenarVector

swap:
    call    imprimirVecJ_1

    mov     al, byte[vectorJ_1]
    mov     byte[aux], al

    mov     cl,byte[j]

    mov     rax, 0
    mov     rbx, 0

    dec     cl
    ;mov	    ebx,ecx
    mov		al, byte[vectorJ]
    mov     byte[vector + ecx], al

    mov     cl,byte[j]

    mov     rax, 0
    mov     rbx, 0

    ;mov	    ebx,ecx
    mov		al, byte[aux]
    mov     byte[vector + ecx], al

    call    imprimirVector

    jmp     desincrementarJ
tipoOrdenamiento:
    cmp     byte[numero], 1
    je      ordenamientoCreciente
    
    mov     al, byte[vectorJ_1]
    cmp     al, byte[vectorJ]

    jg      swap

    ret
ordenamientoCreciente:
    mov     al, byte[vectorJ_1]
    cmp     al, byte[vectorJ]

    jl      swap

    ret

imprimirVector:
	mov		cl,byte[tope]
	mov     bl, 0

sigPosicion:
	push	rcx

    mov		rdi,msjVec
	sub		rsi,rsi
	mov		esi,[vector + ebx]
    sub		rax,rax
	call	printf
    
    pop		rcx
    inc     bl

	loop	sigPosicion	

    mov		rdi,msjSalto
    sub		rax,rax
	call	printf

    ret

imprimirIniciadoCiclo:
    mov		rdi,msjIniciadoCiclo
	sub		rsi,rsi
	mov		esi,[i]
    sub		rax,rax
	call	printf
ret

imprimirI:
    mov		rdi,msjI
	sub		rsi,rsi
	mov		esi,[i]
    sub		rax,rax
	call	printf
ret

imprimirJ:
    mov		rdi,msjJ
	sub		rsi,rsi
	mov		esi,[j]
    sub		rax,rax
	call	printf
ret

imprimirVecJ_1:
    mov		rdi,msjVecJ_1
	sub		rsi,rsi
    sub		rdx,rdx
	mov		esi,[j]
    dec     esi
	mov		edx,[vectorJ_1]
    sub		rax,rax
	call	printf
imprimirVecJ:
    mov		rdi,msjVecJ
	sub		rsi,rsi
    sub		rdx,rdx
	mov		esi,[j]
	mov		edx,[vectorJ]
    sub		rax,rax
	call	printf
ret

imprimirMsjBienvenida:
    mov     rdi, msjBienvenida
    sub     rax, rax
    call    printf

    call    imprimirVector
ret

;----------------------------------------
;----------------------------------------
; ****	checkAlign ****
;----------------------------------------
;----------------------------------------
checkAlign:
	push rax
	push rbx
;	push rcx
	push rdx
	push rdi

	mov   qword[plusRsp],0
	mov		rdx,0

	mov		rax,rsp		
	add     rax,8		;para sumar lo q restó la CALL 
	add		rax,32	;para sumar lo que restaron las PUSH
	
	mov		rbx,16
	idiv	rbx			;rdx:rax / 16   resto queda en RDX

	cmp     rdx,0		;Resto = 0?
	je		finCheckAlign
;mov rdi,msj
;call puts
	mov   qword[plusRsp],8
finCheckAlign:
	pop rdi
	pop rdx
;	pop rcx
	pop rbx
	pop rax
	ret

