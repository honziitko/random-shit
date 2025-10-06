#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <time.h>

typedef struct Node {
    void *data;
    struct Node *next;
} Node;

extern Node* linklist_append(Node *list, void *data);
extern unsigned long idk();

void print_list(Node *head) {
    printf("{");
    Node *current = head;
    while (current) {
        printf("%c, ", (int)current->data);
        current = current->next;
    }
    printf("\a\a}\n");
}

int main(void) {
    printf("%lu\n", idk());
    return 0;
    printf("size = %d, data offset = %d, next offset = %d\n", sizeof(Node), offsetof(Node, data), offsetof(Node, next));
    srand(time(NULL));
    Node head = {
        .data = (void*) 0,
        .next = NULL,
    };
    const int n = rand() % 10 + 10;
    for (int i = 0; i < n; i++) {
        const int data = rand() % 26 + 'A';
        printf("Appending %c... ", data);
        printf("Appended %c\n", (char) linklist_append(&head, (void*)data)->data);
    }
    printf("head.next = %p\n", head.next);
    print_list(&head);
    return 0;
}
