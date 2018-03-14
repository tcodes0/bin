#! /bin/bash
if [[ $HOME/bin/progress.sh ]]; then . $HOME/bin/progress.sh; fi
progress start "Updating Brewfile..."
(runc cd "$HOME/Desktop"
if [ -f ./Brewfile ];then #prevents an error from previous run's files
  trash ./Brewfile
fi
runc brew bundle dump #this creates an up-to-date brewfile in ./ named Brewfile
OLD=$(readlink ~/.Brewfile)
NEW=./Brewfile
if [ "$(diff --brief $NEW $OLD)" == "" ]; then
  trash $NEW
else
  runc mv $OLD $OLD-old
  runc trash $OLD-old
  runc mv $NEW $OLD
fi)
progress finish "$?"
