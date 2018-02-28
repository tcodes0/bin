#! /usr/bin/env bash
# - - -- - - - - - - - - - - - - - - - - - - - - - - -  Vars
months="01 02 03 04 05 06 07 08 09 10 11 12"
# - - -- - - - - - - - - - - - - - - - - - - - - - - -  Functions
findYearsWithFiles () {
  #1 a dir to search on
  #2 $pat global
  #returns a list of years
  local where=$1
  local years=$(echo {2000..2099})
  local results=''
  for year in $years; do
    if [[ $(gfind "$where" -maxdepth 1 -name "${pat}${year}*") != '' ]]; then
      results=$results" "$year
    fi
  done
  echo -n $results
}
moveFiles() {
  #1 a dir to search on
  #2 a list of years
  #3 $pat global
  #4 $months global
  #sideffect moves files
  if [ $dry ]; then echo -e "\n\n\n\n--------------------------- MOVING -------------------------\n\n\n\n" ; fi
  local where=$1
  shift
  local years=$@
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
            fileType=zap
          fi
          if [[ $where =~ Sent ]]; then
            destination="$(dirname $dir)/$year/$month/$fileType/sent"
          else
            destination="$dir/$year/$month/$fileType"
          fi
          if [[ ! -d $destination ]]; then
            $dry runc -c mkdir -p $destination
          fi
          for file in $files; do
            $dry mv "$file" $destination
          done
        fi
        files=''
      done
  done
}
source_bashFunctions () {
  if [[ -f ~/.bash_functions ]]; then
    . ~/.bash_functions
  else
    echo ~/.bash_functions not found.
    exit 1
  fi
}
find_whatsappDir () {
  if [[ -d 'WhatsApp Images' ]] && [ "$pat" == "IMG-" ]; then
    runc -c mv WhatsApp\ Images WhatsApp_Images
    dir=./WhatsApp_Images
  elif [[ -d 'WhatsApp_Images' ]] && [ "$pat" == "IMG-" ]; then
    dir=./WhatsApp_Images
  elif [[ -d 'WhatsApp Video' ]] && [ "$pat" == "VID-" ]; then
    runc -c mv WhatsApp\ Video WhatsApp_Video
    dir=./WhatsApp_Video
  elif [[ -d 'WhatsApp_Video' ]] && [ "$pat" == "VID-" ]; then
    dir=./WhatsApp_Video
  else
    precho no WhatsApp Images or WhatsApp Video folder found
    exit 1
  fi
}
renameFolders (){
  if [ $dry ]; then echo -e "\n\n\n\n--------------------------- RENAMING -------------------------\n\n\n\n" ; fi
  #1 dir global
  local folders=$(gfind "$dir" -regextype posix-extended -regex '.*[/][0-9][0-9]')
  if [[ "$folders" == '' ]]; then
    echo "no hits for renaming"
  fi
  for folder in $folders; do
    case $folder in
      *01)
        $dry mv $folder ${folder}jan
      ;;
      *02)
        $dry mv $folder ${folder}feb
      ;;
      *03)
        $dry mv $folder ${folder}mar
      ;;
      *04)
        $dry mv $folder ${folder}apr
      ;;
      *05)
        $dry mv $folder ${folder}may
      ;;
      *06)
        $dry mv $folder ${folder}jun
      ;;
      *07)
        $dry mv $folder ${folder}jul
      ;;
      *08)
        $dry mv $folder ${folder}aug
      ;;
      *09)
        $dry mv $folder ${folder}sep
      ;;
      *10)
        $dry mv $folder ${folder}oct
      ;;
      *11)
        $dry mv $folder ${folder}nov
      ;;
      *12)
        $dry mv $folder ${folder}dec
      ;;
    esac
  done
}
args (){
  #1 takes args given to script
  if [[ "$#" == 0 ]] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
    precho "process images with --imgs and videos with --vids"
    precho "automatically finds WhatsApp Images or WhatsApp Video folder"
    precho "pass --dry-run as second arg to print commands only"
    exit
  elif [[ "$1" == "--vids" ]]; then
    pat=VID-
    shift
  elif [[ "$1" == "--imgs" ]]; then
    pat=IMG-
    shift
  fi
  if [[ "$1" == "--dry-run" ]]; then
    dry="echo"
  fi
}
# - - -- - - - - - - - - - - - - - - - - - - - - - - -  Code
source_bashFunctions
args $@
find_whatsappDir
renameFolders
exit
moveFiles $dir $(findYearsWithFiles $dir)
if [[ -d "$dir/Sent" ]]; then
  dir=$dir/Sent
  moveFiles $dir $(findYearsWithFiles $dir)
  $dry trash $dir
fi
