#!/bin/bash
# testing multiple commands in the then block

testUser=lxc

if grep $testUser /etc/passwd
then
    echo "This is my first command in the then block"
    echo "This is my second command in the then blcok"
    echo "I can even put in other commands besides echo:"
    ls /home/$testing/*.sh
fi
echo "We are outside the if statement"
