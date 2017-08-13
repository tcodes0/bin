#! /bin/bash

#try setting set -o 

external=$HOME/.bash_functions

if [ -f $external ];then
    source $external
fi

precho "Updating homebrew and Brewfile..."
echo

runc brew update
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
    precho "...Brewfile unchanged, skipping it."
    trash $NEW
    echo
    exit 0
fi

runc mv $OLD $OLD-old
runc trash $OLD-old
runc mv $NEW $OLD
echo
