#! /bin/bash
#x-to-mp3-parallel-for-find"
if  [ $# = 0 ]; then
    echo "usage: x-to-mp3-parallel-for-find \$(find command)"
    echo "where format is any such: mp3, flac, m4a, alac, etc..."
    exit 1
fi
#echo "running with format=$1..."
for song in $@; do

    echo parallel -i -j$(sysctl -n hw.ncpu) ffmpeg -i {} -qscale:a 0 {}.mp3 -- "$song"
    #echo rename -s "$song".mp3 .mp3 ./*.mp3
done
