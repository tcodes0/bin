#! /usr/bin/env bash
##-----------------------  Deps & Setup  ----------------------##
source "$HOME/bin/bkp-vars-and-routines.sh" || bailout "Dependency failed"
source "$HOME/bin/optar.sh" || bailout "Dependency failed"
source "$HOME/bin/progress.sh" || bailout "Dependency failed"
source "$HOME/bin/paralol.sh" || bailout "Dependency failed"

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

######----------------- Main  -----------------######
now-running
pathlist
safelist
dellist
applist
ziplist
do-software
do-brewfile
do-mackup

progress total ~/.bkp-run-times
scheduler.sh --record
