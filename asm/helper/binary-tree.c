#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

//             vvv Probably useless but better be safe than sorry
typedef struct __attribute__((__packed__)) BinaryTree {
    uint64_t value;
    struct BinaryTree *left;
    struct BinaryTree *right;
} BinaryTree;

void tree_insert(BinaryTree*, uint64_t);
// void tree_insert(uint64_t, BinaryTree*);

void printTree(BinaryTree *bt, int lvl) {
    if (bt == NULL) {
        return;
    }
    printTree(bt->right, lvl + 1);
    for (int i = 0; i < lvl; i++) {
        printf("  ");
    }
    printf("%lu\n", bt->value);
    printTree(bt->left, lvl + 1);
}

#define N 20
#define MIDDLE (N / 2)

int main() {
    srand(time(NULL));
    BinaryTree bt = {.value = MIDDLE, .left = 0, .right = 0};
    printf("Root = %d\n", bt.value);
    for (int i = 0; i < N; i++) {
        int x = rand() % N;
        printf("Inseting %d...\n", x);
        tree_insert(&bt, x);
    }

    printTree(&bt, 0);
    return 0;
}
