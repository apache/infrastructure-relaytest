#!/bin/sh
#
# Simple ApacheCon wrapper script for makelist-apache.sh 
#

if [ "x$1" = "x" -o "x$1" = "x-h" -o "x$1" = "x--help" ]
then
  echo "Usage: $0 <YYYY-LOC> [lead-address] [planner-addresses ...]"
  exit 1
fi

LISTDIR=$HOME/lists/apachecon.com
AOLISTDIR=$HOME/lists/apache.org
MAKELIST=$HOME/bin/makelist-apache.sh
DEFMOD=rbowen@apache.org
EVENT=$1

shift
if [ "$1" ]
then
  LEAD="$1"
else
  LEAD=$DEFMOD
fi

shift
if [ "$1" ]
then
  PLANNERS="$*"
else
  PLANNERS=$DEFMOD
fi

echo
echo "The following ApacheCon mailing lists will be created:"
echo "  planners-${EVENT}@apachecon.com"
echo "  cfp-${EVENT}@apachecon.com"
echo "  speakers-${EVENT}@apachecon.com"
echo "  instructors-${EVENT}@apachecon.com"
echo "  fastfeather-${EVENT}@apachecon.com"
echo "  barcamp-${EVENT}@apachecon.com"
echo
echo "Event lead address: $LEAD
echo "Planners addresses: $PLANNERS
echo 
echo "Press RETURN to continue list creation, or press CTRL-C to abort."
read R

$MAKELIST -d apachecon.com -m $LEAD -r planners-${EVENT}@apachecon.com .planners-${EVENT} .cfp-${EVENT} .speakers-${EVENT} .instructors-${EVENT} .fastfeather-${EVENT} .barcamp-${EVENT}

sed -e s/planners/fastfeather/ -i "" $LISTDIR/fastfeather-${EVENT}/headeradd
sed -e s/planners/barcamp/     -i "" $LISTDIR/barcamp-${EVENT}/headeradd

ezmlm-sub $LISTDIR/planners-${EVENT}          $PLANNERS
ezmlm-sub $LISTDIR/planners-${EVENT}/mod      $LEAD $DEFMOD
ezmlm-sub $LISTDIR/planners-${EVENT}/allow    $PLANNERS
ezmlm-sub $LISTDIR/planners-${EVENT}/allow    `ezmlm-list $AOLISTDIR/concom`
ezmlm-sub $LISTDIR/planners-${EVENT}/allow    `ezmlm-list $AOLISTDIR/concom/allow`
ezmlm-sub $LISTDIR/speakers-${EVENT}          $PLANNERS
ezmlm-sub $LISTDIR/speakers-${EVENT}/mod      $LEAD 
ezmlm-sub $LISTDIR/instructors-${EVENT}       $PLANNERS
ezmlm-sub $LISTDIR/instructors-${EVENT}/mod   $LEAD 
ezmlm-sub $LISTDIR/fastfeather-${EVENT}       $PLANNERS
ezmlm-sub $LISTDIR/fastfeather-${EVENT}/mod   $LEAD 
ezmlm-sub $LISTDIR/fastfeather-${EVENT}/allow $PLANNERS 
ezmlm-sub $LISTDIR/barcamp-${EVENT}           $PLANNERS
ezmlm-sub $LISTDIR/barcamp-${EVENT}/mod       $LEAD 
ezmlm-sub $LISTDIR/barcamp-${EVENT}/allow     $PLANNERS 
ezmlm-sub $LISTDIR/cfp-${EVENT}               $LEAD $DEFMOD

exit
