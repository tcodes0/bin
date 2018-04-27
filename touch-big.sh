#! /bin/bash
help-text(){
  precho "Example: touch-big.sh 200
  \n creates a file with 200 MB on the current dir called 'big'"
}
if [ "$#" != 0 -a "$1" != "-h" ]; then
  # /dev/zero zips to nothing, dev/ranodm zips to 100% ratio.
  dd if=/dev/random bs=1000 count=$(($1*1000)) > ./big 2>/dev/null
  exit 0
else
  filezise=200
  help-text
  exit 1
fi
