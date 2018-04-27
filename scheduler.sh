#! /usr/bin/env bash
#======================================== vars
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
should_run=''
#======================================== functions
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
  if ! [ -f "$record_file" ]; then
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
#======================================== main
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
  if [ -f "$lock_file" ]; then
    precho "locked: already running"
    exit 11
  fi
  #temporary fix for multiple instances of command on terminal resume
  if [ "$(tty | sed -e "s:/dev/::")" != "ttys000" ]; then
    precho "not ttys000"
    exit 12
  fi
  #check if today is not a bkp day. Bkp days are saturday (6) thursday (4) and tuesday (2), respectively.
  if [ "$todays_weekday" != "6" ] && [ "$todays_weekday" != "4" ] && [ "$todays_weekday" != "2" ]; then
    precho "not a backup day"
    exit 13
  else
    #check if a previous run left a file telling the run's day.
    if [ -f "$record_file" ]; then
      while read recorded_weekday; do
        if [ "$recorded_weekday" == "$todays_weekday" ]; then
          precho "already run today"
          exit 14
        else
          should_run='true'
        fi
      done < "$record_file"
    else
      run-command-with-lock
    fi
    if [[ "$should_run" != '' ]]; then
      run-command-with-lock
    fi
  fi
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
  precho "scheduler: run a command in certain weekdays
  \n
  \n --record \t save todays weekday in a record file
  \n --check  \t check the weekday and execute the command if appropriate
  \n --reset  \t delete record file
  \n --lock   \t create lock file to prevent multiple instances
  \n --unlock \t remove lock file
  \n
  \n current command: $command
  \n backup days are saturday (6) thursday (4) and tuesday (2), respectively
  \n
  \n exit statuses:
  \n 11	\t already running ($lock_file is present)
  \n 12 \t not ttys000
  \n 13 \t not a backup day
  \n 14 \t already run today"
  exit 0
  ;;
esac
