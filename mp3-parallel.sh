#! /bin/bash
external=$HOME/.bash_functions
if [ -f $external ];then
  source $external
fi
if [ $# != 1 ]; then
  precho --usage
  precho "mp3-parallel.sh [format]"
  precho "format is: mp3, flac, m4a, alac, ..."
  precho "...defaulting to '.aif' in 3s..."
  read -t 3
  if [ "$REPLY" == "n" ]; then
    exit 1
  else
    format="aif"
  fi
else
  format="$1"
fi
parallel -i -j$(sysctl -n hw.ncpu) ffmpeg -i {} -qscale:a 0 {}.mp3 -- ./*."$format"
rename -s ."$format".mp3 .mp3 ./*.mp3
