#! /bin/sh
#
# Collect stats about the mailing lists.
#
# $1 = alternate eddress to send to
# $2 = send to stdout instead of sending mail
#

STATFILE=/tmp/liststats.$$
echo >> $STATFILE `date +%Y-%m-%d`
PATHTO=~apmail/lists
perl ~apmail/bin/aplists.pl -acx $PATHTO > $STATFILE
if [ -z "$1" ] ; then
    SENDTO=collect-listinfo@apache.org
else
    SENDTO=$1
fi
if [ -f "$STATFILE" ] ; then
    if [ -n "$2" ] ; then
        cat $STATFILE
    else
        mail -s "Apache list stats" -c "coar@Apache.Org" "$SENDTO" < $STATFILE
    fi
    rm -f $STATFILE
fi
