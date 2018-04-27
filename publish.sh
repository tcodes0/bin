#! /usr/bin/env bash
source "$HOME/bin/optar.sh" || bailout "Dependency failed"

parse-options "$@"
maybeDebug

if [[ "$h" ]]; then
  precho "publish.sh:
  \n post processes css using post-css
  \n transpiles JS with npx gulp
  \n moves misc files to ./build
  \n kills sourceMappingURLs on css files.
  \n
  \n options (passed to upload-rsync too):
  \n
  \n -h         \t\t see this help
  \n --rebuild-imgs \t regenerate all image assets
  \n --purge      \t delete ./build
  \n --dry-run
  \n and calls upload-rsync, which:
  \n"
  upload-rsync.sh -h
  exit
fi

if [[ ! "$(dirname $PWD)" =~ ^/Users/vamac/Code ]]; then   # Don't run outside ~/Code
  bailout "Can't run publish outside $(echo ~/Code)"
fi

case " " in
  "$dry_run")
    DRY="echo"
  ;;
  "$purge")
    $DRY npx gulp purgeBuild && precho -k "./build deleted"
    exit
  ;;
esac

if [ ! -d ${PWD}/build ]; then
  precho -w "No ./build dir found, creating it"
  $DRY mkdir ./build || bailout "Failed to make dir ./build"
fi

$DRY post-css && precho -k "Post-processed CSS"
$DRY npx gulp scripts 1>/dev/null 2>&1 && precho -k "Transpiled JS"
($DRY \cp -R ./*html ./build # the backlash \ on \cp avoids any aliases called "cp"
$DRY \cp -R ./*php ./build
# $DRY \cp -R ./css/img ./build/css
$DRY \cp -R ./LICENSE* ./build
$DRY \cp -R ./*json ./build) && precho -k "Moved project files to ./build"
for file in ./build/css/*.css; do
  $DRY gsed --in-place --regexp-extended --expression='/[/][*]# sourceMappingURL.*[*][/]/d' $file
done && precho -k "Killed sourcemapping lines in css files on ./build/css/"

if [[ "$rebuild_imgs" ]]; then
  precho -w "Regenerating all build images..."
  $DRY npx gulp optimizeImgs && precho -k "Images regenerated"
fi
upload-rsync.sh "$@"
