format ELF64

extrn exit
extrn malloc
extrn printf

section ".text" executable
public main
main:
    push rbp ; for memory aligment

    sub rsp, 128
    mov rdi, 16
    call malloc
    add rsp, 128
    mov r12, rax

    mov WORD [r12], 1
    mov WORD [r12+2], 1

    mov r13, 4
    fibonacci_loop:
        mov dx, [r12+r13-4]
        add dx, [r12+r13-2]
        mov [r12+r13], dx

        add r13, 2
    cmp r13, 16
    jl fibonacci_loop

    mov r13, 0
    mov rsi, 0
    print_loop:
        mov si, [r12+r13]
        sub rsp, 128
        mov rdi, printf_string
        call printf
        add rsp, 128

        add r13, 2
    cmp r13, 16
    jl print_loop


    mov rdi, 69
    call exit

section ".data"
printf_string: db "%hu", 10, 0
