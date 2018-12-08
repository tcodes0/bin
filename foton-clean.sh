#! /usr/bin/env bash

targets=(\
    "$HOME/Library/Developer/Xcode/DerivedData" \
    "$HOME/Library/Caches" \
    "$HOME/Library/Containers/com.apple.mail/Data/Library/Mail\\ Downloads" \
#    "/private/var/folders"\
    "$HOME/Library/Developer/CoreSimulator/Devices"
)

explanations=(\
    "
    \\033[2;3;4mBuild products, safe to delete.\\033[0m
    \\033[2;3;4mCan also be deleted from organizer.\\033[0m
    " \
    "
    \\033[2;3;4mVarious app caches.\\033[0m
    " \
    "
    \\033[2;3;4mDownloaded Mail.app stuff.\\033[0m
    " \
#    "
#    \\033[2;3;4mTemporary folders.\\033[0m
#    " \
    "
    \\033[4;38;05;196mWarning\\033[0m
    \\033[2;3;4mAll your iOS simulator data will be deleted.\\033[0m
    "
)

clear
echo -ne "
\\033[7;38;05;55m\
Let's clean your Mac, foton style.\
\\033[0m
"

for index in "${!targets[@]}"; do
    target=${targets[$index]}
    explanation=${explanations[$index]}

    echo
    echo -e "$target"
    echo -ne "$explanation"
    [[ $target =~ /([^/]+/[^/]+)$ ]]

    echo -e "
\\033[4;38;05;196mrm -rf\\033[0m ${BASH_REMATCH[1]} ?
  \\033[2;3mtype y to remove.\\033[0m
  \\033[2;3mtype n to skip.\\033[0m
  \\033[2;3mtype z to calculate space you'd gain.\\033[0m
  \\033[2;3mtype o to reveal in Finder.\\033[0m
  \\033[2;3mctrl + c to quit.\\033[0m
    "

    if ! read -r; then
        exit "$?"
    fi

    if [ "$REPLY" == "o" ] || [ "$REPLY" == "o" ]; then
        readagain=true
        command open "$target"
    fi
    if [ "$readagain" ]; then
        if ! read -r; then
            exit "$?"
        fi
    fi

    if [ "$REPLY" == "z" ] || [ "$REPLY" == "z" ]; then
        readagain=true
        command du -sh "$target"
    fi
    if [ "$readagain" ]; then
        if ! read -r; then
            exit "$?"
        fi
    fi

    unset readagain
    if [ "$REPLY" == "n" ] || [ "$REPLY" == "N" ]; then
        say hmmmm
        clear
        continue
    fi

    if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
        echo removing "$target"...
        command rm -fr "$target"
        read -rt 1
    fi

    clear
done

echo -ne "
\\033[7;38;05;55m\
Done.\
\\033[0m 🚀
"
read -rt 2

say ja burrrr la la la
