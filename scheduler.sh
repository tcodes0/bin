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
dont_annoy_file=~/.scheduler-dont-annoy
command="$HOME/bin/bkp.sh"

#======================================== FUNCTIONS

scheduler-lock() {
  if [ "$1" == "-v" ]; then
    verbose="true"
    shift
  fi
  if ! [ -f "$lock_file" ]; then
    touch "$lock_file" || bailout
    if [ "$verbose" == "true" ]; then
      echo "lock file created"
    fi
    return
  fi
}

scheduler-reset() {
  if [ "$1" == "-v" ]; then
    verbose="true"
    shift
  fi
  if [ -f "$record_file" ]; then
    trash "$record_file" || bailout
    if [ "$verbose" == "true" ]; then
      echo "record file removed"
    fi
    return
  fi
}

scheduler-unlock() {
  if [ "$1" == "-v" ]; then
    verbose="true"
    shift
  fi
  if [ -f "$lock_file" ]; then
    trash "$lock_file" || bailout
    if [ "$verbose" == "true" ]; then
      echo "lock file removed"
    fi
    return
  fi
}

run-command-with-lock() {
  echo "Run $(basename "$command") now? (y/n)"
  echo "...defaulting to no in 6s"

  if ! read -rt 6; then
    exit "$?"
  fi

  if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
    scheduler-lock
    $command
    scheduler-unlock
  fi
}

scheduler-check() {
  if [ -f "$lock_file" ]; then
    echo "locked: already running"
    exit 11
  fi

  if [ -f "$dont_annoy_file" ]; then
    local last_time
    while read -r rd; do
      last_time=$rd
    done <"$dont_annoy_file"
    # set -x
    if [ "$last_time" == "$todays_weekday" ]; then
      echo "already asked to run today"
      exit 17
    fi
  fi
  echo "$todays_weekday" >"$dont_annoy_file"

  #check if a previous run left a file telling the run's day.
  if [ -f "$record_file" ]; then
    local recorded_weekday

    while read -r rd; do
      recorded_weekday=$rd
    done <"$record_file"

    if [ "$recorded_weekday" == "$todays_weekday" ]; then
      echo "already run today"
      exit 14
    elif [ "$((recorded_weekday + 1))" == "$todays_weekday" ] ||
      { [ "$recorded_weekday" == '6' ] && [ "$todays_weekday" == '0' ]; }; then
      echo "run yesterday"
      exit 12
    # elif [ "$((recorded_weekday + 2))" == "$todays_weekday" ] ||
    #   { [ "$recorded_weekday" == '5' ] && [ "$todays_weekday" == '0' ]; } ||
    #   { [ "$recorded_weekday" == '6' ] && [ "$todays_weekday" == '1' ]; }; then
    #   echo "run 2 day ago"
    #   exit 15
    # elif [ "$((recorded_weekday + 3))" == "$todays_weekday" ] ||
    #   { [ "$recorded_weekday" == '4' ] && [ "$todays_weekday" == '0' ]; } ||
    #   { [ "$recorded_weekday" == '5' ] && [ "$todays_weekday" == '1' ]; } ||
    #   { [ "$recorded_weekday" == '6' ] && [ "$todays_weekday" == '2' ]; }; then
    #   echo "run 3 day ago"
    #   exit 16
    else
      run-command-with-lock
    fi
  else
    run-command-with-lock
  fi
}
#======================================== MAIN

case $1 in
--record)
  echo "$todays_weekday" >$record_file || bailout
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
    echo "no record file to remove"
    exit 1
  fi
  ;;
*)
  echo -e "scheduler: run a command every 2 days

  --record \\t save todays weekday in a record file
  --check  \\t check the weekday and execute the command if appropriate
  --reset  \\t delete record file
  --lock   \\t create lock file to prevent multiple instances
  --unlock \\t remove lock file

  current command: $command

  exit statuses:
  11 \\t already running ($lock_file is present)
  12 \\t run yesterday
  14 \\t already run today
  15 \\t run 2 day ago
  16 \\t run 3 day ago
  17 \\t already asked to run today ($dont_annoy_file is present)"
  exit 0
  ;;
esac
