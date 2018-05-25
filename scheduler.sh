#! /usr/bin/env bash
#======================================== VARS
#weekdays	num	bkp?
#sunday   0 	no
#mon      1 	no
#tues     2 	yes
#wed      3 	no
#thurs    4 	yes
#fri      5 	no
#saturday 6 	yes
todays_weekday=$(date +"%w")
record_file=~/.scheduler-last-run-date
lock_file=~/.scheduler-lock
command="$HOME/bin/bkp.sh"

#======================================== FUNCTIONS

scheduler-lock () {
  if [ "$1" == "-v" ]; then
    verbose="true"
    shift
  fi
  if ! [ -f "$lock_file" ]; then
    touch "$lock_file" || bailout
    if [ "$verbose" == "true" ]; then
      precho "lock file created"
    fi
    return
  fi
}

scheduler-reset () {
  if [ "$1" == "-v" ]; then
    verbose="true"
    shift
  fi
  if [ -f "$record_file" ]; then
    trash "$record_file" || bailout
    if [ "$verbose" == "true" ]; then
      precho "record file removed"
    fi
    return
  fi
}

scheduler-unlock () {
  if [ "$1" == "-v" ]; then
    verbose="true"
    shift
  fi
  if [ -f "$lock_file" ]; then
    trash "$lock_file" || bailout
    if [ "$verbose" == "true" ]; then
      precho "lock file removed"
    fi
    return
  fi
}

run-command-with-lock () {
  precho "Run $(basename $command) now? (y/n)"
  precho "...defaulting to no in 6s"
  read -t 6
  if [ "$?" != 0 ]; then
    exit 1
  fi
  if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
    scheduler-lock
    $command
    scheduler-unlock
  fi
}

scheduler-check() {
  if [ -f "$lock_file" ]; then
    precho "locked: already running"
    exit 11
  fi

  #check if a previous run left a file telling the run's day.
  if [ -f "$record_file" ]; then
    while read recorded_weekday; do
      if [ "$recorded_weekday" == "$todays_weekday" ]; then
        precho "already run today"
        exit 14

      elif [ "$((recorded_weekday + 1))" == "$todays_weekday" ] ||
      [ "$recorded_weekday" == '6' -a "$todays_weekday" == '0' ]; then
        precho "run yesterday"
        exit 12

      else
        run-command-with-lock
      fi
    done < "$record_file"
  else
    run-command-with-lock
  fi
}
#======================================== MAIN

case $1 in
  --record)
    echo $todays_weekday > $record_file || bailout
    exit 0
  ;;
  --lock)
    scheduler-lock -v
    exit 0
  ;;
  --unlock)
    scheduler-unlock -v
    exit 0
  ;;
  --check)
    scheduler-check
  ;;
  --reset)
    if [ -f "$record_file" ]; then
      scheduler-reset -v
    else
      precho "no record file to remove"
      exit 1
    fi
  ;;
  *)
    precho "scheduler: run a command every other day

  --record \t save todays weekday in a record file
  --check  \t check the weekday and execute the command if appropriate
  --reset  \t delete record file
  --lock   \t create lock file to prevent multiple instances
  --unlock \t remove lock file

  current command: $command

  exit statuses:
  11 \t already running ($lock_file is present)
  12 \t run yesterday
    14 \t already run today"
    exit 0
  ;;
esac
