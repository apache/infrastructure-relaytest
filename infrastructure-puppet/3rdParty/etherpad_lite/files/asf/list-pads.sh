#!/bin/sh
sed -n '/"key":"pad:/s/^{"key":"pad:\([^:"]*\).*/\1/p' dirty.db | sort -u
