#! /usr/bin/env bash
# shellcheck disable=SC2154
##-----------------------  Deps & Setup  ----------------------##
for name in bkp-routines optar progress paralol; do
    # shellcheck disable=SC1090
    source "$HOME/bin/$name.sh" || bailout "Dependency $name failed"
done

parse-options "$@"

######----------------- Quick exits  -----------------######
if [[ "$#" != 0 ]]; then
    if [ "$help" ] || [ "$h" ]; then
        do-help
        exit 1
    fi
fi

#-- Test for backup drive plugged in
[ ! -d "$BKPDIR" ] && bailout "Backup destination not plugged in?"

[[ ! "$(uname -s)" =~ Darwin ]] && bailout "Careful using this on Win/linux."

######----------------- Main  -----------------######
start-run
copyRegular
copyRedundant
syncDeleting
listApps
listVscodeExtensions
copyZipping
updateSoftware
updateBrewfile
runMackup
finish-run
