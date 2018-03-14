#! /usr/bin/env bash
do-help() {
  precho "run sass --watch and reload here: $(pwd)"
  precho '--sass-only, -s:\tdont run reload'
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
