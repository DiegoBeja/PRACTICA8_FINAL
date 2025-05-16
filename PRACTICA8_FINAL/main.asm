.386
.model flat, c
.stack 4096

.DATA
libros DB 10600 dup(?) 
librosTotales DWORD 0

.CODE
agregarLibro PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    push ecx
    
    mov esi, [ebp + 8]
    
    mov ecx, librosTotales
    cmp ecx, 0
    je nuevoLibro        
    
    xor ebx, ebx       
    
buscarExistente:
    mov edi, OFFSET libros
    mov eax, 212
    mul ebx
    add edi, eax
    
    push dword ptr [ebp + 8]  
    push edi                  
    call compararTitulos
    
    cmp eax, 1
    jne siguienteLibro
    
    mov ecx, [esi + 204]      
    add [edi + 204], ecx      
    mov ecx, [esi + 208]      
    add [edi + 208], ecx     
    
    mov eax, 1               
    jmp salir
    
siguienteLibro:
    inc ebx
    cmp ebx, [librosTotales]
    jl buscarExistente
    
nuevoLibro:
    mov eax, librosTotales
    cmp eax, 50
    jge finalizar          
    
    mov edi, OFFSET libros
    mov eax, 212
    mul dword ptr [librosTotales]
    add edi, eax
    
    mov esi, [ebp + 8]
    
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
    
    mov esi, [ebp + 8]       
    mov ecx, librosTotales
    cmp ecx, 0
    je fin                   
    
    mov ebx, 0              
    mov edx, 0               
    
buscarLibro:
    mov edi, OFFSET libros
    mov eax, 212             
    mul ebx
    add edi, eax
    
    push esi                 
    push edi                
    call compararTitulos
    
    cmp eax, 1
    jne siguienteLibro
    
    mov eax, [edi + 204]     
    cmp eax, 0
    jle siguienteLibro       
    
    dec dword ptr [edi + 204]  
    inc edx                  
    
siguienteLibro:
    inc ebx                  
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
        mov edx, [edi + 204]       
        
        mov eax, [edi + 208]        
        cmp edx, eax               
        jge noPuedeDevolverse      
        
        inc dword ptr [edi + 204]   
        mov eax, 1
        jmp salir

    noPuedeDevolverse:
        mov eax, 2                 
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
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov edx, [ebp + 8]     
    mov edi, [ebp + 12]    
    
    cmp dword ptr [librosTotales], 0
    je noLibros
    
    xor ebx, ebx          
    xor ecx, ecx           
    
buscarLoop:
    push edx               
    mov eax, ebx
    imul eax, 212          
    lea esi, [libros + eax] 
    
    push edx              
    push esi               
    call compararTitulos   
    
    pop edx                
    
    test eax, eax
    jz siguienteLibro     
    
    push edx               
    
    mov eax, ebx
    imul eax, 212          
    lea esi, [libros + eax]
    
    mov eax, ecx           
    imul eax, 212          
    add eax, [ebp + 12]    
    mov edi, eax           
    
    mov ecx, 53            
    cld                 
    rep movsd
    
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
    mov ebx, 0             
    
recorrerLibros: 
    mov esi, OFFSET libros
    push eax
    mov eax, 212           
    mul ebx
    add esi, eax
    pop eax
    
    mov edi, [ebp + 8]     
    push eax
    mov eax, 212            
    mul ebx
    add edi, eax
    pop eax
    
    push ecx
    mov ecx, 212            
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
    
    mov edi, [ebp + 8]      
    mov esi, [ebp + 12]     
    
    mov ecx, 100            
    
comparar:
    cmpsb                   
    jne diferentes          
    cmp byte ptr [esi-1], 0 
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
    ret 8                   
compararTitulos ENDP


END