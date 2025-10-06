#include <stdio.h>
#include <stdbool.h>

#define NOB_IMPLEMENTATION
#include "nob.h"

void appendCompiler(Nob_Cmd* cmd) {
#ifdef _WIN32
#   error "Idk how to compile C on windows. Nobody uses windows anyway, get a real OS bitch."
#else
    nob_cmd_append(cmd, "gcc");
#endif
}

void appendCFlags(Nob_Cmd* cmd) {
    nob_cmd_append(cmd, "-Wall", "-Wextra");
}

#define FAIL_ON_FAILURE(x) if (!(x)) {exit(1);}
int main(int argc, char** argv) {
    NOB_GO_REBUILD_URSELF(argc, argv);
    const char *program = nob_shift_args(&argc, &argv);
    bool run = false;
    while (argc) {
        const char *arg = nob_shift_args(&argc, &argv);
        if (strcmp(arg, "-r") == 0) {
            run = true;
        } else if (strcmp(arg, "--") == 0) {
            break;
        }
    }
    Nob_Cmd cmd = {0};
    appendCompiler(&cmd);
    appendCFlags(&cmd);
    nob_cmd_append(&cmd, "-o", "test", "main.c");
    FAIL_ON_FAILURE(nob_cmd_run_sync(cmd));
    if (run) {
        cmd.count = 0;
        nob_cmd_append(&cmd, "./test");
        while (argc) {
            nob_cmd_append(&cmd, nob_shift_args(&argc, &argv));
        }
        FAIL_ON_FAILURE(nob_cmd_run_sync(cmd));
    }
    return 0;
}
