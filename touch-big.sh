#! /bin/bash
help-text(){
  echo "Example: touch-big.sh 200"
  echo "creates a file with 200 MB on the current dir called 'big'"
}
if [[ "$#" != 0 ]]; then
  dd if=/dev/zero bs=1000 count=$(($1*1000)) > ./big 2>/dev/null
  exit 0
else
  filezise=200
  help-text
  exit 1
fi
