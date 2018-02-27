#! /usr/bin/env bash
if [[ -f ~/.bash_functions ]]; then
  . ~/.bash_functions
else
  precho ~/.bash_functions not found.
  exit 1
fi
if [[ -d 'WhatsApp Images' ]]; then
  runc -c cd 'WhatsApp Images'
else
  precho no WhatsApp Images folder found
  exit 1
fi
years=$(echo 20{0..9}{0..9})
months="01 02 03 04 05 06 07 08 09 10 11 12"
for year in $years; do
  files=$(gfind . -maxdepth 1 -name "IMG-${year}*")
  if [[ $files != '' ]]; then
    # replace all filenames " " with _
    gfind . -maxdepth 1 -name "IMG-${year}*" -print0 | rename -0 -S " " "_"
    if [[ ! -d $year ]]; then
      runc -c mkdir $year
    fi
    for month in $months; do
      mfiles=$(gfind . -maxdepth 1 -name "IMG-${year}${month}*")
      if [[ $mfiles != '' ]]; then
        # echo $month - $mfiles
        if [[ ! -d $year/$month ]]; then
          runc -c mkdir $year/$month
        fi
        # echo mv IMG-$year$month* $year/$month
        for mfile in $mfiles; do
          # unquotedfile=$(gsed -Ee "s/'//g" <<< $mfile)
          # echo $mfile
          # echo mfile - "$mfile"
          mv $mfile ./$year/$month
        done
      fi
    done
    # cd ../
  fi
  files=''
done
if [[ -d Sent ]]; then
  cd Sent
  for year in $years; do
    files=$(gfind . -maxdepth 1 -name "IMG-${year}*")
    if [[ $files != '' ]]; then
      gfind . -maxdepth 1 -name "IMG-${year}*" -print0 | rename -0 -S " " "_"
      if [[ ! -d ../$year ]]; then
        runc -c mkdir ../$year
      fi
      for month in $months; do
        sentfiles=$(gfind . -maxdepth 1 -name "IMG-${year}${month}*")
        if [[ $sentfiles != '' ]]; then
          # echo $month - $sentfiles
          if [[ ! -d ../$year/$month/sent ]]; then
            runc -c mkdir ../$year/$month/sent
          fi
          # echo mv IMG-$year$month* $year/$month
          for sentfile in $sentfiles; do
            # unquotedfile=$(gsed -Ee "s/'//g" <<< $sentfile)
            # echo $sentfile
            # echo sentfile - "$sentfile"
            mv $sentfile ../$year/$month/sent
          done
        fi
      done
    fi
  done
  cd ../
fi
cd ../
# case $month in
#     "01")
#       mv ./$year/$month ./$year/${month}jan
#     ;;
#     "02")
#       mv ./$year/$month ./$year/${month}feb
#     ;;
#     "03")
#       mv ./$year/$month ./$year/${month}mar
#     ;;
#     "04")
#       mv ./$year/$month ./$year/${month}apr
#     ;;
#     "05")
#       mv ./$year/$month ./$year/${month}may
#     ;;
#     "06")
#       mv ./$year/$month ./$year/${month}jun
#     ;;
#     "07")
#       mv ./$year/$month ./$year/${month}jul
#     ;;
#     "08")
#       mv ./$year/$month ./$year/${month}aug
#     ;;
#     "09")
#       mv ./$year/$month ./$year/${month}sep
#     ;;
#     "10")
#       mv ./$year/$month ./$year/${month}oct
#     ;;
#     "11")
#       mv ./$year/$month ./$year/${month}nov
#     ;;
#     "12")
#       mv ./$year/$month ./$year/${month}dec
#     ;;
#   esac
