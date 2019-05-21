#!/bin/sh

echo "Content-Type: text/html"
echo ""

DBPATH=/var/www/etherpad-lite

echo "<html><head><title>List of Pads</title></head><body>"

cd $DBPATH
for p in `./asf/list-pads.sh`; do echo "<p><a href='/p/$p'>$p</a></p>" ; done

echo "</body></html>"
