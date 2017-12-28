#! /bin/bash
external=$HOME/.bash_functions
if [ -f $external ];then
    source $external
fi
if [ "$#" -lt "2" ]; then
    precho "usage: echoform.sh 1 49 39 blabla"
    precho "echos blabla with ^[1;49;39m format"
    precho "warning: starting the text with a number will lead to weird results!"
    exit 0
fi
#this is a regex that matches numbers
re='^[0-9]+$'
while [[ "$1" =~ $re ]]; do
    echo -ne "\e[$1m"
    shift
done
#the @ echos all remaining arguments/words, and then formating is reset.
echo -e "$@\e[0m"
