#!/bin/bash
# testing nested ifs

testUser=NoSuchUser
if grep $testUser /etc/passwd
then
    echo "The user $testUser account exists on this system."
    echo
else
    echo "The user $testUser doen not exist on this system."
    if ls -d /home/$testUser
    then
        echo "However, $testUser has a directory."
    fi
fi
echo "We are outside the if statement."