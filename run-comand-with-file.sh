#!/usr/bin/env bash

do-help() {
  precho "\
  Usage
    run-command-with-file.sh <command string> <file string>
      read lines from file and pass them as args to command
  "
}

if [ "$#" -lt 2 -o "$1" == "-h" -o "$1" == "--help" ]; then
  do-help
  exit 1
fi

command=$1
file=$2

if [ ! -f "$file" ]; then
  do-help
  bailout "File $file not found on $PWD or invalid.\n"
fi

#select the command basename, up to the first space
if [[ $command =~ ^([[:alnum:]]+)[[:blank:]] ]]; then
  baseCommand=${BASH_REMATCH[1]}
else
  baseCommand=$command
fi

if ! which $baseCommand 1>/dev/null 2>&1; then
  do-help
  bailout "Command '$baseCommand' not found.\n"
fi

while read line; do
  eval $command $line
done < $file

exit $?
