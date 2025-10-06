#!/usr/bin/env bash

CFLAGS="-Wall -Wextra -pedantic -std=c++26 -fmodules"

set -xe
# g++ -o main $CFLAGS main.cpp gcm.cache/idk.gcm
g++ -o main $CFLAGS main.cpp -fsearch-include-path gcm.cache/idk.gcm
