#! usr/bin/env bash
function _eraseLine() {
  printf "\\r%${progress_line_length}s"
}

function _printMessageWithRunner() {
  printf "\\r%0s%s%s%${time_padding}s\\e[33m" '' "$progress_message" "$accumulated_runner" ''
}

function _show_longrunner() {
  local pad_right=$progress_pad_left
  local pos=1
  while :; do
    printf "\\r%${progress_pad_left}s%s%${pos}s%s" '' "$progress_message" '' "$progress_runner"
    pos=$((pos + 1))
    sleep "$progress_speed"
    if [[ "$pos" == "$pad_right" ]]; then
      pos=0
      _eraseLine
    fi
  done
}

function _show() {
  local accumulated_runner pad_right right_offset time_padding i
  accumulated_runner=$progress_runner
  pad_right=$progress_pad_left
  right_offset=$((progress_line_length / 10))
  i=0
  SECONDS=0

  while :; do
    time_padding=$((progress_line_length - ${#progress_message} - ${#accumulated_runner} - 5 - right_offset))
    _printMessageWithRunner
    _print_time $SECONDS
    printf "\\e[0m"
    i=$((i + 1))
    accumulated_runner=$accumulated_runner$progress_runner
    sleep "$progress_speed"
    if [[ "$i" == "$((pad_right / 2))" ]]; then
      i=0
      accumulated_runner=$progress_runner
      _eraseLine
    fi
  done
}

function _print() {
  local time_padding=$((progress_line_length - progress_pad_left - ${#progress_message} - ${#accumulated_runner} - 5))
  _printMessageWithRunner
  printf "     "
  printf "\\e[0m"
}

function progress() {
  case "$1" in
  "start")
    if [[ "$progress_pid" ]]; then
      printf "\\r%2s\\e[31m✘ %b\\n" '' "Progress is already running. Kill it with \\e[100;37mkill $progress_pid\\e[0m"
      exit 1
    fi
    shift
    progress_speed=0.075 #0.050 good for _show_longrunner
    progress_runner="."
    progress_message="$*"
    progress_line_length=$(tput cols)
    progress_pad_left=$(((progress_line_length - ${#progress_message} - ${#progress_runner}) / 2))
    _show &
    #removes last job put to bg from shell list. Now when killed, it says nothing to stdout.
    disown
    progress_pid="$!"
    ;;
  "finish")
    # hard to find a good value here. ${#accumulated_runner} can't be referenced because _show is called with &
    local time_padding=$(((progress_pad_left / 2) + ${#progress_message} + 4)) # +4: the emoji (3) + 1 space

    # echo time_padding $time_padding >foo.txt
    # echo progress_line_length "$progress_line_length" >>foo.txt
    # echo progress_pad_left $progress_pad_left >>foo.txt
    # echo progress_message ${#progress_message} >>foo.txt

    printf "\\r%${time_padding}s" '' #erases line from beginning to the clock
    if [ "${#progress_pid}" == "0" ]; then
      true # noop
    else
      kill "$progress_pid"
    fi
    progress_pad_left=$((progress_pad_left - 2))
    case "$2" in
    # will reprint the message with color indicating the status
    "0") #success
      printf "\\r%0s\\e[32m✔ %s\\e[0m\\n" '' "$progress_message"
      ;;
    "1") #failure
      printf "\\r%0s\\e[31m✘ %s\\e[0m\\n" '' "$progress_message"
      ;;
    "*") #other status, or no status passed
      printf "\\r%0s\\e[33m● %s\\e[0m\\n" '' "$progress_message"
      ;;
    esac
    unset progress_speed progress_runner progress_message progress_pid progress_line_length progress_pad_left
    ;;
  "total")
    shift
    progress_message="Total "
    local progress_message2=''
    if [[ -f "$1" ]]; then
      _print_time "$SECONDS" >>"$1"
      progress_message="Total✝ "
    fi
    progress_line_length=$(tput cols)
    progress_pad_left=$((progress_line_length - ${#progress_message} - 5))
    printf "%0s\\e[33;1m%s%s%s\\e[0m\\n" '' "$progress_message" "$(_print_time $SECONDS)" "$progress_message2"
    ;;
  "print")
    shift
    progress_message="$*"
    progress_line_length=$(tput cols)
    progress_pad_left=$(((progress_line_length - ${#progress_message} - ${#progress_runner}) / 2))
    _print
    ;;
  *)
    echo "Please give a valid command"
    echo "start, finish, total or print"
    ;;
  esac
}

function _print_time() { #$1 - a number in seconds
  if [[ "$#" == 0 ]]; then exit 1; fi
  printf "%02d:%02d" "$(($1 / 60))" "$(($1 % 60))"
}
