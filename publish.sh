#! /usr/bin/env bash
if [[ ! "$(dirname $PWD)" =~ ^/Users/vamac/Code ]]; then   # Don't run outside ~/Code
  bailout "Can't run publish outside $(echo ~/Code)"
fi
# if [[ ! -f "$(echo css/*css)" ]] || [[ ! -f "$(echo js/*js)" ]] || [[ ! -f "$(echo *html)" ]]; then
#   bailout "$PWD - need CSS, JS and HTML files to work with."
# fi
if [ ! -d ${PWD}/public ]; then
  echoform 1 49 33 "♦︎ No ./public dir found, creating it for you..."
  mkdir ./public || bailout "Failed to make dir ./public"
fi
post-css
echoform 1 49 32 "✔ Moving project files to ./public"
\cp -R ./*.html ./public # the backlash \ on \cp avoids any aliases called "cp"
\cp -R ./js ./public
\cp -R ./css/img ./public/css
\cp -R ./LICENSE* ./public
\cp -R ./*json ./public
echoform 1 49 32 "✔ Killing sourcemapping lines in css files on ./public/css/"
for file in ./public/css/*.css; do
  gsed --in-place --regexp-extended --expression='/[/][*]# sourceMappingURL.*[*][/]/d' $file
done
publish-upload
