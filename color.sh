#! /usr/bin/env bash
  source $HOME/bin/optar.sh || bailout "optar.sh not found."
  parse-options "$@"

  maybeDebug

  if [ "$h" -o "$help" ]; then
    echo -e "\e[1;36m♦︎ usage: color --yellow --bold foobar\
    \n  result: \e[33;1;49mfoobar\e[1;36m
    \n  colors
    --black\t --purple
    --red\t --pink
    --green\t --teal
    --yellow\t --grey
    --white
    --light-black\t --light-purple
    --light-red  \t --light-pink
    --light-green\t --light-teal
    --light-yellow\t --light-grey
    \n  styles:
    --bold\t --underline
    --dim\t --blink
    --box
    \n  backgrounds:
    --bg=white\t --bg=black\t --bg=light-black
    \n  to see all possible formats try
    format-dump.sh\t format-dump.sh -a\e[0m"
    exit
  fi

  # styles
  # only (bold or white) and (bold) prints yellow. Implementation quirk.
  if [ $bold ]; then
    printf "\e[1m"
  elif [ $dim ]; then
    printf "\e[2m"
  elif [ $underline ]; then
    printf "\e[4m"
  elif [ $blink ]; then
    printf "\e[5m"
  elif [ $box ]; then
    printf "\e[7m"
  fi

  # foregrounds
  if [ $black ]; then
    printf "\e[30m"
  elif [ $red ]; then
    printf "\e[31m"
  elif [ $green ]; then
    printf "\e[32m"
  elif [ $yellow ]; then
    printf "\e[33m"
  elif [ $purple ]; then
    printf "\e[34m"
  elif [ $pink ]; then
    printf "\e[35m"
  elif [ $teal ]; then
    printf "\e[36m"
  elif [ "$gray" -o "$grey" ]; then
    printf "\e[37m"
  elif [ $white ]; then
    printf "\e[39m"
  elif [ $light_black ]; then
    printf "\e[90m"
  elif [ $light_red ]; then
    printf "\e[91m"
  elif [ $light_green ]; then
    printf "\e[92m"
  elif [ $light_yellow ]; then
    printf "\e[93m"
  elif [ $light_purple ]; then
    printf "\e[94m"
  elif [ $light_pink ]; then
    printf "\e[95m"
  elif [ $light_teal ]; then
    printf "\e[96m"
  elif [ "$light_gray" -o "$light_grey" ]; then
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
