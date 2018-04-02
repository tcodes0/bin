old() {
  if [ "$1" == "-h" -o "$1" == "--help" ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "usage: color 1 49 39 formatted text"
    echo -n "result: "; color 1 49 39 "formatted text"
    echo "the formatting is reset after each call, or use --clear/-c"
    exit
  fi

  if [ "$1" == "-c" -o "$1" == "--clear" ]; then
    shift
    echo -ne '\e[0m'
    exit
  fi

  local i=0
  while [[ "$1" =~ ^[0-9]+$ ]] && [ $i -lt 3 ]; do #regex to match numbers && 3 numbers max
    echo -ne "\e[$1m"
    shift
    i=$((i+1))
  done

  #echos all remaining arguments (words), and then formating is reset.
  echo -e "$@\e[0m"
}

new() {
  source $HOME/bin/optar.sh || bailout "optar.sh not found."
  parse-options "$@"

  if [[ -n $h ]] || [[ -n $help ]]; then
    precho "example: color --yellow --bold foobar \
    \nresult: \e[33;1mfoobar\e[0;34;49m \n\
    \ncolors:\n\
    --black\t --purple \n\
    --red\t --pink \n\
    --green\t --teal \n\
    --yellow\t --grey \n\
    --white \n\
    --light-black\t --light-purple \n\
    --light-red  \t --light-pink \n\
    --light-green\t --light-teal \n\
    --light-yellow\t --light-grey \n\
    \nstyles: \n\
    --bold\t --underline \n\
    --dim\t --blink \n\
    --box \n\
    \nbackgrounds: \n\
    --bg=white\t --bg=black\t --bg=light-black \n\
    \nto see all possible formats try:\n\
    format-dump.sh\t format-dump.sh -a"
    exit
  fi

  if [[ -n $black ]]; then
    printf "\e[30m"
  elif [[ -n $red ]]; then
    printf "\e[31m"
  elif [[ -n $green ]]; then
    printf "\e[32m"
  elif [[ -n $yellow ]]; then
    printf "\e[33m"
  elif [[ -n $purple ]]; then
    printf "\e[34m"
  elif [[ -n $pink ]]; then
    printf "\e[35m"
  elif [[ -n $teal ]]; then
    printf "\e[36m"
  elif [[ -n $gray ]] || [[ -n $grey ]]; then
    printf "\e[37m"
  elif [[ -n $white ]]; then
    printf "\e[39m"
  elif [[ -n $light_black ]]; then
    printf "\e[90m"
  elif [[ -n $light_red ]]; then
    printf "\e[91m"
  elif [[ -n $light_green ]]; then
    printf "\e[92m"
  elif [[ -n $light_yellow ]]; then
    printf "\e[93m"
  elif [[ -n $light_purple ]]; then
    printf "\e[94m"
  elif [[ -n $light_pink ]]; then
    printf "\e[95m"
  elif [[ -n $light_teal ]]; then
    printf "\e[96m"
  elif [[ -n $light_gray ]] || [[ -n $light_grey ]]; then
    printf "\e[97m"
  fi

  # only bold or white and bold prints yellow. Implementation quirk.
  if [[ -n $bold ]]; then
    printf "\e[1m"
  elif [[ -n $dim ]]; then
    printf "\e[2m"
  elif [[ -n $underline ]]; then
    printf "\e[4m"
  elif [[ -n $blink ]]; then
    printf "\e[5m"
  elif [[ -n $box ]]; then
    printf "\e[7m"
  fi

  case $bg in
    "black")
      printf "\e[40m"
    ;;
    "light_black")
      printf "\e[100m"
    ;;
    "white")
      printf "\e[49m"
    ;;
    *)
      printf "\e[49m"
    ;;
  esac

  printf "$(get-arguments)"
  printf "\e[0m\n"
}

if [[ "$1" == "-x" ]]; then
  set -x
  shift
fi

if [[ "$1" == "--dev" ]]; then
  shift
  new "$@"
else
  old "$@"
fi
