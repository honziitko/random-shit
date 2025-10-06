format ELF64

extrn mmap
extrn memcpy

section ".text" executable
; idkWhatToNameThis:
;     mov rdi, 69
;     call exit
public runOn3
runOn3: ; rdi = f: fn (i32) i32 -> i32
    push r12
    mov r12, rdi
    mov rdi, 3
    call r12
    pop r12
    ret
public floatTest
floatTest: ; xmm0 = x: f32 -> f32
    mov r12, 5
    cvtsi2ss xmm1, r12
    addss xmm0, xmm1
    ret

public addFloats
addFloats: ; xmm0 = x: f32, xmm1 = y: f32 -> f32
    addss xmm0, xmm1
    ret

public derivate
derivate: ; rdi = f: fn (f32) f32, xmm0 = x: f32, xmm1 -> dx: f32 -> f32
    push rbp
    mov rbp, rsp
    sub rbp, 8

    sub rsp, 0x40 ; only 56 bytes used but gurantee 16-byte alignment

    movss [rbp], xmm0
    movss [rbp-0x10], xmm1
    mov [rbp-0x30], rdi

    call rdi
    movss [rbp-0x20], xmm0 ; f(x)

    movss xmm0, [rbp]
    addss xmm0, [rbp-0x10]
    call QWORD [rbp-0x30]
    ; xmm0 = f(x - h)

    subss xmm0, [rbp-0x20]
    divss xmm0, [rbp-0x10]

    add rsp, 0x40
    pop rbp
    ret

public derive
derive: ; rdi = f: fn(f32) f32, xmm0 = dx: f32 -> fn(f32) f32
    ; mov rax, derive_closure_compiled ; TODO: returns the same thing
    push r12
    push r13
    sub rsp, 8 ; 16-byte stack alignment bullshit
    movd r13d, xmm0
    mov r12, rdi

    mov rdi, 0 ; addr = NULL
    mov rsi, derive_closure_compiled_size
    mov rdx, 7 ; prot = PROT_EXEC | PROT_READ | PROT_WRITE
    mov rcx, 34; flags = MAP_PRICATE | MAP_ANONYMOUS (I have no idea what that means btw)
    mov r8, -1 ; id = -1
    mov r9, 0  ; offset = 0 (whatever that means)
    call mmap

    mov rdi, rax ;dest = allocated memory
    mov rsi, derive_closure_compiled
    mov rdx, derive_closure_compiled_size
    call memcpy ; memcpy returns dest

    mov QWORD [rax+DERIVE_F_OFFSET], r12
    mov DWORD [rax+DERIVE_DX_OFFSET], r13d

    add rsp, 8
    pop r13
    pop r12
    ret
derive_closure:
    push 0x0A0A0A0A
    movss xmm1, DWORD [rsp]
    mov rdi, 0x0B0B0B0B0B0B0B0B
    add rsp, 8
    ; derivate GETS INLUNED HERE
derive_closure_end:

section ".data"
