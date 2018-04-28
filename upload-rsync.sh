#! /usr/bin/env bash
source "$HOME/bin/optar.sh" || bailout "Dependency failed"

parse-options "$@"

if [ "$h" -o "$help" ]; then
  precho "upload-rsync.sh uploads a local directory to a web server.
  It appends the current directory to the destination, to make it
  easier to call it from multiple project folders.

  -h, --help      see this help
  -y, --yes       auto confirmation
  -v, --verbose   verbose rsync
                    see rsync option --verbose
  --delete        remove extraneous files on server
                    see rsync option --delete
  --dry-run       show what would be done
                    see rsync option --dry-run"
  exit
fi

#~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
#     EDIT INFO HERE
#
#enter below: command to use for SSH, and port
#example: "ssh -p 83723"
SSH="ssh -p 21098"
#enter below: username@hostname:pathToRemoteDirectory
#example: "you@server.web-hosting.com:/home/you/work"
remote_dir="tazemuad@server179.web-hosting.com:/home/tazemuad/sites"
#enter below: local directory to upload **relative** to current directory
#example: "build"
local_dir="build"
#
#~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

# validation
if [ ! "$SSH" -o ! "$remote_dir" -o ! "$local_dir" ]; then
  bailout "Missing either \$SSH, \$remote_dir or \$local_dir. Please edit the script."
fi

if [[ ! -d "$local_dir" ]]; then
  bailout "Looking for \"$(basename $local_dir)\" inside \"$PWD\":
  $local_dir doesn't appear to exist.
  Keep in mind the directory is relative."
fi

remote_dir=$remote_dir"/$(basename $PWD)/"
local_dir=$PWD/$local_dir/

case "true" in
  "$y" | "$yes")
    REPLY="yes"
  ;;&
  "$dry_run")
    options=$options" --dry-run"
  ;;&
  "$delete")
    options=$options" --delete"
  ;;&
  "$v" | "$verbose")
    options=$options" --verbose"
  ;;
esac

if [ "$REPLY" != "yes" ]; then
  precho "Upload to server via rsync? (y/n)
  ...defaulting to yes in 6s"
  read -t 6
  if [ "$?" != 0 ]; then
    REPLY=''
  fi
fi

if [ "$REPLY" == "y" -o "$REPLY" == "yes" -o "$REPLY" == "Y" -o "$REPLY" == "YES" -o "$REPLY" == "" ]; then
  echo -ne "\e[1;49;33m♦︎ Uploading all files with rsync...\e[0m"
  options=$options" --recursive --update --inplace --no-relative --checksum --compress"
  rsync $options -e "$SSH" $local_dir $remote_dir
  if [[ "$?" == 0 ]]; then
    echo -e "\r\e[1;49;32m✔ Done 🕰  $(date +%H:%M)                                         \e[0m"
  fi
fi
