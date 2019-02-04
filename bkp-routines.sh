#! /usr/bin/env bash
##-----------------------  Input  ----------------------##

declare LOGPATH="$HOME/Desktop/log.txt"
declare ADDDELETE=(--delete --checksum)
declare EXCLUDE="--exclude=node_modules/ --exclude=.vscode/extensions/ --exclude=android/app/bin/build/ --exclude=android/app/build"
declare RSYNC="rsync --recursive --update --inplace --no-relative $EXCLUDE"
declare BKPDIR="/Volumes/Seagate"
declare SAFECOPYDIR="/Volumes/Izi"
declare GDRIVE="$HOME/Documents/GoogleDrive/Mackup"

declare -A REGULAR=(
    # DO end paths with a trailing slash/
    ["/EFI-Backups/"]="$BKPDIR/Bkp/_Mac/others/EFI-Backups/"
    ["/Users/vamac/Documents/"]="$BKPDIR/Bkp/_Mac/documents/"
    ["/Volumes/Izi/Ableton/_projects/"]="$BKPDIR/Bkp/Ableton/_projects/"
    ["/Volumes/Izi/Ableton/Factory Packs/"]="$BKPDIR/Bkp/Ableton/Factory Packs/"
    ["/Volumes/Izi/Ableton/User Library/"]="$BKPDIR/Bkp/Ableton/User Library/"
    ["/Users/vamac/Pictures/2019/"]="$BKPDIR/Bkp/Pictures/2018/"
    ["/Users/vamac/Pictures/walls/"]="$BKPDIR/Bkp/Pictures/walls/"
    ["/Users/vamac/.ssh/"]="$BKPDIR/Bkp/_Mac/home/dot-ssh/"
    ["/Users/vamac/.gnupg/"]="$BKPDIR/Bkp/_Mac/home/dot-gnupg/"
    ["/Users/vamac/Code/"]="$BKPDIR/Bkp/Code/"
    # [""]=""
    # [""]=""
)

declare -A REDUNDANT=(
    ["/Users/vamac/Desktop/"]="$SAFECOPYDIR/bkp/Desktop/"
    ["/Users/vamac/Downloads/"]="$SAFECOPYDIR/bkp/Downloads/"
    ["/Users/vamac/Movies/"]="$SAFECOPYDIR/bkp/Movies/"
    # ["/Users/vamac/VirtualBox VMs/"]="$SAFECOPYDIR/bkp/VirtualBox/"
    # [""]=""
    # [""]=""
)

declare -A SYNCDELETING=(
    ["/Users/vamac/bin/"]="$BKPDIR/Bkp/_Mac/bin/"
    ["/Users/vamac/Code/foton/sense-chat-mobile/"]="$BKPDIR/Bkp/Code/foton/sense-chat-mobile/"
    ["/Users/vamac/Code/foton/squirrel-mobile/"]="$BKPDIR/Bkp/Code/foton/squirrel-mobile/"
    ["/Users/vamac/Code/foton/greuv-mobile/"]="$BKPDIR/Bkp/Code/foton/greuv-mobile/"
    # [""]=""
)

declare -A ZIPPING=(
    #do NOT end file paths with a trailing slash/. It will zip contents ONLY and create a file named .tar.7z (hidden)
    #old ff path: "/Users/Shared/5e3ouofl.default"
    ["$HOME/Library/Application Support/Firefox/Profiles/cthdp4sx.dev-edition-default"]="$BKPDIR/Bkp/Firefox/5e3ouofl.default.tar.7z"
    # ["/Volumes/Izi/bkp/vuzebkp"]="$BKPDIR/Bkp/_Mac/others/vuzebkp.tar.7z"a
)

##--------------------  Functions --------------------##

do-help() {
  precho "bkp.sh ➡ personal backup script
  -p, --print     prints all files and folders with their bkp location
  -h, --help      see this message
  -v              verbose
  no args         run"
}

start-run() {
  # shellcheck disable=SC2154
  echo -e "${r256}"
  echo -e "💫  🖥 \\040Running $(basename "$0") 🖥  💫"
  echo -e "\\e[0m"
}

finish-run() {
  progress total ~/.bkp-run-times
  scheduler.sh --record
}

copyRegular() {
  progress start "Copying common files to backup locations"
  printf "\\n#################### STARTING NEW RUN ####################\\n" >>"$LOGPATH"
  for file in "${!REGULAR[@]}"; do
    local bkp="${REGULAR[$file]}"
    echo -e "\\n-> $(date +"%b %d %T ")$file    to     $bkp" >>"$LOGPATH"
    if ! [ -d "$bkp" ] && ! [ -f "$bkp" ]; then
      echo "-> full bkp path doesn't seem to exist, making it." >>"$LOGPATH"
      mkdir -p "$bkp"
    fi
    $RSYNC --log-file "$LOGPATH" "$file" "$bkp" 1>/dev/null
  done
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

syncDeleting() {
  progress start "Copying version controlled files"
  for file in "${!SYNCDELETING[@]}"; do
    local bkp="${SYNCDELETING[$file]}"
    echo -e "\\n-> $(date +"%b %d %T ")$file    to     $bkp" >>"$LOGPATH"
    if ! [ -d "$bkp" ] && ! [ -f "$bkp" ]; then
      echo "-> full bkp path doesn't seem to exist, making it." >>"$LOGPATH"
      mkdir -p "$bkp"
    fi
    $RSYNC --log-file "$LOGPATH" "${ADDDELETE[@]}" "$file" "$bkp" 1>/dev/null
  done
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

copyRedundant() {
  progress start "Copying other files to redundant storage"
  for file in "${!REDUNDANT[@]}"; do
    local bkp="${REDUNDANT[$file]}"
    echo -e "\\n-> $(date +"%b %d %T ")$file    to     $bkp" >>"$LOGPATH"
    if ! [ -d "$bkp" ] && ! [ -f "$bkp" ]; then
      echo "-> full bkp path doesn't seem to exist, making it." >>"$LOGPATH"
      mkdir -p "$bkp"
    fi
    $RSYNC --log-file "$LOGPATH" "$file" "$bkp" 1>/dev/null
  done
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

listApps() {
  echo "-> $(date +"%b %d %T ")Applist started" >>"$LOGPATH"
  progress start "Saving a list of apps on /Applications"
  ls /Applications >"$GDRIVE/plain-text/listApps.txt" || bailout
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

listVscodeExtensions() {
  local file="$GDRIVE/plain-text/vscodeExtensions.txt"

  echo "-> $(date +"%b %d %T ")vscode extension list started" >>"$LOGPATH"
  progress start "Saving a list of vscode extensions"
  code --list-extensions >"$file" 2>/dev/null || bailout
  echo >>"$file" || bailout
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

copyZipping() {
  # progress start "Zipping and copying files"
  echo "-> $(date +"%b %d %T ")copyZipping - tar7zing files..." >>"$LOGPATH"
  for file in "${!ZIPPING[@]}"; do
    tar7z "$file"
  done
  echo "-> $(date +"%b %d %T ")Rsyncing zipped files..." >>"$LOGPATH"
  for file in "${!ZIPPING[@]}"; do
    local bkp="${ZIPPING[$file]}"
    printf "\\n" >>"$LOGPATH"
    echo "-> $(date +"%b %d %T ")Rsyncing $file to $bkp" >>"$LOGPATH"
    $RSYNC --log-file "$LOGPATH" "${file}.tar.7z" "$bkp"
    trash "${file}.tar.7z" || bailout
  done
  # progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

updateSoftware() { #new apps not on system will dl as lastest so its good.
  if [ -f "$HOME/bin/software-update.sh" ]; then
    "$HOME/bin/software-update.sh" --dont-ask
  fi
}

runMackup() { #need to test how google drive handles these files, but if but on path list should be safe.
  progress start "Running Mackup"
  mackup backup -f 1>/dev/null || bailout
  progress finish "$?"
}

updateBrewfile() {
  progress start "Updating Brewfile"
  (
    bf=$(readlink ~/.Brewfile)
    if [ -f "$bf" ]; then
      trash "$bf"
    fi
    brew bundle dump --file="$bf" || bailout
  )
  progress finish "$?"
}
