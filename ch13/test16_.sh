#!/bin/bash
# changing the IFS value

IFS.old=$IFS
IFS=$'\n'
for entry in $(cat /etc/passwd)
do
    echo "Values in $entry -"
    IFS=:
    for value in $entry
    do
        echo "  $value"
    done
done