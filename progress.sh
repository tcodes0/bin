#!/bin/bash
function _show() {
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
function progress() {
  case "$1" in
    "show")
      if [[ "$progress_pid" ]]; then
        printf "\r%2s\e[31m✘ %b\n" '' "Progress is already running. Kill it with \e[100;37mkill $progress_pid\e[0m"
        exit 1
      fi
      shift
      progress_speed=0.050
      progress_runner="💫"
      progress_message="$@"
      progress_line_length=$(tput cols)
      progress_pad_left=$((($progress_line_length-${#progress_message}-${#progress_runner})/2))
      _show &
      disown #removes last job put to bg from shell list. Now when killed, it says nothing to stdout.
      progress_pid="$!"
      ;;
    "finish")
      printf "\r%${progress_line_length}s"
      kill "$progress_pid"
      progress_pad_left=$((progress_pad_left - 2)) #adjust to add the ✔ below
      case "$2" in
        "0") #success
          printf "\r%${progress_pad_left}s\e[32m✔ %s\e[0m\n" '' "$progress_message"
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
    *)
      echo "Please give a valid command"
      echo "show or finish"
      ;;
  esac
}
