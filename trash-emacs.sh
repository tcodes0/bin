#! /bin/bash
#---------------------------------------- FUNC
work () {
  cd "$1" || bailout
  count=0
  #if enclosed in quotes the patterns var below does not expand.
  for file in $patterns; do
    #this filters out patterns that didn't match
    if [ -f "$file" ]; then
      $command $file
      if [ "$?" == 0 ];then
        count=$((count + 1))
      fi
    fi
  done
  if [ $count != "0" ]; then
    echo $command"ed $count emacs files in $(pwd)"
  else
    if [ "$verbose" == "true" ];then
      echo "no emacs files found in $(pwd)"
    fi
  fi
}
#---------------------------------------- VARS
if [ "$1" == "-v" ]; then
  verbose="true"
  shift
fi
command=trash
#space separated list of shell patterns to match
patterns="./*~ ./#*# ./.*~"
dirs="$@ $(pwd) $HOME $HOME/Desktop $HOME/bin $HOME/Desktop/musite/2017/js $HOME/Desktop/musite/2017 /Volumes/Seagate/Bkp/_Mac/bin "
count=0
#---------------------------------------- MAIN
#set -x
for dir in $dirs; do
  if [ -d "$dir" ]; then
    work "$dir"
  fi
done
