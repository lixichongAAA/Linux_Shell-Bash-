#!/bin/bash
# Check if you can read a file
pwfile=/etc/shadow
echo
echo "Checking if you can read $pwfile..."
# 
# Chekc if file exist and is a file
# 
if [ -f $pwfile ]
then
    # File does exist. Check if can read it
    if [ -r $pwfile ]
    then    
        echo "Displaying end of file..."
        tail $pwfile
    # 
    else
        echo "Sorry, read access to $pwfile is denied."
    fi
else
    echo "Sorry, the file $pwfile does NOT exist."
fi