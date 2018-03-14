#!/bin/bash
#---------------------------------------------------------------------- Funcs
hexdec-plain () {
  echo -n "$((0x$1))"
}
dechex-plain () {
  printf '%x' "$1"
}
hexplusdec () {
  echo -n "$((0x$1 + $2))"
}
print-description() {
  printf "\n"
  echo -e $formatStart$description$formatEnd
  description=""
}
range () {
  start=$(hexdec-plain $b4)
  #this range is zero-indexed & we split the line in half to fit better
  half=$(($start+31))
  #each group is 64 chars long.
  end=$(($start+64))
  #without this space the chars overlap
  spacebetween="  "
  #black foreground for the description line
  formatStart="\e[0;49;30m"
  formatEnd="\e[0m"
  printf "\n"
  echo -e $formatStart"                                        "$formatEnd $b1 $b2 $b3 __$formatEnd
  while [ "$start" -lt "$end" ]; do
    b4=$(dechex-plain $start)
    echo -ne \\x$b1\\x$b2\\x$b3\\x$b4"$spacebetween"
    description=$description$b4"$spacebetween"
    if [ "$start" == "$half" ]; then
      print-description
    fi
    start=$((start+1))
  done
  #all groups begin on 80
  b4=80
  print-description
}
work() {
  startGroup=$(hexdec-plain $b3)
  finalGroup=$((howMany+startGroup))
  while [ $startGroup -lt $finalGroup ]; do
    b3=$(dechex-plain $startGroup)
    range $b1 $b2 $b3 $b4
    startGroup=$((startGroup+1))
    if [ "$startGroup" == "$(hexdec-plain 9e)" ]; then
      #jump 6 empty groups from f0 9f 9e __ to f0 9f a3 __
      startGroup=$((startGroup+6))
    fi
  done
  printf "\n"
}
do-help() {
  precho --usage
  precho "Dump unicode character groups in utf-8 hex with readable formatting"
  precho "Options:"
  precho "--dingbats	dumps the Dingbats unicode table"
  precho "--custom	takes 5 args for a start char and how many 64 char groups to print"
  precho "		example:"
  precho "		--custom 00 e2 9c 80 12 will start from char 00 e2 9c 80"
  precho "		and print 12*64=768 chars, 12 groups"
  precho "...by default it dumps all the way from Miscellaneous Symbols and Pictographs to Supplemental Symbols and Pictographs (from f0 9f 8c 80, 28*64=1792 chars, 28 groups)."
}
#---------------------------------------------------------------------- Vars
#starting character address in hex to dump.
b1=f0
b2=9f
b3=8c
b4=80
#how many groups of chars to dump. Each group has 64 chars.
howMany=28 #28 groups from the default address above will dump many emoji
#---------------------------------------------------------------------- MAIN
#set -x
case "$1" in
  --help | -h)
  do-help
  ;;
  --custom)
  shift
  b1=$1
  b2=$2
  b3=$3
  b4=$4
  howMany=$5
  work
  ;;
  --dingbats)
  shift
  b1=00
  b2=e2
  b3=9c
  b4=80
  howMany=12
  work
  ;;
  "")
  work
  ;;
  *)
  do-help
  ;;
esac
