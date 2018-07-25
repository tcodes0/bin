#! /usr/bin/env bash
##-----------------------  Deps & Setup  ----------------------##
for name in bkp-vars-and-routines optar progress paralol; do
  source "$HOME/bin/$name.sh" || bailout "Dependency $name failed"
done

parse-options "$@"
maybeDebug

######----------------- Quick exits  -----------------######
if [[ "$#" != 0 ]]; then
  if [ "$print" -o "$p" ]; then
    do-print
    exit 0
  elif [ "$help" -o "$h" ]; then
    do-help
    exit 1
  fi
fi

#-- Test for backup drive plugged in
[ -d "$BKPDIR" ] || bailout "Backup destination not plugged in?"

[[ "$(uname -s)" =~ Darwin ]] || bailout "Careful using this on Win/linux."

######----------------- Main  -----------------######
start-run
pathlist
safelist
dellist
applist
vscodeExtensionList
# ziplist #bugged: creating empty file
do-software
do-brewfile
do-mackup
finish-run
