.386
.model flat, c
.stack 4096

; Estructura del libro (ajustado para incluir copiasTotales):
; struct libro {
;     char nombreLibro[100];  ; offset 0
;     char autorLibro[100];   ; offset 100 
;     int anoLibro;           ; offset 200
;     int cantidadLibros;     ; offset 204
;     int copiasTotales;      ; offset 208
; };
; Total: 212 bytes

.DATA
libros DB 10600 dup(?) ;50 libros por 212 bytes por libro
librosTotales DWORD 0

.CODE
agregarLibro PROC
    push ebp
    mov ebp, esp
    
    ;registros que vamos a usar
    push esi
    push edi
    push ebx
    push ecx
    
    ;puntero del libro nuevo
    mov esi, [ebp + 8]
    
    ; Verificar primero si el libro ya existe para solo actualizar la cantidad
    mov ecx, librosTotales
    cmp ecx, 0
    je nuevoLibro        ; Si no hay libros, ir directo a agregar
    
    xor ebx, ebx         ; Contador de libros
    
buscarExistente:
    ; Calcular dirección del libro actual
    mov edi, OFFSET libros
    mov eax, 212
    mul ebx
    add edi, eax
    
    ; Comparar títulos
    push dword ptr [ebp + 8]  ; Libro nuevo
    push edi                  ; Libro actual
    call compararTitulos
    
    cmp eax, 1
    jne siguienteLibro
    
    ; Si encontramos el mismo libro, solo actualizamos la cantidad
    mov ecx, [esi + 204]      ; cantidadLibros del libro nuevo
    add [edi + 204], ecx      ; Agregar a cantidadLibros existente
    mov ecx, [esi + 208]      ; copiasTotales del libro nuevo
    add [edi + 208], ecx      ; Agregar a copiasTotales existente
    
    mov eax, 1                ; Éxito
    jmp salir
    
siguienteLibro:
    inc ebx
    cmp ebx, [librosTotales]
    jl buscarExistente
    
nuevoLibro:
    ; Verificar si hay espacio para un nuevo libro
    mov eax, librosTotales
    cmp eax, 50
    jge finalizar          ; Si ya hay 50 libros diferentes, salir
    
    ; Calcular la posición del libro nuevo
    mov edi, OFFSET libros
    mov eax, 212
    mul dword ptr [librosTotales]
    add edi, eax
    
    mov esi, [ebp + 8]
    
    ; Copiar el libro nuevo
    mov ecx, 212
    cld
    rep movsb
    
    inc dword ptr [librosTotales]
    
    mov eax, 1
    jmp salir
    
finalizar:
    mov eax, 0
    
salir:
    pop ecx
    pop ebx
    pop edi
    pop esi
    
    pop ebp
    ret
agregarLibro ENDP

prestarLibro PROC
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx
    push ecx
    push edx
    
    mov esi, [ebp + 8]       ;titulo a buscar
    mov ecx, librosTotales
    cmp ecx, 0
    je fin                   ;si no hay libros, terminar
    
    mov ebx, 0               ;indice del libro actual
    mov edx, 0               ;contador de libros prestados
    
buscarLibro:
    ;direccion libro actual
    mov edi, OFFSET libros
    mov eax, 212             
    mul ebx
    add edi, eax
    
    push esi                 
    push edi                
    call compararTitulos
    
    cmp eax, 1
    jne siguienteLibro
    
    mov eax, [edi + 204]     ; cantidadLibros en offset 204
    cmp eax, 0
    jle siguienteLibro       
    
    dec dword ptr [edi + 204]  ; Decrementar cantidadLibros
    inc edx                  
    
siguienteLibro:
    inc ebx                  ;indice del libro actual
    cmp ebx, ecx             
    jl buscarLibro           
    
fin:
    mov eax, edx            
    
    pop edx
    pop ecx
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret
prestarLibro ENDP

devolverLibro PROC
    ;registros que vamos a usar
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx
    push ecx
    push edx

    ;ver si quedan libros
    mov esi, [ebp + 8]
    mov ecx, librosTotales
    cmp ecx, 0
    je salir

    mov ebx, 0

    buscarLibro:
        mov edi, OFFSET libros
        mov eax, 212
        mul ebx
        add edi, eax

        push esi
        push edi
        call compararTitulos

        cmp eax, 1
        je encontrado

        inc ebx
        cmp ebx, ecx
        jl buscarLibro
        jmp noEncontrado

    encontrado:
        ; Verificar si hay copias prestadas
        ; Necesitamos verificar que el número actual de copias sea menor
        ; que el número total de copias del libro
        mov edx, [edi + 204]        ; cantidadLibros (copias disponibles actualmente)
        
        ; Comprobamos si podemos devolver un libro
        mov eax, [edi + 208]        ; copiasTotales en offset 208
        cmp edx, eax                ; Comparar disponibles con total
        jge noPuedeDevolverse       ; Si disponibles >= total, no se puede devolver más
        
        ; Si se puede devolver, incrementamos el contador de copias disponibles
        inc dword ptr [edi + 204]   ; Incrementamos cantidadLibros
        mov eax, 1
        jmp salir

    noPuedeDevolverse:
        mov eax, 2                  ; Código de error específico: no hay copias prestadas
        jmp salir

    noEncontrado:
        mov eax, 0

    salir:
        pop edx
        pop ecx
        pop ebx
        pop esi
        pop edi
        pop ebp

        ret
devolverLibro ENDP

buscarLibro PROC
    ;guardamos registros que vamos a usar
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ;parametros de la funcion
    mov edx, [ebp + 8]     
    mov edi, [ebp + 12]    
    
    ;verificar si hay libros
    cmp dword ptr [librosTotales], 0
    je noLibros
    
    xor ebx, ebx           ;libro actual
    xor ecx, ecx           ;contador de libros encontrados
    
buscarLoop:
    ;calcular direccion del libro actual
    push edx               ; Guardar título a buscar
    mov eax, ebx
    imul eax, 212          ; Tamaño de cada libro (212 bytes)
    lea esi, [libros + eax] 
    
    push edx              
    push esi               
    call compararTitulos   
    
    pop edx                
    
    test eax, eax
    jz siguienteLibro     
    
    ;si coincide copiar el libro
    push edx               
    
    ;calcular direccion del libro actual de nuevo
    mov eax, ebx
    imul eax, 212          ; Tamaño de cada libro
    lea esi, [libros + eax]
    
    ;calcular posicion en el arreglo destino
    mov eax, ecx           
    imul eax, 212          ; Usar el tamaño completo (212 bytes)
    add eax, [ebp + 12]    
    mov edi, eax           
    
    ;copiar todo el libro (53 dwords = 212 bytes)
    mov ecx, 53            
    cld                 
    rep movsd
    
    ;incrementar contador de libros encontrados
    pop edx              
    inc ecx
    
siguienteLibro:
    inc ebx
    cmp ebx, dword ptr [librosTotales]
    jl buscarLoop
    
    mov eax, ecx
    jmp fin
    
noLibros:
    xor eax, eax         
    
fin:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret
buscarLibro ENDP 

mostrarLibros PROC
    push ebp 
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov edi, [ebp + 8]
    mov eax, librosTotales
    cmp eax, 0
    je sinLibros
    
    mov esi, OFFSET libros
    mov ecx, librosTotales
    mov ebx, 0              ;contador para recorrer los libros
    
recorrerLibros:
    ;calcular direccion origen 
    mov esi, OFFSET libros
    push eax
    mov eax, 212            ; Tamaño de cada libro
    mul ebx
    add esi, eax
    pop eax
    
    ;calcular direccion para guardar la info
    mov edi, [ebp + 8]      ;puntero del arreglo destino
    push eax
    mov eax, 212            ; Tamaño completo (212 bytes)
    mul ebx
    add edi, eax
    pop eax
    
    ;copiar el libro
    push ecx
    mov ecx, 212            ; Tamaño total a copiar (incluye copiasTotales)
    cld
    rep movsb
    pop ecx
    
    inc ebx
    cmp ebx, ecx
    jl recorrerLibros
    
sinLibros:
    mov eax, librosTotales
    
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret
mostrarLibros ENDP


compararTitulos PROC
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ecx
    
    mov edi, [ebp + 8]      ;puntero al libro actual
    mov esi, [ebp + 12]     ;titulo a buscar
    
    mov ecx, 100            ;longitud del titulo
    
comparar:
    cmpsb                   ;compara un byte
    jne diferentes          
    cmp byte ptr [esi-1], 0 ;verificar si llegamos al final
    je iguales              
    dec ecx                 
    jnz comparar            
    
iguales:
    mov eax, 1             
    jmp fin
    
diferentes:
    mov eax, 0              
    
fin:
    pop ecx
    pop esi
    pop edi
    pop ebp
    ret 8                   ;limpiar 8 bytes de la pila 
compararTitulos ENDP


END