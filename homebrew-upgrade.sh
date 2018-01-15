#! /bin/bash
external=$HOME/.bash_functions
if [ -f $external ];then
  source $external
fi
if [[ $HOME/bin/progress.sh ]]; then . $HOME/bin/progress.sh; fi
work(){
  progress show "Upgrading all homebrew apps (and casks)..."
    (brew upgrade 1>/dev/null 2>&1
    brew cask upgrade 1>/dev/null)
  progress finish "$?"
  progress show "Scrubbing homebrew's cache..."
    (brew cleanup -s --prune=31 1>/dev/null
    brew cask cleanup 1>/dev/null)
  progress finish "$?"
  progress show "Upgrading gems..."
    gem update 1>/dev/null
  progress finish "$?"
}
case "$1" in
  --dont-ask | -f)
  work
  exit 0
  ;;
esac
#confirm upgrade
precho "Upgrade all homebrew apps, casks and gems now? (y/n)"
precho "...defaulting to no in 5s"
read -t 5
if [ "$?" != 0 ]; then
  exit 1
fi
if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
  work
fi
