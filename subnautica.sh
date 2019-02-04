#! /usr/bin/env bash

set -e

cd "$HOME/SteamLibrary/steamapps/common/Subnautica/Subnautica.app/Contents/Resources/Data/Managed"
# cd /Volumes/Izi/SteamLibrary/steamapps/common/Subnautica/Subnautica.app/Contents/Resources/Data/Managed
mono QModManager.exe
