#!/bin/bash
# count number of files in your PATH
mypath=`echo $PATH | sed 's/:/ /g'`
total=0
count=0
for directory in $mypath
do
    check=$(ls $directory)
    for item in $check
    do
        count=$[ $count + 1 ]
        total=$[ $total + 1 ]
    done
    echo "$directory - $count"
    count=0
done

echo "Total: $total"