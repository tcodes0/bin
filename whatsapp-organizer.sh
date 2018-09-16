#! /usr/bin/env bash
# - - -- - - - - - - - - - - - - - - - - - - - - - - -  Vars
months="01 02 03 04 05 06 07 08 09 10 11 12"
# - - -- - - - - - - - - - - - - - - - - - - - - - - -  Functions
findYearsWithFiles() {
  #1 a dir to search on
  #2 $pat global
  #returns a list of years
  local where=$1
  local years && years=$(echo {2000..2099})
  local results=''
  for year in $years; do
    if [[ $(gfind "$where" -maxdepth 1 -name "${pat}${year}*") != '' ]]; then
      results=$results" "$year
    fi
  done
  echo -n "$results"
}
moveFiles() {
  #1 a dir to search on
  #2 a list of years
  #3 $pat global
  #4 $months global
  #sideffect moves files
  if [ "$dry" ]; then echo -e "\\n\\n\\n\\n--------------------------- MOVING -------------------------\\n\\n\\n\\n"; fi
  local where=$1
  shift
  local years=$*
  local files=''
  local destination=''
  local fileType=''
  for year in $years; do
    gfind "$where" -maxdepth 1 -name "${pat}${year}*" -print0 | rename -0 --sanitize
    for month in $months; do
      files=$(gfind "$where" -maxdepth 1 -name "${pat}${year}${month}*")
      if [[ $files != '' ]]; then
        if [[ $where =~ Video ]]; then
          fileType=zap-vids
        else
          [ ! -n "$manual" ] && fileType=zap
          [ -n "$manual" ] && fileType="$manualFileType"
        fi
        if [[ $where =~ Sent ]]; then
          destination="$(dirname "$dir")/$year/$month/$fileType/sent"
        else
          destination="$dir/$year/$month/$fileType"
        fi
        if [[ ! -d $destination ]]; then
          $dry mkdir -p "$destination" || bailout
        fi
        for file in $files; do
          $dry mv "$file" "$destination"
        done
      fi
      files=''
    done
  done
}
find_whatsappDir() {
  if [[ -d 'WhatsApp Images' ]] && [ "$pat" == "IMG-" ]; then
    mv WhatsApp\ Images WhatsApp_Images || bailout
    dir=./WhatsApp_Images
  elif [[ -d 'WhatsApp_Images' ]] && [ "$pat" == "IMG-" ]; then
    dir=./WhatsApp_Images
  elif [[ -d 'WhatsApp Video' ]] && [ "$pat" == "VID-" ]; then
    mv WhatsApp\ Video WhatsApp_Video || bailout
    dir=./WhatsApp_Video
  elif [[ -d 'WhatsApp_Video' ]] && [ "$pat" == "VID-" ]; then
    dir=./WhatsApp_Video
  else
    precho no WhatsApp Images or WhatsApp Video folder found
    exit 1
  fi
}
renameFolders() {
  if [ "$dry" ]; then echo -e "\\n\\n\\n\\n--------------------------- RENAMING -------------------------\\n\\n\\n\\n"; fi
  #1 dir global
  local folders && folders=$(gfind "$dir" -regextype posix-extended -regex '.*[/][0-9][0-9]')
  if [[ "$folders" == '' ]]; then
    echo "no hits for renaming"
  fi
  for folder in $folders; do
    case $folder in
    *01)
      $dry mv "$folder" "${folder}jan"
      ;;
    *02)
      $dry mv "$folder" "${folder}feb"
      ;;
    *03)
      $dry mv "$folder" "${folder}mar"
      ;;
    *04)
      $dry mv "$folder" "${folder}apr"
      ;;
    *05)
      $dry mv "$folder" "${folder}may"
      ;;
    *06)
      $dry mv "$folder" "${folder}jun"
      ;;
    *07)
      $dry mv "$folder" "${folder}jul"
      ;;
    *08)
      $dry mv "$folder" "${folder}aug"
      ;;
    *09)
      $dry mv "$folder" "${folder}sep"
      ;;
    *10)
      $dry mv "$folder" "${folder}oct"
      ;;
    *11)
      $dry mv "$folder" "${folder}nov"
      ;;
    *12)
      $dry mv "$folder" "${folder}dec"
      ;;
    esac
  done
}
args() {
  #1 takes args given to script
  if [[ "$#" == 0 ]] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    precho "automatically organizes content from WhatsApp Images or WhatsApp Video folder"
    precho "it produces a folder structure like: 2019/05/pics/*stuff*"
    precho "--imgs do WhatsApp images (don't use both)"
    precho "--vids do WhatsApp videos (don't use both)"
    precho "--dry-run to print commands only"
    precho "the underlying pattern based system can be used to match other files and folders:"
    precho "--manual <path to dir with content> <filename pattern> <folder name>"
    precho "where filename pattern is PAT in: \$PAT\$YEAR\$MONTH"
    precho "and folder name is final folder with content. E.g. folderName=foobar: 2018/04/foobar/*pics*"
    exit
  elif [[ "$1" == "--vids" ]]; then
    pat=VID-
    shift
  elif [[ "$1" == "--imgs" ]]; then
    pat=IMG-
    shift
  fi
  if [[ "$1" == "--manual" ]]; then
    manual=true
    dir="$2"
    pat="$3"
    manualFileType="$4"
  fi
  if [[ "$*" =~ --dry-run ]]; then
    dry="echo"
  fi
}
# - - -- - - - - - - - - - - - - - - - - - - - - - - -  Code
# HAS UNTESTED SHCHECK CHANGES! ROLL BACK THE COMMIT IF NEEDED
args "$@"
[ ! -n "$manual" ] && find_whatsappDir
renameFolders
moveFiles "$dir" "$(findYearsWithFiles "$dir")"
if [[ -d "$dir/Sent" ]]; then
  dir=$dir/Sent
  moveFiles "$dir" "$(findYearsWithFiles "$dir")"
  $dry trash "$dir"
fi
