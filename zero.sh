#! /usr/bin/env bash
source "$HOME/bin/optar.sh" || bailout "Dependency failed"

parse-options "$@"

if [[ "$h" ]]; then
  precho "bla
  -o     bla
  -o     bla
  -o     bla
  --opt  bla
  --opt  bla"
  exit
fi

case "true" in
  "$y")
    REPLY="yes"
  ;;&
  "$dry_run")
    DRY="echo"
  ;;
esac
