#!/bin/bash

MOINDATA="/usr/local/etc/moin-to-cwiki/universal-wiki-converter/projects"

cd $MOINDATA

  rsync -a --password-file=/root/.pw-moin \
    --include data/\*/data/pages         \
    --include data/\*/data/user         \
    --exclude-from /usr/local/etc/moin-to-cwiki/universal-wiki-converter/exclude-list.txt \
    --delete-excluded \
    rsync://apb-moin@moin-vm/moin $MOINDATA

