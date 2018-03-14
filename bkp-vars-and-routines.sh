#! /usr/bin/env bash
##-----------------------  Input  ----------------------##
# declare LOGPATH="$HOME/Desktop/bkp-log.txt"
declare LOGPATH="/dev/null"
# declare ADDLOG="--log-file $LOGPATH"
declare ADDLOG=""
declare RSYNC="rsync --recursive --update --inplace --no-relative --checksum"
declare BKPDIR="/Volumes/Seagate"
declare SAFECOPYDIR="/Volumes/Izi"
declare -A PATHS=(
# DO end paths with a trailing slash/
["/Users/vamac/bin/"]="$BKPDIR/Bkp/_Mac/bin/"
["/EFI-Backups/"]="$BKPDIR/Bkp/_Mac/others/EFI-Backups/"
["/Users/vamac/Documents/"]="$BKPDIR/Bkp/_Mac/documents/"
["/Volumes/Izi/Ableton/_projects/"]="$BKPDIR/Bkp/Ableton/_projects/"
["/Volumes/Izi/Ableton/Factory Packs/"]="$BKPDIR/Bkp/Ableton/Factory Packs/"
["/Volumes/Izi/Ableton/User Library/"]="$BKPDIR/Bkp/Ableton/User Library/"
["/Users/vamac/Pictures/2018/"]="$BKPDIR/Bkp/Pictures/2018/"
["/Users/vamac/Pictures/walls/"]="$BKPDIR/Bkp/Pictures/walls/"
["/Users/vamac/Code/"]="$BKPDIR/Bkp/Code/"
# [""]=""
# [""]=""
["/Users/vamac/Desktop/"]="$SAFECOPYDIR/bkp/Desktop/"
["/Users/vamac/Downloads/"]="$SAFECOPYDIR/bkp/Downloads/"
["/Users/vamac/Movies/"]="$SAFECOPYDIR/bkp/Movies/"
["/Users/vamac/VirtualBox VMs/"]="$SAFECOPYDIR/bkp/VirtualBox/"
# [""]=""
# [""]=""
# [""]=""
)
##------------------  External deps -------------------##
if [[ -f "$HOME/bin/progress.sh" ]]; then
  source $HOME/bin/progress.sh;
fi
##--------------------  Functions --------------------##
print(){
  precho "Printing input..."
  for file in "${!PATHS[@]}"; do
    for bkp in "${PATHS[$file]}"; do
      echo -en '\e[97;1m'; echo "  File - $file"
      echo -en '\e[0m';    echo "Backup - $bkp"
    done
  done
  return
}
help(){
  precho --usage
  precho "bkp.sh -- personal backup script"
  precho "-p, --print: prints all files and folders with their bkp location"
  precho "-h, --help : see this message"
  precho "no args    : run"
}
######----------------- Routines  -----------------######
now-running () {
  echo -e "\e[1;37m"
  center --padding=-1 "💫 🖥 Running $(basename $0) 🖥 💫"
  echo -e "\e[0m"
}
pathlist () {  #overwrite smart
  progress start "Copying pathlist to backup locations"
  printf "\n" 						                                            >> "$LOGPATH"
  echo "#################### STARTING NEW RUN ####################" 	>> "$LOGPATH"
  printf "\n"							                                            >> "$LOGPATH"
  #cleaning up emacs bkps and other files before sync
  trash-emacs.sh -v							                                      >> "$LOGPATH"
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
app-list() { #overwrite dumb
  progress start "Saving a list of all apps on /Applications"
  echo "-> $(date +"%b %d %T ")Applist rsync started"			          >> "$LOGPATH"
  (new_applist=./applist.txt
  old_applist=$BKPDIR/Bkp/_Mac/others/applist.txt
  cd "$HOME/Desktop" || bailout
  ls /Applications/ > ./applist.txt || bailout
  $RSYNC $ADDLOG "$new_applist" "$old_applist"
  trash ./applist.txt || bailout)
  progress finish "$?"
  echo "_________________________________________________________"	>> "$LOGPATH"
  printf "\n"    						                                        >> "$LOGPATH"
}
zip-move() { #overwrite dumb
  #do NOT end file paths with a trailing slash/. It will zip contents ONLY and create a file named .tar.7z (hidden)
  declare -A ZIPLIST=(
  #old ff path: "/Users/Shared/5e3ouofl.default"
  ["$HOME/Library/Application Support/Waterfox/Profiles/5e3ouofl.default"]="$BKPDIR/Bkp/Firefox/5e3ouofl.default.tar.7z"
  ["/Volumes/Izi/bkp/vuzebkp"]="$BKPDIR/Bkp/_Mac/others/vuzebkp.tar.7z"
  )
  progress start "Zipping and moving ziplist"
  echo "-> $(date +"%b %d %T ")tar-7zing files using parellel..."        	>> "$LOGPATH"
  parallel -i -j$(sysctl -n hw.ncpu) 7z-it.sh {} -- "${!ZIPLIST[@]}" || bailout
  echo "-> $(date +"%b %d %T ")Rsyncing zipped files..."			            >> "$LOGPATH"
  for zippedfile in "${!ZIPLIST[@]}"; do
    for bkp in "${ZIPLIST[$zippedfile]}"; do
      printf "\n"   								                                      >> "$LOGPATH"
      echo "-> $(date +"%b %d %T ")Rsyncing $zippedfile to $bkp"	        >> "$LOGPATH"
      $RSYNC $ADDLOG "${zippedfile}.tar.7z" "$bkp"
    done
    trash "${zippedfile}.tar.7z" || bailout
  done
  progress finish "$?"
  echo "_________________________________________________________"	      >> "$LOGPATH"
  printf "\n"								                                              >> "$LOGPATH"
}
do-homebrew () { #new apps not on system will dl as lastest so its good.
  if [ -f "$HOME/bin/homebrew-upgrade.sh" ]; then
    $HOME/bin/homebrew-upgrade.sh --dont-ask
  fi
}
do-mackup (){ #need to test how google drive handles these files, but if but on path list should be safe.
  progress start "Running Mackup"
  mackup backup 1>/dev/null || bailout
  progress finish "$?"
}
do-brewfile () { #will overwrite if different. could rewrite to use rsync, and then it would be safe.
  if [ -f "$HOME/bin/brewfile-update.sh" ];then
    $HOME/bin/brewfile-update.sh
  fi
}
