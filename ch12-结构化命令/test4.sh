#!/bin/bash
# testing the else section

testUser=NoSuchUser
if grep $testUser /etc/passwd
then    
    echo "The script files in the home directory of $testUser are:"
    ls /home/$testUser/*.sh
    echo
else
    echo "The user $testUser does not exit in the system."
    echo
fi
echo "We are outside the if statement"