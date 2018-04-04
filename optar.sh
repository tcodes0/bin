#/usr/bin/env bash

parse-options() {
#input - string containing shorts (-s) longs (--longs) and params
#returns - arrays with parsed data and boolean opts set as vars
#shorts take no arguments, to give args to an option use a --long=with_equals

# for debuging
if [[ "$1" == "--debug" ]]; then
  shift
  printf "\n\e[4;33m$(printf %${COLUMNS}s) $(center DEBUGGING ${FUNCNAME[0]}!)$(printf %${COLUMNS}s)\e[0m\n"
  set -x
fi

if [[ "$#" == 0 ]]; then
  precho "input: string containing shorts (-s) longs (--longs) and params"
  precho "output: arrays with parsed data and boolean opts set as vars"
  return
fi

local argn
local long
local short
local alreadyProcessedNext
local noMoreOptions

#repeat until no args left
for arg in "$@"; do
  argn=$(($argn + 1))

  # if flag set
  if [[ -n $alreadyProcessedNext ]]; then
    # unset flag, skip this arg.
    alreadyProcessedNext=""
    continue
  fi

  # if flag set
  if [[ -n $noMoreOptions ]]; then
    #end of options seen, just push remaining args
    arguments+=($arg)
    continue
  fi

  # if end of options is seen
  if [[ "$arg" =~ ^--$ ]]; then
    # set flag to stop parsing
    noMoreOptions=" "
    continue
  fi

  # if long
  if [[ "$arg" =~ ^--[[:alnum:]] ]]; then
    long=${arg:2} #start on char 2, skip leading --
    # substitute any - with _
    long=${long/-/_}
    # if arg has an =, it means it has an arg
    if [[ "$arg" =~ ^--[[:alnum:]][[:alnum:]]+= ]]; then
      # split long from arg. Ann=choco makes export ann=choco
      export ${long%=*}="${long#*=}"
      longsWithArgs+=(${long%=*})
    else
      #no arg, just push
      longs+=($long)
    fi
    continue
  fi

  # if short
  if [[ "$arg" =~ ^-[[:alnum:]] ]]; then
    local i=1 #start on 1, skip leading -
    # since shorts can be chained (-gpH), look at one char at a time
    while [ $i != ${#arg} ]; do
      short=${arg:$i:1}
      # # if this is the last short in the chain AND the next arg has no leading - or --
      # if [[ $i == $((${#arg} - 1)) ]] && [[ $(eval echo \$$((argn + 1))) =~ ^[[:alnum:]] ]]; then
      #   # then it must be the last short's argument
      #   export $short=$(eval echo \$$((argn + 1)))
      #   shortsWithArgs+=($short)
      #   # set flag to avoid processing next arg again
      #   alreadyProcessedNext=" "
      # else
      #   #no arg, just push
        shorts+=($short)
      # fi
      i=$((i + 1))
    done
    continue
  fi

  # not a long or short, push as an arg
  arguments+=($arg)

done

# export everything not already exported as vars for visibility
for short in ${shorts[@]}; do
  export $short=" "
done

for long in ${longs[@]}; do
  export $long=" "
done
}

get-shorts() {
  for short in ${shorts[@]}; do
    echo -ne "$short "
  done
  for short in ${shortsWithArgs[@]}; do
    echo -ne "${short}* "
  done
  printf "\n"
}

get-longs() {
  for long in ${longs[@]}; do
    echo -ne "$long "
  done
  for long in ${longsWithArgs[@]}; do
    echo -ne "${long}* "
  done
  printf "\n"
}

get-arguments() {
  for arg in ${arguments[@]}; do
    echo -ne "$arg "
  done
  printf "\n"
}

get-optionsWithArgs() {
  for opt in ${shortsWithArgs[@]}; do
    echo -ne "${opt}* "
  done
  for opt in ${longsWithArgs[@]}; do
    echo -ne "${opt}* "
  done
  printf "\n"
}
