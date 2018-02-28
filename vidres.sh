#!/bin/bash
#dumps resized files in current dir
if [ "$#" == "0" ] || [ "$1" == "-h" ] ||  [ "$1" == "--help" ]; then
    echo "converts vids in a folder. check source."
    exit 1
fi
prefix="med-"
temp=0
width=804
for file in ./git-vids/git*; do
  temp=${prefix}$(basename $file)
  ffmpeg -i $file -filter:v scale=$width:-1 -c:a copy $temp
done
