#! /bin/bash
case "$1" in
  --help | -h)
    echo "$0: dump formating options to std out"
    echo "    by default dumps only not-crazy-looking formats"
    echo "    use -a or --all to dump all possible formats"
  ;;
  --all | -a)
    #echo provokes expansion
    bgrange=$(echo {40..47} {100..107} 49)
    fgrange=$(echo {30..37} {90..97} 39)
    fmrange=$(echo 0 1 2 4 5 7)
  ;;
  *)
    #tranparent and light gray
    bgrange=$(echo 100 49)
    #all options
    fgrange=$(echo {30..37} {90..97} 39)
    #only regular and bold
    fmrange=$(echo 0 1)
  ;;
esac
#Background
for clbg in $bgrange ; do
  #Foreground
  for clfg in $fgrange ; do
    #Formatting
    for attr in $fmrange ; do
      #Print the result
      echo -en "\e[${attr};${clbg};${clfg}m \\\e[${attr};${clbg};${clfg}m \e[0m"
    done
    printf "\n"
  done
done
exit 0
