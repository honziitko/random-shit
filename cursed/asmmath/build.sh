#!/usr/bin/env bash

set -e
mkdir -p build

extract_func() {
    grep -A 999 "$1:" main.asm | tail -n +2 |  grep -e "public" -e ".*:" -B 999 -m 1 | head -n -1
}

echo "use64" > build/temp.asm
extract_func "derive_closure" >> build/temp.asm
extract_func "derivate" >> build/temp.asm
fasm build/temp.asm build/temp.bin

search_for_placeholder() {
    local PATTERN=""
    for i in $(seq 1 $2); do
        PATTERN+="\\x$1"
    done
    grep --byte-offset --binary -a --only-matching -z --perl-regexp "$PATTERN" build/temp.bin | grep -ao "[0-9]*"
}

echo "DERIVE_DX_OFFSET = $(search_for_placeholder 0a 4)" > build/temp.asm
echo "DERIVE_F_OFFSET = $(search_for_placeholder 0b 8)" >> build/temp.asm
cat main.asm >> build/temp.asm

function pend() { while read line; do echo "${1}${line}${2}"; done; }

echo -n "derive_closure_compiled: db " >> build/temp.asm
xxd -c 1 -ps build/temp.bin | pend "0x" "," | tr "\n" " " | head -c -2 >> build/temp.asm
echo "" >> build/temp.asm
echo 'derive_closure_compiled_size = $ - derive_closure_compiled' >> build/temp.asm

fasm build/temp.asm
CFLAGS="-static -static-libgcc -no-pie -g"
gcc -o build/main helper.c build/temp.o $CFLAGS
