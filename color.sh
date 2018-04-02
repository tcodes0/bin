#! /usr/bin/env bash
  source $HOME/bin/optar.sh || bailout "optar.sh not found."
  parse-options "$@"

  if [[ -n $h ]] || [[ -n $help ]]; then
    printf "\e[1;36m♦︎ usage: color --yellow --bold foobar \
    \n  result: \e[33;1;49mfoobar\e[1;36m \n\
    \n  colors:\n\
    --black\t --purple \n\
    --red\t --pink \n\
    --green\t --teal \n\
    --yellow\t --grey \n\
    --white \n\
    --light-black\t --light-purple \n\
    --light-red  \t --light-pink \n\
    --light-green\t --light-teal \n\
    --light-yellow\t --light-grey \n\
    \n  styles: \n\
    --bold\t --underline \n\
    --dim\t --blink \n\
    --box \n\
    \n  backgrounds: \n\
    --bg=white\t --bg=black\t --bg=light-black \n\
    \n  to see all possible formats try:\n\
    format-dump.sh\t format-dump.sh -a\e[0m\n"
    exit
  fi

  # styles
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

  # foregrounds
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

  # backgrounds
  case $bg in
    black)
      printf "\e[40m"
    ;;
    red)
      printf "\e[41m"
    ;;
    green)
      printf "\e[42m"
    ;;
    yellow)
      printf "\e[43m"
    ;;
    purple)
      printf "\e[44m"
    ;;
    pink)
      printf "\e[45m"
    ;;
    teal)
      printf "\e[46m"
    ;;
    gray | grey)
      printf "\e[47m"
    ;;
    white)
      printf "\e[49m"
    ;;
    light_black)
      printf "\e[100m"
    ;;
    light_red)
      printf "\e[101m"
    ;;
    light_green)
      printf "\e[102m"
    ;;
    light_yellow)
      printf "\e[103m"
    ;;
    light_purple)
      printf "\e[104m"
    ;;
    light_pink)
      printf "\e[105m"
    ;;
    light_teal)
      printf "\e[106m"
    ;;
    light_gray | light_grey)
      printf "\e[107m"
    ;;
    *)
      printf "\e[49m"
    ;;
  esac

  # print all arguments
  printf "$(get-arguments)"
  # end formatting
  printf "\e[0m\n"
