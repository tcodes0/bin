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
# if [[ ! -f "$(echo css/*css)" ]] || [[ ! -f "$(echo js/*js)" ]] || [[ ! -f "$(echo *html)" ]]; then
#   bailout "$PWD - need CSS, JS and HTML files to work with."
# fi
if [ ! -d ${PWD}/public ]; then
  color 1 49 33 "♦︎ No ./public dir found, creating it for you..."
  mkdir ./public || bailout "Failed to make dir ./public"
fi
post-css && color 1 49 32 "✔ Post-processed CSS"
npm run build 1>/dev/null && color 1 49 32 "✔ Transpiled JS"
(\cp -R ./*.html ./public # the backlash \ on \cp avoids any aliases called "cp"
# \cp -R ./js ./public
\cp -R ./css/img ./public/css
\cp -R ./LICENSE* ./public
\cp -R ./*json ./public) && color 1 49 32 "✔ Moved project files to ./public"
for file in ./public/css/*.css; do
  gsed --in-place --regexp-extended --expression='/[/][*]# sourceMappingURL.*[*][/]/d' $file
done && color 1 49 32 "✔ Killed sourcemapping lines in css files on ./public/css/"
publish-rsync "$@"
