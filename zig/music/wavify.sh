#!/usr/bin/bash

set -xe
ffmpeg -f f32le -ar 44100 -ac 1 -i song.pcm song.wav
