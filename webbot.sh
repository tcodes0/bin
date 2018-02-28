#! /usr/bin/env bash
external=$HOME/.bash_functions
if [ -f $external ];then
  source $external
fi
do-sass() {
  sass --watch css/index.sass:css/index.css   2>/dev/null 1>&2 &
  sass --watch css/grid.sass:css/grid.css     2>/dev/null 1>&2 &
  sass --watch css/boiler.sass:css/boiler.css 2>/dev/null 1>&2 &
}
do-help() {
  precho "run sass --watch and reload here: $(pwd)"
  precho '--only_sass, -s:\tdont run reload'
}
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
  do-help
  exit
fi
if [[ "$1" == "--sass-only" ]] || [[ "$1" == "-s" ]]; then
  do-sass
  precho  "Sass is now running and watching, hit ⏎ to quit"
  read
  exit
fi
instances=$(echo $(ps | grep $HOME/bin/webbot.sh | wc -l))
instances=$(( $instances - 4))
port=8080
if [[ "$instances" -gt 0 ]]; then
  port=$((port + $instances))
fi
do-sass
reload -p $port
