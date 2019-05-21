#!/bin/sh

OLDADDY=${1}
NEWADDY=${2}


if [ -z "${1}" -o -z "${2}" ]; then 
 echo -e "Usage::  ${0} old-mail-address new-mail-address\n\nYou need to enter at least two email addresses";
 exit 1
fi


cd /home/apmail/lists


CWD=`pwd`
if [ ${CWD} != "/home/apmail/lists" ]; then 
  echo "You must be in '/home/apmail/lists' to run this script.";
  exit 1
fi

if [ ${USER} != "apmail" ]; then 
  echo "You must be user 'apmail' to run this script. Exiting..";
  exit 1
fi

/home/apmail/bin/find-subscriber ${OLDADDY} | while read list dir address; 
  do
     (set -x;
     /usr/local/bin/ezmlm-sub `pwd`/$list $dir ${NEWADDY}; 
     /usr/local/bin/ezmlm-unsub `pwd`/$list $dir $address;
     )
  done


