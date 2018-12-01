#! /usr/bin/env bash

  echo -e "
  \\033[4;38;05;196mrm -rf\\033[0m the following folders? (y/n)

    ~/Library/Developer/Xcode/DerivedData
        \\033[2;3;4mBuild products, safe to delete.\\033[0m
        \\033[2;3;4mCan also be deleted from organizer.\\033[0m

    ~/Library/Caches
        \\033[2;3;4mVarious app caches.\\033[0m

    ~/Library/Containers/com.apple.mail/Data/Library/Mail Downloads
        \\033[2;3;4mDownloaded Mail.app stuff.\\033[0m

    /private/var/folders/*
        \\033[2;3;4mTemporary folders.\\033[0m
"

  if ! read -r; then
    exit "$?"
  fi

  if [ "$REPLY" == "n" ] || [ "$REPLY" == "N" ]; then
    say hmmmm
    exit
  fi

  if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
    say ja burrrr la la la
    echo removing "$HOME/Library/Developer/Xcode/DerivedData"...
    echo removing "$HOME/Library/Caches"...
    echo removing "$HOME/Library/Containers/com.apple.mail/Data/Library/Mail\\ Downloads"...
    echo removing "/private/var/folders/*"...
    exit
  fi
