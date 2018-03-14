#! /bin/bash
if [[ $HOME/bin/progress.sh ]]; then . $HOME/bin/progress.sh; fi
progress start "Updating Brewfile..."
(cd "$HOME/Desktop" || bailout
if [ -f ./Brewfile ];then #prevents an error from previous run's files
  trash ./Brewfile
fi
brew bundle dump || bailout #this creates an up-to-date brewfile in ./ named Brewfile
OLD=$(readlink ~/.Brewfile)
NEW=./Brewfile
if [ "$(diff --brief $NEW $OLD)" == "" ]; then
  trash $NEW
else
  mv $OLD $OLD-old || bailout
  trash $OLD-old || bailout
  mv $NEW $OLD || bailout
fi)
progress finish "$?"
