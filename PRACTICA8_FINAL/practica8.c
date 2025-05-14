#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

extern int agregarLibro(struct libro* libro);
extern int prestarLibro(char* titulo);
extern int devolverLibro(struct libro* libro);
extern int buscarLibro(char* tituloBuscar, struct libro* librosEnsamblador);
extern int mostrarLibros(struct libro* librosEnsamblador);

struct libro {
    char nombreLibro[100];
    char autorLibro[100];
    int anoLibro;
    int cantidadLibros;
};


int main() {
    struct libro libroNuevo;
    struct libro libroDevolver;
    struct libro librosEnsamblador[50];
    int opcionUsuario;
    char titulo[100];
    char tituloBuscar[100];
    int totalLibros;

    do {
        printf("1. Ingresar un libro\n");
        printf("2. Prestar un libro\n");
        printf("3. Devolver un libro\n");
        printf("4. Buscar libro\n");
        printf("5. Listar libros\n");
        printf("6. Salir\n");
        printf("Seleccione una opcion: ");
        scanf("%d", &opcionUsuario);
        getchar();

        switch (opcionUsuario) {
        case 1:
            printf("Ingrese el titulo del libro: ");
            scanf("%[^\n]", libroNuevo.nombreLibro);
            getchar();

            printf("Ingrese el autor del libro: ");
            scanf("%[^\n]", libroNuevo.autorLibro);
            getchar();

            printf("Ingrese el ano de publicacion de libro: ");
            scanf("%d", &libroNuevo.anoLibro);
            getchar();

            printf("Ingrese la cantidad de libros que hay: ");
            scanf("%d", &libroNuevo.cantidadLibros);
            getchar();

            agregarLibro(&libroNuevo);
            printf("Libro Guardado Correctamente\n");
            break;

        case 2:
            printf("Ingrese el nombre del libro que quiere\n");
            printf("Ingrese el titulo del libro: ");
            scanf("%[^\n]", titulo);
            getchar();

            if (prestarLibro(titulo)) {
                printf("Libro prestado correctamente\n");
            }
            else {
                printf("No se encontro el libro o no hay copias disponibles\n");
            }
            break;

        case 3:
            printf("\n~~~~Devolver Libro~~~~\n");
            printf("Ingrese el titulo del libro: ");
            scanf("%[^\n]", libroDevolver.nombreLibro);
            getchar();

            printf("Ingrese el autor del libro: ");
            scanf("%[^\n]", libroDevolver.autorLibro);
            getchar();

            printf("Ingrese el ano de publicacion de libro: ");
            scanf("%d", &libroDevolver.anoLibro);
            getchar();

            libroDevolver.cantidadLibros = 1;

            devolverLibro(&libroDevolver);
            break;

        case 4:
            printf("\n~~~~Buscar libro~~~~\n");
            printf("Ingrese el nombre del libro: ");
            scanf("%[^\n]", tituloBuscar);
            getchar();

            totalLibros = buscarLibro(tituloBuscar, librosEnsamblador);

            if (totalLibros > 0) {
                printf("Libro encontrado\n");
                for (int i = 0; i < totalLibros; i++) {
                    printf("Titulo: %s\n", librosEnsamblador[i].nombreLibro);
                    printf("Autor: %s\n", librosEnsamblador[i].autorLibro);
                    printf("Ano publicacion: %d\n", librosEnsamblador[i].anoLibro);
                    printf("Cantidad copias: %d\n\n", librosEnsamblador[i].cantidadLibros);
                }
            }
            else {
                printf("No se encontro ese libro\n");
            }
            break;

        case 5:
            totalLibros = mostrarLibros(librosEnsamblador);

            if (totalLibros > 0) {
                printf("\n~~~~Lista de libros disponibles~~~~\n");
                for (int i = 0; i < totalLibros; i++) {
                    printf("Titulo: %s\n", librosEnsamblador[i].nombreLibro);
                    printf("Autor: %s\n", librosEnsamblador[i].autorLibro);
                    printf("Ano publicacion: %d\n", librosEnsamblador[i].anoLibro);
                    printf("Cantidad copias: %d\n\n", librosEnsamblador[i].cantidadLibros);
                }
            }
            else {
                printf("No hay libros\n");
            }
            break;
        default:
            printf("Seleccione una opcion correcta");
            break;
        }
    } while (opcionUsuario != 6);

    return 0;
}
