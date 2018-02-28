#! /usr/bin/env bash
names="jan feb mar apr may jun jul aug sep oct nov dec"
i=1
for name in $names; do
  cp -R 00template 00template-copy
  if [[ "${#i}" -gt 1 ]]; then
    mv 00template-copy ${i}$name
    i=$((i + 1))
    continue
  fi
  mv 00template-copy 0${i}$name
  i=$((i + 1))
done
