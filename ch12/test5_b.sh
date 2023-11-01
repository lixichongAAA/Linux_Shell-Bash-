#!/bin/bash
# testing nested ifs - using elif and else

testUser=NoSuchUser

if grep $testUser /etc/passwd
    then
        echo "The user $testUser account exists on this system."
        echo
elif ls -d /home/$testUser
    then    
        echo "The user $testUser has a directory,"
        echo "even $testUser doesn't have an account."
else
    echo "The user $testUser doesn's exit on this system,"
    echo "and no directory exists for the $testUser."
fi
echo "We are outside the if statement."