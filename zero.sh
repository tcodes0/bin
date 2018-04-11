#! /usr/bin/env bash
source "$HOME/bin/optar.sh" || bailout "Dependency failed"

parse-options "$@"
maybeDebug

if [[ "$h" ]]; then
  precho "bla\n\
    -o\t\t bla\n\
    -o\t\t bla\n\
    -o\t\t bla\n\
    --opt\t bla\n\
    --opt\t bla"
  exit
fi

case " " in
  "$y")
    REPLY="yes"
  ;;&
  "$dry_run")
    DRY="echo"
  ;;
esac
