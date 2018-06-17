#! /usr/bin/env bash
##-----------------------  Input  ----------------------##

# TODO consider set -(opt to exit on any err)
# declare LOGPATH="$HOME/Desktop/bkp-log.txt"
declare LOGPATH="$HOME/Desktop/log.txt"
declare ADDLOG="--log-file $LOGPATH"
declare ADDDELETE="--delete --checksum"
# declare LOGPATH="/dev/null"
# declare ADDLOG=""
declare RSYNC="rsync --recursive --update --inplace --no-relative"
declare BKPDIR="/Volumes/Seagate"
declare SAFECOPYDIR="/Volumes/Izi"

declare -A PATHS=(
# DO end paths with a trailing slash/
["/EFI-Backups/"]="$BKPDIR/Bkp/_Mac/others/EFI-Backups/"
["/Users/vamac/Documents/"]="$BKPDIR/Bkp/_Mac/documents/"
["/Volumes/Izi/Ableton/_projects/"]="$BKPDIR/Bkp/Ableton/_projects/"
["/Volumes/Izi/Ableton/Factory Packs/"]="$BKPDIR/Bkp/Ableton/Factory Packs/"
["/Volumes/Izi/Ableton/User Library/"]="$BKPDIR/Bkp/Ableton/User Library/"
["/Users/vamac/Pictures/2018/"]="$BKPDIR/Bkp/Pictures/2018/"
["/Users/vamac/Pictures/walls/"]="$BKPDIR/Bkp/Pictures/walls/"
# [""]=""
# [""]=""
)

declare -A SAFECOPIES=(
["/Users/vamac/Desktop/"]="$SAFECOPYDIR/bkp/Desktop/"
["/Users/vamac/Downloads/"]="$SAFECOPYDIR/bkp/Downloads/"
["/Users/vamac/Movies/"]="$SAFECOPYDIR/bkp/Movies/"
["/Users/vamac/VirtualBox VMs/"]="$SAFECOPYDIR/bkp/VirtualBox/"
# [""]=""
# [""]=""
# [""]=""
)

declare -A DELPATHS=(
["/Users/vamac/bin/"]="$BKPDIR/Bkp/_Mac/bin/"
["/Users/vamac/Code/"]="$BKPDIR/Bkp/Code/"
)

declare -A ZIPTHIS=(
#do NOT end file paths with a trailing slash/. It will zip contents ONLY and create a file named .tar.7z (hidden)
#old ff path: "/Users/Shared/5e3ouofl.default"
["$HOME/Library/Application Support/Waterfox/Profiles/5e3ouofl.default"]="$BKPDIR/Bkp/Firefox/5e3ouofl.default.tar.7z"
["/Volumes/Izi/bkp/vuzebkp"]="$BKPDIR/Bkp/_Mac/others/vuzebkp.tar.7z"
)

##--------------------  Functions --------------------##
do-print(){
  precho "Pathlist..."
  for file in "${!PATHS[@]}"; do
    for bkp in "${PATHS[$file]}"; do
      echo -en '\e[97;1m'; echo "  File - $file"
      echo -en '\e[0m';    echo "Backup - $bkp"
    done
  done

  printf "\n"
  precho "Safecopies..."
  for file in "${!SAFECOPIES[@]}"; do
    for bkp in "${SAFECOPIES[$file]}"; do
      echo -en '\e[97;1m'; echo "  File - $file"
      echo -en '\e[0m';    echo "Backup - $bkp"
    done
  done

  printf "\n"
  precho "Version controlled list..."
  for file in "${!DELPATHS[@]}"; do
    for bkp in "${DELPATHS[$file]}"; do
      echo -en '\e[97;1m'; echo "  File - $file"
      echo -en '\e[0m';    echo "Backup - $bkp"
    done
  done

  printf "\n"
  precho "Ziplist..."
  for file in "${!ZIPTHIS[@]}"; do
    for bkp in "${ZIPTHIS[$file]}"; do
      echo -en '\e[97;1m'; echo "  File - $file"
      echo -en '\e[0m';    echo "Backup - $bkp"
    done
  done
  return
}

do-help(){
  precho "bkp.sh ➡ personal backup script
  -p, --print     prints all files and folders with their bkp location
  -h, --help      see this message
  -v              verbose
  no args         run"
}

now-running () {
  echo -e "\e[1;37m"
  center --padding=-1 "💫 🖥 Running $(basename $0) 🖥 💫"
  echo -e "\e[0m"
}

pathlist () {
  progress start "Copying common files to backup locations"
  printf "\n" 						                                            >> "$LOGPATH"
  echo "#################### STARTING NEW RUN ####################" 	>> "$LOGPATH"
  printf "\n"							                                            >> "$LOGPATH"
  for file in "${!PATHS[@]}"; do
    for bkp in "${PATHS[$file]}"; do
      echo -e "\n-> $(date +"%b %d %T ")$file    to     $bkp"		     >> "$LOGPATH"
      if ! [ -d "$bkp" ] && ! [ -f "$bkp" ]; then
        echo "-> full bkp path doesn't seem to exist!" 		           >> "$LOGPATH"
        echo "-> attempting to make it" 				                     >> "$LOGPATH"
        mkdir -p "$bkp"
      fi
      $RSYNC $ADDLOG "$file" "$bkp" 1>/dev/null
    done
  done
  progress finish "$?"
  echo "_________________________________________________________"	>> "$LOGPATH"
  printf "\n"    					                                          >> "$LOGPATH"
}

dellist () {
  progress start "Copying version controlled files"
  for file in "${!DELPATHS[@]}"; do
    for bkp in "${DELPATHS[$file]}"; do
      echo -e "\n-> $(date +"%b %d %T ")$file    to     $bkp"		     >> "$LOGPATH"
      if ! [ -d "$bkp" ] && ! [ -f "$bkp" ]; then
        echo "-> full bkp path doesn't seem to exist!" 		           >> "$LOGPATH"
        echo "-> attempting to make it" 				                     >> "$LOGPATH"
        mkdir -p "$bkp"
      fi
      $RSYNC $ADDLOG $ADDDELETE "$file" "$bkp" 1>/dev/null
    done
  done
  progress finish "$?"
  echo "_________________________________________________________"	>> "$LOGPATH"
  printf "\n"    					                                          >> "$LOGPATH"
}

safelist () {
  progress start "Copying other files to redundant storage"
  for file in "${!SAFECOPIES[@]}"; do
    for bkp in "${SAFECOPIES[$file]}"; do
      echo -e "\n-> $(date +"%b %d %T ")$file    to     $bkp"		     >> "$LOGPATH"
      if ! [ -d "$bkp" ] && ! [ -f "$bkp" ]; then
        echo "-> full bkp path doesn't seem to exist!" 		           >> "$LOGPATH"
        echo "-> attempting to make it" 				                     >> "$LOGPATH"
        mkdir -p "$bkp"
      fi
      $RSYNC $ADDLOG "$file" "$bkp" 1>/dev/null
    done
  done
  progress finish "$?"
  echo "_________________________________________________________"	>> "$LOGPATH"
  printf "\n"    					                                          >> "$LOGPATH"
}

applist() {
  echo "-> $(date +"%b %d %T ")Applist rsync started"			          >> "$LOGPATH"
  progress start "Saving a list of apps on /Applications"
  ls /Applications > "$BKPDIR/Bkp/_Mac/others/applist.txt" || bailout
  progress finish "$?"
  echo "_________________________________________________________"	>> "$LOGPATH"
  printf "\n"    						                                        >> "$LOGPATH"
}

ziplist() {
  progress start "Zipping and copying files"
  echo "-> $(date +"%b %d %T ")ziplist - tar7zing files using paralol..." >> "$LOGPATH"
  for file in "${!ZIPTHIS[@]}"; do
    paralolDo tar7z "$file"
  done
  paralolWait || bailout
  echo "-> $(date +"%b %d %T ")Rsyncing zipped files..."			            >> "$LOGPATH"
  for file in "${!ZIPTHIS[@]}"; do
    for bkp in "${ZIPTHIS[$file]}"; do
      printf "\n"   								                                      >> "$LOGPATH"
      echo "-> $(date +"%b %d %T ")Rsyncing $file to $bkp"	              >> "$LOGPATH"
      $RSYNC $ADDLOG "${file}.tar.7z" "$bkp"
    done
    trash "${file}.tar.7z" || bailout
  done
  progress finish "$?"
  echo "_________________________________________________________"	      >> "$LOGPATH"
  printf "\n"								                                              >> "$LOGPATH"
}

do-software () { #new apps not on system will dl as lastest so its good.
  if [ -f "$HOME/bin/software-update.sh" ]; then
    $HOME/bin/software-update.sh --dont-ask
  fi
}

do-mackup (){ #need to test how google drive handles these files, but if but on path list should be safe.
  progress start "Running Mackup"
  mackup backup -f 1>/dev/null || bailout
  progress finish "$?"
}

do-brewfile () {
  progress start "Updating Brewfile"
    (bf=$(readlink ~/.Brewfile)
    if [ -f "$bf" ]; then
      trash "$bf"
    fi
    brew bundle dump --file="$bf" || bailout)
  progress finish "$?"
}
