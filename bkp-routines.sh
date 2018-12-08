#! /usr/bin/env bash
##-----------------------  Input  ----------------------##

declare LOGPATH="$HOME/Desktop/log.txt"
declare ADDDELETE=(--delete --checksum)
declare RSYNC="rsync --recursive --update --inplace --no-relative --exclude=node_modules/ --exclude=.vscode/extensions/"
declare BKPDIR="/Volumes/Seagate"
declare SAFECOPYDIR="/Volumes/Izi"
declare GDRIVE="$HOME/Documents/GoogleDrive/Mackup"

declare -A PATHS=(
  # DO end paths with a trailing slash/
  ["/EFI-Backups/"]="$BKPDIR/Bkp/_Mac/others/EFI-Backups/"
  ["/Users/vamac/Documents/"]="$BKPDIR/Bkp/_Mac/documents/"
  ["/Volumes/Izi/Ableton/_projects/"]="$BKPDIR/Bkp/Ableton/_projects/"
  ["/Volumes/Izi/Ableton/Factory Packs/"]="$BKPDIR/Bkp/Ableton/Factory Packs/"
  ["/Volumes/Izi/Ableton/User Library/"]="$BKPDIR/Bkp/Ableton/User Library/"
  ["/Users/vamac/Pictures/2018/"]="$BKPDIR/Bkp/Pictures/2018/"
  ["/Users/vamac/Pictures/walls/"]="$BKPDIR/Bkp/Pictures/walls/"
  ["/Users/vamac/.ssh/"]="$BKPDIR/Bkp/_Mac/home/dot-ssh/"
  ["/Users/vamac/.gnupg/"]="$BKPDIR/Bkp/_Mac/home/dot-gnupg/"
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
  ["$HOME/Library/Application Support/Firefox/Profiles/cthdp4sx.dev-edition-default"]="$BKPDIR/Bkp/Firefox/5e3ouofl.default.tar.7z"
  # ["/Volumes/Izi/bkp/vuzebkp"]="$BKPDIR/Bkp/_Mac/others/vuzebkp.tar.7z"
)

##--------------------  Functions --------------------##
do-print() {
  precho "Pathlist..."
  for file in "${!PATHS[@]}"; do
    for bkp in ${PATHS[$file]}; do
      echo -en '\e[97;1m'
      echo "  File - $file"
      echo -en '\e[0m'
      echo "Backup - $bkp"
    done
  done

  printf "\\n"
  precho "Safecopies..."
  for file in "${!SAFECOPIES[@]}"; do
    for bkp in ${SAFECOPIES[$file]}; do
      echo -en '\e[97;1m'
      echo "  File - $file"
      echo -en '\e[0m'
      echo "Backup - $bkp"
    done
  done

  printf "\\n"
  precho "Version controlled list..."
  for file in "${!DELPATHS[@]}"; do
    for bkp in ${DELPATHS[$file]}; do
      echo -en '\e[97;1m'
      echo "  File - $file"
      echo -en '\e[0m'
      echo "Backup - $bkp"
    done
  done

  printf "\\n"
  precho "Ziplist..."
  for file in "${!ZIPTHIS[@]}"; do
    for bkp in ${ZIPTHIS[$file]}; do
      echo -en '\e[97;1m'
      echo "  File - $file"
      echo -en '\e[0m'
      echo "Backup - $bkp"
    done
  done
  return
}

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

pathlist() {
  progress start "Copying common files to backup locations"
  printf "\\n#################### STARTING NEW RUN ####################\\n" >>"$LOGPATH"
  for file in "${!PATHS[@]}"; do
    local bkp="${PATHS[$file]}"
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

dellist() {
  progress start "Copying version controlled files"
  for file in "${!DELPATHS[@]}"; do
    local bkp="${DELPATHS[$file]}"
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

safelist() {
  progress start "Copying other files to redundant storage"
  for file in "${!SAFECOPIES[@]}"; do
    local bkp="${SAFECOPIES[$file]}"
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

applist() {
  echo "-> $(date +"%b %d %T ")Applist started" >>"$LOGPATH"
  progress start "Saving a list of apps on /Applications"
  ls /Applications >"$GDRIVE/plain-text/applist.txt" || bailout
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

vscodeExtensionList() {
  local file="$GDRIVE/plain-text/vscodeExtensions.txt"

  echo "-> $(date +"%b %d %T ")vscode extension list started" >>"$LOGPATH"
  progress start "Saving a list of vscode extensions"
  code --list-extensions >"$file" 2>/dev/null || bailout
  echo >>"$file" || bailout
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

ziplist() {
  progress start "Zipping and copying files"
  echo "-> $(date +"%b %d %T ")ziplist - tar7zing files using paralol..." >>"$LOGPATH"
  for file in "${!ZIPTHIS[@]}"; do
    paralolDo tar7z "$file"
  done
  paralolWait || bailout
  echo "-> $(date +"%b %d %T ")Rsyncing zipped files..." >>"$LOGPATH"
  for file in "${!ZIPTHIS[@]}"; do
    local bkp="${ZIPTHIS[$file]}"
    printf "\\n" >>"$LOGPATH"
    echo "-> $(date +"%b %d %T ")Rsyncing $file to $bkp" >>"$LOGPATH"
    $RSYNC --log-file "$LOGPATH" "${file}.tar.7z" "$bkp"
    trash "${file}.tar.7z" || bailout
  done
  progress finish "$?"
  echo -e "_________________________________________________________\\n" >>"$LOGPATH"
}

do-software() { #new apps not on system will dl as lastest so its good.
  if [ -f "$HOME/bin/software-update.sh" ]; then
    "$HOME/bin/software-update.sh" --dont-ask
  fi
}

do-mackup() { #need to test how google drive handles these files, but if but on path list should be safe.
  progress start "Running Mackup"
  mackup backup -f 1>/dev/null || bailout
  progress finish "$?"
}

do-brewfile() {
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
