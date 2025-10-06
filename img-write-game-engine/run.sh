#!/usr/bin/bash
set -xe

# zig build-exe test.zig -target x86_64-windows -lc
zig build -Dtarget=x86_64-windows
./zig-out/bin/img-write-game-engine.exe
