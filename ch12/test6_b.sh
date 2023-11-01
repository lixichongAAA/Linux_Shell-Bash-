#!/bin/bash
# testing the test command
my_variable="Full"
# 
if test $my_variable
then
    echo "The my_variable variable has content and returns a True."
    echo "The my_variable variable content is $my_variable."
else
    echo "The my_variable variable doesn't have content,"
    echo "and return a False."
fi
