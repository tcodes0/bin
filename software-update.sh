#! /usr/bin/env bash
# shellcheck source=/Users/vamac/bin/progress.sh
set -e
if [ -f "${HOME}/bin/progress.sh" ]; then source "$HOME/bin/progress.sh"; fi


work() {
  [ "$1" == "silently" ] && local silently=">/dev/null 2>&1"
  set -e

  [ "$silently" ] && progress start "Upgrading homebrew"
  # || true because brew fails on pinned itens being upgraded...
  eval setsid -w brew upgrade </dev/null "$silently" || true
  eval setsid -w brew cask upgrade </dev/null "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Scrubbing homebrew's cache"
  eval brew cleanup -s --prune=31 "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Updating NPM global packages"
  eval npm update -g "$silently"
  eval npm -g i caniuse "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Updating gems"
  # /usr/bin/gem often conflicts. MacOS version is root - wheel, no write perm.
  eval "setsid -w yes | /usr/local/bin/gem update $silently" || true
  eval /usr/local/bin/gem cleanup "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Updating Node"
  eval "yes | nvm install node $silently"
  [ "$silently" ] && progress finish "$?"
}

case "$1" in
--dont-ask | -f)
  work silently || progress finish "$?"
  exit 0
  ;;
esac

#confirm upgrade
precho "Upgrade all cli-software now? (y/n)
   ...defaulting to no in 5s"
if ! read -rt 5; then exit $?; fi

if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
  work
fi
