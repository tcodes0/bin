#! /bin/bash

#################### notes to self

##-----------------------  Input  ----------------------##

declare LOGPATH="$HOME/Desktop/bkp-log.txt"
declare ADDLOG="--log-file $LOGPATH"
declare RSYNC="rsync --recursive --update --inplace --no-relative"

declare -A PATHS=(
    ["/Users/vamac/bin/"]="/Volumes/Seagate/Bkp/_Mac/bin/"
    ["/EFI-Backups/"]="/Volumes/Seagate/Bkp/_Mac/others/EFI-Backups/"
    ["/Users/vamac/Desktop/hmac/"]="/Volumes/Seagate/Bkp/_Mac/desktop/hmac/"
    #moved these two to backup permanently
    #["/Users/vamac/Desktop/logs/"]="/Volumes/Seagate/Bkp/_Mac/desktop/logs/"
    #["/Users/vamac/Desktop/lisp/"]="/Volumes/Seagate/Bkp/Code/lisp/"
    ["/Users/vamac/Desktop/musite/"]="/Volumes/Seagate/Bkp/Documents/andrea/musite/"
    ["/Users/vamac/Documents/mac-memos.rtf"]="/Volumes/Seagate/Bkp/_Mac/documents/mac-memos.rtf"
    ["/Users/vamac/Documents/Native Instruments/"]="/Volumes/Seagate/Bkp/_Mac/documents/Native Instruments/"
    ["/Volumes/Izi/Ableton/_projects/"]="/Volumes/Seagate/Bkp/Ableton/_projects/"
    ["/Volumes/Izi/Ableton/Factory Packs/"]="/Volumes/Seagate/Bkp/Ableton/Factory Packs/"
    ["/Volumes/Izi/Ableton/User Library/"]="/Volumes/Seagate/Bkp/Ableton/User Library/"
    ["/Users/vamac/Pictures/17/"]="/Volumes/Seagate/Bkp/Pictures/17/"
    ["/Users/vamac/Pictures/walls/"]="/Volumes/Seagate/Bkp/Pictures/walls/"
    ["/Users/vamac/Documents/rpg-sheet-folder/"]="/Volumes/Seagate/Bkp/Documents/RPG/2017 july RPG/rpg-sheet-folder/"
    # [""]=""
    # [""]=""
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
    echo -c "$external not found. Exiting..."
    exit 1
fi

print(){
    precho "Printing input..."

    for file in "${!PATHS[@]}"; do
	for bkp in "${PATHS[$file]}"; do
	    echo 
	    echo "File - $file"
	    echo "Bkp  - $bkp"
	done
    done
    echo    
    return
}

######-----------------  Main -----------------######

if [ "$1" == "--print" ]; then
    print
    exit 0
fi

clear

#-- Homebrew
# obsolete since upgrade does an update and is run in the end.
# if [ -f "$HOME/bin/homebrew-update.sh" ]; then
#    $HOME/bin/homebrew-update.sh
# fi

#-- Rsync

precho "Running main rsync backup... "
echo    								>> "$LOGPATH"
echo "#################### STARTING NEW RUN ####################" 	>> "$LOGPATH"
echo    								>> "$LOGPATH"

#cleaning up emacs bkps and other files before sync
trash-emacs.sh -v							>> "$LOGPATH"

for file in "${!PATHS[@]}"; do
    for bkp in "${PATHS[$file]}"; do
	echo -e "\n-> $(date +"%b %d %T ")$file    to     $bkp"		>> "$LOGPATH"
	if ! [ -d "$bkp" ] && ! [ -f "$bkp" ]; then
            echo "-> full bkp path doesn't seem to exist!" 		>> "$LOGPATH"
	    echo "-> attempting to make it" 				>> "$LOGPATH"
	    mkdir -p "$bkp"
	fi
	$RSYNC $ADDLOG "$file" "$bkp"
    done
done
echo
echo "_________________________________________________________"	>> "$LOGPATH"
echo    								>> "$LOGPATH"

#-- Applist

precho "Rsyncing applist..."
echo "-> $(date +"%b %d %T ")Applist rsync started"			>> "$LOGPATH"
new_applist=./applist.txt
old_applist=/Volumes/Seagate/Bkp/_Mac/others/applist.txt

runc cd "$HOME/Desktop"
runc ls /Applications/ > ./applist.txt

$RSYNC $ADDLOG "$new_applist" "$old_applist"

runc trash ./applist.txt

echo
echo "_________________________________________________________"	>> "$LOGPATH"
echo    								>> "$LOGPATH"

#-- Zip-move

#do NOT end file paths with a trailing slash/. It will zip contents ONLY and create a file named .tar.7z (hidden)

declare -A ZIPLIST=(
    ["/Users/Shared/5e3ouofl.default"]="/Volumes/Seagate/Bkp/Firefox/5e3ouofl.default.tar.7z"
    ["/Volumes/Izi/bkp/vuzebkp"]="/Volumes/Seagate/Bkp/_Mac/others/vuzebkp.tar.7z"
)

precho "Zipping and moving ziplist..."
echo "-> $(date +"%b %d %T ")tar-7zing files using parellel..."        	>> "$LOGPATH"
runc parallel -i -j$(sysctl -n hw.ncpu) 7z-it.sh {} -- "${!ZIPLIST[@]}"

echo "-> $(date +"%b %d %T ")Rsyncing zipped files..."			>> "$LOGPATH"
for zippedfile in "${!ZIPLIST[@]}"; do
    for bkp in "${ZIPLIST[$zippedfile]}"; do
	echo   								>> "$LOGPATH"
	echo "-> $(date +"%b %d %T ")Rsyncing $zippedfile to $bkp"	>> "$LOGPATH"
	$RSYNC $ADDLOG "${zippedfile}.tar.7z" "$bkp"
    done
    runc trash "${zippedfile}.tar.7z"
done
echo
echo "_________________________________________________________"	>> "$LOGPATH"
echo    								>> "$LOGPATH"

#-- Homebrew upgrade

if [ -f "$HOME/bin/homebrew-gradeup.sh" ]; then
    $HOME/bin/homebrew-gradeup.sh
fi

#-- Mackup

precho "Running Mackup..."
runc mackup backup
echo

#-- Scheduler
scheduler.sh --record
