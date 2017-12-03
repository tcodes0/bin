#! /bin/bash
external=$HOME/.bash_functions
if [ -f $external ];then
  source $external
fi
if [ "$1" == "--dont-ask" -o "$1" == "-f" ];then
  brew upgrade
  exit 0
fi
#confirm upgrade
precho "Upgrade all homebrew apps now? (y/n)"
precho "...defaulting to yes in 10s"
read -t 10
if [ "$?" != 0 ]; then
  exit 1
fi
if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
  brew upgrade
fi
exit 0
