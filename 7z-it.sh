#! /bin/bash

if [ $# == "0" ]; then
    echo "7z-it.sh failed to understand args"
    exit 1
fi		
    
tar cf - "$1" | 7za a -si -mx=7 "$1".tar.7z
