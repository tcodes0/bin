#! /bin/bash
external=$HOME/.bash_functions
if [ -f $external ];then
  source $external
fi
work(){
  precho "Upgrading all homebrew apps..."
  # echo
  brew upgrade 1>/dev/null
  precho "Scrubbing homebrew's cache..."
  # echo
  brew cleanup -s --prune=31 1>/dev/null
}
case "$1" in
  --dont-ask | -f)
  work
  exit 0
  ;;
esac
#confirm upgrade
precho "Upgrade all homebrew apps now? (y/n)"
precho "...defaulting to yes in 10s"
read -t 10
if [ "$?" != 0 ]; then
  exit 1
fi
if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
  work
  exit 0
fi
