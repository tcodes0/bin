#! /usr/bin/env bash
if [[ "$@" =~ -h ]]; then
  precho this utility:
  precho "post processes css using >post-css"
  precho "transpiles JS with >npm run build"
  precho "moves files to ./public"
  precho "kills sourceMappingURLs on css files"
  precho "and optionally calls publish-rsync, which:"
  publish-rsync -h
  exit
fi
if [[ ! "$(dirname $PWD)" =~ ^/Users/vamac/Code ]]; then   # Don't run outside ~/Code
  bailout "Can't run publish outside $(echo ~/Code)"
fi
if [ ! -d ${PWD}/public ]; then
  color --bold --yellow "♦︎ No ./public dir found, creating it for you..."
  mkdir ./public || bailout "Failed to make dir ./public"
fi
post-css && color --bold --green "✔ Post-processed CSS"
npm run build 1>/dev/null && color --bold --green "✔ Transpiled JS"
(\cp -R ./*.html ./public # the backlash \ on \cp avoids any aliases called "cp"
# \cp -R ./js ./public
\cp -R ./css/img ./public/css
\cp -R ./LICENSE* ./public
\cp -R ./*json ./public) && color --bold --green "✔ Moved project files to ./public"
for file in ./public/css/*.css; do
  gsed --in-place --regexp-extended --expression='/[/][*]# sourceMappingURL.*[*][/]/d' $file
done && color --bold --green "✔ Killed sourcemapping lines in css files on ./public/css/"
publish-rsync "$@"
