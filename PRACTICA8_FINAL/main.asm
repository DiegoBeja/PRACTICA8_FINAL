.386
.model flat, c
.stack 4096

.DATA
libros DB 10400 dup(?) ;50 libros por 208 byte por libro
librosTotales DWORD 0

.CODE
agregarLibro PROC
    push ebp
    mov ebp, esp
    
    ; Guardar registros
    push esi
    push edi
    push ebx
    push ecx
    
    ; Obtener puntero a la estructura libro
    mov esi, [ebp + 8]
    mov ecx, [esi + 204]

    cmp ecx, 0
    jle finalizar
    
    agregarCopias:
    ; Comprobar si hay espacio en el arreglo
    mov eax, librosTotales
    cmp eax, 50
    jge finalizar          ; Si ya hay 50 libros, salir

    push ecx
    
    ; Calcular la posición donde guardar el libro
    mov edi, OFFSET libros
    mov eax, 208           ; Tamaño de la estructura libro (100+100+4+4)
    mul dword ptr [librosTotales]
    add edi, eax

    mov esi, [ebp + 8]
    
    ; Copiar los datos del libro (208 bytes)
    mov ecx, 208
    cld
    rep movsb
    
    ; Incrementar el contador de libros
    inc dword ptr [librosTotales]

    pop ecx
    loop agregarCopias
    
    ; Retornar 1 (éxito)
    mov eax, 1
    jmp salir
    
finalizar:
    ; Si no hay espacio, retornar 0 (fallo)
    mov eax, 0
    
salir:
    ; Restaurar registros
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
    
    mov esi, [ebp + 8]       ; título a buscar
    mov ecx, librosTotales
    cmp ecx, 0
    je fin                   ; Si no hay libros, terminar
    
    mov ebx, 0               ; índice del libro actual
    mov edx, 0               ; contador de libros prestados
    
buscarLibro:
    ; Calcular la dirección del libro actual
    mov edi, OFFSET libros
    mov eax, 208             ; Tamaño de cada registro (208 bytes)
    mul ebx
    add edi, eax
    
    ; Llamar a compararTitulos
    push esi                 ; título a buscar (segundo parámetro)
    push edi                 ; dirección del libro actual (primer parámetro)
    call compararTitulos
    
    ; Si encontramos el libro con el título buscado
    cmp eax, 1
    jne siguienteLibro
    
    ; Verificar si hay copias disponibles
    mov eax, [edi + 204]     ; cantidadLibros (offset 204)
    cmp eax, 0
    jle siguienteLibro       ; Si no hay copias, pasar al siguiente
    
    ; Decrementar el contador de copias
    dec dword ptr [edi + 204]
    inc edx                  ; Incrementar contador de libros prestados
    
siguienteLibro:
    inc ebx                  ; Incrementar índice
    cmp ebx, ecx             ; Comparar con el total de libros
    jl buscarLibro           ; Si hay más libros, seguir buscando
    
fin:
    mov eax, edx             ; Devolver número de libros prestados
    
    pop edx
    pop ecx
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret
prestarLibro ENDP

devolverLibro PROC
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx
    push ecx
    push edx

    mov esi, [ebp + 8]
    mov ecx, librosTotales
    cmp ecx, 0
    je salir

    mov ebx, 0

    buscarLibro:
        mov edi, OFFSET libros
        mov eax, 208
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
        inc dword ptr [edi + 204] 
        mov eax, 1
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
    imul eax, 208          
    lea esi, [libros + eax] 
    
    push edx               ;ttulo a buscar
    push esi               ;direccion del libro actual
    call compararTitulos   
    
    pop edx                
    
    test eax, eax
    jz siguienteLibro     
    
    ;si coincide, copiar el libro completo al arreglo resultado
    push edx               
    
    ;calcular direccion del libro actual de nuevo
    mov eax, ebx
    imul eax, 208          
    lea esi, [libros + eax]
    
    ;calcular posicion en el arreglo destino
    mov eax, ecx           
    imul eax, 208
    add eax, [ebp + 12]    
    mov edi, eax           
    
    ;copiar todo el libro
    mov ecx, 52            
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
    mov ebx, 0              ; Contador para recorrer libros
    
recorrerLibros:
    ; Calcular dirección origen (libro actual en el arreglo)
    mov esi, OFFSET libros
    push eax
    mov eax, 208
    mul ebx
    add esi, eax
    pop eax
    
    ; Calcular dirección destino (posición en el arreglo destino)
    mov edi, [ebp + 8]      ; Puntero al arreglo destino
    push eax
    mov eax, 208
    mul ebx
    add edi, eax
    pop eax
    
    ; Copiar el libro (208 bytes)
    push ecx
    mov ecx, 208
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
    
    mov edi, [ebp + 8]      ; puntero al libro actual
    mov esi, [ebp + 12]     ; título a buscar
    
    ; Realizar la comparación de cadenas
    mov ecx, 100            ; longitud máxima del título
    cld                     ; dirección ascendente
    
comparar:
    cmpsb                   ; compara un byte
    jne diferentes          ; si no son iguales, salir
    cmp byte ptr [esi-1], 0 ; verificar si llegamos al final de la cadena (título)
    je iguales              ; si es cero, las cadenas son iguales
    dec ecx                 ; decrementar contador
    jnz comparar            ; si no es cero, seguir comparando
    
iguales:
    mov eax, 1              ; encontrado
    jmp fin
    
diferentes:
    mov eax, 0              ; no encontrado
    
fin:
    pop ecx
    pop esi
    pop edi
    pop ebp
    ret 8                   ; limpiar 8 bytes de la pila (2 parámetros)
compararTitulos ENDP


END
