#!/bin/bash
# breaking out of an outer loop

for (( a = 1; a <= 3; a++ ))
do
    echo "Outer loop: $a"
    for((b = 1; b <= 100; b++ ))
    do
        if [ $b -eq 5 ]
        then
            break 2
        fi
        echo "  Inner loop: $b"
    done
done
echo "done."