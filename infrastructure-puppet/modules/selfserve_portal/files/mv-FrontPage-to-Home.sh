#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Need to specify a project name as an arg: exiting."
exit 1;
fi

MOINDATA="/usr/local/etc/moin-to-cwiki/universal-wiki-converter/projects"
PROJECT=$1

echo "Renaming FrontPage to Home for the $1 project..."
sleep 1

cd $MOINDATA/$PROJECT

# Lets check if we have a FrontPage, else exit.

if [ -d "data/pages/FrontPage" ]; then
  #rename the page History log entries to say Home.
  perl -pi -e s'|FrontPage|Home|g' data/pages/FrontPage/edit-log

  # rename metatag in each revision file
  perl -pi -e s'|##master-page:FrontPage|##master-page:Home|' data/pages/FrontPage/revisions/*

  # finally, rename the Frontpage dir to Home
  /bin/mv data/pages/FrontPage data/pages/Home
else
  echo "No FrontPage exists, so doing nothing"
exit 0;
fi

