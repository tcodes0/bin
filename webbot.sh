#! /usr/bin/env bash
instances=$(echo $(ps | grep $HOME/bin/webbot.sh | wc -l))
instances=$(( $instances - 4))
port=8080
if [[ "$instances" -gt 0 ]]; then
  port=$((port + $instances))
fi
sass --watch css/index.sass:css/index.css   2>/dev/null 1>&2 &
sass --watch css/grid.sass:css/grid.css     2>/dev/null 1>&2 &
sass --watch css/boiler.sass:css/boiler.css 2>/dev/null 1>&2 &
reload -p $port
