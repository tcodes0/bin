#!/bin/bash

external=$HOME/.bash_functions

if [ -f $external ];then
    source $external
fi

if [ $# != 1 ]; then
    precho "usage: mp3-parallel.sh [format]"
    precho "...where format is any: mp3, flac, m4a, alac, ..."
    exit 0
fi

parallel -i -j$(sysctl -n hw.ncpu) ffmpeg -i {} -qscale:a 0 {}.mp3 -- ./*."$1"
rename -s ."$1".mp3 .mp3 ./*.mp3
