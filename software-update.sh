#! /usr/bin/env bash
if [ $HOME/bin/progress.sh ]; then . $HOME/bin/progress.sh; fi

work(){
  failSudo install

  progress start "Upgrading homebrew"
    (brew upgrade 1>/dev/null 2>&1
    brew cask upgrade 1>/dev/null)
    progress finish "$?"

  progress start "Scrubbing homebrew's cache"
    (brew cleanup -s --prune=31 1>/dev/null
    brew cask cleanup 1>/dev/null)
    progress finish "$?"

  # progress print "Updating some NPM packages"
  #   npm install -g caniuse
  #   progress finish "$?"

  progress print "Updating NPM global packages"
    npm update -g #1>/dev/null 2>&1
    progress finish "$?"

  progress start "Updating gems"
    # /usr/bin/gem often conflicts. MacOS version is root - wheel, no write perm.
    /usr/local/bin/gem update 1>/dev/null
    progress finish "$?"

  failSudo uninstall
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
