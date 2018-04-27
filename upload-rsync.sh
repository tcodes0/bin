#! /usr/bin/env bash
source "$HOME/bin/optar.sh" || bailout "Dependency failed"

parse-options "$@"
maybeDebug

if [[ "$h" ]]; then
  precho "upload-rsync.sh uploads ./build via ssh to web server
  \n -y     \t\t auto confirm
  \n -v     \t\t verbose rsync
  \n -h     \t\t see this help
  \n --clean \t remove extra files on server
  \n --dry-run"
  exit
fi

case " " in
  "$y")
    REPLY="yes"
  ;;&
  "$dry_run")
    DRY="echo"
  ;;
esac

if [[ ! "$y" ]]; then
  precho "Upload to server via rsync? (y/n)\n\
  ...defaulting to yes in 6s"
  read -t 6
  if [ "$?" != 0 ]; then
    REPLY=''
  fi
fi

if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ] || [ "$REPLY" == "" ]; then
  echo -ne "\e[1;49;33m♦︎ Uploading all files with rsync...\e[0m"
  options="--recursive --update --inplace --no-relative --checksum --compress"
  if [[ "$clean" ]]; then
    options=$options" --delete"
  fi
  if [ "$v" -o "$verbose" ]; then
    options=$options" -v"
  fi
  SSH="ssh -p 21098"
  host="tazemuad@server179.web-hosting.com:/home/tazemuad"
  remote_dir=$host/sites/$(basename $PWD)/
  local_dir=$PWD/build/
  $DRY rsync $options -e "$SSH" $local_dir $remote_dir
  if [[ "$?" == 0 ]]; then
    echo -e "\r\e[1;49;32m✔ Done $(date +%H:%M)                                         \e[0m"
  fi
fi
