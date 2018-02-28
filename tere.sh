#!/bin/bash
if [[ "$#" == 0 ]] || [ "$1" == '-h' ]; then
  echo provide two emoticons to make a ❤️   for her.
  exit
fi
model="💕💕💕💕💕💕💕💕💕💕💕\n💕🌻🌻🌻💕💕💕🌻🌻🌻💕\n🌻🌻🌻🌻🌻💕🌻🌻🌻🌻🌻\n🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻\n💕🌻🌻🌻🌻🌻🌻🌻🌻🌻💕\n💕💕🌻🌻🌻🌻🌻🌻🌻💕💕\n💕💕💕🌻🌻🌻🌻🌻💕💕💕\n💕💕💕💕🌻🌻🌻💕💕💕💕\n💕💕💕💕💕🌻💕💕💕💕💕\n"
model=$(gsed -Ee s/💕/"$1"/gm <<< "$model")
model=$(gsed -Ee s/🌻/"$2"/gm <<< "$model")
echo -e $model | pbcopy
