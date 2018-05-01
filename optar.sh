#/usr/bin/env bash

parse-options() {
#input   - $@ or string containing shorts (-s), longs (--longs), and arguments
#returns - arrays with parsed data and opts set as vars
#exports a var for each option. (-s => $s, --foo => $foo, --long-opt => $long_opt)
#"-" are translated i(nto "_"
#"--" signals the end of options
#shorts take no arguments, to give args to an option use a --long=arg

if [[ "$1" == "--debug" ]]; then
  printf "\n\e[4;33m$(printf %${COLUMNS}s) $(center DEBUGGING ${FUNCNAME[0]}!)$(printf %${COLUMNS}s)\e[0m\n"
  set -x
fi

if [[ "$#" == 0 ]]; then
  return
fi

# Opts we may have inherited from a parent function also using parse-options. Unset to void collisions.
if [ "$allOptions" ]; then
  for opt in ${allOptions[@]}; do
    unset $opt
  done
fi

local argn long short noMoreOptions

#echo to split quoted args, repeat until no args left
for arg in $(echo "$@"); do
  argn=$(($argn + 1))

  # if flag set
  if [[ "$noMoreOptions" ]]; then
    #end of options seen, just push remaining args
    arguments+=($arg)
    continue
  fi

  # if end of options is seen
  if [[ "$arg" =~ ^--$ ]]; then
    # set flag to stop parsing
    noMoreOptions="true"
    continue
  fi

  # if long
  if [[ "$arg" =~ ^--[[:alnum:]] ]]; then
    #start on char 2, skip leading --
    long=${arg:2}
    # substitute any - with _
    long=${long/-/_}
    # if opt has an =, it means it has an arg
    if [[ "$arg" =~ ^--[[:alnum:]][[:alnum:]]+= ]]; then
      # split opt from arg. Ann=choco makes export ann=choco
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
        shorts+=($short)
      i=$((i + 1))
    done
    continue
  fi

  # not a long or short, push as an arg
  arguments+=($arg)
done

# give opts with no arguments value "true"
for short in ${shorts[@]}; do
  export $short="true"
done

for long in ${longs[@]}; do
  export $long="true"
done

export allOptions="$(get-shorts)$(get-longs)"
}

#part of parse-options
get-shorts() {
  if [ "$shorts" ]; then
    for short in ${shorts[@]}; do
      echo -ne "$short "
    done
  fi
}

#part of parse-options
get-longs() {
  if [ "$longs" ]; then
    for long in ${longs[@]}; do
      echo -ne "$long "
    done
  fi
  if [ "$longsWithArgs" ]; then
    for long in ${longsWithArgs[@]}; do
      echo -ne "${long}* "
    done
  fi
}

#part of parse-options
get-arguments() {
  for arg in ${arguments[@]}; do
    echo -ne "$arg "
  done
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
