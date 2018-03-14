#! /bin/bash
files_found=0
if [ -d "$1" ];then
  path=$1
else
  path=~/bin
fi
precho "Running on $path..."
for sh in $path/*.sh; do
  if [ -f "$sh" ] && ! [ -x "$sh" ]; then
    files_found=$((files_found+1))
    precho "Chmod $(basename $sh)? (y/n)"
    read -e
    if [ $REPLY == "y" ] || [ $REPLY == "yes" ];then
      sudo chmod u+x "$sh" || bailout
    fi
  fi
done
if [ $files_found == 0 ]; then
  precho -r "No suitable files found"
fi
