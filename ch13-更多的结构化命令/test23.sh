#!/bin/bash
# redirecting the for output to a file

for (( a = 1; a <= 5; a++ ))
do
    echo "Iteration number: $a"
done > output.txt
echo "Done."