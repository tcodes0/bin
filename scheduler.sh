#! /bin/bash

#======================================== functions
external=$HOME/.bash_functions
if [ -f "$external" ]; then
    source "$external"
else
    precho -c "$external not found. External functions will error"
fi
scheduler-lock () {
    if [ "$1" == "-v" ]; then
	verbose="true"
	shift
    fi
    if ! [ -f "$lock_file" ]; then
	runc -c touch "$lock_file"
	if [ $verbose == "true" ]; then
	    precho "lock file created"
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
	runc -c trash "$lock_file"
	if [ $verbose == "true" ]; then
	    precho "lock file removed"
	fi
	return
    fi
}
run-command-with-lock () {
    scheduler-lock
    $command
    scheduler-unlock
}
#======================================== vars
#    weekdays	num	bkp?
#sunday		0 	no
#mon		1 	no
#tues		2 	yes
#wed		3 	no
#thurs		4 	yes
#fri		5 	no
#saturday	6 	yes
todays_weekday=$(date +"%w")
record_file=~/.scheduler-last-run-date
lock_file=~/.scheduler-lock
command="$HOME/bin/bkp.sh"
#======================================== main
case $1 in
    --record)
	runc echo $todays_weekday > $record_file
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
	    precho -d "scheduler: bkp currently running, exiting"
	    exit 0
	fi
	#check if today is not a bkp day. Bkp days are saturday (6) thursday (4) and tuesday (2), respectively.
	if [ "$todays_weekday" != "6" ] && [ "$todays_weekday" != "4" ] && [ "$todays_weekday" != "2" ]; then
	    precho -d "scheduler: not a backup day, exiting"
	    exit 0
	else
	   #check if a previous run left a file telling the run's day.
	    if [ -f "$record_file" ]; then
		while read recorded_weekday; do
		    if [ "$recorded_weekday" == "$todays_weekday" ]; then
			precho -d "scheduler: already run today, exiting"
		        exit 0
		    else
		        run-command-with-lock
		    fi
		done < "$record_file"
	    else
		run-command-with-lock
	    fi
	fi
	;;
    --reset)
	if [ -f "$record_file" ]; then
	    runc trash "$record_file"
	fi
	;;
    *)
	echo -e "scheduler: run a command in certain weekdays"
	echo -e "--record 		save todays weekday in a record file"
	echo -e "--check 		check the weekday and execute the command if appropriate"
	echo -e "--reset                 delete record file"
	echo -e "--lock			create lock file to prevent multiple instances"
	echo -e "--unlock		remove lock file"
	echo -e "current command: $command"
	exit 0
	;;
esac
