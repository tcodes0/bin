#!/bin/bash
function _show_longrunner() {
  local pad_right=$progress_pad_left
  local pos=1
  while :
	do
    printf "\r%${progress_pad_left}s%s%${pos}s%s" '' "$progress_message" '' "$progress_runner"
    pos=$((pos + 1))
    sleep $progress_speed
    if [[ "$pos" == "$pad_right" ]]; then
      pos=0
      printf "\r%${progress_line_length}s" #"erases" the line completely
    fi
  done
}

function _show() {
  local pad_right=$progress_pad_left
  local accumulated_runner=$progress_runner
  local time_padding=$(($progress_line_length-$progress_pad_left-${#progress_message}-${#accumulated_runner}-5))
  local i=0
  SECONDS=0
  while :
	do
    printf "\r%${progress_pad_left}s%s%s%${time_padding}s\e[33m" '' "$progress_message" "$accumulated_runner" ''
    print_time $SECONDS
    printf "\e[0m"
    i=$((i + 1))
    accumulated_runner=$accumulated_runner$progress_runner
    time_padding=$(($progress_line_length-$progress_pad_left-${#progress_message}-${#accumulated_runner}-5))
    sleep $progress_speed
    if [[ "$i" == "$((pad_right / 2))" ]]; then
      i=0
      accumulated_runner=$progress_runner
      time_padding=$(($progress_line_length-$progress_pad_left-${#progress_message}-${#accumulated_runner}-5))
      printf "\r%${progress_line_length}s" #"erases" the line completely
    fi
  done
}

function _print() {
  local time_padding=$(($progress_line_length-$progress_pad_left-${#progress_message}-${#accumulated_runner}-5))
  printf "\r%${progress_pad_left}s%s%s%${time_padding}s\e[33m" '' "$progress_message" "$accumulated_runner" ''
  printf "     "
  printf "\e[0m"
}

function progress() {
  case "$1" in
    "start")
      if [[ "$progress_pid" ]]; then
        printf "\r%2s\e[31m✘ %b\n" '' "Progress is already running. Kill it with \e[100;37mkill $progress_pid\e[0m"
        exit 1
      fi
      shift
      progress_speed=0.075 #0.050 good for _show_longrunner
      progress_runner="."
      progress_message="$@"
      progress_line_length=$(tput cols)
      progress_pad_left=$((($progress_line_length-${#progress_message}-${#progress_runner})/2))
      _show &
      disown #removes last job put to bg from shell list. Now when killed, it says nothing to stdout.
      progress_pid="$!"
      ;;
    "finish")
      local line_length_minus_time=$((progress_line_length - 5))
      printf "\r%${line_length_minus_time}s" ''
      if [ "${#progress_pid}" == "0" ]; then
        true
      else
      kill "$progress_pid"
      fi
      progress_pad_left=$((progress_pad_left - 2)) #adjust to add the ✔ below
      case "$2" in
        "0") #success
          #                             -1: \r, -2: ✔, -1: , -5: 00:00 (the time counter), +2: not sure
          # local time_padding=$(($progress_line_length-1-2-1-$progress_pad_left-${#progress_message}-5+2))
          printf "\r%${progress_pad_left}s\e[32m✔ %s\e[0m\n" '' "$progress_message"
          # print_time $SECONDS
          ;;
        "1") #failure
          printf "\r%${progress_pad_left}s\e[31m✘ %s\e[0m\n" '' "$progress_message"
          ;;
        "*") #other status, or no status passed
          printf "\r%${progress_pad_left}s\e[33m● %s\e[0m\n" '' "$progress_message"
          ;;
      esac
      unset progress_speed progress_runner progress_message progress_pid progress_line_length progress_pad_left
      ;;
    "total")
      shift
      progress_message="Total "
      if [[ -f "$1" ]]; then
        echo "$(print_time $SECONDS)" >> "$1"
        progress_message="Total✝ "
      fi
      progress_line_length=$(tput cols)
      progress_pad_left=$(($progress_line_length-${#progress_message}-5))
      printf "%${progress_pad_left}s\e[33;1m%s%s%s\e[0m\n" '' "$progress_message" "$(print_time $SECONDS)" "$progress_message2"
      ;;
    "print")
      shift
      progress_message="$@"
      progress_line_length=$(tput cols)
      progress_pad_left=$((($progress_line_length-${#progress_message}-${#progress_runner})/2))
      _print
      ;;
    *)
      echo "Please give a valid command"
      echo "start, finish, total or print"
      ;;
  esac
}

function print_time { #$1 - a number in seconds
if [[ "$#" == 0 ]]; then exit 1; fi
  printf "%02d:%02d" "$(($1 / 60))" "$(($1 % 60))"
}
