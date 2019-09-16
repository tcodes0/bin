#! /usr/bin/env bash

set -e
GIT_COMMAND="git pull --ff-only"

if [ "$1" == "push" ] || [ "$1" == "p" ]; then
  GIT_COMMAND="git push"
fi

cd "$HOME/bin"
git fetch
eval "$GIT_COMMAND"

cd "$HOME/Documents/GoogleDrive/Mackup"
git fetch
eval "$GIT_COMMAND"
