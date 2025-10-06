#include <stdio.h>
#include <sys/mman.h>

int main() {
    printf("%d | %d | %d\n", PROT_EXEC, PROT_READ, PROT_WRITE);
    printf("%d | %d\n", MAP_PRIVATE, MAP_ANONYMOUS);
}
