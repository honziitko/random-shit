#!/usr/bin/bash

if [ ! -L "stdin" ]; then
    echo "Please run init.sh first"
    exit 1
fi

set -xe
tee temp.txt > /dev/null
zig build-exe main.zig < temp.txt
