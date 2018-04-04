#!/usr/bin/env bash

paralolWait() {
  #input - "pids" env array to get pids to check for exit
  local runningPids
  local pid
  while true; do
    # if our list is empty, all processes are done
    if [[ "${#pids[@]}" == 0 ]]; then
      break
    else
      # if not, some processes still need time, so let's wait
      sleep 4
      # get all processes running, substitute \n with spaces.
      runningPids="$(ps -T -o pid | tr \\n \\040)"
      # check every process we created
      for i in "${!pids[@]}"; do
        pid=${pids[$i]}
        # is it running?
        if [[ ! $runningPids =~ "$pid" ]]; then
          [ "$v" ] && precho -k "$pid finished"
          [ "$v" ] && precho -k "doing unset pids[$i] (value is: ${pids[$i]})"
          # if not, its done, so remove from list.
          unset pids[$i]
        else
          [ "$v" ] && echo "$pid is running, total ${#pids[@]}"
        fi
      done
      [ "$v" ] && printf "\n"
    fi
  done
}
paralolBg() {
  #input - task and params to send to bg
  #returns - pids put to bg as "pids" env array
  [ "$v" ] && echo -n "running in bg disowned: $@"
  "$@" &
  disown
  [ "$v" ] && echo -e " (pid: $!)\n"
  export pids+=("$! ")
}
