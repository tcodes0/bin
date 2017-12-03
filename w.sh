#!/bin/bash
external=$HOME/.bash_functions
if [ -f "$external" ]; then
  source "$external"
fi
mupush () {
  precho "git checkout master"
  runc -c git checkout master
  prehco "git merge wip"
  runc -c git merge wip
  precho "git push"
  runc -c git push
}
murevert () {
  precho "git checkout master"
  runc -c git checkout master
  precho "git reset --hard \$webcommit"
  runc -c git reset --hard $webcommit
  precho "git push --force"
  runc -c git push --force
  precho "git checkout wip"
  runc -c git checkout wip
}
helpw () {
  echo "Please provide args. such as mupush or murevert"
}
if [ "$#" != "1" ]; then
  helpw
  exit 1
else
  case "$1" in
    mupush)
    mupush
    ;;
    murevert)
    murevert
    ;;
    *)
    helpw
    exit 1
    ;;
  esac
fi
