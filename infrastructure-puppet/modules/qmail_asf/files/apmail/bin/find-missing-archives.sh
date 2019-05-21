#!/usr/local/bin/bash

cd /home/apmail/lists
lists=`find . -type d -maxdepth 2 -mindepth 2 -print | sed -E 's/^..//g; s/\.com\//-/g; s/\.apache\.org\//-/g; s/apache\.org\///g'`
for list in $lists; do
  if [[ ! -e "/home/apmail/.qmail-$list-archive" ]]; then
    echo $list
  fi
done
