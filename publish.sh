#! /usr/bin/env bash
source "$HOME/bin/optar.sh" || bailout "Dependency failed"

parse-options "$@"
maybeDebug

if [[ "$h" ]]; then
  precho "this utility:\n\
  post processes css using post-css\n\
  transpiles JS with npm run build\n\
  moves files to ./public\n\
  kills sourceMappingURLs on css files\n\
  options (passed to upload-rsync too):\n\
  --dry-run\n\
  and calls publish-rsync, which:"
  printf "\n"
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
esac

if [ ! -d ${PWD}/public ]; then
  precho -w "No ./public dir found, creating it for you..."
  $DRY mkdir ./public || bailout "Failed to make dir ./public"
fi
$DRY post-css && precho -k "Post-processed CSS"
$DRY npm run build 1>/dev/null && precho -k "Transpiled JS"
($DRY \cp -R ./*.html ./public # the backlash \ on \cp avoids any aliases called "cp"
# $DRY \cp -R ./js ./public
$DRY \cp -R ./css/img ./public/css
$DRY \cp -R ./LICENSE* ./public
$DRY \cp -R ./*json ./public) && precho -k "Moved project files to ./public"
for file in ./public/css/*.css; do
  $DRY gsed --in-place --regexp-extended --expression='/[/][*]# sourceMappingURL.*[*][/]/d' $file
done && precho -k "Killed sourcemapping lines in css files on ./public/css/"
upload-rsync.sh "$@"
