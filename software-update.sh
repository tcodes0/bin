#! /usr/bin/env bash
if [ $HOME/bin/progress.sh ]; then source $HOME/bin/progress.sh; fi
LOGPATH=$HOME/.log

work(){
  progress start "Upgrading homebrew"
    (setsid -w brew upgrade </dev/null 2>&1 1>$LOGPATH/brew-update.txt
    setsid -w brew cask upgrade </dev/null 2>&1 1>$LOGPATH/brewcask-update.txt)
    progress finish "$?"

  progress start "Scrubbing homebrew's cache"
    (brew cleanup -s --prune=31 2>&1 1>$LOGPATH/brew-cleanup.txt
    brew cask cleanup 2>&1 1>$LOGPATH/brewcask-cleanup.txt)
    progress finish "$?"

  progress print "Updating NPM global packages"
    npm update -g 2>&1 1>$LOGPATH/npm-update.txt
    progress finish "$?"

  progress start "Updating gems"
    # /usr/bin/gem often conflicts. MacOS version is root - wheel, no write perm.
    /usr/local/bin/gem update 2>&1 1>$LOGPATH/gem-update.txt
    progress finish "$?"
}

case "$1" in
  --dont-ask | -f)
  work
  exit 0
  ;;
esac

#confirm upgrade
precho "Upgrade all cli-software now? (y/n)
   ...defaulting to no in 5s"
read -t 5

if [ "$?" != 0 ]; then
  exit 1
fi

if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
  work
fi
