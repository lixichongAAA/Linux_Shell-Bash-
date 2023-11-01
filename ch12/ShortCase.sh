#!/bin/bash
# Using a short case statement.
#
case $USER in
rich | christine)
    echo "Welcome $USER"
    echo "Please enjoy your visit."
    ;;
barbara | lxc)
    echo "Hi, there, $USER"
    echo "We are glad you could join us."
    ;;
testing)
    echo "Please log out when done with test."
    ;;
*)
    echo "Sorry, you are not allowed here."
    ;;
esac
