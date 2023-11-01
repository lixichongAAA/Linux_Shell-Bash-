#!/bin/bash
# Check if a file is empty
# 
file_name=$HOME/sentinel
echo
echo "Checking if file $file_name is empty..."
echo
if [ -f $file_name ]
then
    # The file does exist, and check if it it empty
    if [ -s $file_name ]
    then
        echo "The file $file_name does exist and has data in it."
        echo "Will not remove this file."
    else
        echo "The file $file_name exists, but is empty."
        echo "Deleting this empty file..."
        rm $file_name
        echo "This file has been deleted."
    fi
else
    echo "The file $file_name does NOT exit."
fi