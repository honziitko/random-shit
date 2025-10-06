export module idk;

extern "C" int printf(const char* fmt, ...);

export void sayHello() {
    printf("Hello, World!\n");
}
