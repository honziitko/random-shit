format ELF64

extrn exit
extrn malloc
extrn printf

extrn printTree

section ".text" executable
; public main
; main:
;     push rbp ; for memory aligment
;
;     mov rdi, head
;     mov rsi, 0
;     sub rsp, 128
;     call printTree
;     add rsp, 128
;
;     mov rdi, head
;     mov rsi, 7
;     call tree_insert
;
;     mov rdi, head
;     mov rsi, 0
;     call printTree
;
;     mov rdi, 69
;     call exit
public tree_insert
tree_insert: ; rdi = BinaryTree *bt, rsi = x
    push r12
    push r13
tree_insert_real:
    ; TODO: assumes that root != NULL
    mov r12, [rdi]
    cmp rsi, r12
    je early_return

    jg tree_insert_right
    tree_insert_left:
        add rdi, 8
        jmp tree_insert_idk_1
    tree_insert_right:
        add rdi, 16
    tree_insert_idk_1:
    cmp QWORD [rdi], 0
    je tree_insert_null_child

    mov rdi, [rdi]
    jmp tree_insert_real
    tree_insert_null_child:; rsi = x
        mov r12, rdi
        call allocate_node
        mov [r12], rax

    early_return:
        pop r13
        pop r12
        ret
allocate_node: ; rsi = x
    mov r13, rsi
    mov rdi, 24
    sub rsp, 128
    call malloc
    add rsp, 128
    mov [rax], r13
    mov QWORD [rax+8], 0
    mov QWORD [rax+16], 0
    ret

section ".data"
printf_string: db "%hu", 10, 0
; head:
;     dq 5
;     dq 0
;     dq 0
