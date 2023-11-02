#!/bin/bash
# reading values from a file    

file="states.txt"
for state in $(cat $file)
do
    echo "Visit beautiful $state"
done
