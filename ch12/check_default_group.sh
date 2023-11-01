#!/bin/bash
# Compare file and script user's default groups
# 
if [ -G $HOME/TestGroupFile ]
then
    echo "You are in the same default groups"
    echo "as the $HOME/TestGroupFile file's group."
# 
else
    echo "Sorry, Your default group and $HOME/TestGroupFile"
    echo "file's group are different."
fi
