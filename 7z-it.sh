#! /bin/bash
if [ $# == "0" ]; then
    echo "7z-it.sh needs at least 1 arg"
    exit 1
fi
tar cf - "$1" 2>/dev/null | 7za a -si -mx=7 "$1".tar.7z 1>/dev/null
