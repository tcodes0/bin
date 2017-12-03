#! /bin/bash
#################### notes to self
##-----------------------  Input  ----------------------##
declare LOGPATH="$HOME/Desktop/bkp-log.txt"
declare ADDLOG="--log-file $LOGPATH"
declare RSYNC="rsync --recursive --update --inplace --no-relative"
declare BKPDIR="/Volumes/Seagate"
declare -A PATHS=(
# DO end paths with a trailing slash/
["/Users/vamac/bin/"]="$BKPDIR/Bkp/_Mac/bin/"
["/EFI-Backups/"]="$BKPDIR/Bkp/_Mac/others/EFI-Backups/"
["/Users/vamac/Documents/hmac"]="$BKPDIR/Bkp/_Mac/documents/hmac"
["/Users/vamac/Documents/mac-memos.rtf"]="$BKPDIR/Bkp/_Mac/documents/mac-memos.rtf"
["/Users/vamac/Documents/Native Instruments/"]="$BKPDIR/Bkp/_Mac/documents/Native Instruments/"
["/Volumes/Izi/Ableton/_projects/"]="$BKPDIR/Bkp/Ableton/_projects/"
["/Volumes/Izi/Ableton/Factory Packs/"]="$BKPDIR/Bkp/Ableton/Factory Packs/"
["/Volumes/Izi/Ableton/User Library/"]="$BKPDIR/Bkp/Ableton/User Library/"
["/Users/vamac/Pictures/17/"]="$BKPDIR/Bkp/Pictures/17/"
["/Users/vamac/Pictures/walls/"]="$BKPDIR/Bkp/Pictures/walls/"
["/Users/vamac/Code/"]="$BKPDIR/Bkp/Code/"
["/Users/vamac/Desktop/cecats/"]="$BKPDIR/Bkp/_Mac/desktop/cecats/"
# [""]=""
# [""]=""
# [""]=""
# [""]=""
# [""]=""
)
##--------------------  Functions --------------------##
external=$HOME/.bash_functions
if [ -f "$external" ]; then
  source "$external"
else
  echo "$external not found. Exiting..."
  exit 1
fi
print(){
  precho "Printing input..."
  for file in "${!PATHS[@]}"; do
    for bkp in "${PATHS[$file]}"; do
      echo
      echo "File - $file"
      echo "Dest - $bkp"
    done
  done
  echo
  return
}
ask-first() {
  precho "run bkp.sh now (y/n)?"
  precho "...defaulting to yes in 5s"
  read -t 5
  if [ "$REPLY" == "n" -o "no" -o "N" -o "NO" ]; then
    exit 1
  fi
}
######-----------------  Main -----------------######
if [ "$1" == "--print" ] || [ "$1" == "-p" ]; then
  print
  exit 0
fi
#-- Test for backup drive plugged in
if ! [ -d "$BKPDIR" ]; then
  precho -c "Seagate is not plugged in! Aborting"
  exit 1
fi
#-- Rsync
precho "Running main rsync backup... "
echo    								                                            >> "$LOGPATH"
echo "#################### STARTING NEW RUN ####################" 	>> "$LOGPATH"
echo    								                                            >> "$LOGPATH"
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
    $RSYNC $ADDLOG "$file" "$bkp"
  done
done
echo
echo "_________________________________________________________"	>> "$LOGPATH"
echo    								                                          >> "$LOGPATH"
#-- Applist
precho "Rsyncing applist..."
echo "-> $(date +"%b %d %T ")Applist rsync started"			          >> "$LOGPATH"
new_applist=./applist.txt
old_applist=$BKPDIR/Bkp/_Mac/others/applist.txt
runc cd "$HOME/Desktop"
runc ls /Applications/ > ./applist.txt
$RSYNC $ADDLOG "$new_applist" "$old_applist"
runc trash ./applist.txt
echo
echo "_________________________________________________________"	>> "$LOGPATH"
echo    								                                          >> "$LOGPATH"
#-- Zip-move
#do NOT end file paths with a trailing slash/. It will zip contents ONLY and create a file named .tar.7z (hidden)
declare -A ZIPLIST=(
#old ff path: "/Users/Shared/5e3ouofl.default"
["$HOME/Library/Application Support/Waterfox/Profiles/5e3ouofl.default"]="$BKPDIR/Bkp/Firefox/5e3ouofl.default.tar.7z"
["/Volumes/Izi/bkp/vuzebkp"]="$BKPDIR/Bkp/_Mac/others/vuzebkp.tar.7z"
)
precho "Zipping and moving ziplist..."
echo "-> $(date +"%b %d %T ")tar-7zing files using parellel..."        	>> "$LOGPATH"
runc parallel -i -j$(sysctl -n hw.ncpu) 7z-it.sh {} -- "${!ZIPLIST[@]}"
echo "-> $(date +"%b %d %T ")Rsyncing zipped files..."			            >> "$LOGPATH"
for zippedfile in "${!ZIPLIST[@]}"; do
  for bkp in "${ZIPLIST[$zippedfile]}"; do
    echo   								                                              >> "$LOGPATH"
    echo "-> $(date +"%b %d %T ")Rsyncing $zippedfile to $bkp"	        >> "$LOGPATH"
    $RSYNC $ADDLOG "${zippedfile}.tar.7z" "$bkp"
  done
  runc trash "${zippedfile}.tar.7z"
done
echo
echo "_________________________________________________________"	      >> "$LOGPATH"
echo    								                                                >> "$LOGPATH"
#-- Homebrew upgrade
if [ -f "$HOME/bin/homebrew-gradeup.sh" ]; then
  $HOME/bin/homebrew-gradeup.sh --dont-ask
fi
#-- Mackup
precho "Running Mackup..."
runc mackup backup
echo
#-- Brewfile
if [ "$HOME/bin/brewfile-update.sh" ];then
  $HOME/bin/brewfile-update.sh
fi
#-- Scheduler
scheduler.sh --record
