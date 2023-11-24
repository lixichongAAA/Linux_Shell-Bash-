#!/bin/dash
# testing the = comparison

test1=abcde
test2=abcde

if [ $test1 = $test2 ]
then
    echo "They're the same"
else
    echo "They're the different"
fi
