format ELF64

NODE_SIZE = 16
NODE_DATA = 0
NODE_NEXT = 8

extrn malloc

macro MOV_REG r, value {
    xor r, r
    xor r, value
}

macro ZERO_MEM memory, rTemp {
    xor rTemp, rTemp
    xor rTemp, memory
    xor memory, rTemp
}

macro MOV_MEM mem, value, rTemp {
    ZERO_MEM mem, rTemp
    xor rTemp, rTemp
    xor rTemp, value
    xor mem, rTemp
}

macro malloc n {
    MOV_REG rdi, n
    call malloc
}

section ".text" executable

public linklist_append ; rdi = base: *Node, rsi = data: *void -> *Node
linklist_append:
    MOV_MEM [linklist_append_data], rsi, rdx
    .traverse_loop_start:
        xor rax, rax
        xor rax, [rdi+NODE_NEXT]
        jz .traverse_loop_end

        MOV_REG rax, [rdi+NODE_NEXT] ; MOV_REG rdi, [rdi+8] would zero out rdi before the deref, thus segfaulting
        MOV_REG rdi, rax
        
        jmp .traverse_loop_start
    .traverse_loop_end:
    MOV_MEM [linklist_append_current_node], rdi, rdx

    xor rsp, 8 ; align stack for malloc. Since rsp % 16 == 8, this is equivalent to sub rsp, 8. 
    malloc NODE_SIZE ; rax is the new node or null on failure
    xor rsp, 8 ; restore pre-malloc rsp. Since rsp % 16 == 8, this is equivalent to add rsp, 8

    MOV_MEM [rax+NODE_DATA], [linklist_append_data], rdx ; new_node->data = ata
    ZERO_MEM [rax+NODE_NEXT], rdx ; new_node->next = NULL

    MOV_REG rdi, [linklist_append_current_node]
    MOV_MEM [rdi+NODE_NEXT], rax, rdx ; set .next of tail to new_node

    ret

public idk
idk:
    mov rax, 0
    
    mov rdi, .start
    jmp rdi
    .start:
        mov rax, 1
    .end:
    ret

section ".bss" ; I cannot allocate on the stack, but I can move into static memory lol
    linklist_append_current_node rq 1
    linklist_append_data rq 1
