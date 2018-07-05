#! /usr/bin/env bash

FAKE_SUDO="/usr/local/bin/sudo"

__install () {
  if [ ! -f "$1" ]; then
    echo "echo 'sudo denied' && exit 1" > $1
    chmod u+x $1
  fi
}

__uninstall () {
  # echo "removing fake sudo"
  if [ -f "$1" ]; then
    \rm $1
  fi
}

case $1 in
  "install") __install "$FAKE_SUDO"
  ;;
  "uninstall") __uninstall "$FAKE_SUDO"
  ;;
  "-h" | "--help")
      precho "\
  failSudo - redirect calls to /usr/bin/sudo to a dummy file.
    options:
      install       install the redirect
      uninstall     uninstall the redirect
      -h, --help  see this help
    "
    exit 1
  ;;
esac

if [ "$1" != "install" -a "$1" != "uninstall" ]; then
  __install "$FAKE_SUDO"
  $@
  status=$?
  __uninstall "$FAKE_SUDO"
  exit $status
fi