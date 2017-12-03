#! /bin/bash
external=$HOME/.bash_functions
if [ -f $external ];then
  source $external
fi
precho "Updating Brewfile..."
echo
runc cd "$HOME/Desktop"
#prevents an error from previous run's files
if [ -f ./Brewfile ];then
  trash ./Brewfile
fi
#this creates an up-to-date brewfile in the current dir named Brewfile
runc brew bundle dump
OLD=$(readlink ~/.Brewfile)
NEW=./Brewfile
if [ "$(diff --brief $NEW $OLD)" == "" ]; then
  #precho "...Brewfile unchanged, skipping it."
  trash $NEW
  echo
else
  runc mv $OLD $OLD-old
  runc trash $OLD-old
  runc mv $NEW $OLD
  echo
fi
