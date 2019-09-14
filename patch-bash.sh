#! /usr/bin/env bash

if [ -f /bin/bash.old ]; then
  echo "Already patched"
  exit
fi

if [ ! -f /usr/local/bin/bash ]; then
  echo "Please install bash first. /usr/local/bin/bash not found"
  exit
fi

sudo mv /bin/bash /bin/bash.old
sudo ln -si /usr/local/bin/bash /bin/bash
