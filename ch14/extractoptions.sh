#!/bin/bash
# Extract command-line options.
# 

while [ -n "$1" ]
do
    case "$1" in
    -a) echo "Found the -a option." ;;
    -b) echo "Found the -b option." ;;
    -c) echo "Found the -c option." ;;
    *) echo "$1 is not an options.";;
    esac
    shift

done
echo
exit