#! /usr/bin/env bash

set -e

cd "$HOME/bin"
git fetch
git push -q
git pull --ff-only

cd "$HOME/Documents/GoogleDrive/Mackup"
git fetch
git push -q
git pull --ff-only
