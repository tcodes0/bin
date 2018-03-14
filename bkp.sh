#! /usr/bin/env bash
##-----------------------  Deps  ----------------------##
if [[ -f $HOME/bin/bkp-vars-and-routines.sh ]]; then
  source $HOME/bin/bkp-vars-and-routines.sh
else
  echo $HOME/bin/bkp-vars-and-routines.sh not found. Exiting...
  exit 1
fi
######----------------- Quick exits  -----------------######
if [[ "$#" != 0 ]]; then
  case "$1" in
    --print | -p)
    print
    exit 0
    ;;
    *)
    help
    exit 1
    ;;
  esac
fi
#-- Test for backup drive plugged in
if ! [ -d "$BKPDIR" ]; then
  precho -r "Seagate is not plugged in! Aborting"
  exit 1
fi
######----------------- Main  -----------------######
now-running
pathlist
app-list
zip-move
do-homebrew
do-mackup
do-brewfile
#-- progress
progress total ~/.bkp-run-times
#-- Scheduler
scheduler.sh --record
